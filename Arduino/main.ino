/*
 * =============================================================================
 *  OpenRehEx - main.ino  (formerly CubemarsAK_all_motors.ino)
 *  Control firmware for the CONTROL Arduino MEGA 2560
 * =============================================================================
 *
 *  Hardware
 *    Arduino MEGA 2560  <-SPI->  MCP2515 (8 MHz)  <-CAN 1 Mbps->  6 x AK70-10
 *    Serial  (USB, 115200) : operator console (single-character commands)
 *    Serial1 (TX1 = D18)   : telemetry to the VISUALIZATION MEGA (RX1 = D19)
 *
 *  Pins (MCP2515 module)
 *    SCK -> D52, SI -> D51, SO -> D50, CS -> D53, INT -> D2, VCC -> 5V, GND
 *
 *  Libraries
 *    mcp_can by coryjfowler (Library Manager: "mcp_can")
 *
 *  Operator console (Serial Monitor, 115200, "No line ending" or "Newline")
 *    e  enable  : enter MIT mode, zero (if enabled) and hold posture
 *    s  start   : ramp to the gait start pose and walk
 *    p  pause   : ramp back to neutral standing and hold
 *    d  disable : leave MIT mode (motors go limp - support the user first!)
 *    c  clear   : clear a FAULT and hold the current posture
 *    z  zero    : set encoder zero at current posture (DISABLED/HOLD only)
 *    + / -      : amplitude +/- 0.05       f / l : stride time -/+ 0.25 s
 *    ?          : status
 *
 *  !!! A hardware emergency stop that cuts motor power is mandatory. The
 *      firmware supervision below is NOT a substitute (see docs/wiring_diagram).
 *
 *  License: see LICENSE at the repository root.
 * =============================================================================
 */

#include "CAN_Driver/CAN_Driver.h"
#include "Motor_Control/Motor_Control.h"

// -----------------------------------------------------------------------------
//  User configuration
// -----------------------------------------------------------------------------
#define CAN_CS_PIN        53
#define CAN_INT_PIN       2        // set to -1 if INT is not wired
#define CONSOLE_BAUD      115200
#define TELEMETRY_BAUD    115200
#define CONTROL_HZ        200      // lower to 100 if the overrun counter grows

// Joint table. IDs 1-6 must match MOTOR_META in GUI_plotting_V4.py.
// Soft limits follow LIMITS in MATLAB/trajectory_generator.m (deg):
//   hip [-20, 40], knee [0, 50], ankle [-20, 20]
// `direction` must be checked on the real hardware: with the exo unloaded,
// command a small flexion and verify the joint flexes. Left and right motors
// are usually mirrored, hence the -1 on one side.
static const JointConfig JOINTS[6] = {
  // name           id  joint        side        dir  offset  min          max          kp     kd
  {"Right hip",     1,  JOINT_HIP,   SIDE_RIGHT, +1,  0.0f,   radians(-20), radians(40), 60.0f, 1.0f},
  {"Right knee",    2,  JOINT_KNEE,  SIDE_RIGHT, +1,  0.0f,   radians(0),   radians(50), 60.0f, 1.0f},
  {"Right ankle",   3,  JOINT_ANKLE, SIDE_RIGHT, +1,  0.0f,   radians(-20), radians(20), 60.0f, 1.0f},
  {"Left hip",      4,  JOINT_HIP,   SIDE_LEFT,  -1,  0.0f,   radians(-20), radians(40), 60.0f, 1.0f},
  {"Left knee",     5,  JOINT_KNEE,  SIDE_LEFT,  -1,  0.0f,   radians(0),   radians(50), 60.0f, 1.0f},
  {"Left ankle",    6,  JOINT_ANKLE, SIDE_LEFT,  -1,  0.0f,   radians(-20), radians(20), 60.0f, 1.0f},
};

// -----------------------------------------------------------------------------
//  Objects
// -----------------------------------------------------------------------------
AKCanBus canBus(CAN_CS_PIN, CAN_INT_PIN);
ExoController<6> exo(canBus, JOINTS);

const unsigned long PERIOD_US = 1000000UL / CONTROL_HZ;
unsigned long next_tick_us = 0;
unsigned long overruns = 0;
unsigned long max_exec_us = 0;
uint8_t telemetry_idx = 0;

void handleConsole();

// -----------------------------------------------------------------------------
void setup() {
  Serial.begin(CONSOLE_BAUD);
  Serial1.begin(TELEMETRY_BAUD);

  // Replace AK70_10_LIMITS by AK_LEGACY_SKETCH_LIMITS only if CubeMarsTool
  // shows those ranges for your firmware (see CAN_Protocol/motor_commands.md).
  canBus.setLimits(AK70_10_LIMITS);

  while (!canBus.begin(CAN_1000KBPS, MCP_8MHZ)) {
    Serial.println(F("[ERR] MCP2515 init failed - check wiring / crystal. Retrying..."));
    delay(1000);
  }
  Serial.println(F("[OK] CAN @ 1 Mbps"));
  Serial.println(F("OpenRehEx ready. Commands: e s p d c z + - f l ?"));
  next_tick_us = micros() + PERIOD_US;
}

// -----------------------------------------------------------------------------
void loop() {
  handleConsole();

  const unsigned long now = micros();
  if ((long)(now - next_tick_us) < 0) return;          // not yet time
  next_tick_us += PERIOD_US;
  if ((long)(now - next_tick_us) > 0) {                // fell behind
    overruns++;
    next_tick_us = now + PERIOD_US;
  }

  const unsigned long t0 = micros();
  exo.update(1.0f / CONTROL_HZ);

  // One telemetry line per cycle, round-robin over the six motors
  // (6 x ~25 bytes spread over 6 cycles keeps Serial1 well below 115200 baud)
  if (exo.state() != EXO_DISABLED) {
    exo.sendTelemetry(Serial1, telemetry_idx);
    telemetry_idx = (telemetry_idx + 1) % 6;
  }

  const unsigned long exec = micros() - t0;
  if (exec > max_exec_us) max_exec_us = exec;
}

// -----------------------------------------------------------------------------
void handleConsole() {
  while (Serial.available()) {
    const char c = (char)Serial.read();
    switch (c) {
      case 'e':
        Serial.println(exo.enable() ? F("[OK] enabled, holding posture")
                                    : F("[ERR] enable failed, see status"));
        break;
      case 's': exo.startWalking(); Serial.println(F("start (ramp in)")); break;
      case 'p': exo.stopWalking();  Serial.println(F("pause (ramp out)")); break;
      case 'd': exo.disable();      Serial.println(F("disabled - motors free")); break;
      case 'c': exo.clearFault();   Serial.println(F("fault cleared")); break;
      case 'z':
        Serial.println(exo.zeroHere() ? F("zero set") : F("zero only in DISABLED/HOLD"));
        break;
      case '+': exo.setAmplitude(exo.amplitude() + 0.05f); break;
      case '-': exo.setAmplitude(exo.amplitude() - 0.05f); break;
      case 'f': exo.setStrideTime(exo.strideTime() - 0.25f); break;
      case 'l': exo.setStrideTime(exo.strideTime() + 0.25f); break;
      case '?':
        exo.printStatus(Serial);
        Serial.print(F("  loop: ")); Serial.print(CONTROL_HZ);
        Serial.print(F(" Hz, max exec us=")); Serial.print(max_exec_us);
        Serial.print(F(", overruns=")); Serial.println(overruns);
        break;
      default: break;   // ignore CR/LF and unknown characters
    }
    if (c == '+' || c == '-' || c == 'f' || c == 'l') {
      Serial.print(F("amp=")); Serial.print(exo.amplitude(), 2);
      Serial.print(F("  stride_s=")); Serial.println(exo.strideTime(), 2);
    }
  }
}
