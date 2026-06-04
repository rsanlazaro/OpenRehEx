%% run_all_examples.m
%  Master script that sequentially runs all three gait example scripts.
%
%  USAGE:
%    Simply run this file from the MATLAB command window or editor.
%    Each example generates its own trajectories, plots, and output files.
%
%  EXAMPLES INCLUDED:
%    1. example_slow_gait.m   - Elderly / pathological walking pattern
%    2. example_normal_gait.m - Healthy adult walking pattern
%    3. example_fast_gait.m   - Brisk / athletic walking pattern
%
%  REQUIREMENTS:
%    - generate_exoskeleton_trajectories_backend() must be on the MATLAB path
%      (defined inside ExoskeletonTrajectoryApp.m or extracted separately)
%
%  NOTE:
%    Output files for each case are saved in the current working directory.
%    Rename or move them between examples if you want to keep all three sets.
% =========================================================================

clc;
fprintf('\n');
fprintf('╔══════════════════════════════════════════════════════════════════╗\n');
fprintf('║        EXOSKELETON TRAJECTORY GENERATOR - EXAMPLES RUNNER       ║\n');
fprintf('╚══════════════════════════════════════════════════════════════════╝\n\n');

%% Example 1 - Slow Gait
fprintf('▶  Running Example 1: Slow Gait...\n');
fprintf('%s\n', repmat('─', 1, 60));
example_slow_gait;
fprintf('\n✓  Example 1 complete.\n\n');

%% Example 2 - Normal Gait
fprintf('▶  Running Example 2: Normal Gait...\n');
fprintf('%s\n', repmat('─', 1, 60));
example_normal_gait;
fprintf('\n✓  Example 2 complete.\n\n');

%% Example 3 - Fast Gait
fprintf('▶  Running Example 3: Fast Gait...\n');
fprintf('%s\n', repmat('─', 1, 60));
example_fast_gait;
fprintf('\n✓  Example 3 complete.\n\n');

fprintf('╔══════════════════════════════════════════════════════════════════╗\n');
fprintf('║                  ALL EXAMPLES FINISHED                          ║\n');
fprintf('╚══════════════════════════════════════════════════════════════════╝\n\n');
