# CubeMars AK70-10 — CAN Motor Commands (MIT mode)

This document describes every CAN frame that OpenRehEx exchanges with the six
CubeMars **AK70-10** actuators, and how those frames are produced and decoded by
`Arduino/CAN_Driver/CAN_Driver.h`.

> **Source of truth.** Frame layouts follow the CubeMars *AK Series Actuator
> Manual*, section "MIT power mode communication protocol". Scaling ranges can
> change between firmware versions — always confirm them for **your** motors
> with `CubeMarstool_V1.32.exe` (in this folder) before running the exoskeleton
> with a person in it.

---

## 1. Bus configuration

| Parameter        | Value                                               |
|------------------|-----------------------------------------------------|
| Standard         | CAN 2.0A (11-bit standard identifier)               |
| Bit rate         | 1 Mbps (AK factory default)                         |
| Payload          | 8 bytes (commands), 6 or 8 bytes (replies)          |
| Topology         | Linear bus, daisy-chained through each motor's CAN IN/OUT port |
| Termination      | 120 Ω between CAN_H and CAN_L at **both** physical ends |
| Controller       | MCP2515 + TJA1050 module, 8 MHz crystal, SPI to Arduino MEGA 2560 |
| Arduino library  | `mcp_can` by coryjfowler                            |

### Motor ID map

IDs are assigned with CubeMarsTool (factory default is `0x01` for every motor,
so each motor must be re-addressed **one at a time** before joining the bus).
The map matches `JOINTS[]` in `Arduino/main.ino` and `MOTOR_META` in
`Arduino/Graphs_visualization/GUI_plotting_V4.py`.

| CAN ID | Joint        | Side  |
|:------:|--------------|-------|
| `0x01` | Hip          | Right |
| `0x02` | Knee         | Right |
| `0x03` | Ankle        | Right |
| `0x04` | Hip          | Left  |
| `0x05` | Knee         | Left  |
| `0x06` | Ankle        | Left  |

---

## 2. Special commands

Sent to the motor's CAN ID, 8 data bytes. Only the last byte changes.

| Command            | Data (hex)                  | Effect                                              | Driver call        |
|--------------------|-----------------------------|-----------------------------------------------------|--------------------|
| Enter MIT mode     | `FF FF FF FF FF FF FF FC`   | Enables the motor; it starts answering MIT frames   | `enterMit(id)`     |
| Exit MIT mode      | `FF FF FF FF FF FF FF FD`   | Disables the motor (free / back-drivable)           | `exitMit(id)`      |
| Set zero position  | `FF FF FF FF FF FF FF FE`   | Current output-shaft angle becomes 0 rad            | `setZero(id)`      |

> ⚠ **Set zero** redefines the joint reference. OpenRehEx sends it on every
> `enable` (`zero_on_enable = true`, same behaviour as the original sketch), so
> the exoskeleton **must be in the neutral standing posture** (hip 0°, knee 0°,
> ankle 0°) when the operator types `e`. Set `zero_on_enable = false` in
> `DEFAULT_SETTINGS` once zeroing is done with a fixture instead.

---

## 3. Control command (Arduino → motor)

Every control cycle the firmware sends one 8-byte frame per motor. The motor
closes an impedance loop at the output shaft:

```
tau = kp * (p_des - p) + kd * (v_des - v) + t_ff
```

### Fields

| Field   | Bits | Unit      | Meaning                        |
|---------|:----:|-----------|--------------------------------|
| `p_des` | 16   | rad       | Desired output position        |
| `v_des` | 12   | rad/s     | Desired output velocity        |
| `kp`    | 12   | N·m/rad   | Position (stiffness) gain      |
| `kd`    | 12   | N·m·s/rad | Velocity (damping) gain        |
| `t_ff`  | 12   | N·m       | Feed-forward torque            |

### Byte layout

| Byte | Bits 7‥4           | Bits 3‥0           |
|:----:|--------------------|--------------------|
| 0    | `p_des[15:8]`      |                    |
| 1    | `p_des[7:0]`       |                    |
| 2    | `v_des[11:4]`      |                    |
| 3    | `v_des[3:0]`       | `kp[11:8]`         |
| 4    | `kp[7:0]`          |                    |
| 5    | `kd[11:4]`         |                    |
| 6    | `kd[3:0]`          | `t_ff[11:8]`       |
| 7    | `t_ff[7:0]`        |                    |

---

## 4. Reply (motor → Arduino)

The motor answers **each** control frame (and only then). The reply is sent to
the master ID (default `0x00`); the motor ID is inside the payload, so replies
are routed by **byte 0**, not by the CAN identifier.

| Byte | Content                                                    |
|:----:|------------------------------------------------------------|
| 0    | Motor ID                                                   |
| 1    | `p[15:8]`                                                  |
| 2    | `p[7:0]`                                                   |
| 3    | `v[11:4]`                                                  |
| 4    | `v[3:0]` (high nibble) · `i[11:8]` (low nibble)            |
| 5    | `i[7:0]`                                                   |
| 6    | Driver temperature *(firmware ≥ V2 only)*                  |
| 7    | Error code *(firmware ≥ V2 only)*                          |

`i` is scaled with the torque range (`T_MIN … T_MAX`), so it decodes directly
to output torque in N·m.

### Error codes (byte 7)

| Code | Meaning                  |
|:----:|--------------------------|
| 0    | No fault                 |
| 1    | Motor over-temperature   |
| 2    | Over-current             |
| 3    | Over-voltage             |
| 4    | Under-voltage            |
| 5    | Encoder fault            |
| 6    | Phase-current unbalance  |

With `fault_on_motor_error = true` any non-zero code puts the controller in
`FAULT` (damping only). Replies of 6 bytes (older firmware) carry no status and
never trigger this check. The temperature byte is stored raw (`temp_raw`)
because its offset differs between firmware versions.

---

## 5. Scaling (float ↔ integer)

All values are linearly mapped onto unsigned integers:

```
x_int   = round( (x - x_min) * (2^bits - 1) / (x_max - x_min) )
x_float =  x_int * (x_max - x_min) / (2^bits - 1) + x_min
```

Values outside `[x_min, x_max]` are saturated before packing.

### Ranges

| Symbol          | AK70-10 (CubeMars manual) — **used by default** | Original sketch (`AK_LEGACY_SKETCH_LIMITS`) |
|-----------------|:------------------------------------:|:-----------------------------:|
| `P_MIN / P_MAX` | −12.5 / 12.5 rad                     | −12.5 / 12.5 rad              |
| `V_MIN / V_MAX` | −50 / 50 rad/s                       | −30 / 30 rad/s                |
| `KP_MIN / KP_MAX` | 0 / 500 N·m/rad                    | 0 / 500 N·m/rad               |
| `KD_MIN / KD_MAX` | 0 / 5 N·m·s/rad                    | 0 / 5 N·m·s/rad               |
| `T_MIN / T_MAX` | −25 / 25 N·m                         | −18 / 18 N·m                  |

> ⚠ **Why this matters.** If the firmware uses ±50 rad/s and ±25 N·m but the
> code packs with ±30 and ±18, every velocity and torque value is wrong by a
> constant factor (e.g. torque read as 72 % of its real value), while position
> still looks correct. Some third-party drivers list ±24 N·m for AK70-10
> firmware V1.1. Read the ranges in CubeMarsTool and select the matching
> constant in `setup()` (`canBus.setLimits(...)`).

### Resolution (with the default ranges)

| Quantity | Step          |
|----------|---------------|
| Position | 0.00038 rad (0.022°) |
| Velocity | 0.0244 rad/s  |
| Torque   | 0.0122 N·m    |
| `kp`     | 0.122 N·m/rad |
| `kd`     | 0.0012 N·m·s/rad |

### Worked examples (default ranges)

| `p_des` | `v_des` | `kp` | `kd` | `t_ff` | Frame (hex)                 |
|--------:|--------:|-----:|-----:|-------:|-----------------------------|
| 0       | 0       | 0    | 0    | 0      | `80 00 80 00 00 00 08 00` — passive, used to read state |
| 0.5     | 0       | 60   | 1    | 0      | `85 1E 80 01 EB 33 38 00`   |
| 1.234   | −3.2    | 60   | 1    | 2.5    | `8C A2 77 C1 EB 33 38 CC`   |

---

## 6. Command sequence used by the firmware

```
enable (console 'e')
  for id in 1..6:  ENTER_MIT(id) ; [SET_ZERO(id)]
  for id in 1..6:  PASSIVE(id) -> wait reply (≤ 5 attempts) -> store position
  state = HOLD (reference = measured posture)

every control period (default 200 Hz)
  for id in 1..6:
      send MIT command(id)            # p_des, v_des (feed-forward), kp, kd, t_ff = 0
      wait reply from id (≤ 1.5 ms)   # one request/one reply keeps the MCP2515
                                      # 2-frame RX buffer from overflowing
  supervise:  no reply > 50 ms | angle outside limits + 8.6° | error code ≠ 0
              -> FAULT: kp = 0, kd = 2, t_ff = 0 on all joints

disable (console 'd')
  for id in 1..6:  EXIT_MIT(id)       # motors become free: support the limb!
```

**Why request/reply per motor?** The MCP2515 has only two receive buffers. If
six commands are sent back-to-back, up to six replies arrive within ~0.7 ms and
four are lost. Waiting for each reply before sending the next command costs
~0.4–0.6 ms per motor, which still fits inside a 5 ms (200 Hz) cycle. The
console command `?` prints the worst-case loop time and the overrun counter; if
overruns increase, set `CONTROL_HZ` to 100.

---

## 7. Telemetry to the PC (not CAN)

The control MEGA sends one line per control cycle on `Serial1` (round-robin over
the six motors). The visualization MEGA validates and forwards it over USB to
`GUI_plotting_V4.py`.

```
motor_id,timestamp_ms,ref_mrad,pos_mrad,torque_mNm\n
e.g.  2,445473,611,598,4130
```

All values are integers in **joint coordinates** (sign convention of
`trajectory_generator.m`: hip/knee + flexion, ankle + dorsiflexion).

---

## 8. Servo mode (not used)

AK actuators also support a *servo mode* that uses **extended 29-bit IDs**
(`control_mode << 8 | motor_id`) and different payloads (duty, current, RPM,
position). OpenRehEx uses MIT mode only because it exposes the impedance gains
needed for assist-as-needed control. Do not mix both modes on the same bus.

---

## 9. Troubleshooting

| Symptom                                   | Likely cause / fix                                          |
|-------------------------------------------|-------------------------------------------------------------|
| `MCP2515 init failed`                     | SPI wiring, CS ≠ D53, or crystal is 16 MHz → use `MCP_16MHZ` |
| No replies, `FAULT_ENABLE_FAILED`         | Wrong ID, motor not powered, missing termination, CAN_H/CAN_L swapped |
| Only one motor answers                    | All motors still have ID `0x01` — re-address them one by one |
| Position OK, torque/velocity look scaled  | `MitLimits` do not match the firmware (section 5)           |
| Joint moves the wrong way                 | Flip `direction` for that joint in `JOINTS[]`               |
| Random `FAULT_NO_REPLY` while walking     | Bus length/stubs too long, missing common ground, loop overruns |
| Motor jumps on enable                     | Exoskeleton was not at neutral posture when zero was set    |
