#!/usr/bin/env python3
"""
OpenRehEx - csv_to_header.py
============================

Converts the reference trajectories exported by MATLAB/trajectory_generator.m
(exoskeleton_trajectories.csv) into `gait_trajectory.h`, a PROGMEM lookup
table that Motor_Control.h uses on the Arduino MEGA 2560.

Only ONE stride of the RIGHT leg is stored (hip, knee, ankle). The firmware
generates the left leg by shifting the gait phase by 50 %, exactly as the
MATLAB generator does.

Usage
-----
  # From the MATLAB export (CSV columns: Time_s, Hip, Knee, Ankle)
  python csv_to_header.py --csv exoskeleton_trajectories.csv --units deg --cycles 3

  # Rebuild the default table shipped with the repo (nominal gait keypoints)
  python csv_to_header.py --baseline

Options
-------
  --csv PATH        CSV exported by trajectory_generator.m
  --units deg|rad   units selected in the MATLAB app (default: deg)
  --cycles N        number of strides in the CSV (the "Gait Cycles" field)
  --points N        samples per stride stored in flash (default: 250)
  --out PATH        output header (default: gait_trajectory.h next to this file)

Requires: numpy, scipy (only for --baseline)
"""

import argparse
import csv
import os
from datetime import datetime

import numpy as np

# Mechanical range of motion (deg) - must match trajectory_generator.m (LIMITS)
LIMITS_DEG = {"hip": (-20.0, 40.0), "knee": (0.0, 50.0), "ankle": (-20.0, 20.0)}

# Nominal keypoints from trajectory_generator.m (deg, 0:10:100 % of stride)
BASELINE = {
    "hip":   [20, 10,   5,  -5, -15, -20, -10, 10, 25, 35, 20],
    "knee":  [10, 12,  20,  15,   5,   0,  15, 40, 70, 25, 10],
    "ankle": [ 0, -7, -10, -15, -20, -18, -10,  5, 10, 15,  0],
}
REF_SPEED = 1.40         # m/s
REF_STEP_LENGTH = 0.73   # m


def baseline_stride(n_points):
    """Periodic PCHIP through the clamped nominal keypoints (one stride)."""
    from scipy.interpolate import PchipInterpolator

    phase = np.linspace(0.0, 100.0, n_points, endpoint=False)
    out = {}
    for joint, kp in BASELINE.items():
        lo, hi = LIMITS_DEG[joint]
        kp = np.clip(np.asarray(kp[:-1], dtype=float), lo, hi)      # 0..90 %
        ev = np.arange(0, 100, 10, dtype=float)
        # pad two events on each side so the slopes are periodic
        ev_ext = np.concatenate([ev[-2:] - 100, ev, ev[:3] + 100])
        kp_ext = np.concatenate([kp[-2:], kp, kp[:3]])
        out[joint] = np.clip(PchipInterpolator(ev_ext, kp_ext)(phase), lo, hi)
    stride_time = 2.0 * REF_STEP_LENGTH / REF_SPEED
    return out, stride_time


def csv_stride(path, units, cycles, n_points):
    """Extract one stride from the MATLAB CSV and resample it."""
    t, hip, knee, ankle = [], [], [], []
    with open(path, newline="") as f:
        for row in csv.DictReader(f):
            t.append(float(row["Time_s"]))
            hip.append(float(row["Hip"]))
            knee.append(float(row["Knee"]))
            ankle.append(float(row["Ankle"]))
    t = np.asarray(t)
    stride_time = t[-1] / cycles
    k = 180.0 / np.pi if units == "rad" else 1.0

    # Use the LAST complete stride (farthest from any start-up transient)
    t0 = t[-1] - stride_time
    ts = t0 + np.linspace(0.0, stride_time, n_points, endpoint=False)
    out = {}
    for joint, y in (("hip", hip), ("knee", knee), ("ankle", ankle)):
        lo, hi = LIMITS_DEG[joint]
        out[joint] = np.clip(np.interp(ts, t, np.asarray(y) * k), lo, hi)
    return out, stride_time


def write_header(path, traj, stride_time, source):
    n = len(traj["hip"])

    def arr(name, deg):
        mrad = np.round(np.deg2rad(deg) * 1000.0).astype(int)
        lines = []
        for i in range(0, n, 12):
            lines.append("  " + ", ".join(f"{v:5d}" for v in mrad[i:i + 12]))
        return (f"const int16_t {name}[GAIT_N] PROGMEM = {{\n"
                + ",\n".join(lines) + "\n};\n")

    with open(path, "w", newline="\n") as f:
        f.write("/*\n")
        f.write(" * OpenRehEx - gait_trajectory.h  (AUTO-GENERATED, do not edit)\n")
        f.write(f" * Generated : {datetime.now():%Y-%m-%d %H:%M}\n")
        f.write(f" * Source    : {source}\n")
        f.write(" * Content   : one stride of the RIGHT leg, joint angles in mrad.\n")
        f.write(" *             Left leg = same table shifted by 50 % of the stride.\n")
        f.write(" * Signs     : hip +flexion, knee +flexion, ankle +dorsiflexion\n")
        f.write(" * Regenerate: python csv_to_header.py --csv <file> --cycles <n>\n")
        f.write(" */\n\n")
        f.write("#ifndef OPENREHEX_GAIT_TRAJECTORY_H\n#define OPENREHEX_GAIT_TRAJECTORY_H\n\n")
        f.write("#include <Arduino.h>\n#include <avr/pgmspace.h>\n\n")
        f.write(f"#define GAIT_N {n}\n")
        f.write(f"#define GAIT_STRIDE_TIME_S {stride_time:.4f}f\n\n")
        f.write(arr("GAIT_HIP_MRAD", traj["hip"]) + "\n")
        f.write(arr("GAIT_KNEE_MRAD", traj["knee"]) + "\n")
        f.write(arr("GAIT_ANKLE_MRAD", traj["ankle"]) + "\n")
        f.write("#endif  // OPENREHEX_GAIT_TRAJECTORY_H\n")


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    src = ap.add_mutually_exclusive_group(required=True)
    src.add_argument("--csv")
    src.add_argument("--baseline", action="store_true")
    ap.add_argument("--units", choices=["deg", "rad"], default="deg")
    ap.add_argument("--cycles", type=float, default=1.0)
    ap.add_argument("--points", type=int, default=250)
    ap.add_argument("--out", default=os.path.join(here, "gait_trajectory.h"))
    a = ap.parse_args()

    if a.baseline:
        traj, T = baseline_stride(a.points)
        source = "nominal keypoints of trajectory_generator.m (1.40 m/s, 0.73 m step)"
    else:
        traj, T = csv_stride(a.csv, a.units, a.cycles, a.points)
        source = os.path.basename(a.csv)

    write_header(a.out, traj, T, source)
    for j in ("hip", "knee", "ankle"):
        print(f"{j:6s}: {traj[j].min():7.2f} .. {traj[j].max():7.2f} deg")
    print(f"stride time: {T:.3f} s  ->  {a.out}")


if __name__ == "__main__":
    main()
