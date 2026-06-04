%% example_slow_gait.m
%  Example: Slow / Pathological Gait Trajectory Generation
%
%  DESCRIPTION:
%    Generates reference joint trajectories representative of elderly or
%    pathological walking.  Compared to normal gait, slow gait is
%    characterised by:
%      - Reduced walking speed     (~0.89 m/s vs 1.40 m/s)
%      - Shorter step length       (~0.58 m  vs 0.73 m)
%      - Decreased joint ROM       (especially hip and knee)
%      - Longer stance phase       (~65% of the gait cycle)
%      - Greater double-support time
%
%  CLINICAL RELEVANCE:
%    These parameters are useful for programming exoskeletons intended for
%    early-stage rehabilitation, elderly patients, or individuals with
%    neurological or musculoskeletal impairments.
%
%  FUNCTION SIGNATURE (for reference):
%    generate_exoskeleton_trajectories_backend(
%        n_points, n_cycles, gait_speed, step_length, amplitude_scale,
%        smoothness, plot_results, save_data, verify_continuous,
%        save_data_format)
%
%  REFERENCES:
%    [1] Oberg et al. (1993) - Basic gait parameters: reference data for
%        normal subjects, 10-79 years of age. J Rehabil Res Dev.
%    [2] Lim et al. (2017)   - Effects of step length and step frequency
%        on lower-limb muscle function in human gait. J Biomech.
% =========================================================================

clc;
fprintf('\n');
fprintf('╔══════════════════════════════════════════════════════════════════╗\n');
fprintf('║              EXAMPLE: SLOW / PATHOLOGICAL GAIT                  ║\n');
fprintf('╚══════════════════════════════════════════════════════════════════╝\n\n');

% -------------------------------------------------------------------------
%  PARAMETERS
% -------------------------------------------------------------------------

% --- Temporal resolution ---
n_points  = 500;        % points per trajectory vector
n_cycles  = 1.0;        % number of complete gait cycles to generate

% --- Primary spatiotemporal parameters (slow gait) ---
gait_speed   = 0.89;    % m/s  |  Typical slow / elderly walking speed
step_length  = 0.58;    % m    |  Shorter step length associated with slow gait

% --- Amplitude and smoothness ---
amplitude_scale = 1.0;  % 1.0 = 100% of nominal ROM (no scaling applied)
smoothness      = 9;    % 1-10 | Higher smoothness suits slow mechanical motion

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
fprintf('\n  Clinical Notes (Slow Gait):\n');
fprintf('  • Reduced hip extension due to shortened step length\n');
fprintf('  • Lower peak knee flexion during swing (~55 deg vs ~65 deg)\n');
fprintf('  • Decreased ankle push-off power\n');
fprintf('  • Prolonged double-support time increases stability\n');
fprintf('  • Suitable for: early rehabilitation, elderly, neurological impairment\n\n');
