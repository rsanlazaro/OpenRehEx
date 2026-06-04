%% example_normal_gait.m
%  Example: Normal / Healthy Adult Gait Trajectory Generation
%
%  DESCRIPTION:
%    Generates reference joint trajectories for a healthy adult walking at
%    a self-selected comfortable pace.  This is the baseline condition from
%    which slow and fast gait deviations are measured.  Key characteristics:
%      - Comfortable walking speed    (~1.40 m/s)
%      - Nominal step length          (~0.73 m)
%      - Full physiological ROM for hip, knee, and ankle
%      - Stance phase ~62% of the gait cycle
%      - Double-support time ~18% of the gait cycle
%
%  CLINICAL RELEVANCE:
%    Normal gait parameters serve as the rehabilitation target for patients
%    recovering from stroke, spinal cord injury, or orthopaedic surgery.
%    The generated trajectories define the ideal motion the exoskeleton
%    should guide the patient towards.
%
%  FUNCTION SIGNATURE (for reference):
%    generate_exoskeleton_trajectories_backend(
%        n_points, n_cycles, gait_speed, step_length, amplitude_scale,
%        smoothness, plot_results, save_data, verify_continuous,
%        save_data_format)
%
%  REFERENCES:
%    [1] Kadaba et al. (1990) - Measurement of lower extremity kinematics
%        during level walking. J Orthop Res.
%    [2] Lim et al. (2017)   - Effects of step length and step frequency
%        on lower-limb muscle function in human gait. J Biomech.
%    [3] Perry & Burnfield (2010) - Gait Analysis: Normal and Pathological
%        Function. SLACK Incorporated.
% =========================================================================

clc;
fprintf('\n');
fprintf('╔══════════════════════════════════════════════════════════════════╗\n');
fprintf('║                EXAMPLE: NORMAL / HEALTHY GAIT                   ║\n');
fprintf('╚══════════════════════════════════════════════════════════════════╝\n\n');

% -------------------------------------------------------------------------
%  PARAMETERS
% -------------------------------------------------------------------------

% --- Temporal resolution ---
n_points  = 500;        % points per trajectory vector
n_cycles  = 1.0;        % number of complete gait cycles to generate

% --- Primary spatiotemporal parameters (normal gait) ---
gait_speed   = 1.40;    % m/s  |  Self-selected comfortable walking speed
step_length  = 0.73;    % m    |  Nominal step length for healthy adults

% --- Amplitude and smoothness ---
amplitude_scale = 1.0;  % 1.0 = 100% of nominal ROM (no scaling applied)
smoothness      = 8;    % 1-10 | Balanced smoothing for typical gait

% --- Output options ---
plot_results      = true;   % generate trajectory visualisation figures
verify_continuous = true;   % plot two consecutive cycles to check periodicity
save_data         = true;   % export .mat / .csv / .txt / arduino files
save_data_format  = 'deg';  % 'deg' = degrees  |  'rad' = radians

% -------------------------------------------------------------------------
%  PRINT CONFIGURATION SUMMARY
% -------------------------------------------------------------------------
fprintf('  Configuration Summary\n');
fprintf('  %s\n', repmat('-', 1, 45));
fprintf('  %-25s  %g points\n',  'Trajectory points:',  n_points);
fprintf('  %-25s  %.1f cycles\n','Gait cycles:',         n_cycles);
fprintf('  %-25s  %.2f m/s\n',   'Gait speed  [*KEY*]:', gait_speed);
fprintf('  %-25s  %.2f m\n',     'Step length [*KEY*]:', step_length);
fprintf('  %-25s  %.1f (%.0f%%)\n','Amplitude scale:',   amplitude_scale, amplitude_scale*100);
fprintf('  %-25s  %d / 10\n',    'Smoothness level:',    smoothness);
fprintf('  %-25s  %s\n',         'Output units:',         save_data_format);
fprintf('\n');

% -------------------------------------------------------------------------
%  GENERATE TRAJECTORIES
% -------------------------------------------------------------------------
generate_exoskeleton_trajectories_backend( ...
    n_points, n_cycles, gait_speed, step_length, amplitude_scale, ...
    smoothness, plot_results, save_data, verify_continuous, save_data_format);

% -------------------------------------------------------------------------
%  POST-GENERATION NOTES
% -------------------------------------------------------------------------
fprintf('\n  Clinical Notes (Normal Gait):\n');
fprintf('  • Peak hip flexion ~32 deg, peak hip extension ~-19 deg\n');
fprintf('  • Peak knee flexion during swing ~65 deg\n');
fprintf('  • Ankle dorsiflexion ~13 deg; push-off plantarflexion ~-18 deg\n');
fprintf('  • This is the standard rehabilitation target trajectory\n');
fprintf('  • Use amplitude_scale < 1.0 to set sub-maximal ROM goals\n\n');
