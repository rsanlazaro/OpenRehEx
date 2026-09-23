/*
 * =============================================================================
 *  OpenRehEx - ArduinoMEGA_receiveSerial.ino
 *  Firmware for the VISUALIZATION Arduino MEGA 2560
 * =============================================================================
 *
 *  Receives telemetry lines from the CONTROL MEGA on Serial1 (RX1 = D19) and
 *  forwards the valid ones to the PC over USB (Serial) for GUI_plotting_V4.py.
 *
 *  Line format (5 integers, comma separated, '\n' terminated):
 *      motor_id,timestamp_ms,ref_mrad,pos_mrad,torque_mNm
 *
 *  Wiring: CONTROL TX1 (D18) -> VISUALIZATION RX1 (D19), and a common GND.
 *
 *  Changes vs. the first version: fixed-size char buffer instead of String
 *  (no heap fragmentation), all five fields validated, overlong lines dropped.
 * =============================================================================
 */

const uint8_t LINE_MAX = 48;
char line[LINE_MAX];
uint8_t len = 0;
bool overflow = false;

void setup() {
  Serial.begin(115200);    // USB -> PC (Python GUI)
  Serial1.begin(115200);   // UART <- control MEGA
}

void loop() {
  while (Serial1.available()) {
    const char c = (char)Serial1.read();
    if (c == '\r') continue;
    if (c == '\n') {
      line[len] = '\0';
      if (!overflow && isValidPacket(line)) Serial.println(line);
      len = 0;
      overflow = false;
    } else if (len < LINE_MAX - 1) {
      line[len++] = c;
    } else {
      overflow = true;     // discard the rest of this line
    }
  }
}

// Exactly five fields, each an optionally signed integer.
bool isValidPacket(const char* s) {
  uint8_t fields = 0;
  bool digits = false;
  for (const char* p = s; ; p++) {
    const char c = *p;
    if (c == ',' || c == '\0') {
      if (!digits) return false;
      fields++;
      digits = false;
      if (c == '\0') break;
    } else if (c == '-' && (p == s || *(p - 1) == ',')) {
      // sign allowed only at the start of a field
    } else if (c >= '0' && c <= '9') {
      digits = true;
    } else {
      return false;
    }
  }
  return fields == 5;
}
