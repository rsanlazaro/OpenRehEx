/*
 * =============================================================================
 *  OpenRehEx - CAN_Driver.h
 *  CubeMars AK-series (AK70-10) MIT-mode driver over an MCP2515 CAN module
 * =============================================================================
 *
 *  Header-only on purpose: the Arduino IDE only compiles .cpp files located in
 *  the sketch root or in src/, so keeping the implementation inline lets
 *  main.ino include this file from a sub-folder without extra build steps.
 *
 *  Dependencies
 *    - MCP_CAN library by coryjfowler  (Library Manager: "mcp_can")
 *    - SPI (built in)
 *
 *  Frame layouts are documented in CAN_Protocol/motor_commands.md.
 *
 *  License: see LICENSE at the repository root.
 * =============================================================================
 */

#ifndef OPENREHEX_CAN_DRIVER_H
#define OPENREHEX_CAN_DRIVER_H

#include <Arduino.h>
#include <SPI.h>
#include <mcp_can.h>

// -----------------------------------------------------------------------------
//  MIT-mode scaling limits
// -----------------------------------------------------------------------------
//  These ranges define how floats are mapped to the 16/12-bit integers inside
//  every MIT frame. They MUST match the motor firmware, otherwise commanded and
//  measured velocity/torque are scaled incorrectly (position is usually still
//  right because P_MIN/P_MAX = +/-12.5 is common to all AK firmwares).
//
//  Check the values for your firmware in CubeMarsTool (CAN_Protocol/) or in the
//  AK70-10 product manual, section "MIT power mode communication protocol".
struct MitLimits {
  float p_min,  p_max;   // rad
  float v_min,  v_max;   // rad/s
  float kp_min, kp_max;  // N*m/rad
  float kd_min, kd_max;  // N*m*s/rad
  float t_min,  t_max;   // N*m
};

// AK70-10 values listed by CubeMars for MIT mode.
static const MitLimits AK70_10_LIMITS = {
  -12.5f, 12.5f,
  -50.0f, 50.0f,
    0.0f, 500.0f,
    0.0f,   5.0f,
  -25.0f, 25.0f
};

// Values used in the original CubemarsAK_one_motor.ino sketch (kept for
// reference / backwards comparison with previously recorded data).
static const MitLimits AK_LEGACY_SKETCH_LIMITS = {
  -12.5f, 12.5f,
  -30.0f, 30.0f,
    0.0f, 500.0f,
    0.0f,   5.0f,
  -18.0f, 18.0f
};

// -----------------------------------------------------------------------------
//  Data containers
// -----------------------------------------------------------------------------
struct MitCommand {
  float p;    // desired position        [rad]
  float v;    // desired velocity        [rad/s]
  float kp;   // position gain           [N*m/rad]
  float kd;   // velocity gain           [N*m*s/rad]
  float t;    // feed-forward torque     [N*m]
};

struct MitFeedback {
  uint8_t  id;          // motor CAN ID reported in byte 0
  float    p;           // measured position   [rad]
  float    v;           // measured velocity   [rad/s]
  float    t;           // measured torque     [N*m]
  uint8_t  temp_raw;    // byte 6: driver temperature (firmware >= V2 only;
                        //   scaling/offset depends on firmware, see manual)
  uint8_t  error;       // byte 7: error code  (firmware >= V2 only)
  bool     has_status;  // true if the frame carried temp/error bytes
};

// Error codes reported in byte 7 of the reply (firmware >= V2)
enum AkErrorCode : uint8_t {
  AK_OK              = 0,
  AK_OVER_TEMP       = 1,
  AK_OVER_CURRENT    = 2,
  AK_OVER_VOLTAGE    = 3,
  AK_UNDER_VOLTAGE   = 4,
  AK_ENCODER_FAULT   = 5,
  AK_PHASE_UNBALANCE = 6
};

// -----------------------------------------------------------------------------
//  Fixed-point helpers (shared with the Python tools, see motor_commands.md)
// -----------------------------------------------------------------------------
namespace akcan {

inline uint16_t floatToUint(float x, float x_min, float x_max, uint8_t bits) {
  const float span = x_max - x_min;
  const float max_int = (float)((1UL << bits) - 1UL);
  if (x < x_min) x = x_min;
  if (x > x_max) x = x_max;
  return (uint16_t)((x - x_min) * max_int / span + 0.5f);   // rounded
}

inline float uintToFloat(uint16_t x_int, float x_min, float x_max, uint8_t bits) {
  const float span = x_max - x_min;
  const float max_int = (float)((1UL << bits) - 1UL);
  return ((float)x_int) * span / max_int + x_min;
}

// Pack a MIT command into 8 bytes
inline void packCommand(const MitCommand& c, const MitLimits& L, uint8_t buf[8]) {
  const uint16_t p  = floatToUint(c.p,  L.p_min,  L.p_max,  16);
  const uint16_t v  = floatToUint(c.v,  L.v_min,  L.v_max,  12);
  const uint16_t kp = floatToUint(c.kp, L.kp_min, L.kp_max, 12);
  const uint16_t kd = floatToUint(c.kd, L.kd_min, L.kd_max, 12);
  const uint16_t t  = floatToUint(c.t,  L.t_min,  L.t_max,  12);

  buf[0] = (uint8_t)(p >> 8);
  buf[1] = (uint8_t)(p & 0xFF);
  buf[2] = (uint8_t)(v >> 4);
  buf[3] = (uint8_t)(((v & 0x0F) << 4) | (kp >> 8));
  buf[4] = (uint8_t)(kp & 0xFF);
  buf[5] = (uint8_t)(kd >> 4);
  buf[6] = (uint8_t)(((kd & 0x0F) << 4) | (t >> 8));
  buf[7] = (uint8_t)(t & 0xFF);
}

// Unpack a MIT reply (6 or 8 bytes)
inline bool unpackReply(const uint8_t* buf, uint8_t len, const MitLimits& L, MitFeedback& fb) {
  if (len < 6) return false;
  const uint16_t p = ((uint16_t)buf[1] << 8) | buf[2];
  const uint16_t v = ((uint16_t)buf[3] << 4) | (buf[4] >> 4);
  const uint16_t i = ((uint16_t)(buf[4] & 0x0F) << 8) | buf[5];

  fb.id = buf[0];
  fb.p  = uintToFloat(p, L.p_min, L.p_max, 16);
  fb.v  = uintToFloat(v, L.v_min, L.v_max, 12);
  fb.t  = uintToFloat(i, L.t_min, L.t_max, 12);

  fb.has_status = (len >= 8);
  fb.temp_raw = fb.has_status ? buf[6] : 0;
  fb.error  = fb.has_status ? buf[7] : 0;
  return true;
}

}  // namespace akcan

// -----------------------------------------------------------------------------
//  AKCanBus: thin wrapper around MCP_CAN
// -----------------------------------------------------------------------------
class AKCanBus {
 public:
  AKCanBus(uint8_t cs_pin, int8_t int_pin = -1)
      : can_(cs_pin), int_pin_(int_pin), limits_(AK70_10_LIMITS) {}

  // bitrate: CAN_1000KBPS for AK motors (factory default)
  // crystal: MCP_8MHZ for most blue MCP2515 modules (check the can on the board)
  bool begin(uint8_t bitrate = CAN_1000KBPS, uint8_t crystal = MCP_8MHZ) {
    if (int_pin_ >= 0) pinMode(int_pin_, INPUT);
    if (can_.begin(MCP_ANY, bitrate, crystal) != CAN_OK) return false;
    can_.setMode(MCP_NORMAL);
    return true;
  }

  void setLimits(const MitLimits& L) { limits_ = L; }
  const MitLimits& limits() const { return limits_; }

  // --- Special MIT frames ---------------------------------------------------
  bool enterMit(uint8_t id)  { return sendSpecial(id, 0xFC); }
  bool exitMit(uint8_t id)   { return sendSpecial(id, 0xFD); }
  bool setZero(uint8_t id)   { return sendSpecial(id, 0xFE); }

  // --- Control frame --------------------------------------------------------
  bool sendCommand(uint8_t id, const MitCommand& cmd) {
    uint8_t buf[8];
    akcan::packCommand(cmd, limits_, buf);
    return can_.sendMsgBuf(id, 0, 8, buf) == CAN_OK;
  }

  // Zero-torque command: motor replies with its state without moving.
  bool sendPassive(uint8_t id) {
    MitCommand c = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f};
    return sendCommand(id, c);
  }

  // --- Reception ------------------------------------------------------------
  bool available() {
    if (int_pin_ >= 0) return digitalRead(int_pin_) == LOW;
    return can_.checkReceive() == CAN_MSGAVAIL;
  }

  // Reads one frame if available. Returns true only for a valid MIT reply.
  bool read(MitFeedback& fb) {
    if (!available()) return false;
    unsigned long rx_id = 0;
    uint8_t len = 0;
    uint8_t buf[8];
    if (can_.readMsgBuf(&rx_id, &len, buf) != CAN_OK) return false;
    return akcan::unpackReply(buf, len, limits_, fb);
  }

  // Waits (busy) up to timeout_us for a reply from a specific motor.
  // Frames from other motors received meanwhile are passed to `other`.
  bool waitReply(uint8_t id, MitFeedback& fb, uint16_t timeout_us,
                 void (*other)(const MitFeedback&) = nullptr) {
    const unsigned long t0 = micros();
    while ((unsigned long)(micros() - t0) < timeout_us) {
      MitFeedback tmp;
      if (read(tmp)) {
        if (tmp.id == id) { fb = tmp; return true; }
        if (other) other(tmp);
      }
    }
    return false;
  }

  MCP_CAN& raw() { return can_; }

 private:
  bool sendSpecial(uint8_t id, uint8_t last) {
    uint8_t buf[8] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, last};
    return can_.sendMsgBuf(id, 0, 8, buf) == CAN_OK;
  }

  MCP_CAN   can_;
  int8_t    int_pin_;
  MitLimits limits_;
};

#endif  // OPENREHEX_CAN_DRIVER_H
