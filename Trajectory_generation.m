function [hip_trajectory, knee_trajectory, ankle_trajectory, time_vector] = generate_exoskeleton_trajectories(varargin)
% GENERATE_EXOSKELETON_TRAJECTORIES - Generate smooth reference trajectories for lower limb exoskeleton
%
% This function generates smooth, physiologically accurate reference trajectories
% for hip, knee, and ankle joints in the sagittal plane for exoskeleton control.
%
% SYNTAX:
%   [hip, knee, ankle, time] = generate_exoskeleton_trajectories()
%   [hip, knee, ankle, time] = generate_exoskeleton_trajectories('Parameter', Value)
%
% PARAMETERS:
%   'n_points'     - Number of trajectory points (default: 500)
%   'n_cycles'     - Number of gait cycles (default: 1.0)
%   'gait_speed'   - Gait speed in m/s (default: 1.2)
%   'step_length'  - Step length in m (default: 0.7)
%   'smoothness'   - Smoothness factor 1-10 (default: 8)
%   'plot_results' - Show plots (default: true)
%   'save_data'    - Save to file (default: true)
%   'verify_continuous'    - Generate plots to check continuity of period signals (default: true)
%   'save_data_format'    - Format to save trajectories (deg or rad) (default: 'rad')
%
% OUTPUTS:
%   hip_trajectory   - 500x1 vector of hip angles (degrees)
%   knee_trajectory  - 500x1 vector of knee angles (degrees) 
%   ankle_trajectory - 500x1 vector of ankle angles (degrees)
%   time_vector      - 500x1 time vector (seconds)
%
% JOINT CONVENTIONS:
%   Hip:   Positive = flexion, Negative = extension
%   Knee:  Positive = flexion, Negative = extension
%   Ankle: Positive = dorsiflexion, Negative = plantarflexion
%
% Example:
%   [hip, knee, ankle, t] = generate_exoskeleton_trajectories('gait_speed', 1.0, 'smoothness', 9);
%
% Author: Rafael Pérez-San Lázaro
% Date: 2026

%% Parse input parameters
close all
p = inputParser;
addParameter(p, 'n_points', 500, @(x) x > 0);
addParameter(p, 'n_cycles', 1, @(x) x > 0);
addParameter(p, 'gait_speed', 1.2, @(x) x > 0);  % m/s
addParameter(p, 'step_length', 0.7, @(x) x > 0); % m
addParameter(p, 'smoothness', 8, @(x) x >= 1 && x <= 10);
addParameter(p, 'plot_results', true, @islogical);
addParameter(p, 'save_data', true, @islogical);
addParameter(p, 'verify_continuous', true, @islogical);
addParameter(p, 'save_data_format', 'rad');
parse(p, varargin{:});

n_points = p.Results.n_points;
n_cycles = p.Results.n_cycles;
gait_speed = p.Results.gait_speed;
step_length = p.Results.step_length;
smoothness = p.Results.smoothness;
plot_results = p.Results.plot_results;
save_data = p.Results.save_data;
verify_continuous = p.Results.verify_continuous;
save_data_format = p.Results.save_data_format;

%% Gait timing parameters
gait_cycle_time = step_length / gait_speed;  % seconds per cycle
total_time = n_cycles * gait_cycle_time;
time_vector = linspace(0, total_time, n_points)';

% Gait phase percentages
heel_strike = 0;      % 0% of cycle
toe_off = 60;         % 60% of cycle  
swing_phase = 40;     % 40% of cycle duration

%% Define key gait events and joint angles
% Percentage of gait cycle for key events
gait_events = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100];

% Hip joint angles at key events (degrees)
% Range: -20° (extension) to +35° (flexion)
hip_keypoints = [20, 10, 5, -5, -15, -20, -10, 10, 25, 35, 20];

% Knee joint angles at key events (degrees) 
% Range: 0° (extension) to +70° (flexion)
knee_keypoints = [10, 12, 20, 15, 5, 0, 15, 40, 70, 25, 10];

% Ankle joint angles at key events (degrees)
% Range: -20° (plantarflexion) to +15° (dorsiflexion)
ankle_keypoints = [0, -7, -10, -15, -20, -18, -10, 5, 10, 15, 0];

%% Generate smooth trajectories using spline interpolation
% Convert gait events to actual time points across all cycles
cycle_duration = 100;  % percentage points per cycle
full_cycle_events = [];
full_hip_points = [];
full_knee_points = [];
full_ankle_points = [];

for cycle = 0:n_cycles-1
    cycle_offset = cycle * cycle_duration;
    if cycle < n_cycles - 1 || mod(n_cycles, 1) == 0
        % Full cycle
        cycle_events = gait_events + cycle_offset;
        full_cycle_events = [full_cycle_events, cycle_events(1:end-1)];
        full_hip_points = [full_hip_points, hip_keypoints(1:end-1)];
        full_knee_points = [full_knee_points, knee_keypoints(1:end-1)];
        full_ankle_points = [full_ankle_points, ankle_keypoints(1:end-1)];
    else
        % Partial cycle
        partial_length = (n_cycles - cycle) * cycle_duration;
        partial_events_idx = gait_events <= partial_length;
        cycle_events = gait_events(partial_events_idx) + cycle_offset;
        full_cycle_events = [full_cycle_events, cycle_events];
        full_hip_points = [full_hip_points, hip_keypoints(partial_events_idx)];
        full_knee_points = [full_knee_points, knee_keypoints(partial_events_idx)];
        full_ankle_points = [full_ankle_points, ankle_keypoints(partial_events_idx)];
    end
end

% Add final point
full_cycle_events = [full_cycle_events, n_cycles * cycle_duration];
full_hip_points = [full_hip_points, hip_keypoints(1)];
full_knee_points = [full_knee_points, knee_keypoints(1)];
full_ankle_points = [full_ankle_points, ankle_keypoints(1)];

% Convert percentage to actual time
time_keypoints = full_cycle_events * total_time / (n_cycles * cycle_duration);

% Generate smooth trajectories using cubic spline with tension control
smoothness_factor = smoothness / 10;  % Convert to 0.1-1.0 range

% Create smooth splines
hip_trajectory = smooth_spline_interpolation(time_keypoints, full_hip_points, time_vector, smoothness_factor);
knee_trajectory = smooth_spline_interpolation(time_keypoints, full_knee_points, time_vector, smoothness_factor);
ankle_trajectory = smooth_spline_interpolation(time_keypoints, full_ankle_points, time_vector, smoothness_factor);

% Apply additional smoothing filter for exoskeleton use
if smoothness >= 7
    filter_order = 3;
    cutoff_freq = 0.1;  % Normalized frequency
    [b, a] = butter(filter_order, cutoff_freq, 'low');
    hip_trajectory = filtfilt(b, a, hip_trajectory);
    knee_trajectory = filtfilt(b, a, knee_trajectory);
    ankle_trajectory = filtfilt(b, a, ankle_trajectory);
end

%% Display trajectory information
fprintf('Lower Limb Exoskeleton Reference Trajectories\n');
fprintf('=============================================\n');
fprintf('Configuration:\n');
fprintf('  Points per trajectory: %d\n', n_points);
fprintf('  Number of gait cycles: %.1f\n', n_cycles);
fprintf('  Gait speed: %.1f m/s\n', gait_speed);
fprintf('  Step length: %.1f m\n', step_length);
fprintf('  Cycle duration: %.2f s\n', gait_cycle_time);
fprintf('  Total duration: %.2f s\n', total_time);
fprintf('  Smoothness level: %d/10\n', smoothness);
fprintf('\nJoint Ranges:\n');
fprintf('  Hip:   %.1f° to %.1f° (%.1f° ROM)\n', min(hip_trajectory), max(hip_trajectory), range(hip_trajectory));
fprintf('  Knee:  %.1f° to %.1f° (%.1f° ROM)\n', min(knee_trajectory), max(knee_trajectory), range(knee_trajectory));
fprintf('  Ankle: %.1f° to %.1f° (%.1f° ROM)\n', min(ankle_trajectory), max(ankle_trajectory), range(ankle_trajectory));

%% Create comprehensive visualizations
if plot_results
    create_exoskeleton_plots(hip_trajectory, knee_trajectory, ankle_trajectory, time_vector, gait_cycle_time);
end

%% Visualize continuity of trajectories
if verify_continuous
    verify_continuous_data(hip_trajectory, knee_trajectory, ankle_trajectory, time_vector, gait_cycle_time);
end

%% Save data if requested
if save_data
    save_exoskeleton_data(hip_trajectory, knee_trajectory, ankle_trajectory, time_vector, gait_speed, step_length, gait_cycle_time, plot_results, save_data_format);
end

end

%% Supporting Functions

function trajectory = smooth_spline_interpolation(time_points, angle_points, time_vector, smoothness_factor)
% Create smooth spline interpolation with tension control
    % Use pchip for shape-preserving interpolation, then smooth
    rough_traj = pchip(time_points, angle_points, time_vector);
    
    % Apply smoothing based on smoothness factor
    if smoothness_factor >= 0.7
        % High smoothness - use moving average + spline smoothing
        window_size = max(3, round(length(time_vector) * 0.02));
        if mod(window_size, 2) == 0
            window_size = window_size + 1;  % Ensure odd window size
        end
        trajectory = smooth(rough_traj, window_size, 'sgolay', 3);
    else
        % Lower smoothness - minimal filtering
        trajectory = smooth(rough_traj, 'rloess');
    end
end

function create_exoskeleton_plots(hip_traj, knee_traj, ankle_traj, time_vec, cycle_time)
% Create comprehensive plots for exoskeleton trajectory analysis

    figure('Position', [100, 100, 1400, 900]);
    
    % Colors for each joint
    colors = struct('hip', [0.8, 0.2, 0.2], 'knee', [0.2, 0.6, 0.8], 'ankle', [0.2, 0.8, 0.2]);
    
    % Plot 1: All trajectories vs time
    subplot(2, 3, 1);
    plot(time_vec, hip_traj, 'Color', colors.hip, 'LineWidth', 2.5); hold on;
    plot(time_vec, knee_traj, 'Color', colors.knee, 'LineWidth', 2.5);
    plot(time_vec, ankle_traj, 'Color', colors.ankle, 'LineWidth', 2.5);
    xlabel('Time (s)'); ylabel('Joint Angle (degrees)');
    title('All Joint Trajectories vs Time');
    legend('Hip', 'Knee', 'Ankle', 'Location', 'best');
    grid on; axis tight;
    
    % Plot 2: Single gait cycle
    subplot(2, 3, 2);
    cycle_samples = round(length(time_vec) / (max(time_vec) / cycle_time));
    cycle_percent = linspace(0, 100, cycle_samples);
    plot(cycle_percent, hip_traj(1:cycle_samples), 'Color', colors.hip, 'LineWidth', 2.5); hold on;
    plot(cycle_percent, knee_traj(1:cycle_samples), 'Color', colors.knee, 'LineWidth', 2.5);
    plot(cycle_percent, ankle_traj(1:cycle_samples), 'Color', colors.ankle, 'LineWidth', 2.5);
    temp_hip = hip_traj(1:cycle_samples);
    temp_knee = knee_traj(1:cycle_samples);
    temp_ankle = ankle_traj(1:cycle_samples);

    % Add gait phase indicators
    xline(60, 'k--', 'Alpha', 0.7, 'LineWidth', 1.5, 'DisplayName', 'Toe Off');
    xline(0, 'k:', 'Alpha', 0.7, 'LineWidth', 1.5, 'DisplayName', 'Heel Strike');
    
    xlabel('Gait Cycle (%)'); ylabel('Joint Angle (degrees)');
    title('Single Gait Cycle Pattern');
    legend('Hip', 'Knee', 'Ankle', 'Toe Off', 'Heel Strike', 'Location', 'best');
    grid on; axis tight;
    
    % Plot 3: Hip trajectory detail
    subplot(2, 3, 3);
    plot(time_vec, hip_traj, 'Color', colors.hip, 'LineWidth', 3);
    xlabel('Time (s)'); ylabel('Hip Angle (degrees)');
    title('Hip Joint Trajectory');
    grid on; axis tight;
    yline(0, 'k--', 'Alpha', 0.5, 'DisplayName', 'Neutral');
    legend('Hip Flexion/Extension', 'Neutral Position');
    
    % Plot 4: Knee trajectory detail
    subplot(2, 3, 4);
    plot(time_vec, knee_traj, 'Color', colors.knee, 'LineWidth', 3);
    xlabel('Time (s)'); ylabel('Knee Angle (degrees)');
    title('Knee Joint Trajectory');
    grid on; axis tight;
    yline(0, 'k--', 'Alpha', 0.5, 'DisplayName', 'Full Extension');
    legend('Knee Flexion', 'Full Extension');
    
    % Plot 5: Ankle trajectory detail  
    subplot(2, 3, 5);
    plot(time_vec, ankle_traj, 'Color', colors.ankle, 'LineWidth', 3);
    xlabel('Time (s)'); ylabel('Ankle Angle (degrees)');
    title('Ankle Joint Trajectory');
    grid on; axis tight;
    yline(0, 'k--', 'Alpha', 0.5, 'DisplayName', 'Neutral');
    legend('Dorsi/Plantarflexion', 'Neutral Position');
    
    % Plot 6: Joint coordination plot
    subplot(2, 3, 6);
    % Create 3D trajectory in joint space
    plot3(hip_traj, knee_traj, ankle_traj, 'k-', 'LineWidth', 2);
    xlabel('Hip Angle (deg)'); ylabel('Knee Angle (deg)'); zlabel('Ankle Angle (deg)');
    title('Joint Coordination Pattern');
    grid on; view(45, 30);
    
    sgtitle('Lower Limb Exoskeleton Reference Trajectories', 'FontSize', 16, 'FontWeight', 'bold');
end

function verify_continuous_data(hip_traj, knee_traj, ankle_traj, time_vec, cycle_time)
    figure('Position', [100, 100, 600, 350]);
    % Colors for each joint
    colors = struct('hip', [0.8, 0.2, 0.2], 'knee', [0.2, 0.6, 0.8], 'ankle', [0.2, 0.8, 0.2]);
    cycle_samples = round(length(time_vec) / (max(time_vec) / cycle_time));
    plot([hip_traj(1:cycle_samples);hip_traj(1:cycle_samples)], 'Color', colors.hip, 'LineWidth', 2.5); hold on;
    plot([knee_traj(1:cycle_samples);knee_traj(1:cycle_samples)], 'Color', colors.knee, 'LineWidth', 2.5);
    plot([ankle_traj(1:cycle_samples);ankle_traj(1:cycle_samples)], 'Color', colors.ankle, 'LineWidth', 2.5);
    legend('Hip', 'Knee', 'Ankle');
    grid on
    sgtitle('Cycles', 'FontSize', 10, 'FontWeight', 'bold');
end

function save_exoskeleton_data(hip_traj, knee_traj, ankle_traj, time_vec, gait_speed, step_length, cycle_time, plot_results, save_data_format)
% Save trajectory data in multiple formats for exoskeleton use

    % Save as rad or deg
    if (save_data_format == "rad")
        hip_traj = deg2rad(hip_traj);
        knee_traj = deg2rad(knee_traj);
        ankle_traj = deg2rad(ankle_traj);
        units = "radians";
    else
        units = "degrees";
    end

    % Create data structure
    exoskeleton_data = struct();
    exoskeleton_data.time = time_vec;
    exoskeleton_data.hip_angle = hip_traj;
    exoskeleton_data.knee_angle = knee_traj;
    exoskeleton_data.ankle_angle = ankle_traj;
    exoskeleton_data.parameters.gait_speed = gait_speed;
    exoskeleton_data.parameters.step_length = step_length;
    exoskeleton_data.parameters.sample_rate = length(time_vec) / max(time_vec);
    exoskeleton_data.info.units = units;
    exoskeleton_data.info.conventions = struct(...
        'hip', 'positive=flexion, negative=extension', ...
        'knee', 'positive=flexion, negative=extension', ...
        'ankle', 'positive=dorsiflexion, negative=plantarflexion');
    
    % Save as .mat file
    save('exoskeleton_trajectories.mat', 'exoskeleton_data');
    fprintf('\nData saved to: exoskeleton_trajectories.mat\n');
    
    % Save as CSV for other applications
    trajectory_table = table(time_vec, hip_traj, knee_traj, ankle_traj, ...
        'VariableNames', {'Time_s', 'Hip', 'Knee', 'Ankle'});
    writetable(trajectory_table, 'exoskeleton_trajectories.csv');
    fprintf('Data exported to: exoskeleton_trajectories.csv\n');
    
    % Save as text file with metadata
    fid = fopen('exoskeleton_trajectories.txt', 'w');
    fprintf(fid, '%% Lower Limb Exoskeleton Reference Trajectories\n');
    fprintf(fid, '%% Generated: %s\n', datestr(now));
    fprintf(fid, '%% Gait Speed: %.2f m/s\n', gait_speed);
    fprintf(fid, '%% Step Length: %.2f m\n', step_length);
    fprintf(fid, '%% Units: %s\n', units);
    fprintf(fid, '%% Sample Rate: %.1f Hz\n', length(time_vec) / max(time_vec));
    fprintf(fid, '%% Columns: Time(s), Hip, Knee, Ankle\n');
    for i = 1:length(time_vec)
        fprintf(fid, '%.4f\t%.2f\t%.2f\t%.2f\n', time_vec(i), hip_traj(i), knee_traj(i), ankle_traj(i));
    end
    fclose(fid);
    fprintf('Data exported to: exoskeleton_trajectories.txt\n');

    % Save as text file for Arduino for 10% of data from original vector
    hip_traj = hip_traj(1:10:length(hip_traj)) * 0.75;
    knee_traj = knee_traj(1:10:length(knee_traj)) * 0.75;
    ankle_traj = ankle_traj(1:10:length(ankle_traj)) * 0.75;
    time_vec = time_vec(1:10:length(time_vec));
    fid = fopen('exoskeleton_trajectories_arduino.txt', 'w');
    fprintf(fid, 'hip_r = {');
    for i = 1:length(time_vec)
        if (i == length(time_vec))
            fprintf(fid, '%.3f', hip_traj(i));
        else
            fprintf(fid, '%.3f,', hip_traj(i));
        end
    end
    fprintf(fid, '};\n');
    fprintf(fid, 'knee_r = {');
    for i = 1:length(time_vec)
        if (i == length(time_vec))
            fprintf(fid, '%.3f', knee_traj(i));
        else
            fprintf(fid, '%.3f,', knee_traj(i));
        end
    end
    fprintf(fid, '};\n');
    fprintf(fid, 'ankle_r = {');
    for i = 1:length(time_vec)
        if (i == length(time_vec))
            fprintf(fid, '%.3f', ankle_traj(i));
        else
            fprintf(fid, '%.3f,', ankle_traj(i));
        end
    end
    fprintf(fid, '};\n');
    halfLength = floor(length(hip_traj) / 2);
    shiftedVectorHip = circshift(hip_traj, halfLength);
    fprintf(fid, 'hip_l = {');
    for i = 1:length(time_vec)
        if (i == length(time_vec))
            fprintf(fid, '%.3f', shiftedVectorHip(i));
        else
            fprintf(fid, '%.3f,', shiftedVectorHip(i));
        end
    end
    fprintf(fid, '};\n');
    halfLength = floor(length(knee_traj) / 2);
    shiftedVectorKnee = circshift(knee_traj, halfLength);
    fprintf(fid, 'knee_l = {');
    for i = 1:length(time_vec)
        if (i == length(time_vec))
            fprintf(fid, '%.3f', shiftedVectorKnee(i));
        else
            fprintf(fid, '%.3f,', shiftedVectorKnee(i));
        end
    end
    fprintf(fid, '};\n');
    halfLength = floor(length(ankle_traj) / 2);
    shiftedVectorAnkle = circshift(ankle_traj, halfLength);
    fprintf(fid, 'ankle_l = {');
    for i = 1:length(time_vec)
        if (i == length(time_vec))
            fprintf(fid, '%.3f', shiftedVectorAnkle(i));
        else
            fprintf(fid, '%.3f,', shiftedVectorAnkle(i));
        end
    end
    fprintf(fid, '};\n');
    if plot_results
        figure('Position', [100, 100, 1100, 350]);
        % Colors for each joint
        colors = struct('hip', [0.8, 0.2, 0.2], 'knee', [0.2, 0.6, 0.8], 'ankle', [0.2, 0.8, 0.2]);
        subplot(1,3,1)
        plot([hip_traj], 'Color', colors.hip, 'LineWidth', 2.5); hold on;
        plot([shiftedVectorHip], '-.', 'Color', colors.hip, 'LineWidth', 2.5);
        legend('Original', 'Shifted');
        title('Hip');
        grid on
        subplot(1,3,2)
        plot([knee_traj], 'Color', colors.knee, 'LineWidth', 2.5); hold on;
        plot([shiftedVectorKnee], '-.', 'Color', colors.knee, 'LineWidth', 2.5);
        legend('Original', 'Shifted');
        title('Knee');
        grid on
        subplot(1,3,3)
        plot([ankle_traj], 'Color', colors.ankle, 'LineWidth', 2.5); hold on;
        plot([shiftedVectorAnkle], '-.', 'Color', colors.ankle, 'LineWidth', 2.5);
        legend('Original', 'Shifted');
        title('Ankle');
        grid on
        sgtitle('Cycles', 'FontSize', 10, 'FontWeight', 'bold');
    end
    fclose(fid);
    fprintf('Data exported to: exoskeleton_trajectories_arduino.txt');
end

function validate_trajectories()
% Validate the generated trajectories for exoskeleton use

    fprintf('\nValidating trajectories for exoskeleton control...\n');
    
    % Generate trajectories with different parameters
    [hip1, knee1, ankle1, t1] = generate_exoskeleton_trajectories('gait_speed', 0.8, 'smoothness', 9);
    [hip2, knee2, ankle2, t2] = generate_exoskeleton_trajectories('gait_speed', 1.5, 'smoothness', 8);
    
    % Check smoothness (maximum acceleration)
    dt = t1(2) - t1(1);
    hip_acc = diff(diff(hip1)) / dt^2;
    knee_acc = diff(diff(knee1)) / dt^2;
    ankle_acc = diff(diff(ankle1)) / dt^2;
    
    fprintf('Trajectory validation results:\n');
    fprintf('  Maximum hip acceleration: %.1f deg/s²\n', max(abs(hip_acc)));
    fprintf('  Maximum knee acceleration: %.1f deg/s²\n', max(abs(knee_acc)));
    fprintf('  Maximum ankle acceleration: %.1f deg/s²\n', max(abs(ankle_acc)));
    
    % Check for discontinuities
    hip_jumps = max(abs(diff(hip1)));
    knee_jumps = max(abs(diff(knee1)));
    ankle_jumps = max(abs(diff(ankle1)));
    
    fprintf('  Maximum step discontinuity:\n');
    fprintf('    Hip: %.3f deg\n', hip_jumps);
    fprintf('    Knee: %.3f deg\n', knee_jumps);
    fprintf('    Ankle: %.3f deg\n', ankle_jumps);
    
    if max([hip_jumps, knee_jumps, ankle_jumps]) < 2.0
        fprintf('Trajectories are smooth enough for exoskeleton control\n');
    else
        fprintf('Consider increasing smoothness parameter\n');
    end
end