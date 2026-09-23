import os
import serial
import time
import sys
import csv
import numpy as np
from collections import deque

from PyQt5.QtWidgets import (
    QApplication,
    QMainWindow,
    QWidget,
    QVBoxLayout,
    QHBoxLayout,
    QPushButton,
    QLabel,
    QGridLayout,
    QFrame,
    QMessageBox
)

from PyQt5.QtCore import QTimer, Qt

from matplotlib.backends.backend_qt5agg import (
    FigureCanvasQTAgg as FigureCanvas
)

from matplotlib.figure import Figure


# =============================================================================
# CONFIGURATION
# =============================================================================

COM_PORT = "COM8"
BAUD_RATE = 115200

N = 800

SPIKE_THRESHOLD = 0.3
SPIKE_WINDOW = 20


# =============================================================================
# COLORS
# =============================================================================

BG_DARK = "#13131f"
BG_PLOT = "#1e1e2e"
BG_PANEL = "#1e1e2e"


# =============================================================================
# MOTOR CONFIGURATION
# =============================================================================

MOTOR_META = {

    1: {
        "name": "Right hip",
        "pos": (0, 0)
    },

    2: {
        "name": "Right knee",
        "pos": (1, 0)
    },

    3: {
        "name": "Right ankle",
        "pos": (2, 0)
    },

    4: {
        "name": "Left hip",
        "pos": (0, 1)
    },

    5: {
        "name": "Left knee",
        "pos": (1, 1)
    },

    6: {
        "name": "Left ankle",
        "pos": (2, 1)
    },
}


# =============================================================================
# ROM PAIRS
# =============================================================================

ROM_PAIRS = {

    "Hip": (
        1,
        4
    ),

    "Knee": (
        2,
        5
    ),

    "Ankle": (
        3,
        6
    ),
}


# =============================================================================
# SERIAL CONNECTION
# =============================================================================

try:

    ser = serial.Serial(
        COM_PORT,
        BAUD_RATE,
        timeout=0.05
    )

    time.sleep(2)

    # Clear any old data that may have accumulated
    # before the Python program started.
    ser.reset_input_buffer()

    SERIAL_OK = True

    print(
        f"[INFO] Serial connected: "
        f"{COM_PORT} @ {BAUD_RATE}"
    )


except Exception as e:

    print(
        f"[WARNING] Serial port unavailable: {e}"
    )

    SERIAL_OK = False


# =============================================================================
# DATA BUFFERS
# =============================================================================

def _empty_buf():

    return deque(
        maxlen=N
    )


X = np.arange(N)


motor_data = {

    mid: {

        "ref": _empty_buf(),

        "pos": _empty_buf(),

        "tor": _empty_buf(),

        "vel": _empty_buf()

    }

    for mid in MOTOR_META
}


# =============================================================================
# SPIKE FILTER BUFFERS
# =============================================================================

motor_spike_ref = {

    mid: {

        "ref": deque(
            maxlen=SPIKE_WINDOW
        ),

        "pos": deque(
            maxlen=SPIKE_WINDOW
        )

    }

    for mid in MOTOR_META
}

def spike_filter(new_val: float, spike_buf: deque):
    """
    Reject sudden spikes by comparing the new value
    against the median of the recent samples.

    Returns:
        new_val  -> normal value
        None     -> detected as a spike
    """

    if len(spike_buf) < SPIKE_WINDOW:
        return new_val

    median_val = np.median(list(spike_buf))

    if abs(new_val - median_val) > SPIKE_THRESHOLD:
        return None

    return new_val



# =============================================================================
# VELOCITY STATE
#
# Velocity is calculated from:
#
#     velocity = Δposition / Δtime
#
# The incoming timestamp is assumed to be milliseconds.
# =============================================================================

last_timestamp = {

    mid: None

    for mid in MOTOR_META
}


last_position = {

    mid: None

    for mid in MOTOR_META
}


# =============================================================================
# SERIAL RECEIVE BUFFER
#
# Serial data can arrive in pieces.
#
# Example:
#
# Read 1:
#     1,445534,115,95
#
# Read 2:
#     ,320\r\n
#
# Without this buffer, the packet would be lost.
# =============================================================================

serial_buffer = b""


# =============================================================================
# VIEW CONFIGURATION
# =============================================================================

VIEW_CYCLE = [

    "position",

    "torque",

    "velocity"

]


VIEW_META = {

    "position": {

        "btn_label": "Show Torque",

        "btn_color": "#2e7d32",

        "y_label": "Position (rad)"

    },

    "torque": {

        "btn_label": "Show Velocity",

        "btn_color": "#1565c0",

        "y_label": "Torque (N·m)"

    },

    "velocity": {

        "btn_label": "Show Position",

        "btn_color": "#6a1b9a",

        "y_label": "Velocity (rad/s)"

    }

}


# =============================================================================
# MAIN WINDOW
# =============================================================================

class MultiPlotWindow(QMainWindow):

    def __init__(self):

        super().__init__()


        # ---------------------------------------------------------------------
        # Window
        # ---------------------------------------------------------------------

        self.setWindowTitle(
            "Lower Limb Exoskeleton GUI"
        )

        self.setStyleSheet(
            f"background-color: {BG_DARK};"
            "color: white;"
        )


        # ---------------------------------------------------------------------
        # Central widget
        # ---------------------------------------------------------------------

        central = QWidget()

        central.setStyleSheet(
            f"background-color: {BG_DARK};"
        )


        main_layout = QHBoxLayout(
            central
        )

        main_layout.setContentsMargins(
            6,
            6,
            6,
            6
        )

        main_layout.setSpacing(
            8
        )


        self.setCentralWidget(
            central
        )


        # =====================================================================
        # PLOT FRAME
        # =====================================================================

        plot_frame = QFrame()

        plot_frame.setStyleSheet(
            f"background-color: {BG_DARK};"
            "border: none;"
        )


        plot_grid = QGridLayout(
            plot_frame
        )

        plot_grid.setContentsMargins(
            0,
            0,
            0,
            0
        )


        main_layout.addWidget(
            plot_frame,
            stretch=4
        )


        # ---------------------------------------------------------------------
        # Matplotlib figure
        # ---------------------------------------------------------------------

        self.figure = Figure(
            constrained_layout=True
        )


        self.figure.patch.set_facecolor(
            BG_DARK
        )


        self.canvas = FigureCanvas(
            self.figure
        )


        self.canvas.setStyleSheet(
            f"background-color: {BG_DARK};"
        )


        plot_grid.addWidget(
            self.canvas,
            0,
            0
        )


        # ---------------------------------------------------------------------
        # Six axes
        # ---------------------------------------------------------------------

        self.axes = self.figure.subplots(
            3,
            2
        )


        # ---------------------------------------------------------------------
        # Plot lines
        #
        # lines[mid] =
        #
        #     reference
        #     position
        #     torque
        #     velocity
        # ---------------------------------------------------------------------

        self.lines = {}


        for mid, meta in MOTOR_META.items():

            r, c = meta["pos"]

            ax = self.axes[
                r,
                c
            ]


            ax.set_facecolor(
                BG_PLOT
            )


            ax.set_title(
                meta["name"],
                fontsize=28,
                fontweight="bold",
                color="white"
            )


            ax.set_xlabel(
                "Samples",
                fontsize=22,
                color="#aaaaaa"
            )


            ax.set_ylabel(
                "Position (rad)",
                fontsize=22,
                color="#aaaaaa"
            )


            ax.tick_params(
                colors="#aaaaaa",
                labelsize=20
            )


            for spine in ax.spines.values():

                spine.set_edgecolor(
                    "#444466"
                )


            ax.grid(
                True,
                color="#333355",
                linewidth=0.7
            )


            ax.set_xlim(
                0,
                N - 1
            )


            ax.set_ylim(
                -1,
                1
            )


            # Reference

            line_ref, = ax.plot(

                [],

                [],

                linewidth=2.5,

                color="#58a6ff",

                label="Reference",

                visible=True

            )


            # Position

            line_pos, = ax.plot(

                [],

                [],

                linewidth=2.5,

                color="#ff7b54",

                label="Position",

                visible=True

            )


            # Torque

            line_tor, = ax.plot(

                [],

                [],

                linewidth=2.5,

                color="#3ddc84",

                label="Torque (N·m)",

                visible=False

            )


            # Velocity

            line_vel, = ax.plot(

                [],

                [],

                linewidth=2.5,

                color="#f7c948",

                label="Velocity (rad/s)",

                visible=False

            )


            ax.legend(

                fontsize=20,

                loc="upper right",

                facecolor="#2a2a3e",

                labelcolor="white",

                edgecolor="#444466"

            )


            self.lines[mid] = (

                line_ref,

                line_pos,

                line_tor,

                line_vel

            )


        # =====================================================================
        # CROSSHAIRS
        # =====================================================================

        self._crosshairs = {}


        for mid, meta in MOTOR_META.items():

            r, c = meta["pos"]

            ax = self.axes[
                r,
                c
            ]


            vline = ax.axvline(

                x=0,

                color="#ffffff",

                linewidth=1.2,

                linestyle="--",

                alpha=0.65,

                visible=False,

                zorder=10

            )


            self._crosshairs[mid] = vline


        # =====================================================================
        # TOOLTIP
        # =====================================================================

        self._tooltip = QLabel(
            plot_frame
        )


        self._tooltip.setStyleSheet(

            "background-color: rgba(30,30,46,220);"

            "color: #ffffff;"

            "font-size: 22px;"

            "padding: 6px 10px;"

            "border: 1px solid #444466;"

            "border-radius: 6px;"

        )


        self._tooltip.setAlignment(

            Qt.AlignLeft |
            Qt.AlignTop

        )


        self._tooltip.hide()


        self._tooltip.setAttribute(

            Qt.WA_TransparentForMouseEvents

        )


        # =====================================================================
        # CURSOR DOTS
        # =====================================================================

        self._cursor_dots = {}


        for mid, meta in MOTOR_META.items():

            r, c = meta["pos"]

            ax = self.axes[
                r,
                c
            ]


            dot, = ax.plot(

                [],

                [],

                "o",

                markersize=9,

                color="#ffffff",

                zorder=11,

                visible=False

            )


            self._cursor_dots[mid] = dot


        # =====================================================================
        # MOUSE EVENTS
        # =====================================================================

        self.canvas.mpl_connect(

            "motion_notify_event",

            self._on_mouse_move

        )


        self.canvas.mpl_connect(

            "axes_leave_event",

            self._on_mouse_leave

        )


        self.canvas.mpl_connect(

            "figure_leave_event",

            self._on_mouse_leave

        )


        # =====================================================================
        # SIDE PANEL
        # =====================================================================

        side_panel = QFrame()

        side_panel.setStyleSheet(

            f"background-color: {BG_PANEL};"

            "border: none;"

        )


        side_layout = QVBoxLayout(
            side_panel
        )


        side_layout.setSpacing(
            14
        )


        side_layout.setContentsMargins(

            12,

            12,

            12,

            12

        )


        main_layout.addWidget(

            side_panel,

            stretch=0

        )


        # =====================================================================
        # ROM TITLE
        # =====================================================================

        rom_title = QLabel(
            "Range of Motion"
        )


        rom_title.setStyleSheet(

            "font-size:36px;"

            "font-weight:bold;"

            "color:#58a6ff;"

            "border-bottom:1px solid #444466;"

            "padding-bottom:6px;"

        )


        side_layout.addWidget(
            rom_title
        )


        # =====================================================================
        # ROM LABELS
        # =====================================================================

        self.rom_labels = {}


        for joint in (

            "Hip",

            "Knee",

            "Ankle"

        ):

            lbl_title = QLabel(

                f"ROM {joint}:"

            )


            lbl_title.setStyleSheet(

                "font-size:34px;"

                "font-weight:bold;"

                "color:#58a6ff;"

                "margin-top:8px;"

            )


            side_layout.addWidget(
                lbl_title
            )


            lbl_r = QLabel(
                "R  --"
            )


            lbl_r.setStyleSheet(

                "font-size:34px;"

                "color:#dddddd;"

                "padding-left:12px;"

            )


            side_layout.addWidget(
                lbl_r
            )


            lbl_l = QLabel(
                "L  --"
            )


            lbl_l.setStyleSheet(

                "font-size:34px;"

                "color:#dddddd;"

                "padding-left:12px;"

            )


            side_layout.addWidget(
                lbl_l
            )


            self.rom_labels[joint] = {

                "title": lbl_title,

                "R": lbl_r,

                "L": lbl_l

            }


        side_layout.addStretch()


        # =====================================================================
        # VIEW BUTTON
        # =====================================================================

        self._view_mode = "position"


        self.btn_view = QPushButton(

            VIEW_META["position"]["btn_label"]

        )


        self.btn_view.setStyleSheet(

            f"font-size:34px;"

            f"background:"
            f"{VIEW_META['position']['btn_color']};"

            "color:white;"

            "font-weight:bold;"

            "padding:10px;"

            "border-radius:6px;"

            "border:none;"

        )


        self.btn_view.clicked.connect(
            self.toggle_view
        )


        side_layout.addWidget(
            self.btn_view
        )


        # =====================================================================
        # RESTART BUTTON
        # =====================================================================

        btn_restart = QPushButton(
            "Restart"
        )


        btn_restart.setStyleSheet(

            "font-size:34px;"

            "background:#c47800;"

            "color:white;"

            "font-weight:bold;"

            "padding:10px;"

            "border-radius:6px;"

            "border:none;"

        )


        btn_restart.clicked.connect(
            self.restart_plots
        )


        side_layout.addWidget(
            btn_restart
        )


        # =====================================================================
        # SAVE BUTTON
        # =====================================================================

        btn_save = QPushButton(
            "Save Data"
        )


        btn_save.setStyleSheet(

            "font-size:34px;"

            "background:#095180;"

            "color:white;"

            "font-weight:bold;"

            "padding:10px;"

            "border-radius:6px;"

            "border:none;"

        )


        btn_save.clicked.connect(
            self.save_data
        )


        side_layout.addWidget(
            btn_save
        )


        # =====================================================================
        # TIMER
        # =====================================================================

        self._redraw_counter = 0


        self.timer = QTimer()


        self.timer.timeout.connect(
            self.update_plots
        )


        self.timer.start(
            10
        )


    # =========================================================================
    # MOUSE / CROSSHAIR
    # =========================================================================

    def _on_mouse_move(self, event):

        if event.inaxes is None:

            self._hide_cursor()

            return


        hovered_mid = None


        for mid, meta in MOTOR_META.items():

            r, c = meta["pos"]


            if self.axes[
                r,
                c
            ] is event.inaxes:

                hovered_mid = mid

                break


        if hovered_mid is None:

            self._hide_cursor()

            return


        buf = motor_data[
            hovered_mid
        ]


        n_samples = len(
            buf["ref"]
        )


        if n_samples == 0:

            self._hide_cursor()

            return


        sample_idx = int(
            round(event.xdata)
        )


        sample_idx = max(

            0,

            min(

                sample_idx,

                n_samples - 1

            )

        )


        # ---------------------------------------------------------------------
        # Update crosshairs and dots
        # ---------------------------------------------------------------------

        for mid, meta in MOTOR_META.items():

            vline = self._crosshairs[
                mid
            ]

            dot = self._cursor_dots[
                mid
            ]

            buf_m = motor_data[
                mid
            ]


            n_m = len(
                buf_m["ref"]
            )


            if n_m == 0:

                vline.set_visible(
                    False
                )

                dot.set_visible(
                    False
                )

                continue


            idx = min(

                sample_idx,

                n_m - 1

            )


            vline.set_xdata(
                [idx, idx]
            )

            vline.set_visible(
                True
            )


            if self._view_mode == "position":

                y_val = list(
                    buf_m["pos"]
                )[idx]


            elif self._view_mode == "torque":

                y_val = list(
                    buf_m["tor"]
                )[idx]


            else:

                y_val = list(
                    buf_m["vel"]
                )[idx]


            dot.set_xdata(
                [idx]
            )

            dot.set_ydata(
                [y_val]
            )

            dot.set_visible(
                True
            )


        self.canvas.draw_idle()


        # ---------------------------------------------------------------------
        # Tooltip text
        # ---------------------------------------------------------------------

        lines_txt = [

            f"Sample {sample_idx}"

        ]


        for mid, meta in MOTOR_META.items():

            buf_m = motor_data[
                mid
            ]


            n_m = len(
                buf_m["ref"]
            )


            if n_m == 0:

                continue


            idx = min(

                sample_idx,

                n_m - 1

            )


            if self._view_mode == "position":

                ref_v = list(
                    buf_m["ref"]
                )[idx]

                pos_v = list(
                    buf_m["pos"]
                )[idx]


                lines_txt.append(

                    f"{meta['name'][:10]:10s}  "
                    f"ref={ref_v:+.3f}  "
                    f"pos={pos_v:+.3f} rad"

                )


            elif self._view_mode == "torque":

                tor_v = list(
                    buf_m["tor"]
                )[idx]


                lines_txt.append(

                    f"{meta['name'][:10]:10s}  "
                    f"tor={tor_v:+.3f} N·m"

                )


            else:

                vel_v = list(
                    buf_m["vel"]
                )[idx]


                lines_txt.append(

                    f"{meta['name'][:10]:10s}  "
                    f"vel={vel_v:+.3f} rad/s"

                )


        self._tooltip.setText(
            "\n".join(lines_txt)
        )


        self._tooltip.adjustSize()


        # ---------------------------------------------------------------------
        # Position tooltip
        # ---------------------------------------------------------------------

        canvas_h = self.canvas.height()


        cx = int(
            event.x
        ) + 18


        cy = int(

            canvas_h -
            event.y

        ) + 18


        tw = self._tooltip.width()

        th = self._tooltip.height()

        fw = self.canvas.width()

        fh = self.canvas.height()


        if cx + tw > fw:

            cx = int(
                event.x
            ) - tw - 8


        if cy + th > fh:

            cy = int(

                canvas_h -
                event.y

            ) - th - 8


        self._tooltip.move(
            cx,
            cy
        )


        self._tooltip.show()

        self._tooltip.raise_()


    def _on_mouse_leave(
        self,
        event=None
    ):

        self._hide_cursor()


    def _hide_cursor(self):

        for vline in self._crosshairs.values():

            vline.set_visible(
                False
            )


        for dot in self._cursor_dots.values():

            dot.set_visible(
                False
            )


        self._tooltip.hide()


        self.canvas.draw_idle()


    # =========================================================================
    # VIEW TOGGLE
    # =========================================================================

    def toggle_view(self):

        idx = VIEW_CYCLE.index(
            self._view_mode
        )


        self._view_mode = VIEW_CYCLE[
            (idx + 1) %
            len(VIEW_CYCLE)
        ]


        meta = VIEW_META[
            self._view_mode
        ]


        self.btn_view.setText(
            meta["btn_label"]
        )


        self.btn_view.setStyleSheet(

            f"font-size:34px;"

            f"background:{meta['btn_color']};"

            "color:white;"

            "font-weight:bold;"

            "padding:10px;"

            "border-radius:6px;"

            "border:none;"

        )


        pos_mode = (
            self._view_mode ==
            "position"
        )


        tor_mode = (
            self._view_mode ==
            "torque"
        )


        vel_mode = (
            self._view_mode ==
            "velocity"
        )


        for mid, ax_meta in MOTOR_META.items():

            line_ref, line_pos, line_tor, line_vel = \
                self.lines[mid]


            line_ref.set_visible(
                pos_mode
            )


            line_pos.set_visible(
                pos_mode
            )


            line_tor.set_visible(
                tor_mode
            )


            line_vel.set_visible(
                vel_mode
            )


            r, c = ax_meta["pos"]


            ax = self.axes[
                r,
                c
            ]


            ax.set_ylabel(

                meta["y_label"],

                fontsize=22,

                color="#aaaaaa"

            )


            self._rescale_axis(
                mid
            )


        # Refresh legends

        for mid, ax_meta in MOTOR_META.items():

            r, c = ax_meta["pos"]


            self.axes[
                r,
                c
            ].legend(

                fontsize=20,

                loc="upper right",

                facecolor="#2a2a3e",

                labelcolor="white",

                edgecolor="#444466"

            )


        self.canvas.draw_idle()


    # =========================================================================
    # RESCALE AXIS
    # =========================================================================

    def _rescale_axis(
        self,
        mid
    ):

        buf = motor_data[
            mid
        ]


        r, c = MOTOR_META[
            mid
        ]["pos"]


        ax = self.axes[
            r,
            c
        ]


        if self._view_mode == "position":

            arr = np.concatenate([

                np.array(
                    buf["ref"]
                ),

                np.array(
                    buf["pos"]
                )

            ])


        elif self._view_mode == "torque":

            arr = np.array(
                buf["tor"]
            )


        else:

            arr = np.array(
                buf["vel"]
            )


        if len(arr):

            valid = arr[
                ~np.isnan(arr)
            ]

        else:

            valid = np.array([])


        if len(valid):

            y_lo = valid.min()

            y_hi = valid.max()


            margin = max(

                (y_hi - y_lo) * 0.15,

                0.05

            )


            ax.set_ylim(

                y_lo - margin,

                y_hi + margin

            )


        else:

            ax.set_ylim(
                -1,
                1
            )


    # =========================================================================
    # UPDATE PLOTS
    # =========================================================================

    def update_plots(self):

        packets = self.drain_serial()


        if not packets:

            return


        # IMPORTANT:
        #
        # Every valid packet is processed immediately.
        #
        # We do NOT wait for all six motors.

        for packet in packets:

            self._process_packet(
                packet
            )


        self._redraw_counter += len(
            packets
        )


        # Redraw regularly rather than after every packet.
        if self._redraw_counter >= 6:

            self._redraw_counter = 0

            self.canvas.draw_idle()


    # =========================================================================
    # PROCESS 5-VALUE PACKET
    # =========================================================================

    def _process_packet(
        self,
        packet
    ):

        # Incoming format:
        #
        # motor_id,
        # timestamp_ms,
        # reference,
        # position,
        # torque
        #
        # Example:
        #
        # 4,445473,-39,-44,13


        try:

            mid, t_ms, ref_raw, pos_raw, tor_raw = packet

        except ValueError:

            return


        if mid not in MOTOR_META:

            return


        # ---------------------------------------------------------------------
        # Convert raw values
        #
        # Assumption:
        #
        # raw position = milliradians
        # raw reference = milliradians
        # raw torque = milli-Nm
        #
        # Therefore /1000.
        # ---------------------------------------------------------------------

        ref_d = (
            ref_raw / 1000.0
        )


        pos_d = (
            pos_raw / 1000.0
        )


        tor_d = (
            tor_raw / 1000.0
        )


        # ---------------------------------------------------------------------
        # Calculate velocity
        #
        # timestamp is assumed to be milliseconds.
        # ---------------------------------------------------------------------

        vel_d = 0.0


        previous_time = last_timestamp[
            mid
        ]


        previous_position = last_position[
            mid
        ]


        if (

            previous_time is not None

            and previous_position is not None

        ):

            dt = (

                t_ms -
                previous_time

            ) / 1000.0


            if dt > 0:

                vel_d = (

                    pos_d -
                    previous_position

                ) / dt


        # Store previous sample

        last_timestamp[
            mid
        ] = t_ms


        last_position[
            mid
        ] = pos_d


        # ---------------------------------------------------------------------
        # Buffers
        # ---------------------------------------------------------------------

        buf = motor_data[
            mid
        ]


        spike_ref = motor_spike_ref[
            mid
        ]


        # ---------------------------------------------------------------------
        # Spike filtering
        # ---------------------------------------------------------------------

        filtered_ref = spike_filter(

            ref_d,

            spike_ref["ref"]

        )


        filtered_pos = spike_filter(

            pos_d,

            spike_ref["pos"]

        )


        # ---------------------------------------------------------------------
        # Recover previous value if spike detected
        # ---------------------------------------------------------------------

        def last_valid(buffer):

            for value in reversed(buffer):

                if not np.isnan(value):

                    return value

            return np.nan


        if filtered_ref is None:

            filtered_ref = last_valid(
                buf["ref"]
            )


        if filtered_pos is None:

            filtered_pos = last_valid(
                buf["pos"]
            )


        # ---------------------------------------------------------------------
        # If both position and reference are invalid, don't add the sample.
        # ---------------------------------------------------------------------

        if (

            filtered_ref is None

            and filtered_pos is None

        ):

            return


        # ---------------------------------------------------------------------
        # Update spike buffers
        # ---------------------------------------------------------------------

        spike_ref["ref"].append(
            filtered_ref
        )


        spike_ref["pos"].append(
            filtered_pos
        )


        # ---------------------------------------------------------------------
        # Store data
        # ---------------------------------------------------------------------

        buf["ref"].append(
            filtered_ref
        )


        buf["pos"].append(
            filtered_pos
        )


        buf["tor"].append(
            tor_d
        )


        buf["vel"].append(
            vel_d
        )


        # ---------------------------------------------------------------------
        # Convert buffers to numpy arrays
        # ---------------------------------------------------------------------

        refs = np.array(
            buf["ref"]
        )


        poses = np.array(
            buf["pos"]
        )


        tors = np.array(
            buf["tor"]
        )


        vels = np.array(
            buf["vel"]
        )


        n = len(
            refs
        )


        xs = X[:n]


        # ---------------------------------------------------------------------
        # Update lines
        # ---------------------------------------------------------------------

        line_ref, line_pos, line_tor, line_vel = \
            self.lines[mid]


        line_ref.set_xdata(
            xs
        )


        line_ref.set_ydata(
            refs
        )


        line_pos.set_xdata(
            xs
        )


        line_pos.set_ydata(
            poses
        )


        line_tor.set_xdata(
            X[:len(tors)]
        )


        line_tor.set_ydata(
            tors
        )


        line_vel.set_xdata(
            X[:len(vels)]
        )


        line_vel.set_ydata(
            vels
        )


        # ---------------------------------------------------------------------
        # Rescale
        # ---------------------------------------------------------------------

        self._rescale_axis(
            mid
        )


        # ---------------------------------------------------------------------
        # ROM
        # ---------------------------------------------------------------------

        for joint, (r_mid, l_mid) in ROM_PAIRS.items():

            r_ref = np.array(

                motor_data[
                    r_mid
                ]["ref"]

            )


            l_ref = np.array(

                motor_data[
                    l_mid
                ]["ref"]

            )


            r_valid = r_ref[
                ~np.isnan(r_ref)
            ]


            l_valid = l_ref[
                ~np.isnan(l_ref)
            ]


            if len(r_valid) > 1:

                r_rom = (

                    f"{r_valid.max() - r_valid.min():.3f} rad"

                )

            else:

                r_rom = "--"


            if len(l_valid) > 1:

                l_rom = (

                    f"{l_valid.max() - l_valid.min():.3f} rad"

                )

            else:

                l_rom = "--"


            self.rom_labels[
                joint
            ]["R"].setText(

                f"R  {r_rom}"

            )


            self.rom_labels[
                joint
            ]["L"].setText(

                f"L  {l_rom}"

            )


    # =========================================================================
    # SERIAL READER
    # =========================================================================

    def drain_serial(self):

        global serial_buffer


        if not SERIAL_OK:

            return []


        packets = []


        try:

            # -----------------------------------------------------------------
            # Read all currently available bytes
            # -----------------------------------------------------------------

            waiting = ser.in_waiting


            if waiting > 0:

                new_data = ser.read(
                    waiting
                )


                # Add to persistent buffer

                serial_buffer += new_data


            # -----------------------------------------------------------------
            # Process complete lines only
            # -----------------------------------------------------------------

            while b"\n" in serial_buffer:

                raw_line, serial_buffer = \
                    serial_buffer.split(
                        b"\n",
                        1
                    )


                line = raw_line.decode(
                    errors="ignore"
                ).strip()


                if not line:

                    continue


                # Remove possible carriage return

                line = line.rstrip(
                    "\r"
                )


                parts = line.split(",")


                # -------------------------------------------------------------
                # EXACTLY FIVE VALUES
                #
                # motor_id,timestamp,reference,position,torque
                # -------------------------------------------------------------

                if len(parts) != 5:

                    print(
                        "[WARNING] Invalid packet:",
                        line
                    )

                    continue


                try:

                    packet = tuple(

                        int(
                            p.strip()
                        )

                        for p in parts

                    )


                except ValueError:

                    print(

                        "[WARNING] "
                        "Non-numeric packet:",

                        line

                    )

                    continue


                # -------------------------------------------------------------
                # Validate motor ID
                # -------------------------------------------------------------

                motor_id = packet[0]


                if motor_id not in MOTOR_META:

                    print(

                        "[WARNING] "
                        f"Unknown motor ID: {motor_id}"

                    )

                    continue


                packets.append(
                    packet
                )


        except Exception as e:

            print(
                "[Serial error]",
                e
            )


        return packets


    # =========================================================================
    # FLUSH BUFFERS
    # =========================================================================

    def _flush_buffers(self):

        global serial_buffer


        # ---------------------------------------------------------------------
        # Clear serial buffer
        # ---------------------------------------------------------------------

        serial_buffer = b""


        if SERIAL_OK:

            try:

                ser.reset_input_buffer()

            except Exception as e:

                print(
                    "Could not reset serial buffer:",
                    e
                )


        # ---------------------------------------------------------------------
        # Clear motor data
        # ---------------------------------------------------------------------

        for mid, buf in motor_data.items():

            buf["ref"] = _empty_buf()

            buf["pos"] = _empty_buf()

            buf["tor"] = _empty_buf()

            buf["vel"] = _empty_buf()


            # Reset velocity calculation

            last_timestamp[
                mid
            ] = None


            last_position[
                mid
            ] = None


            # Clear plot lines

            line_ref, line_pos, line_tor, line_vel = \
                self.lines[mid]


            for line in (

                line_ref,

                line_pos,

                line_tor,

                line_vel

            ):

                line.set_xdata([])

                line.set_ydata([])


            # Reset axis

            r, c = MOTOR_META[
                mid
            ]["pos"]


            self.axes[
                r,
                c
            ].set_ylim(

                -1,

                1

            )


        # ---------------------------------------------------------------------
        # Clear ROM
        # ---------------------------------------------------------------------

        for joint_labels in self.rom_labels.values():

            joint_labels["R"].setText(
                "R  --"
            )

            joint_labels["L"].setText(
                "L  --"
            )


        self.canvas.draw_idle()


    # =========================================================================
    # RESTART
    # =========================================================================

    def restart_plots(self):

        self._flush_buffers()


        # Clear spike filters

        for mid in MOTOR_META:

            motor_spike_ref[
                mid
            ]["ref"].clear()


            motor_spike_ref[
                mid
            ]["pos"].clear()


            last_timestamp[
                mid
            ] = None


            last_position[
                mid
            ] = None


        self._redraw_counter = 0


    # =========================================================================
    # SAVE DATA
    # =========================================================================

    def save_data(self):

        try:

            base = "session_data"


            # -----------------------------------------------------------------
            # TXT
            # -----------------------------------------------------------------

            with open(

                f"{base}.txt",

                "w"

            ) as f:


                for mid, meta in MOTOR_META.items():

                    buf = motor_data[
                        mid
                    ]


                    f.write(

                        f"\n# Motor {mid} — "
                        f"{meta['name']}\n"

                    )


                    f.write(

                        f"  reference: "
                        f"{list(buf['ref'])}\n"

                    )


                    f.write(

                        f"  position:  "
                        f"{list(buf['pos'])}\n"

                    )


                    f.write(

                        f"  torque:    "
                        f"{list(buf['tor'])}\n"

                    )


                    f.write(

                        f"  velocity:  "
                        f"{list(buf['vel'])}\n"

                    )


            # -----------------------------------------------------------------
            # Main CSV
            # -----------------------------------------------------------------

            for mid, meta in MOTOR_META.items():

                buf = motor_data[
                    mid
                ]


                fname = (

                    f"{base}_motor{mid}_"

                    f"{meta['name'].replace(' ', '_')}"

                    ".csv"

                )


                with open(

                    fname,

                    "w",

                    newline=""

                ) as f:


                    writer = csv.writer(
                        f
                    )


                    writer.writerow([

                        "sample",

                        "reference_rad",

                        "position_rad",

                        "torque_Nm",

                        "velocity_rad_s"

                    ])


                    writer.writerows(

                        zip(

                            range(
                                len(buf["ref"])
                            ),

                            buf["ref"],

                            buf["pos"],

                            buf["tor"],

                            buf["vel"]

                        )

                    )


            # -----------------------------------------------------------------
            # Torque CSV
            # -----------------------------------------------------------------

            for mid, meta in MOTOR_META.items():

                buf = motor_data[
                    mid
                ]


                fname = (

                    f"{base}_torque_motor{mid}_"

                    f"{meta['name'].replace(' ', '_')}"

                    ".csv"

                )


                with open(

                    fname,

                    "w",

                    newline=""

                ) as f:


                    writer = csv.writer(
                        f
                    )


                    writer.writerow([

                        "sample",

                        "torque_Nm"

                    ])


                    writer.writerows(

                        zip(

                            range(
                                len(buf["tor"])
                            ),

                            buf["tor"]

                        )

                    )


            # -----------------------------------------------------------------
            # Velocity CSV
            # -----------------------------------------------------------------

            for mid, meta in MOTOR_META.items():

                buf = motor_data[
                    mid
                ]


                fname = (

                    f"{base}_velocity_motor{mid}_"

                    f"{meta['name'].replace(' ', '_')}"

                    ".csv"

                )


                with open(

                    fname,

                    "w",

                    newline=""

                ) as f:


                    writer = csv.writer(
                        f
                    )


                    writer.writerow([

                        "sample",

                        "velocity_rad_s"

                    ])


                    writer.writerows(

                        zip(

                            range(
                                len(buf["vel"])
                            ),

                            buf["vel"]

                        )

                    )


            # -----------------------------------------------------------------
            # Confirmation
            # -----------------------------------------------------------------

            QMessageBox.information(

                self,

                "Saved",

                f"Saved:\n"

                f"  {base}.txt\n"

                f"  {base}_motor<id>_<name>.csv\n"

                f"  {base}_torque_motor<id>_<name>.csv\n"

                f"  {base}_velocity_motor<id>_<name>.csv"

            )


        except Exception as e:

            QMessageBox.critical(

                self,

                "Error",

                f"Could not save:\n{e}"

            )


# =============================================================================
# APPLICATION ENTRY POINT
# =============================================================================

if __name__ == "__main__":

    app = QApplication(
        sys.argv
    )


    window = MultiPlotWindow()


    window.showMaximized()


    sys.exit(
        app.exec_()
    )
