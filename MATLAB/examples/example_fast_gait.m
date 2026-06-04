%% example_fast_gait.m
%  Example: Fast / Brisk Walking Gait Trajectory Generation
%
%  DESCRIPTION:
%    Generates reference joint trajectories for brisk or athletic walking.
%    Fast gait demands greater joint excursions and faster segment
%    accelerations compared to normal walking.  Key characteristics:
%      - Elevated walking speed       (~2.02 m/s)
%      - Longer step length           (~0.87 m)
%      - Increased hip and knee ROM
%      - Enhanced ankle push-off contribution
%      - Reduced stance phase (~58% of the gait cycle)
%      - Minimal double-support time (~10% of the gait cycle)
%
%  CLINICAL RELEVANCE:
%    Fast gait trajectories are useful for:
%      - Advanced-stage rehabilitation where near-normal function is restored
%      - Exoskeleton augmentation for healthy users (assistive / augmentative)
%      - Benchmarking actuator and control system performance at high loads
%
%  FUNCTION SIGNATURE (for reference):
%    generate_exoskeleton_trajectories_backend(
%        n_points, n_cycles, gait_speed, step_length, amplitude_scale,
%        smoothness, plot_results, save_data, verify_continuous,
%        save_data_format)
%
%  REFERENCES:
%    [1] Lim et al. (2017)   - Effects of step length and step frequency
%        on lower-limb muscle function in human gait. J Biomech.
%    [2] Kwon et al. (2015)  - Changes of kinematic parameters of lower
%        extremities with gait speed: a 3D motion analysis study.
%        J Phys Ther Sci.
%    [3] Winter (1991) - The Biomechanics and Motor Control of Human Gait.
%        University of Waterloo Press.
% =========================================================================

clc;
fprintf('\n');
fprintf('╔══════════════════════════════════════════════════════════════════╗\n');
fprintf('║              EXAMPLE: FAST / BRISK WALKING GAIT                 ║\n');
fprintf('╚══════════════════════════════════════════════════════════════════╝\n\n');

% -------------------------------------------------------------------------
%  PARAMETERS
% -------------------------------------------------------------------------

% --- Temporal resolution ---
n_points  = 500;        % points per trajectory vector
n_cycles  = 1.0;        % number of complete gait cycles to generate

% --- Primary spatiotemporal parameters (fast gait) ---
gait_speed   = 2.02;    % m/s  |  Brisk walking speed
step_length  = 0.87;    % m    |  Extended step length at higher speed

% --- Amplitude and smoothness ---
amplitude_scale = 1.0;  % 1.0 = 100% of nominal ROM (no scaling applied)
smoothness      = 7;    % 1-10 | Slightly lower smoothing preserves faster
                        %        transitions characteristic of brisk gait

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
fprintf('\n  Clinical Notes (Fast Gait):\n');
fprintf('  • Peak hip flexion increases to ~38 deg; extension to ~-24 deg\n');
fprintf('  • Peak knee flexion during swing reaches ~73 deg\n');
fprintf('  • Ankle push-off plantarflexion deepens to ~-22 deg\n');
fprintf('  • Higher joint velocities: verify actuator speed limits before use\n');
fprintf('  • Suitable for: late-stage rehab, augmentation, system benchmarking\n\n');
