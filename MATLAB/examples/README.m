%% README.m
%  Examples Folder - Lower Limb Exoskeleton Trajectory Generator
% =========================================================================
%
%  CONTENTS:
%
%    run_all_examples.m      Master script — runs all three examples in
%                            sequence with formatted console output.
%
%    example_slow_gait.m     Slow / pathological gait (0.89 m/s, 0.58 m)
%                            Elderly patients or early-stage rehabilitation.
%
%    example_normal_gait.m   Normal / healthy gait   (1.40 m/s, 0.73 m)
%                            Standard rehabilitation target trajectory.
%
%    example_fast_gait.m     Fast / brisk walking    (2.02 m/s, 0.87 m)
%                            Advanced rehabilitation or augmentation.
%
% -------------------------------------------------------------------------
%  HOW TO RUN
% -------------------------------------------------------------------------
%
%  Option A — Run a single example:
%    >> example_normal_gait
%
%  Option B — Run all three in sequence:
%    >> run_all_examples
%
%  Option C — Customise and run programmatically (see parameter table below)
%
% -------------------------------------------------------------------------
%  PARAMETER QUICK-REFERENCE
% -------------------------------------------------------------------------
%
%  generate_exoskeleton_trajectories_backend(
%      n_points,         % int     Trajectory resolution        [50–2000]
%      n_cycles,         % float   Number of gait cycles        [0.1–10]
%      gait_speed,       % float   Walking speed (m/s)          [0.1–3.0]  *KEY*
%      step_length,      % float   Step length (m)              [0.1–1.5]  *KEY*
%      amplitude_scale,  % float   ROM scaling factor           [0.1–2.0]
%      smoothness,       % int     Smoothing level              [1–10]
%      plot_results,     % bool    Generate plots               [true/false]
%      save_data,        % bool    Save output files            [true/false]
%      verify_continuous,% bool    Two-cycle continuity check   [true/false]
%      save_data_format) % char    Angle units                  ['deg'/'rad']
%
%  Preset values used in each example:
%
%  ┌──────────────────┬────────────┬─────────────┬────────────┐
%  │ Parameter        │ Slow Gait  │ Normal Gait │ Fast Gait  │
%  ├──────────────────┼────────────┼─────────────┼────────────┤
%  │ n_points         │ 500        │ 500         │ 500        │
%  │ n_cycles         │ 1.0        │ 1.0         │ 1.0        │
%  │ gait_speed (m/s) │ 0.89 *KEY* │ 1.40 *KEY*  │ 2.02 *KEY* │
%  │ step_length (m)  │ 0.58 *KEY* │ 0.73 *KEY*  │ 0.87 *KEY* │
%  │ amplitude_scale  │ 1.0        │ 1.0         │ 1.0        │
%  │ smoothness       │ 9          │ 8           │ 7          │
%  │ plot_results     │ true       │ true        │ true       │
%  │ save_data        │ true       │ true        │ true       │
%  │ verify_cont.     │ true       │ true        │ true       │
%  │ format           │ 'deg'      │ 'deg'       │ 'deg'      │
%  └──────────────────┴────────────┴─────────────┴────────────┘
%
% -------------------------------------------------------------------------
%  REQUIREMENTS
% -------------------------------------------------------------------------
%
%  • MATLAB R2020b or later (App Designer + tiledlayout support)
%  • Signal Processing Toolbox  (butter, filtfilt)
%  • Curve Fitting Toolbox      (smooth with 'sgolay')
%  • generate_exoskeleton_trajectories_backend() on the MATLAB path
%    → defined at the bottom of ExoskeletonTrajectoryApp.m
%
% -------------------------------------------------------------------------
%  AUTHOR & VERSION
% -------------------------------------------------------------------------
%
%  Author : Rafael Pérez-San Lázaro
%  Version: 1.0  (January 2026)
%  Contact: rafael.sanlazaro@tec.mx
%
% =========================================================================
