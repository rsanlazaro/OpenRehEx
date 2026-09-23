/*
 * =============================================================================
 *  OpenRehEx - Motor_Control.h
 *  Joint-level control of the six AK70-10 actuators (hip, knee, ankle x 2)
 * =============================================================================
 *
 *  Responsibilities
 *    - Joint configuration (CAN ID, sign, soft limits, impedance gains)
 *    - State machine: DISABLED -> HOLD -> RAMP_IN -> WALKING -> RAMP_OUT -> HOLD
 *                     any state -> FAULT (damping only) on a safety violation
 *    - Gait reference generation from the PROGMEM table (gait_trajectory.h)
 *      with amplitude scaling, adjustable stride time and a 50 % phase offset
 *      between the right and the left leg
 *    - One MIT impedance command per joint per control cycle:
 *          tau = kp (p_ref - p) + kd (v_ref - v) + t_ff
 *    - Safety supervision: CAN reply time-out, joint range, motor error codes
 *    - Telemetry lines for the visualization MEGA / Python GUI
 *
 *  Header-only for the same reason as CAN_Driver.h (Arduino IDE build rules).
 *
 *  Coordinates
 *    "joint" = anatomical angle used by MATLAB (hip/knee +flexion,
 *              ankle +dorsiflexion), in rad.
 *    "motor" = AK70-10 output-shaft angle reported over CAN, in rad.
 *    motor = direction * joint + offset
 *
 *  License: see LICENSE at the repository root.
 * =============================================================================
 */

#ifndef OPENREHEX_MOTOR_CONTROL_H
#define OPENREHEX_MOTOR_CONTROL_H

#include <Arduino.h>
#include <avr/pgmspace.h>
#include "../CAN_Driver/CAN_Driver.h"
#include "gait_trajectory.h"

// -----------------------------------------------------------------------------
//  Types
// -----------------------------------------------------------------------------
enum JointType : uint8_t { JOINT_HIP = 0, JOINT_KNEE = 1, JOINT_ANKLE = 2 };
enum LegSide   : uint8_t { SIDE_RIGHT = 0, SIDE_LEFT = 1 };

struct JointConfig {
  const char* name;
  uint8_t   can_id;       // AK70-10 CAN ID (set with CubeMarsTool)
  JointType joint;
  LegSide   side;
  int8_t    direction;    // +1 or -1: motor sign relative to the joint sign
  float     offset_rad;   // motor angle at anatomical zero (0 if zeroed there)
  float     min_rad;      // soft limit, joint coordinates
  float     max_rad;
  float     kp;           // N*m/rad
  float     kd;           // N*m*s/rad
};

enum ExoState : uint8_t {
  EXO_DISABLED = 0,   // motors out of MIT mode (free)
  EXO_HOLD,           // hold current posture
  EXO_RAMP_IN,        // smooth transition from posture to gait start
  EXO_WALKING,        // tracking the gait trajectory
  EXO_RAMP_OUT,       // smooth transition back to neutral standing
  EXO_FAULT           // damping only, waits for operator
};

enum FaultCode : uint8_t {
  FAULT_NONE = 0,
  FAULT_NO_REPLY,       // motor did not answer within COMM_TIMEOUT_MS
  FAULT_RANGE,          // measured angle outside soft limits + margin
  FAULT_MOTOR_ERROR,    // motor reported an error code
  FAULT_ENABLE_FAILED   // motor did not answer while entering MIT mode
};

struct ControlSettings {
  float    ramp_time_s;          // duration of RAMP_IN / RAMP_OUT
  float    stride_time_s;        // initial stride (gait cycle) duration
  float    amplitude;            // initial amplitude scale (0..1)
  float    amplitude_rate;       // max amplitude change per second
  float    range_margin_rad;     // tolerance beyond soft limits before FAULT
  float    fault_kd;             // damping applied in FAULT
  float    max_ff_velocity;      // clamp for velocity feed-forward [rad/s]
  uint16_t reply_timeout_us;     // wait for each MIT reply
  uint16_t comm_timeout_ms;      // no valid reply for this long -> FAULT
  bool     zero_on_enable;       // send "set zero" when enabling (see README)
  bool     fault_on_motor_error; // use byte 7 of the reply (firmware >= V2)
};

static const ControlSettings DEFAULT_SETTINGS = {
  3.0f,    // ramp_time_s
  3.0f,    // stride_time_s   (slow rehabilitation gait to start with)
  0.5f,    // amplitude       (50 % of the MATLAB trajectory to start with)
  0.10f,   // amplitude_rate
  0.15f,   // range_margin_rad (~8.6 deg)
  2.0f,    // fault_kd
  6.0f,    // max_ff_velocity
  1500,    // reply_timeout_us
  50,      // comm_timeout_ms
  true,    // zero_on_enable  (same behaviour as the original sketch)
  true     // fault_on_motor_error
};

// -----------------------------------------------------------------------------
//  Gait table access
// -----------------------------------------------------------------------------
namespace gait {

inline float tableRad(const int16_t* table, uint16_t i) {
  return (float)(int16_t)pgm_read_word(&table[i]) * 0.001f;
}

// phase in [0,1): linear interpolation over the periodic table
inline float sample(JointType j, float phase) {
  const int16_t* table = (j == JOINT_HIP)  ? GAIT_HIP_MRAD
                       : (j == JOINT_KNEE) ? GAIT_KNEE_MRAD
                                           : GAIT_ANKLE_MRAD;
  phase -= floor(phase);
  const float x = phase * GAIT_N;
  uint16_t i0 = (uint16_t)x;
  if (i0 >= GAIT_N) i0 = GAIT_N - 1;
  const uint16_t i1 = (i0 + 1 == GAIT_N) ? 0 : i0 + 1;
  const float a = x - (float)i0;
  return tableRad(table, i0) * (1.0f - a) + tableRad(table, i1) * a;
}

}  // namespace gait

// -----------------------------------------------------------------------------
//  Controller
// -----------------------------------------------------------------------------
template <uint8_t N_JOINTS>
class ExoController {
 public:
  ExoController(AKCanBus& bus, const JointConfig (&cfg)[N_JOINTS],
                const ControlSettings& s = DEFAULT_SETTINGS)
      : bus_(bus), cfg_(cfg), set_(s) {
    state_ = EXO_DISABLED;
    fault_ = FAULT_NONE;
    fault_joint_ = 0xFF;
    phase_ = 0.0f;
    state_time_ = 0.0f;
    amp_ = amp_target_ = s.amplitude;
    stride_time_ = s.stride_time_s;
    for (uint8_t i = 0; i < N_JOINTS; i++) {
      j_[i].valid = false;
      j_[i].last_rx_ms = 0;
      j_[i].pos = j_[i].vel = j_[i].tor = 0.0f;
      j_[i].ref = j_[i].ref_prev = j_[i].from = 0.0f;
      j_[i].error = 0;
      j_[i].temp_raw = 0;
    }
  }

  // ---------------------------------------------------------------- commands
  // Enter MIT mode on every motor, optionally zero, and hold the posture.
  bool enable() {
    if (state_ != EXO_DISABLED) return true;
    for (uint8_t i = 0; i < N_JOINTS; i++) {
      bus_.enterMit(cfg_[i].can_id);
      delay(5);
      if (set_.zero_on_enable) { bus_.setZero(cfg_[i].can_id); delay(5); }
    }
    // Probe every motor with a zero-gain command to read its position
    for (uint8_t i = 0; i < N_JOINTS; i++) {
      bool ok = false;
      for (uint8_t attempt = 0; attempt < 5 && !ok; attempt++) {
        bus_.sendPassive(cfg_[i].can_id);
        MitFeedback fb;
        if (bus_.waitReply(cfg_[i].can_id, fb, set_.reply_timeout_us)) {
          storeFeedback(i, fb);
          ok = true;
        }
      }
      if (!ok) { enterFault(FAULT_ENABLE_FAILED, i); return false; }
    }
    holdHere();
    return true;
  }

  // Leave MIT mode: motors become back-drivable (the limb is NOT supported).
  void disable() {
    for (uint8_t i = 0; i < N_JOINTS; i++) {
      bus_.exitMit(cfg_[i].can_id);
      delay(2);
    }
    state_ = EXO_DISABLED;
  }

  void startWalking() {
    if (state_ != EXO_HOLD) return;
    phase_ = 0.0f;
    for (uint8_t i = 0; i < N_JOINTS; i++) j_[i].from = j_[i].ref;
    setState(EXO_RAMP_IN);
  }

  void stopWalking() {
    if (state_ != EXO_WALKING && state_ != EXO_RAMP_IN) return;
    for (uint8_t i = 0; i < N_JOINTS; i++) j_[i].from = j_[i].ref;
    setState(EXO_RAMP_OUT);
  }

  void clearFault() {
    if (state_ != EXO_FAULT) return;
    if (fault_ == FAULT_ENABLE_FAILED) { disable(); fault_ = FAULT_NONE; return; }
    fault_ = FAULT_NONE;
    fault_joint_ = 0xFF;
    const unsigned long now = millis();
    for (uint8_t i = 0; i < N_JOINTS; i++) j_[i].last_rx_ms = now;
    holdHere();
  }

  // Zero the encoders at the current posture (only when not moving).
  bool zeroHere() {
    if (state_ != EXO_DISABLED && state_ != EXO_HOLD) return false;
    for (uint8_t i = 0; i < N_JOINTS; i++) { bus_.setZero(cfg_[i].can_id); delay(5); }
    if (state_ == EXO_HOLD) {
      for (uint8_t i = 0; i < N_JOINTS; i++) j_[i].ref = j_[i].ref_prev = 0.0f;
    }
    return true;
  }

  void setAmplitude(float a)     { amp_target_ = constrain(a, 0.0f, 1.0f); }
  void setStrideTime(float t)    { stride_time_ = constrain(t, 0.8f, 10.0f); }
  float amplitude() const        { return amp_target_; }
  float strideTime() const       { return stride_time_; }
  ExoState state() const         { return state_; }
  FaultCode fault() const        { return fault_; }

  // ---------------------------------------------------------------- control
  // Call once per control period (dt in seconds).
  void update(float dt) {
    if (state_ == EXO_DISABLED) return;
    state_time_ += dt;

    // Amplitude slew-rate limit (changing it while walking is smooth)
    const float da = set_.amplitude_rate * dt;
    if (amp_ < amp_target_) amp_ = min(amp_ + da, amp_target_);
    else                    amp_ = max(amp_ - da, amp_target_);

    computeReferences(dt);

    // Send one command per motor and wait for its reply
    const unsigned long now = millis();
    for (uint8_t i = 0; i < N_JOINTS; i++) {
      MitCommand cmd = buildCommand(i, dt);
      bus_.sendCommand(cfg_[i].can_id, cmd);
      MitFeedback fb;
      if (bus_.waitReply(cfg_[i].can_id, fb, set_.reply_timeout_us)) {
        storeFeedback(i, fb);
      }
    }

    if (state_ != EXO_FAULT) supervise(now);
  }

  // ---------------------------------------------------------------- telemetry
  // "motor_id,timestamp_ms,ref_mrad,pos_mrad,torque_mNm\n"
  // (format parsed by Graphs_visualization/GUI_plotting_V4.py)
  void sendTelemetry(Stream& out, uint8_t i) {
    if (i >= N_JOINTS || !j_[i].valid) return;
    out.print(cfg_[i].can_id);           out.print(',');
    out.print(millis());                 out.print(',');
    out.print(lround(j_[i].ref * 1000.0f)); out.print(',');
    out.print(lround(j_[i].pos * 1000.0f)); out.print(',');
    out.println(lround(j_[i].tor * 1000.0f));
  }

  void printStatus(Stream& out) {
    static const char* const names[] = {"DISABLED", "HOLD", "RAMP_IN",
                                        "WALKING", "RAMP_OUT", "FAULT"};
    out.print(F("state=")); out.print(names[state_]);
    out.print(F("  amp="));  out.print(amp_, 2);
    out.print(F("  stride_s=")); out.print(stride_time_, 2);
    if (state_ == EXO_FAULT) {
      out.print(F("  fault=")); out.print(fault_);
      if (fault_joint_ < N_JOINTS) { out.print(F(" @ ")); out.print(cfg_[fault_joint_].name); }
    }
    out.println();
    for (uint8_t i = 0; i < N_JOINTS; i++) {
      out.print(F("  [")); out.print(cfg_[i].can_id); out.print(F("] "));
      out.print(cfg_[i].name);
      out.print(F("  pos_deg=")); out.print(degrees(j_[i].pos), 1);
      out.print(F("  ref_deg=")); out.print(degrees(j_[i].ref), 1);
      out.print(F("  tau_Nm="));  out.print(j_[i].tor, 2);
      out.print(F("  err="));     out.print(j_[i].error);
      out.println(j_[i].valid ? "" : "  (no data)");
    }
  }

 private:
  struct JointRuntime {
    bool          valid;
    unsigned long last_rx_ms;
    float         pos, vel, tor;   // measured, joint coordinates
    float         ref, ref_prev;   // reference, joint coordinates
    float         from;            // start value of a ramp
    uint8_t       error;
    uint8_t       temp_raw;
  };

  void setState(ExoState s) { state_ = s; state_time_ = 0.0f; }

  void holdHere() {
    for (uint8_t i = 0; i < N_JOINTS; i++) {
      const float p = constrain(j_[i].pos, cfg_[i].min_rad, cfg_[i].max_rad);
      j_[i].ref = j_[i].ref_prev = p;
    }
    setState(EXO_HOLD);
  }

  void enterFault(FaultCode code, uint8_t joint) {
    fault_ = code;
    fault_joint_ = joint;
    setState(EXO_FAULT);
  }

  static float smoothStep(float s) {           // cosine blend 0..1
    s = constrain(s, 0.0f, 1.0f);
    return 0.5f * (1.0f - cos(PI * s));
  }

  float gaitRef(uint8_t i, float phase) const {
    const float ph = phase + (cfg_[i].side == SIDE_LEFT ? 0.5f : 0.0f);
    return amp_ * gait::sample(cfg_[i].joint, ph);
  }

  void computeReferences(float dt) {
    for (uint8_t i = 0; i < N_JOINTS; i++) j_[i].ref_prev = j_[i].ref;

    switch (state_) {
      case EXO_RAMP_IN: {
        const float s = smoothStep(state_time_ / set_.ramp_time_s);
        for (uint8_t i = 0; i < N_JOINTS; i++)
          j_[i].ref = j_[i].from + (gaitRef(i, 0.0f) - j_[i].from) * s;
        if (state_time_ >= set_.ramp_time_s) { phase_ = 0.0f; setState(EXO_WALKING); }
        break;
      }
      case EXO_WALKING: {
        phase_ += dt / stride_time_;
        if (phase_ >= 1.0f) phase_ -= 1.0f;
        for (uint8_t i = 0; i < N_JOINTS; i++) j_[i].ref = gaitRef(i, phase_);
        break;
      }
      case EXO_RAMP_OUT: {
        const float s = smoothStep(state_time_ / set_.ramp_time_s);
        for (uint8_t i = 0; i < N_JOINTS; i++) j_[i].ref = j_[i].from * (1.0f - s);
        if (state_time_ >= set_.ramp_time_s) setState(EXO_HOLD);
        break;
      }
      default:  // HOLD / FAULT keep the last reference
        break;
    }
    // Soft limits on the reference
    for (uint8_t i = 0; i < N_JOINTS; i++)
      j_[i].ref = constrain(j_[i].ref, cfg_[i].min_rad, cfg_[i].max_rad);
  }

  MitCommand buildCommand(uint8_t i, float dt) {
    const JointConfig& c = cfg_[i];
    MitCommand cmd;
    if (state_ == EXO_FAULT) {
      // Damping only: resists fast motion, no position stiffness
      cmd.p = 0.0f; cmd.v = 0.0f; cmd.kp = 0.0f; cmd.kd = set_.fault_kd; cmd.t = 0.0f;
      return cmd;
    }
    float v_ref = (dt > 0.0f) ? (j_[i].ref - j_[i].ref_prev) / dt : 0.0f;
    v_ref = constrain(v_ref, -set_.max_ff_velocity, set_.max_ff_velocity);

    cmd.p  = c.direction * j_[i].ref + c.offset_rad;
    cmd.v  = c.direction * v_ref;
    cmd.kp = c.kp;
    cmd.kd = c.kd;
    cmd.t  = 0.0f;   // gravity / interaction torque feed-forward goes here
    return cmd;
  }

  void storeFeedback(uint8_t i, const MitFeedback& fb) {
    const JointConfig& c = cfg_[i];
    j_[i].pos = (fb.p - c.offset_rad) * c.direction;
    j_[i].vel = fb.v * c.direction;
    j_[i].tor = fb.t * c.direction;
    j_[i].error = fb.error;
    j_[i].temp_raw = fb.temp_raw;
    j_[i].valid = true;
    j_[i].last_rx_ms = millis();
  }

  void supervise(unsigned long now) {
    for (uint8_t i = 0; i < N_JOINTS; i++) {
      if ((unsigned long)(now - j_[i].last_rx_ms) > set_.comm_timeout_ms) {
        enterFault(FAULT_NO_REPLY, i); return;
      }
      if (j_[i].pos < cfg_[i].min_rad - set_.range_margin_rad ||
          j_[i].pos > cfg_[i].max_rad + set_.range_margin_rad) {
        enterFault(FAULT_RANGE, i); return;
      }
      if (set_.fault_on_motor_error && j_[i].error != AK_OK) {
        enterFault(FAULT_MOTOR_ERROR, i); return;
      }
    }
  }

  AKCanBus&              bus_;
  const JointConfig    (&cfg_)[N_JOINTS];
  ControlSettings        set_;
  JointRuntime           j_[N_JOINTS];
  ExoState               state_;
  FaultCode              fault_;
  uint8_t                fault_joint_;
  float                  phase_, state_time_;
  float                  amp_, amp_target_, stride_time_;
};

#endif  // OPENREHEX_MOTOR_CONTROL_H
