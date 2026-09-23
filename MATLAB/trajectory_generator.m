classdef ExoskeletonTrajectoryApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        TitleLabel                      matlab.ui.control.Label
        SubtitleLabel                   matlab.ui.control.Label
        HelpButton                      matlab.ui.control.Button

        % Panels
        TrajectoryPanel                 matlab.ui.container.Panel
        OutputPanel                     matlab.ui.container.Panel
        PresetsPanel                    matlab.ui.container.Panel

        % Trajectory Parameters
        PointsLabel                     matlab.ui.control.Label
        PointsField                     matlab.ui.control.NumericEditField
        PointsUnitLabel                 matlab.ui.control.Label

        CyclesLabel                     matlab.ui.control.Label
        CyclesField                     matlab.ui.control.NumericEditField
        CyclesUnitLabel                 matlab.ui.control.Label

        SpeedLabel                      matlab.ui.control.Label
        SpeedField                      matlab.ui.control.NumericEditField
        SpeedUnitLabel                  matlab.ui.control.Label

        StepLengthLabel                 matlab.ui.control.Label
        StepLengthField                 matlab.ui.control.NumericEditField
        StepLengthUnitLabel             matlab.ui.control.Label

        AmplitudeLabel                  matlab.ui.control.Label
        AmplitudeField                  matlab.ui.control.NumericEditField
        AmplitudeUnitLabel              matlab.ui.control.Label

        SmoothnessLabel                 matlab.ui.control.Label
        SmoothnessSlider                matlab.ui.control.Slider
        SmoothnessValueLabel            matlab.ui.control.Label

        % Output Options
        PlotResultsCheckBox             matlab.ui.control.CheckBox
        VerifyContinuousCheckBox        matlab.ui.control.CheckBox
        SaveDataCheckBox                matlab.ui.control.CheckBox

        FormatLabel                     matlab.ui.control.Label
        FormatButtonGroup               matlab.ui.container.ButtonGroup
        DegreesRadioButton              matlab.ui.control.RadioButton
        RadiansRadioButton              matlab.ui.control.RadioButton

        % Preset Buttons
        NormalGaitButton                matlab.ui.control.Button
        SlowGaitButton                  matlab.ui.control.Button
        FastGaitButton                  matlab.ui.control.Button

        % Action Buttons
        GenerateButton                  matlab.ui.control.Button
        ResetButton                     matlab.ui.control.Button
        CloseButton                     matlab.ui.control.Button
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 620 780];
            app.UIFigure.Name = 'Lower Limb Exoskeleton Trajectory Generator';
            app.UIFigure.Resize = 'off';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x'};
            app.GridLayout.RowHeight = {40, 25, 275, 190, 90, 70};
            app.GridLayout.Padding = [10 10 10 10];
            app.GridLayout.RowSpacing = 10;

            % Create TitleLabel
            app.TitleLabel = uilabel(app.GridLayout);
            app.TitleLabel.Layout.Row = 1;
            app.TitleLabel.Layout.Column = 1;
            app.TitleLabel.FontSize = 20;
            app.TitleLabel.FontWeight = 'bold';
            app.TitleLabel.FontColor = [0.2 0.4 0.6];
            app.TitleLabel.HorizontalAlignment = 'center';
            app.TitleLabel.Text = 'Lower Limb Exoskeleton Trajectory Generator';

            % Create SubtitleLabel
            app.SubtitleLabel = uilabel(app.GridLayout);
            app.SubtitleLabel.Layout.Row = 2;
            app.SubtitleLabel.Layout.Column = 1;
            app.SubtitleLabel.FontSize = 12;
            app.SubtitleLabel.FontColor = [0.4 0.4 0.4];
            app.SubtitleLabel.HorizontalAlignment = 'center';
            app.SubtitleLabel.Text = 'Generate smooth reference trajectories for rehabilitation robotics';

            % Create TrajectoryPanel
            app.TrajectoryPanel = uipanel(app.GridLayout);
            app.TrajectoryPanel.Title = 'Trajectory Parameters';
            app.TrajectoryPanel.FontWeight = 'bold';
            app.TrajectoryPanel.FontSize = 12;
            app.TrajectoryPanel.Layout.Row = 3;
            app.TrajectoryPanel.Layout.Column = 1;

            % Create PointsLabel
            app.PointsLabel = uilabel(app.TrajectoryPanel);
            app.PointsLabel.Position = [20 215 180 22];
            app.PointsLabel.Text = 'Number of Points:';
            app.PointsLabel.FontSize = 11;

            % Create PointsField
            app.PointsField = uieditfield(app.TrajectoryPanel, 'numeric');
            app.PointsField.Position = [210 215 100 22];
            app.PointsField.Value = 500;
            app.PointsField.Limits = [50 2000];
            app.PointsField.RoundFractionalValues = 'on';
            app.PointsField.Tooltip = {'Temporal resolution (50-2000 points)'};

            % Create PointsUnitLabel
            app.PointsUnitLabel = uilabel(app.TrajectoryPanel);
            app.PointsUnitLabel.Position = [320 215 100 22];
            app.PointsUnitLabel.Text = 'points';
            app.PointsUnitLabel.FontSize = 10;
            app.PointsUnitLabel.FontColor = [0.5 0.5 0.5];

            % Create CyclesLabel
            app.CyclesLabel = uilabel(app.TrajectoryPanel);
            app.CyclesLabel.Position = [20 180 180 22];
            app.CyclesLabel.Text = 'Number of Gait Cycles:';
            app.CyclesLabel.FontSize = 11;

            % Create CyclesField
            app.CyclesField = uieditfield(app.TrajectoryPanel, 'numeric');
            app.CyclesField.Position = [210 180 100 22];
            app.CyclesField.Value = 1.0;
            app.CyclesField.Limits = [0.1 10];
            app.CyclesField.ValueDisplayFormat = '%.1f';
            app.CyclesField.Tooltip = {'Number of complete gait cycles (strides, 0.1-10)'};

            % Create CyclesUnitLabel
            app.CyclesUnitLabel = uilabel(app.TrajectoryPanel);
            app.CyclesUnitLabel.Position = [320 180 150 22];
            app.CyclesUnitLabel.Text = 'cycles (strides)';
            app.CyclesUnitLabel.FontSize = 10;
            app.CyclesUnitLabel.FontColor = [0.5 0.5 0.5];

            % Create SpeedLabel
            app.SpeedLabel = uilabel(app.TrajectoryPanel);
            app.SpeedLabel.Position = [20 145 180 22];
            app.SpeedLabel.Text = 'Gait Speed:';
            app.SpeedLabel.FontSize = 11;

            % Create SpeedField
            app.SpeedField = uieditfield(app.TrajectoryPanel, 'numeric');
            app.SpeedField.Position = [210 145 100 22];
            app.SpeedField.Value = 1.40;
            app.SpeedField.Limits = [0.1 3.0];
            app.SpeedField.ValueDisplayFormat = '%.2f';
            app.SpeedField.Tooltip = {'Walking velocity (0.1-3.0 m/s)'};

            % Create SpeedUnitLabel
            app.SpeedUnitLabel = uilabel(app.TrajectoryPanel);
            app.SpeedUnitLabel.Position = [320 145 100 22];
            app.SpeedUnitLabel.Text = 'm/s';
            app.SpeedUnitLabel.FontSize = 10;
            app.SpeedUnitLabel.FontColor = [0.5 0.5 0.5];

            % Create StepLengthLabel
            app.StepLengthLabel = uilabel(app.TrajectoryPanel);
            app.StepLengthLabel.Position = [20 110 180 22];
            app.StepLengthLabel.Text = 'Step Length:';
            app.StepLengthLabel.FontSize = 11;

            % Create StepLengthField
            app.StepLengthField = uieditfield(app.TrajectoryPanel, 'numeric');
            app.StepLengthField.Position = [210 110 100 22];
            app.StepLengthField.Value = 0.73;
            app.StepLengthField.Limits = [0.1 1.5];
            app.StepLengthField.ValueDisplayFormat = '%.2f';
            app.StepLengthField.Tooltip = {'Distance between successive left/right heel strikes (0.1-1.5 m). Stride = 2 x step.'};

            % Create StepLengthUnitLabel
            app.StepLengthUnitLabel = uilabel(app.TrajectoryPanel);
            app.StepLengthUnitLabel.Position = [320 110 200 22];
            app.StepLengthUnitLabel.Text = 'm (stride = 2 x step)';
            app.StepLengthUnitLabel.FontSize = 10;
            app.StepLengthUnitLabel.FontColor = [0.5 0.5 0.5];

            % Create AmplitudeLabel
            app.AmplitudeLabel = uilabel(app.TrajectoryPanel);
            app.AmplitudeLabel.Position = [20 75 180 22];
            app.AmplitudeLabel.Text = 'Amplitude Scale:';
            app.AmplitudeLabel.FontSize = 11;

            % Create AmplitudeField
            app.AmplitudeField = uieditfield(app.TrajectoryPanel, 'numeric');
            app.AmplitudeField.Position = [210 75 100 22];
            app.AmplitudeField.Value = 1.0;
            app.AmplitudeField.Limits = [0.1 2.0];
            app.AmplitudeField.ValueDisplayFormat = '%.2f';
            app.AmplitudeField.Tooltip = {'Amplitude scaling factor (0.1-2.0)'};

            % Create AmplitudeUnitLabel
            app.AmplitudeUnitLabel = uilabel(app.TrajectoryPanel);
            app.AmplitudeUnitLabel.Position = [320 75 200 22];
            app.AmplitudeUnitLabel.Text = '(1.0 = 100%)';
            app.AmplitudeUnitLabel.FontSize = 10;
            app.AmplitudeUnitLabel.FontColor = [0.5 0.5 0.5];

            % Create SmoothnessLabel
            app.SmoothnessLabel = uilabel(app.TrajectoryPanel);
            app.SmoothnessLabel.Position = [20 40 180 22];
            app.SmoothnessLabel.Text = 'Smoothness Level:';
            app.SmoothnessLabel.FontSize = 11;

            % Create SmoothnessSlider
            app.SmoothnessSlider = uislider(app.TrajectoryPanel);
            app.SmoothnessSlider.Position = [210 50 260 3];
            app.SmoothnessSlider.Value = 8;
            app.SmoothnessSlider.Limits = [1 10];
            app.SmoothnessSlider.MajorTicks = 1:10;
            app.SmoothnessSlider.MinorTicks = [];
            app.SmoothnessSlider.ValueChangedFcn = createCallbackFcn(app, @SmoothnessSliderValueChanged, true);
            app.SmoothnessSlider.Tooltip = {'Trajectory smoothing (1=minimal, 10=maximum)'};

            % Create SmoothnessValueLabel
            app.SmoothnessValueLabel = uilabel(app.TrajectoryPanel);
            app.SmoothnessValueLabel.Position = [480 40 80 22];
            app.SmoothnessValueLabel.Text = '8 / 10';
            app.SmoothnessValueLabel.FontSize = 11;
            app.SmoothnessValueLabel.FontWeight = 'bold';
            app.SmoothnessValueLabel.FontColor = [0.2 0.4 0.6];

            % Create OutputPanel
            app.OutputPanel = uipanel(app.GridLayout);
            app.OutputPanel.Title = 'Output Options';
            app.OutputPanel.FontWeight = 'bold';
            app.OutputPanel.FontSize = 12;
            app.OutputPanel.Layout.Row = 4;
            app.OutputPanel.Layout.Column = 1;

            % Create PlotResultsCheckBox
            app.PlotResultsCheckBox = uicheckbox(app.OutputPanel);
            app.PlotResultsCheckBox.Position = [20 130 300 22];
            app.PlotResultsCheckBox.Text = 'Generate Trajectory Plots';
            app.PlotResultsCheckBox.Value = true;
            app.PlotResultsCheckBox.FontSize = 11;
            app.PlotResultsCheckBox.Tooltip = {'Display comprehensive visualizations'};

            % Create VerifyContinuousCheckBox
            app.VerifyContinuousCheckBox = uicheckbox(app.OutputPanel);
            app.VerifyContinuousCheckBox.Position = [20 100 300 22];
            app.VerifyContinuousCheckBox.Text = 'Verify Continuity (2 Cycles)';
            app.VerifyContinuousCheckBox.Value = true;
            app.VerifyContinuousCheckBox.FontSize = 11;
            app.VerifyContinuousCheckBox.Tooltip = {'Check trajectory periodicity'};

            % Create SaveDataCheckBox
            app.SaveDataCheckBox = uicheckbox(app.OutputPanel);
            app.SaveDataCheckBox.Position = [20 70 300 22];
            app.SaveDataCheckBox.Text = 'Save Data to Files';
            app.SaveDataCheckBox.Value = true;
            app.SaveDataCheckBox.FontSize = 11;
            app.SaveDataCheckBox.Tooltip = {'Export trajectories (.mat, .csv, .txt)'};

            % Create FormatLabel
            app.FormatLabel = uilabel(app.OutputPanel);
            app.FormatLabel.Position = [20 30 180 22];
            app.FormatLabel.Text = 'Output Unit Format:';
            app.FormatLabel.FontSize = 11;

            % Create FormatButtonGroup
            app.FormatButtonGroup = uibuttongroup(app.OutputPanel);
            app.FormatButtonGroup.BorderType = 'none';
            app.FormatButtonGroup.Position = [210 25 280 30];

            % Create DegreesRadioButton
            app.DegreesRadioButton = uiradiobutton(app.FormatButtonGroup);
            app.DegreesRadioButton.Position = [10 5 100 22];
            app.DegreesRadioButton.Text = 'Degrees';
            app.DegreesRadioButton.FontSize = 10;
            app.FormatButtonGroup.SelectedObject = app.DegreesRadioButton;

            % Create RadiansRadioButton
            app.RadiansRadioButton = uiradiobutton(app.FormatButtonGroup);
            app.RadiansRadioButton.Position = [120 5 100 22];
            app.RadiansRadioButton.Text = 'Radians';
            app.RadiansRadioButton.FontSize = 10;

            % Create PresetsPanel
            app.PresetsPanel = uipanel(app.GridLayout);
            app.PresetsPanel.Title = 'Preset Configurations';
            app.PresetsPanel.FontWeight = 'bold';
            app.PresetsPanel.FontSize = 12;
            app.PresetsPanel.Layout.Row = 5;
            app.PresetsPanel.Layout.Column = 1;

            % Create SlowGaitButton
            app.SlowGaitButton = uibutton(app.PresetsPanel, 'push');
            app.SlowGaitButton.Position = [18 15 160 40];
            app.SlowGaitButton.Text = 'Slow Gait';
            app.SlowGaitButton.FontSize = 11;
            app.SlowGaitButton.ButtonPushedFcn = createCallbackFcn(app, @SlowGaitButtonPushed, true);
            app.SlowGaitButton.Tooltip = {'Load elderly/pathological gait parameters'};

            % Create NormalGaitButton
            app.NormalGaitButton = uibutton(app.PresetsPanel, 'push');
            app.NormalGaitButton.Position = [220 15 160 40];
            app.NormalGaitButton.Text = 'Normal Gait';
            app.NormalGaitButton.FontSize = 11;
            app.NormalGaitButton.ButtonPushedFcn = createCallbackFcn(app, @NormalGaitButtonPushed, true);
            app.NormalGaitButton.Tooltip = {'Load normal adult walking parameters'};

            % Create FastGaitButton
            app.FastGaitButton = uibutton(app.PresetsPanel, 'push');
            app.FastGaitButton.Position = [420 15 160 40];
            app.FastGaitButton.Text = 'Fast Gait';
            app.FastGaitButton.FontSize = 11;
            app.FastGaitButton.ButtonPushedFcn = createCallbackFcn(app, @FastGaitButtonPushed, true);
            app.FastGaitButton.Tooltip = {'Load brisk walking parameters'};

            % Create Action Buttons Panel (invisible container)
            actionPanel = uipanel(app.GridLayout);
            actionPanel.BorderType = 'none';
            actionPanel.Layout.Row = 6;
            actionPanel.Layout.Column = 1;

            % Create GenerateButton
            app.GenerateButton = uibutton(actionPanel, 'push');
            app.GenerateButton.Position = [10 5 280 60];
            app.GenerateButton.Text = 'Generate Trajectories';
            app.GenerateButton.FontSize = 14;
            app.GenerateButton.FontWeight = 'bold';
            app.GenerateButton.BackgroundColor = [0.2 0.6 0.3];
            app.GenerateButton.FontColor = [1 1 1];
            app.GenerateButton.ButtonPushedFcn = createCallbackFcn(app, @GenerateButtonPushed, true);

            % Create ResetButton
            app.ResetButton = uibutton(actionPanel, 'push');
            app.ResetButton.Position = [305 5 145 60];
            app.ResetButton.Text = 'Reset';
            app.ResetButton.FontSize = 14;
            app.ResetButton.FontWeight = 'bold';
            app.ResetButton.BackgroundColor = [0.9 0.5 0.2];
            app.ResetButton.FontColor = [1 1 1];
            app.ResetButton.ButtonPushedFcn = createCallbackFcn(app, @ResetButtonPushed, true);

            % Create CloseButton
            app.CloseButton = uibutton(actionPanel, 'push');
            app.CloseButton.Position = [465 5 125 60];
            app.CloseButton.Text = 'Close';
            app.CloseButton.FontSize = 14;
            app.CloseButton.FontWeight = 'bold';
            app.CloseButton.BackgroundColor = [0.8 0.2 0.2];
            app.CloseButton.FontColor = [1 1 1];
            app.CloseButton.ButtonPushedFcn = createCallbackFcn(app, @CloseButtonPushed, true);

            % Create HelpButton
            app.HelpButton = uibutton(app.UIFigure, 'push');
            app.HelpButton.Position = [570 735 30 30];  % Top right corner
            app.HelpButton.Text = '?';
            app.HelpButton.FontSize = 16;
            app.HelpButton.FontWeight = 'bold';
            app.HelpButton.BackgroundColor = [1 1 1];
            app.HelpButton.FontColor = [0.3 0.5 0.8];
            app.HelpButton.Tooltip = {'Click for help and information about this application'};
            app.HelpButton.ButtonPushedFcn = createCallbackFcn(app, @HelpButtonPushed, true);

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ExoskeletonTrajectoryApp

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end

    % Callbacks
    methods (Access = private)

        % Value changed function: SmoothnessSlider
        function SmoothnessSliderValueChanged(app, event)
            value = round(app.SmoothnessSlider.Value);
            app.SmoothnessValueLabel.Text = sprintf('%d / 10', value);
        end

        % Button pushed function: NormalGaitButton
        function NormalGaitButtonPushed(app, event)
            app.PointsField.Value = 500;
            app.CyclesField.Value = 1.0;
            app.SpeedField.Value = 1.40;
            app.StepLengthField.Value = 0.73;
            app.SmoothnessSlider.Value = 8;
            app.SmoothnessValueLabel.Text = '8 / 10';
            uialert(app.UIFigure, 'Normal Gait preset loaded successfully!', 'Preset Loaded', 'Icon', 'success');
        end

        % Button pushed function: SlowGaitButton
        function SlowGaitButtonPushed(app, event)
            app.PointsField.Value = 500;
            app.CyclesField.Value = 1.0;
            app.SpeedField.Value = 0.89;
            app.StepLengthField.Value = 0.58;
            app.SmoothnessSlider.Value = 9;
            app.SmoothnessValueLabel.Text = '9 / 10';
            uialert(app.UIFigure, 'Slow Gait preset loaded successfully!', 'Preset Loaded', 'Icon', 'success');
        end

        % Button pushed function: FastGaitButton
        function FastGaitButtonPushed(app, event)
            app.PointsField.Value = 500;
            app.CyclesField.Value = 1.0;
            app.SpeedField.Value = 2.02;
            app.StepLengthField.Value = 0.87;
            app.SmoothnessSlider.Value = 7;
            app.SmoothnessValueLabel.Text = '7 / 10';
            uialert(app.UIFigure, 'Fast Gait preset loaded successfully!', 'Preset Loaded', 'Icon', 'success');
        end

        % Button pushed function: ResetButton
        function ResetButtonPushed(app, event)
            app.PointsField.Value = 500;
            app.CyclesField.Value = 1.0;
            app.SpeedField.Value = 1.40;
            app.StepLengthField.Value = 0.73;
            app.AmplitudeField.Value = 1.0;
            app.SmoothnessSlider.Value = 8;
            app.SmoothnessValueLabel.Text = '8 / 10';
            app.PlotResultsCheckBox.Value = true;
            app.VerifyContinuousCheckBox.Value = true;
            app.SaveDataCheckBox.Value = true;
            app.FormatButtonGroup.SelectedObject = app.DegreesRadioButton;
            uialert(app.UIFigure, 'All parameters reset to default values.', 'Reset Complete', 'Icon', 'info');
        end

        % Button pushed function: CloseButton
        function CloseButtonPushed(app, event)
            delete(app)
            close all
        end

        % Button pushed function: GenerateButton
        function GenerateButtonPushed(app, event)
            % Get values from GUI
            n_points = round(app.PointsField.Value);
            n_cycles = app.CyclesField.Value;
            gait_speed = app.SpeedField.Value;
            step_length = app.StepLengthField.Value;
            amplitude_scale = app.AmplitudeField.Value;
            smoothness = round(app.SmoothnessSlider.Value);
            plot_results = app.PlotResultsCheckBox.Value;
            save_data = app.SaveDataCheckBox.Value;
            verify_continuous = app.VerifyContinuousCheckBox.Value;

            if app.FormatButtonGroup.SelectedObject == app.DegreesRadioButton
                save_data_format = 'deg';
            else
                save_data_format = 'rad';
            end

            % Disable generate button during processing
            app.GenerateButton.Enable = 'off';
            app.GenerateButton.Text = 'Generating...';
            drawnow;

            try
                % Call the trajectory generator function
                limit_report = generate_exoskeleton_trajectories_backend(...
                    n_points, n_cycles, gait_speed, step_length, amplitude_scale, smoothness, ...
                    plot_results, save_data, verify_continuous, save_data_format);

                % Derived gait timing (stride = 2 steps)
                stride_length = 2 * step_length;
                stride_time   = stride_length / gait_speed;
                cadence_spm   = 60 * gait_speed / step_length;

                % Success message
                msg = sprintf(['Trajectories generated successfully!\n\n' ...
                    'Configuration:\n' ...
                    '  • Points: %d\n' ...
                    '  • Cycles (strides): %.1f\n' ...
                    '  • Speed: %.2f m/s\n' ...
                    '  • Step Length: %.2f m\n' ...
                    '  • Stride Length: %.2f m\n' ...
                    '  • Stride Time: %.3f s\n' ...
                    '  • Cadence: %.1f steps/min\n' ...
                    '  • Amplitude Scale: %.2f\n' ...
                    '  • Smoothness: %d/10\n' ...
                    '  • Units: %s'], ...
                    n_points, n_cycles, gait_speed, step_length, stride_length, stride_time, ...
                    cadence_spm, amplitude_scale, smoothness, save_data_format);
                if limit_report.any
                    msg = sprintf(['%s\n\nWARNING: some joint angles exceeded the exoskeleton ' ...
                        'mechanical limits and were clamped:\n' ...
                        '  • Hip:   +%.1f° / -%.1f°\n' ...
                        '  • Knee:  +%.1f° / -%.1f°\n' ...
                        '  • Ankle: +%.1f° / -%.1f°\n' ...
                        '(excess above upper / below lower limit)'], msg, ...
                        limit_report.hip.excess_upper,   limit_report.hip.excess_lower, ...
                        limit_report.knee.excess_upper,  limit_report.knee.excess_lower, ...
                        limit_report.ankle.excess_upper, limit_report.ankle.excess_lower);
                    uialert(app.UIFigure, msg, 'Generated with limits applied', 'Icon', 'warning');
                else
                    uialert(app.UIFigure, msg, 'Success', 'Icon', 'success');
                end

            catch ME
                % Error handling
                uialert(app.UIFigure, ['Error generating trajectories: ' ME.message], 'Error', 'Icon', 'error');
            end

            % Re-enable generate button
            app.GenerateButton.Enable = 'on';
            app.GenerateButton.Text = 'Generate Trajectories';
        end

        % Button pushed function: HelpButton
        function HelpButtonPushed(app, event)
            % Create help figure
            helpFig = uifigure('Name', 'Help - Exoskeleton Trajectory Generator', ...
                'Position', [100 100 620 780], ...
                'Resize', 'on');

            % Create grid layout
            grid = uigridlayout(helpFig, [2 1]);
            grid.RowHeight = {'1x', 50};

            % Create text area for help content
            helpTextArea = uitextarea(grid);
            helpTextArea.Layout.Row = 1;
            helpTextArea.Layout.Column = 1;
            helpTextArea.Editable = 'off';
            helpTextArea.FontName = 'Courier New';
            helpTextArea.FontSize = 11;

            % Help content
            helpTextArea.Value = {
                ''
                '  LOWER LIMB EXOSKELETON TRAJECTORY GENERATOR - HELP'
                ''
                '  PURPOSE:'
                '  This application generates reference trajectories for hip, knee, and ankle joints'
                '  in lower limb exoskeletons for rehabilitation purposes. It considers the'
                '  spatio-temporal parameters of step length (m) and gait speed (m/s).'
                ''
                '══════════════════════════════════════════════════════════════════════════════════════'
                ''
                '  GAIT CYCLE DEFINITION:'
                ''
                '  • 1 gait cycle = 1 STRIDE = 2 consecutive steps'
                '    (heel strike to next heel strike of the SAME foot)'
                '  • Stride length   S = 2 × step length'
                '  • Cadence         f = gait speed / step length   [steps/s]'
                '  • Stride time     T = 2 × step length / gait speed   [s]'
                ''
                '══════════════════════════════════════════════════════════════════════════════════════'
                ''
                '  TRAJECTORY PARAMETERS:'
                ''
                '  1. NUMBER OF POINTS (default = 500 points)'
                '     • Temporal resolution of generated trajectories'
                '     • Higher values = smoother curves and longer vectors'
                '     • Recommended: 500'
                ''
                '  2. GAIT CYCLES (default = 1.0 cycles)'
                '     • Number of complete strides to generate'
                '     • 1 cycle = heel strike to next heel strike (same foot) = 2 steps'
                ''
                '  3. GAIT SPEED (default = 1.40 m/s)'
                '     • Walking velocity in meters per second'
                '     • Normal speed: 1.4 m/s'
                '     • Slow speed: 0.89 m/s'
                '     • Fast: 2.02 m/s'
                '     • Primarily affects KNEE angles'
                ''
                '  4. STEP LENGTH (default = 0.73 m)'
                '     • Distance between successive left/right heel strikes'
                '     • Stride length = 2 × step length'
                '     • Nominal step length: 0.73 m'
                '     • Short step length: 0.58 m'
                '     • Long step length: 0.87 m'
                '     • It has a higher impact on HIP and KNEE angles'
                ''
                '  5. AMPLITUDE SCALE (default = 1.0)'
                '     • Global scaling factor for all joint angles'
                '     • 1.0 = 100% (normal range of motion)'
                '     • 0.8 = 80% (reduced ROM for limited mobility)'
                '     • 1.2 = 120% (increased ROM)'
                ''
                '  6. SMOOTHNESS LEVEL (1-10)'
                '     • Controls trajectory filtering and smoothing'
                '     • 1-6: Minimal smoothing (robust LOESS, preserves rapid transitions)'
                '     • 7-10: Maximum smoothing (Savitzky-Golay + zero-phase Butterworth)'
                ''
                '══════════════════════════════════════════════════════════════════════════════════════'
                ''
                '  BIOMECHANICAL SCALING (SCIENTIFIC REFERENCES):'
                ''
                '  Joint-angle keypoints are corrected as a linear function of the deviation'
                '  of cadence and gait speed from the nominal condition (1.40 m/s, 0.73 m).'
                '  At the nominal condition the corrections are zero.'
                ''
                '  [1] Lim et al. (2017) - J Biomech "Effects of step length and step frequency'
                '      on lower-limb muscle function in human gait"'
                '      → Provides the coefficients to determine trajectory peaks based on'
                '        the variation of both step length and step frequency'
                ''
                '  Other references that can be analyzed include:'
                ''
                '  [2] Öberg et al. (1993) - J Rehabil Res Dev "Basic gait parameters:'
                '      Reference data for normal subjects, 10-79 years of age"'
                ''
                '  [3] Kwon et al. (2015) - J Phys Ther Sci "Changes of kinematic parameters'
                '      of lower extremities with gait speed: a 3D motion analysis study"'
                ''
                '  [4] Judge et al. (1996) - J Gerontol A Biol Sci Med Sci "Step Length'
                '      Reductions in Advanced Age: The Role of Ankle and Hip Kinetics"'
                ''
                '══════════════════════════════════════════════════════════════════════════════════════'
                ''
                '  PRESET CONFIGURATIONS:'
                ''
                '  • NORMAL GAIT'
                '    Speed: 1.40 m/s, Step: 0.73 m (Stride: 1.46 m), Amplitude: 1.0'
                '    Typical healthy adult walking pattern'
                ''
                '  • SLOW GAIT'
                '    Speed: 0.89 m/s, Step: 0.58 m (Stride: 1.16 m), Amplitude: 1.0'
                '    Elderly or pathological gait pattern'
                ''
                '  • FAST GAIT'
                '    Speed: 2.02 m/s, Step: 0.87 m (Stride: 1.74 m), Amplitude: 1.0'
                '    Brisk walking or athletic gait pattern'
                ''
                '══════════════════════════════════════════════════════════════════════════════════════'
                ''
                '  OUTPUT OPTIONS:'
                ''
                '  ☑ Generate Trajectory Plots'
                '     Creates 6 comprehensive visualization plots including:'
                '     - All joints vs time'
                '     - Single gait cycle pattern'
                '     - Individual joint trajectories'
                '     - 3D joint coordination pattern'
                ''
                '  ☑ Verify Continuity (2 Cycles)'
                '     Plots two consecutive cycles to verify smooth periodicity'
                '     and check for discontinuities at cycle boundaries'
                ''
                '  ☑ Save Data to Files'
                '     Exports trajectories in multiple formats (see below)'
                ''
                '  Output Unit Format:'
                '     ○ Degrees - Standard biomechanical convention'
                '     ○ Radians - Mathematical/control system convention'
                ''
                '══════════════════════════════════════════════════════════════════════════════════════'
                ''
                '  OUTPUT FILES:'
                ''
                '  1. exoskeleton_trajectories.mat'
                '     MATLAB data structure containing:'
                '     - Time vector and joint angles (right and left leg)'
                '     - All generation parameters (incl. stride length, stride time, cadence)'
                '     - Metadata and conventions'
                '     - Scientific references'
                ''
                '  2. exoskeleton_trajectories.csv'
                '     Comma-separated values file with columns:'
                '     Time_s, Hip, Knee, Ankle (right leg)'
                '     Compatible with Excel, Python, R'
                ''
                '  3. exoskeleton_trajectories.txt'
                '     Plain text file with:'
                '     - Header with metadata'
                '     - Tab-separated data columns'
                '     - Generation timestamp'
                ''
                '  4. exoskeleton_trajectories_arduino.txt'
                '     C-style arrays for microcontroller use:'
                '     - Right leg: hip_r, knee_r, ankle_r'
                '     - Left leg: hip_l, knee_l, ankle_l (shifted by 50% of the stride)'
                '     - Reduced to 10% of points for memory efficiency'
                '     - Scaled by 0.75 for safety margin'
                ''
                '══════════════════════════════════════════════════════════════════════════════════════'
                ''
                '  JOINT ANGLE CONVENTIONS AND MECHANICAL LIMITS:'
                ''
                '  • HIP JOINT (Sagittal Plane)'
                '    Positive (+): Flexion (thigh moves forward)'
                '    Negative (-): Extension (thigh moves backward)'
                '    Mechanical limits: -20° (extension) to +40° (flexion)'
                ''
                '  • KNEE JOINT (Sagittal Plane)'
                '    Positive (+): Flexion (heel toward buttock)'
                '    0°: Full extension (neutral, no hyperextension)'
                '    Mechanical limits: 0° to +50° (flexion)'
                ''
                '  • ANKLE JOINT (Sagittal Plane)'
                '    Positive (+): Dorsiflexion (toes up)'
                '    Negative (-): Plantarflexion (toes down)'
                '    Mechanical limits: -20° (plantarflexion) to +20° (dorsiflexion)'
                ''
                '  Angles outside these limits (e.g. natural knee swing flexion ~60-70°)'
                '  are clamped at the keypoint level; a warning reports the excess.'
                ''
                '══════════════════════════════════════════════════════════════════════════════════════'
                ''
                '  GAIT PHASES:'
                ''
                '  Gait Cycle (1 stride) = 100%'
                '    0%  - Heel Strike (initial contact)'
                '    0-60% - Stance Phase (foot on ground)'
                '    50% - Contralateral heel strike (end of first step)'
                '    60% - Toe Off (start of swing)'
                '    60-100% - Swing Phase (foot in air)'
                '    100% - Next Heel Strike (same foot)'
                ''
                '══════════════════════════════════════════════════════════════════════════════════════'
                ''
                '  TIPS FOR BEST RESULTS:'
                ''
                '  1. Start with preset configurations, then adjust'
                '  2. Use higher smoothness (8-10) for mechanical systems'
                '  3. Match step length to patient anthropometry'
                '  4. Verify continuity for periodic control applications'
                '  5. Check command window for detailed generation report'
                '  6. Use amplitude scale for progressive rehabilitation'
                ''
                '══════════════════════════════════════════════════════════════════════════════════════'
                ''
                '  TROUBLESHOOTING:'
                ''
                '  Q: Trajectories look jerky?'
                '  A: Increase smoothness level to 9-10'
                ''
                '  Q: Joint angles seem too small/large?'
                '  A: Adjust amplitude scale factor'
                ''
                '  Q: Want patient-specific trajectories?'
                '  A: Match gait speed and step length to patient data'
                ''
                '  Q: Need different gait patterns?'
                '  A: Modify speed/step length to match desired pathology'
                ''
                '══════════════════════════════════════════════════════════════════════════════════════'
                ''
                '  CONTACT & VERSION INFO:'
                ''
                '  Author: Rafael Pérez-San Lázaro'
                '  Version: 1.2'
                '  Mail: rafael.sanlazaro@tec.mx'
                '  Application: Lower Limb Exoskeleton Trajectory Generator'
                ''
                '  For issues, suggestions, or questions, please send an email to the provided address.'
                ''
                };

            % Create close button
            closeBtn = uibutton(grid, 'push');
            closeBtn.Layout.Row = 2;
            closeBtn.Layout.Column = 1;
            closeBtn.Text = 'Close';
            closeBtn.FontSize = 12;
            closeBtn.FontWeight = 'bold';
            closeBtn.ButtonPushedFcn = @(btn,event) close(helpFig);
        end
    end
end

%% Trajectory Generation Function
function limit_report = generate_exoskeleton_trajectories_backend(n_points, n_cycles, gait_speed, step_length, amplitude_scale, smoothness, plot_results, save_data, verify_continuous, save_data_format)
% Generates hip/knee/ankle reference trajectories for a lower-limb
% exoskeleton, scaled with gait speed and step length.
%
% Gait-cycle definition (v1.1):
%   One gait cycle = one STRIDE = two consecutive steps
%   (heel strike to next heel strike of the SAME foot).
%
%     step length     L          [m]        (input)
%     stride length   S = 2L     [m]
%     cadence         f = v/L    [steps/s]
%     step time       Ts = L/v   [s]
%     stride time     T  = S/v = 2L/v  [s]  (= gait cycle duration)
%
% Keypoint corrections (Lim et al., 2017) are written in normalised
% (dimensionless) form and centred on the nominal condition REF, so the
% baseline keypoints are reproduced exactly at v = 1.40 m/s, L = 0.73 m:
%
%     Delta_j = a_j*(f/f_ref - 1) + b_j*(v/v_ref - 1)      [deg]
%
% with a_j, b_j in degrees. All outputs respect the exoskeleton's
% mechanical range of motion (LIMITS, v1.2).

%% Exoskeleton mechanical range of motion [deg]  (v1.2)
%   Hip:   flexion 0..40,       extension 0..-20
%   Knee:  flexion 0..50,       extension 0 (neutral, no hyperextension)
%   Ankle: dorsiflexion 0..20,  plantarflexion 0..-20
LIMITS.hip   = [-20, 40];
LIMITS.knee  = [  0, 50];
LIMITS.ankle = [-20, 20];

%% Nominal reference condition (all corrections vanish here)
REF.gait_speed  = 1.40;                               % m/s
REF.step_length = 0.73;                               % m
REF.cadence     = REF.gait_speed / REF.step_length;   % steps/s (~1.92)

%% Gait timing parameters
stride_length   = 2 * step_length;                    % m
cadence         = gait_speed / step_length;           % steps/s
step_time       = step_length / gait_speed;           % s
gait_cycle_time = stride_length / gait_speed;         % s  (stride time)
total_time      = n_cycles * gait_cycle_time;
time_vector     = linspace(0, total_time, n_points)';
dt              = total_time / (n_points - 1);

%% Baseline keypoints (degrees) at the nominal condition, in % of stride
gait_events              = 0:10:100;
hip_keypoints_baseline   = [20, 10,   5,  -5, -15, -20, -10, 10, 25, 35, 20];
knee_keypoints_baseline  = [10, 12,  20,  15,   5,   0,  15, 40, 70, 25, 10];
ankle_keypoints_baseline = [ 0, -7, -10, -15, -20, -18, -10,  5, 10, 15,  0];

%% Biomechanical corrections (dimensionless form), centred on REF
%   Delta = a*(f/f_ref - 1) + b*(v/v_ref - 1)       -> [deg]
% GAIN.* = [a, b] in degrees (= change for a 100 % change of f or v).
% Obtained from the v1.1 dimensional slopes (alpha [deg/(step/s)],
% beta [deg/(m/s)]) as a = alpha*f_ref, b = beta*v_ref, so the
% numerical output is identical to v1.1. Verify against Lim et al. (2017).
GAIN.hip_flex  = [12.543,  0.252];
GAIN.hip_ext   = [10.951, -0.238];
GAIN.knee_flex = [12.677,  4.116];

d_param = [cadence / REF.cadence - 1; gait_speed / REF.gait_speed - 1];   % dimensionless
hip_flex_adj  = GAIN.hip_flex  * d_param;
hip_ext_adj   = GAIN.hip_ext   * d_param;
knee_flex_adj = GAIN.knee_flex * d_param;

% Masks are taken from the BASELINE so each keypoint is corrected once
hip_flex_mask  = hip_keypoints_baseline  > 0;
hip_ext_mask   = hip_keypoints_baseline  < 0;
knee_flex_mask = knee_keypoints_baseline > 0;

hip_keypoints   = hip_keypoints_baseline;
knee_keypoints  = knee_keypoints_baseline;
ankle_keypoints = ankle_keypoints_baseline;

hip_keypoints(hip_flex_mask)   = hip_keypoints(hip_flex_mask)   + hip_flex_adj;
% NOTE: sign kept from v1.0 (a positive hip_ext_adj REDUCES extension
% magnitude). Check this convention against Lim et al. (2017).
hip_keypoints(hip_ext_mask)    = hip_keypoints(hip_ext_mask)    + hip_ext_adj;
knee_keypoints(knee_flex_mask) = knee_keypoints(knee_flex_mask) + knee_flex_adj;

%% Apply amplitude scaling to all joints
hip_keypoints   = hip_keypoints   * amplitude_scale;
knee_keypoints  = knee_keypoints  * amplitude_scale;
ankle_keypoints = ankle_keypoints * amplitude_scale;

%% Enforce mechanical limits on the keypoints (primary limiting stage)
% PCHIP is shape-preserving (no overshoot between keypoints), so clamping
% the keypoints keeps the interpolated curve inside the limits and
% preserves its smoothness. Record how much was removed at each peak.
clampv = @(x, lim) min(max(x, lim(1)), lim(2));
limit_report = struct();
[hip_keypoints,   limit_report.hip]   = clamp_keypoints(hip_keypoints,   LIMITS.hip);
[knee_keypoints,  limit_report.knee]  = clamp_keypoints(knee_keypoints,  LIMITS.knee);
[ankle_keypoints, limit_report.ankle] = clamp_keypoints(ankle_keypoints, LIMITS.ankle);

%% Periodic keypoint set: events 0..90 %, with 100 % == 0 %,
% padded by two events on each side so PCHIP slopes are periodic
pad       = 2;
key_phase = gait_events(1:end-1);                                  % 0..90
ext_phase = [key_phase(end-pad+1:end) - 100, key_phase, key_phase(1:pad+1) + 100];
wrap      = @(v) [v(end-pad:end-1), v(1:end-1), v(1:pad+1)];

%% Extended time axis (one stride of padding on each side) so the
% smoothing filters have no edge effects inside the returned window
n_pad   = ceil(gait_cycle_time / dt);
t_ext   = (-n_pad : n_points - 1 + n_pad)' * dt;
keep    = n_pad + (1:n_points);

% Gait phase (0-100 % of stride). Left leg leads/lags by half a stride.
phase_r = mod(t_ext / gait_cycle_time,       1) * 100;
phase_l = mod(t_ext / gait_cycle_time + 0.5, 1) * 100;

build = @(kp, ph) periodic_smooth_trajectory(ext_phase, wrap(kp), ph, smoothness, n_points, keep);

hip_trajectory     = build(hip_keypoints,   phase_r);
knee_trajectory    = build(knee_keypoints,  phase_r);
ankle_trajectory   = build(ankle_keypoints, phase_r);
hip_trajectory_l   = build(hip_keypoints,   phase_l);
knee_trajectory_l  = build(knee_keypoints,  phase_l);
ankle_trajectory_l = build(ankle_keypoints, phase_l);

%% Final safety guard: smoothing filters can overshoot by a fraction of a
% degree, so hard-limit the output (affects only residual overshoot)
hip_trajectory     = clampv(hip_trajectory,     LIMITS.hip);
knee_trajectory    = clampv(knee_trajectory,    LIMITS.knee);
ankle_trajectory   = clampv(ankle_trajectory,   LIMITS.ankle);
hip_trajectory_l   = clampv(hip_trajectory_l,   LIMITS.hip);
knee_trajectory_l  = clampv(knee_trajectory_l,  LIMITS.knee);
ankle_trajectory_l = clampv(ankle_trajectory_l, LIMITS.ankle);
limit_report.any = limit_report.hip.clipped || limit_report.knee.clipped || limit_report.ankle.clipped;

%% Determine unit label and convert
if strcmp(save_data_format, 'rad')
    unit_label = 'radians';
    unit_conversion = pi/180;
else
    unit_label = 'degrees';
    unit_conversion = 1;
end

hip_trajectory_display   = hip_trajectory   * unit_conversion;
knee_trajectory_display  = knee_trajectory  * unit_conversion;
ankle_trajectory_display = ankle_trajectory * unit_conversion;

%% Create trajectory data structure
traj_data = struct();
traj_data.hip   = hip_trajectory_display;
traj_data.knee  = knee_trajectory_display;
traj_data.ankle = ankle_trajectory_display;
traj_data.hip_l   = hip_trajectory_l   * unit_conversion;
traj_data.knee_l  = knee_trajectory_l  * unit_conversion;
traj_data.ankle_l = ankle_trajectory_l * unit_conversion;
traj_data.time = time_vector;
traj_data.unit_label = unit_label;
traj_data.gait_cycle_time = gait_cycle_time;   % stride time
traj_data.step_time = step_time;
traj_data.gait_speed = gait_speed;
traj_data.step_length = step_length;
traj_data.stride_length = stride_length;
traj_data.cadence = cadence;                   % steps/s
traj_data.amplitude_scale = amplitude_scale;
traj_data.n_points = n_points;
traj_data.limits.hip   = LIMITS.hip   * unit_conversion;
traj_data.limits.knee  = LIMITS.knee  * unit_conversion;
traj_data.limits.ankle = LIMITS.ankle * unit_conversion;

%% Display information
fprintf('\n');
fprintf('══════════════════════════════════════════════════\n');
fprintf('  Lower Limb Exoskeleton Reference Trajectories Generated\n');
fprintf('══════════════════════════════════════════════════\n');
fprintf('\nBiomechanical Scaling Applied (Scientific References):\n');
fprintf('  [1] Lim et al. (2017) - Step length vs frequency effects\n');
fprintf('\nConfiguration:\n');
fprintf('  • Points per trajectory: %d\n', n_points);
fprintf('  • Number of gait cycles (strides): %.1f\n', n_cycles);
fprintf('  • Gait speed: %.2f m/s (Ref: %.2f m/s)\n', gait_speed, REF.gait_speed);
fprintf('  • Step length: %.2f m (Ref: %.2f m)\n', step_length, REF.step_length);
fprintf('  • Stride length: %.2f m\n', stride_length);
fprintf('  • Cadence: %.1f steps/min (Ref: %.1f steps/min)\n', 60*cadence, 60*REF.cadence);
fprintf('  • Amplitude scale: %.2f (%.0f%%)\n', amplitude_scale, amplitude_scale*100);
fprintf('  • Step time: %.3f s\n', step_time);
fprintf('  • Stride (gait cycle) time: %.3f s\n', gait_cycle_time);
fprintf('  • Total duration: %.3f s\n', total_time);
fprintf('  • Smoothness level: %d/10\n', smoothness);
fprintf('  • Output units: %s\n', unit_label);
fprintf('\nKeypoint corrections (deg, before amplitude scaling):\n');
fprintf('  • Hip flexion:   %+.2f\n', hip_flex_adj);
fprintf('  • Hip extension: %+.2f\n', hip_ext_adj);
fprintf('  • Knee flexion:  %+.2f\n', knee_flex_adj);
fprintf('\nMechanical limits (deg): hip [%g, %g], knee [%g, %g], ankle [%g, %g]\n', ...
    LIMITS.hip, LIMITS.knee, LIMITS.ankle);
jn = {'hip', 'knee', 'ankle'};
for jj = 1:3
    r = limit_report.(jn{jj});
    if r.clipped
        fprintf('  ! %s keypoints clamped: max excess above limit %.2f deg, below limit %.2f deg\n', ...
            upper(jn{jj}), r.excess_upper, r.excess_lower);
    end
end
fprintf('\nJoint Ranges (after biomechanical scaling and mechanical limits):\n');
fprintf('  • Hip:   %.3f to %.3f %s (%.3f ROM)\n', min(hip_trajectory_display), max(hip_trajectory_display), unit_label, range(hip_trajectory_display));
fprintf('  • Knee:  %.3f to %.3f %s (%.3f ROM)\n', min(knee_trajectory_display), max(knee_trajectory_display), unit_label, range(knee_trajectory_display));
fprintf('  • Ankle: %.3f to %.3f %s (%.3f ROM)\n', min(ankle_trajectory_display), max(ankle_trajectory_display), unit_label, range(ankle_trajectory_display));
fprintf('\n');

%% Create plots
if plot_results
    create_exoskeleton_plots(traj_data);
end

if verify_continuous
    verify_continuous_data(traj_data);
end

if save_data
    save_exoskeleton_data(traj_data, plot_results);
end
end

%% Supporting Functions
function [kp, report] = clamp_keypoints(kp, lim)
% Clamps keypoints to [lim(1), lim(2)] and reports the removed excess (deg).
report.excess_upper = max([0, kp - lim(2)]);
report.excess_lower = max([0, lim(1) - kp]);
report.clipped      = report.excess_upper > 0 || report.excess_lower > 0;
kp = min(max(kp, lim(1)), lim(2));
end

function trajectory = periodic_smooth_trajectory(key_phase, key_vals, query_phase, smoothness, n_ref, keep)
% PCHIP interpolation over gait phase (periodic keypoints) followed by
% smoothing on the padded signal; returns only the samples in KEEP.
rough_traj = pchip(key_phase, key_vals, query_phase);
if smoothness >= 7
    % Window sized on the returned length (not the padded one).
    % Minimum 5 because a cubic Savitzky-Golay needs span > degree.
    window_size = max(5, round(n_ref * 0.02));
    if mod(window_size, 2) == 0
        window_size = window_size + 1;
    end
    traj = smooth(rough_traj, window_size, 'sgolay', 3);
    [b, a] = butter(3, 0.1, 'low');
    traj = filtfilt(b, a, traj);
else
    traj = smooth(rough_traj, 'rloess');
end
trajectory = traj(keep);
end

function fig = latex_figure(varargin)
% Creates a figure whose text (titles, labels, legends, tick labels)
% is rendered with the LaTeX interpreter.
fig = figure(varargin{:});
set(fig, 'DefaultTextInterpreter', 'latex', ...
         'DefaultLegendInterpreter', 'latex', ...
         'DefaultAxesTickLabelInterpreter', 'latex', ...
         'DefaultColorbarTickLabelInterpreter', 'latex');
end

function u = latex_unit(unit_label)
% LaTeX string for the angle unit shown in axis labels
if strcmp(unit_label, 'radians')
    u = 'rad';
else
    u = '$^{\circ}$';
end
end

function create_exoskeleton_plots(traj_data)
latex_figure('Position', [100, 100, 1300, 900], 'Name', 'Exoskeleton Trajectories', 'NumberTitle', 'off');
colors = struct('hip', [0.8, 0.2, 0.2], 'knee', [0.2, 0.6, 0.8], 'ankle', [0.2, 0.8, 0.2]);
time_vec = traj_data.time;
hip_traj = traj_data.hip;
knee_traj = traj_data.knee;
ankle_traj = traj_data.ankle;
u = latex_unit(traj_data.unit_label);
cycle_time = traj_data.gait_cycle_time;

t = tiledlayout(3, 2);
% Decrease space between tiles and the figure edges
t.TileSpacing = 'compact';
t.Padding = 'compact';

% Plot 1: All trajectories
nexttile
plot(time_vec, hip_traj, 'Color', colors.hip, 'LineWidth', 2.5); hold on;
plot(time_vec, knee_traj, 'Color', colors.knee, 'LineWidth', 2.5);
plot(time_vec, ankle_traj, 'Color', colors.ankle, 'LineWidth', 2.5);
xlabel('\textbf{Time (s)}', 'FontSize', 13);
ylabel(['\textbf{Joint Angle (deg)}'], 'FontSize', 13);
title('\textbf{All Joint Trajectories vs Time}', 'FontSize', 15);
legend('Hip', 'Knee', 'Ankle', 'Location', 'best', 'FontSize', 11);
grid on;
yr = max(knee_traj)-min(ankle_traj);
ylim([min(ankle_traj)-(10) max(knee_traj)+(yr*0.1)])
xlim([min(time_vec) max(time_vec)])

% Plot 2: Single gait cycle (one stride)
nexttile
cycle_samples = min(length(time_vec), round(length(time_vec) / (max(time_vec) / cycle_time)));
cycle_percent = linspace(0, 100, cycle_samples);
plot(cycle_percent, hip_traj(1:cycle_samples), 'Color', colors.hip, 'LineWidth', 2.5); hold on;
plot(cycle_percent, knee_traj(1:cycle_samples), 'Color', colors.knee, 'LineWidth', 2.5);
plot(cycle_percent, ankle_traj(1:cycle_samples), 'Color', colors.ankle, 'LineWidth', 2.5);
xline(60, 'k--', 'Alpha', 0.7, 'LineWidth', 1.5);
xline(0, 'k:', 'Alpha', 0.7, 'LineWidth', 1.5);
xlabel('\textbf{Gait Cycle (\%)}', 'FontSize', 13);
ylabel(['\textbf{Joint Angle (deg)}'], 'FontSize', 13);
title('\textbf{Single Gait Cycle (Stride) Pattern}', 'FontSize', 15);
legend('Hip', 'Knee', 'Ankle', 'Toe Off', 'Heel Strike', 'Location', 'best', 'FontSize', 11);
grid on;

% Plot 3: Hip
nexttile
plot(time_vec, hip_traj, 'Color', colors.hip, 'LineWidth', 2.5);
xlabel('\textbf{Time (s)}', 'FontSize', 13);
ylabel(['\textbf{Hip Angle (deg)}'], 'FontSize', 13);
title('\textbf{Hip Joint Trajectory}', 'FontSize', 15);
lim = traj_data.limits.hip; yr = lim(2) - lim(1);
ylim([lim(1)-0.1*yr, lim(2)+0.1*yr])
xlim([min(time_vec) max(time_vec)])
grid on;
yline(0, 'k--', 'Alpha', 0.5);
yline(lim(2), 'r:', 'LineWidth', 1.5); yline(lim(1), 'r:', 'LineWidth', 1.5);
legend('Hip Flexion/Extension', 'Neutral Position', 'Mechanical Limits', 'FontSize', 11);

% Plot 4: Knee
nexttile
plot(time_vec, knee_traj, 'Color', colors.knee, 'LineWidth', 2.5);
xlabel('\textbf{Time (s)}', 'FontSize', 13);
ylabel(['\textbf{Knee Angle (deg)}'], 'FontSize', 13);
title('\textbf{Knee Joint Trajectory}', 'FontSize', 15);
lim = traj_data.limits.knee; yr = lim(2) - lim(1);
ylim([lim(1)-0.1*yr, lim(2)+0.1*yr])
xlim([min(time_vec) max(time_vec)])
grid on;
yline(0, 'k--', 'Alpha', 0.5);
yline(lim(2), 'r:', 'LineWidth', 1.5);
legend('Knee Flexion', 'Full Extension', 'Mechanical Limit', 'FontSize', 11);

% Plot 5: Ankle
nexttile
plot(time_vec, ankle_traj, 'Color', colors.ankle, 'LineWidth', 2.5);
xlabel('\textbf{Time (s)}', 'FontSize', 13);
ylabel(['\textbf{Ankle Angle (deg)}'], 'FontSize', 13);
title('\textbf{Ankle Joint Trajectory}', 'FontSize', 15);
lim = traj_data.limits.ankle; yr = lim(2) - lim(1);
ylim([lim(1)-0.1*yr, lim(2)+0.1*yr])
xlim([min(time_vec) max(time_vec)])
grid on;
yline(0, 'k--', 'Alpha', 0.5);
yline(lim(2), 'r:', 'LineWidth', 1.5); yline(lim(1), 'r:', 'LineWidth', 1.5);
legend('Dorsi/Plantarflexion', 'Neutral Position', 'Mechanical Limits', 'FontSize', 11);

% Plot 6: 3D Coordination
nexttile
plot3(hip_traj, knee_traj, ankle_traj, 'k-', 'LineWidth', 1.5);
xlabel(['\textbf{Hip Angle (deg)}'], 'FontSize', 13);
ylabel(['\textbf{Knee Angle (deg)}'], 'FontSize', 13);
zlabel(['\textbf{Ankle Angle (deg)}'], 'FontSize', 13);
title('\textbf{Joint Coordination Pattern}', 'FontSize', 15);
grid on; view(45, 30);

end

function verify_continuous_data(traj_data)
latex_figure('Position', [100, 100, 700, 400], 'Name', 'Continuity Verification', 'NumberTitle', 'off');
colors = struct('hip', [0.8, 0.2, 0.2], 'knee', [0.2, 0.6, 0.8], 'ankle', [0.2, 0.8, 0.2]);
time_vec = traj_data.time;
hip_traj = traj_data.hip;
knee_traj = traj_data.knee;
ankle_traj = traj_data.ankle;
u = latex_unit(traj_data.unit_label);
cycle_time = traj_data.gait_cycle_time;

cycle_samples = min(length(time_vec), round(length(time_vec) / (max(time_vec) / cycle_time)));
plot([hip_traj(1:cycle_samples); hip_traj(1:cycle_samples)], 'Color', colors.hip, 'LineWidth', 2.5); hold on;
plot([knee_traj(1:cycle_samples); knee_traj(1:cycle_samples)], 'Color', colors.knee, 'LineWidth', 2.5);
plot([ankle_traj(1:cycle_samples); ankle_traj(1:cycle_samples)], 'Color', colors.ankle, 'LineWidth', 2.5);
xline(cycle_samples, 'k--', 'LineWidth', 2, 'Alpha', 0.7);
legend('Hip', 'Knee', 'Ankle', 'Cycle Boundary', 'FontSize', 11, 'Location', 'best');
ylabel(['\textbf{Joint Angle (deg)}'], 'FontSize', 12);
xlabel('\textbf{Sample Points (2 Cycles)}', 'FontSize', 12);
grid on;
title('\textbf{Continuity Verification: Two Consecutive Strides}', 'FontSize', 14);
end

function write_c_array(fid, name, values)
% Writes a C/Arduino float array: float name[N] = {v1,v2,...};
fprintf(fid, 'float %s[%u] = {', name, numel(values));
fprintf(fid, '%.3f,', values(1:end-1));
fprintf(fid, '%.3f};\n', values(end));
end

function save_exoskeleton_data(traj_data, plot_results)
time_vec = traj_data.time;
hip_traj = traj_data.hip;
knee_traj = traj_data.knee;
ankle_traj = traj_data.ankle;
unit_label = traj_data.unit_label;
gait_speed = traj_data.gait_speed;
step_length = traj_data.step_length;
stride_length = traj_data.stride_length;
amplitude_scale = traj_data.amplitude_scale;

exoskeleton_data = struct();
exoskeleton_data.time = time_vec;
exoskeleton_data.hip_angle = hip_traj;
exoskeleton_data.knee_angle = knee_traj;
exoskeleton_data.ankle_angle = ankle_traj;
exoskeleton_data.hip_angle_left = traj_data.hip_l;
exoskeleton_data.knee_angle_left = traj_data.knee_l;
exoskeleton_data.ankle_angle_left = traj_data.ankle_l;
exoskeleton_data.parameters.gait_speed = gait_speed;
exoskeleton_data.parameters.step_length = step_length;
exoskeleton_data.parameters.stride_length = stride_length;
exoskeleton_data.parameters.cadence_steps_per_s = traj_data.cadence;
exoskeleton_data.parameters.step_time = traj_data.step_time;
exoskeleton_data.parameters.stride_time = traj_data.gait_cycle_time;
exoskeleton_data.parameters.amplitude_scale = amplitude_scale;
exoskeleton_data.parameters.sample_rate = (length(time_vec) - 1) / max(time_vec);
exoskeleton_data.info.units = unit_label;
exoskeleton_data.info.mechanical_limits = traj_data.limits;
exoskeleton_data.info.gait_cycle = 'one stride (heel strike to next heel strike of the same foot) = 2 steps';
exoskeleton_data.info.conventions = struct(...
    'hip', 'positive=flexion, negative=extension', ...
    'knee', 'positive=flexion, negative=extension', ...
    'ankle', 'positive=dorsiflexion, negative=plantarflexion');
exoskeleton_data.info.references = {
    'Oberg et al. (1993) - Basic gait parameters: Reference data for normal subjects, 10-79 years of age'
    'Kwon et al. (2015) - Changes of kinematic parameters of lower extremities with gait speed'
    'Lim et al. (2017) - Effects of step length and step frequency on lower-limb muscle function'
    'Judge et al. (1996) - Step Length Reductions in Advanced Age: The Role of Ankle and Hip Kinetics'
    };

save('exoskeleton_trajectories.mat', 'exoskeleton_data');
fprintf('✓ Data saved to: exoskeleton_trajectories.mat\n');

trajectory_table = table(time_vec, hip_traj, knee_traj, ankle_traj, ...
    'VariableNames', {'Time_s', 'Hip', 'Knee', 'Ankle'});
writetable(trajectory_table, 'exoskeleton_trajectories.csv');
fprintf('✓ Data exported to: exoskeleton_trajectories.csv\n');

fid = fopen('exoskeleton_trajectories.txt', 'w');
fprintf(fid, '%% Lower Limb Exoskeleton Reference Trajectories\n');
fprintf(fid, '%% Generated: %s\n', datestr(now));
fprintf(fid, '%% Gait Speed: %.2f m/s\n', gait_speed);
fprintf(fid, '%% Step Length: %.2f m\n', step_length);
fprintf(fid, '%% Stride Length: %.2f m\n', stride_length);
fprintf(fid, '%% Cadence: %.1f steps/min\n', 60 * traj_data.cadence);
fprintf(fid, '%% Stride (gait cycle) Time: %.3f s\n', traj_data.gait_cycle_time);
fprintf(fid, '%% Amplitude Scale: %.2f\n', amplitude_scale);
fprintf(fid, '%% Units: %s\n', unit_label);
fprintf(fid, '%% Mechanical limits (%s): hip [%g, %g], knee [%g, %g], ankle [%g, %g]\n', unit_label, ...
    traj_data.limits.hip, traj_data.limits.knee, traj_data.limits.ankle);
fprintf(fid, '%% Sample Rate: %.1f Hz\n', (length(time_vec) - 1) / max(time_vec));
fprintf(fid, '%% Biomechanical Scaling References:\n');
fprintf(fid, '%%   [1] Oberg et al. (1993)\n');
fprintf(fid, '%%   [2] Kwon et al. (2015)\n');
fprintf(fid, '%%   [3] Lim et al. (2017)\n');
fprintf(fid, '%%   [4] Judge et al. (1996)\n');
fprintf(fid, '%% Columns: Time(s), Hip, Knee, Ankle (right leg)\n');
for i = 1:length(time_vec)
    fprintf(fid, '%.4f\t%.6f\t%.6f\t%.6f\n', time_vec(i), hip_traj(i), knee_traj(i), ankle_traj(i));
end
fclose(fid);
fprintf('✓ Data exported to: exoskeleton_trajectories.txt\n');

% Arduino export: downsample x10, 0.75 safety scaling.
% Left leg is computed from the gait phase shifted by 50 % of the stride
% (not by half of the vector), so it is correct for any number of cycles.
ds = 1:10:length(hip_traj);
hip_r   = hip_traj(ds)        * 0.75;
knee_r  = knee_traj(ds)       * 0.75;
ankle_r = ankle_traj(ds)      * 0.75;
hip_l   = traj_data.hip_l(ds)   * 0.75;
knee_l  = traj_data.knee_l(ds)  * 0.75;
ankle_l = traj_data.ankle_l(ds) * 0.75;

fid = fopen('exoskeleton_trajectories_arduino.txt', 'w');
write_c_array(fid, 'hip_r',   hip_r);
write_c_array(fid, 'knee_r',  knee_r);
write_c_array(fid, 'ankle_r', ankle_r);
write_c_array(fid, 'hip_l',   hip_l);
write_c_array(fid, 'knee_l',  knee_l);
write_c_array(fid, 'ankle_l', ankle_l);
fclose(fid);
fprintf('✓ Data exported to: exoskeleton_trajectories_arduino.txt\n');

if plot_results
    latex_figure('Position', [100, 100, 1200, 400], 'Name', 'Arduino Phase Shift', 'NumberTitle', 'off');
    colors = struct('hip', [0.8, 0.2, 0.2], 'knee', [0.2, 0.6, 0.8], 'ankle', [0.2, 0.8, 0.2]);
    u = latex_unit(unit_label);
    joints = {'Hip', 'Knee', 'Ankle'};
    right  = {hip_r, knee_r, ankle_r};
    left   = {hip_l, knee_l, ankle_l};
    cols   = {colors.hip, colors.knee, colors.ankle};

    for jj = 1:3
        subplot(1, 3, jj);
        plot(right{jj}, 'Color', cols{jj}, 'LineWidth', 2.5); hold on;
        plot(left{jj}, '-.', 'Color', cols{jj}, 'LineWidth', 2.5);
        legend('Right', 'Left ($+50\%$ stride)', 'FontSize', 10);
        xlabel('\textbf{Sample (downsampled $\times 10$)}', 'FontSize', 11);
        ylabel(['\textbf{' joints{jj} ' Angle (deg) $\times\,0.75$}'], 'FontSize', 11);
        title(['\textbf{' joints{jj} '}'], 'FontSize', 12);
        grid on;
    end

    sgtitle('\textbf{Left/Right Leg Phase Shift}', 'FontSize', 14, 'Interpreter', 'latex');
end
end