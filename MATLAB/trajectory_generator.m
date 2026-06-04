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

        StepLengthLabel               matlab.ui.control.Label
        StepLengthField               matlab.ui.control.NumericEditField
        StepLengthUnitLabel           matlab.ui.control.Label

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
            app.CyclesField.Tooltip = {'Number of complete gait cycles (0.1-10)'};

            % Create CyclesUnitLabel
            app.CyclesUnitLabel = uilabel(app.TrajectoryPanel);
            app.CyclesUnitLabel.Position = [320 180 100 22];
            app.CyclesUnitLabel.Text = 'cycles';
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
            app.SpeedField.Value = 1.2;
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
            app.StepLengthField.Value = 0.7;
            app.StepLengthField.Limits = [0.1 1.5];
            app.StepLengthField.ValueDisplayFormat = '%.2f';
            app.StepLengthField.Tooltip = {'Distance between foot contacts (0.1-1.5 m)'};

            % Create StepLengthUnitLabel
            app.StepLengthUnitLabel = uilabel(app.TrajectoryPanel);
            app.StepLengthUnitLabel.Position = [320 110 100 22];
            app.StepLengthUnitLabel.Text = 'm';
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

            % Create AppButton
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
                generate_exoskeleton_trajectories_backend(...
                    n_points, n_cycles, gait_speed, step_length, amplitude_scale, smoothness, ...
                    plot_results, save_data, verify_continuous, save_data_format);

                % Success message
                msg = sprintf(['Trajectories generated successfully!\n\n' ...
                    'Configuration:\n' ...
                    '  • Points: %d\n' ...
                    '  • Cycles: %.1f\n' ...
                    '  • Speed: %.2f m/s\n' ...
                    '  • Step Length: %.2f m\n' ...
                    '  • Amplitude Scale: %.2f\n' ...
                    '  • Smoothness: %d/10\n' ...
                    '  • Units: %s'], ...
                    n_points, n_cycles, gait_speed, step_length, amplitude_scale, smoothness, save_data_format);
                uialert(app.UIFigure, msg, 'Success', 'Icon', 'success');

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
                '  TRAJECTORY PARAMETERS:'
                ''
                '  1. NUMBER OF POINTS (default = 500 points)'
                '     • Temporal resolution of generated trajectories'
                '     • Higher values = smoother curves and longer vectors'
                '     • Recommended: 500'
                ''
                '  2. GAIT CYCLES (default = 1.0 cycles)'
                '     • Number of complete walking cycles to generate'
                '     • 1 cycle = heel strike to next heel strike (same foot)'
                ''
                '  3. GAIT SPEED (default = 1.40 m/s)'
                '     • Walking velocity in meters per second'
                '     • Normal speed: 1.4 m/s'
                '     • Slow speed: 0.89 m/s'
                '     • Fast: 2.02 m/s'
                '     • Primarily affects KNEE angles'
                ''
                '  4. Step LENGTH (default = 0.73 m)'
                '     • Distance between successive foot contacts'
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
                '     • 1-3: Minimal smoothing (preserves rapid transitions)'
                '     • 7-10: Maximum smoothing (ideal for mechanical systems)'
                ''
                '══════════════════════════════════════════════════════════════════════════════════════'
                ''
                '  BIOMECHANICAL SCALING (SCIENTIFIC REFERENCES):'
                ''
                '  Trajectories are adjusted based on published research to ensure physiological'
                '  accuracy:'
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
                '    Speed: 1.40 m/s, Step: 0.73 m, Amplitude: 1.0'
                '    Typical healthy adult walking pattern'
                ''
                '  • SLOW GAIT'
                '    Speed: 0.89 m/s, Step: 0.58 m, Amplitude: 1.0'
                '    Elderly or pathological gait pattern'
                ''
                '  • FAST GAIT'
                '    Speed: 2.02 m/s, Step: 0.87 m, Amplitude: 1.0'
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
                '     - Time vector and joint angles'
                '     - All generation parameters'
                '     - Metadata and conventions'
                '     - Scientific references'
                ''
                '  2. exoskeleton_trajectories.csv'
                '     Comma-separated values file with columns:'
                '     Time_s, Hip, Knee, Ankle'
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
                '     - Left leg: hip_l, knee_l, ankle_l (phase-shifted)'
                '     - Reduced to 10% of points for memory efficiency'
                '     - Scaled by 0.75 for safety margin'
                ''
                '══════════════════════════════════════════════════════════════════════════════════════'
                ''
                '  JOINT ANGLE CONVENTIONS:'
                ''
                '  • HIP JOINT (Sagittal Plane)'
                '    Positive (+): Flexion (thigh moves forward)'
                '    Negative (-): Extension (thigh moves backward)'
                '    Range: -20° to +35°'
                ''
                '  • KNEE JOINT (Sagittal Plane)'
                '    Positive (+): Flexion (heel toward buttock)'
                '    Negative (-): Extension (straight leg)'
                '    Range: 0° to +70°'
                ''
                '  • ANKLE JOINT (Sagittal Plane)'
                '    Positive (+): Dorsiflexion (toes up)'
                '    Negative (-): Plantarflexion (toes down)'
                '    Range: -20° to +15°'
                ''
                '══════════════════════════════════════════════════════════════════════════════════════'
                ''
                '  GAIT PHASES:'
                ''
                '  Gait Cycle = 100%'
                '    0%  - Heel Strike (initial contact)'
                '    0-60% - Stance Phase (foot on ground)'
                '    60% - Toe Off (start of swing)'
                '    60-100% - Swing Phase (foot in air)'
                '    100% - Next Heel Strike'
                ''
                '══════════════════════════════════════════════════════════════════════════════════════'
                ''
                '  TIPS FOR BEST RESULTS:'
                ''
                '  1. Start with preset configurations, then adjust'
                '  2. Use higher smoothness (8-10) for mechanical systems'
                '  3. Match Step length to patient anthropometry'
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
                '  A: Match gait speed and Step length to patient data'
                ''
                '  Q: Need different gait patterns?'
                '  A: Modify speed/Step to match desired pathology'
                ''
                '══════════════════════════════════════════════════════════════════════════════════════'
                ''
                '  CONTACT & VERSION INFO:'
                ''
                '  Author: Rafael Pérez-San Lázaro'
                '  Version: 1.0 (January 2026)'
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
function generate_exoskeleton_trajectories_backend(n_points, n_cycles, gait_speed, step_length, amplitude_scale, smoothness, plot_results, save_data, verify_continuous, save_data_format)
% function for generating exoskeleton trajectories with biomechanical scaling
% Based on scientific reference:
% 1. Lim et al. (2017) - Effects of step length and step frequency on lower-limb muscle function in human gait

%% Gait timing parameters
gait_cycle_time = step_length / gait_speed;
total_time = n_cycles * gait_cycle_time;
time_vector = linspace(0, total_time, n_points)';

%% Define key gait events and baseline joint angles (at 1.2 m/s, 0.7 m Step)
gait_events = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100];
hip_keypoints_baseline = [20, 10, 5, -5, -15, -20, -10, 10, 25, 35, 20];
knee_keypoints_baseline = [10, 12, 20, 15, 5, 0, 15, 40, 70, 25, 10];
ankle_keypoints_baseline = [0, -7, -10, -15, -20, -18, -10, 5, 10, 15, 0];

% Obtain coefficients to adjust the keypoints based on step length and gait
% speed
hip_flex_step_length_adj = ( gait_speed/step_length - 0.73 ) * 6.54; 
hip_ext_step_length_adj = ( gait_speed/step_length - 0.73 ) * 5.71;
Knee_flex_step_length_adj = ( gait_speed/step_length - 0.73 ) * 6.61;
hip_flex_gait_speed_adj = ( gait_speed - 0.73 ) * 0.18; 
hip_ext_gait_speed_adj = ( gait_speed - 0.73 ) * (-0.17);
Knee_flex_gait_speed_adj = ( gait_speed - 0.73 ) * 2.94;

hip_keypoints_baseline(hip_keypoints_baseline > 0) = hip_keypoints_baseline(hip_keypoints_baseline > 0) + hip_flex_step_length_adj + hip_flex_gait_speed_adj;
hip_keypoints_baseline(hip_keypoints_baseline < 0) = hip_keypoints_baseline(hip_keypoints_baseline < 0) + hip_ext_step_length_adj + hip_ext_gait_speed_adj;
knee_keypoints_baseline(knee_keypoints_baseline > 0) = knee_keypoints_baseline(knee_keypoints_baseline > 0) + Knee_flex_step_length_adj + Knee_flex_gait_speed_adj;

% Copy baseline keypoints
hip_keypoints = hip_keypoints_baseline;
knee_keypoints = knee_keypoints_baseline;
ankle_keypoints = ankle_keypoints_baseline;

%% Apply amplitude scaling to all joints
hip_keypoints = hip_keypoints * amplitude_scale;
knee_keypoints = knee_keypoints * amplitude_scale;
ankle_keypoints = ankle_keypoints * amplitude_scale;

%% Generate smooth trajectories with preallocation
cycle_duration = 100;

% Calculate total number of events for preallocation
total_events = 0;
for cycle = 0:n_cycles-1
    if cycle < n_cycles - 1 || mod(n_cycles, 1) == 0
        total_events = total_events + length(gait_events) - 1;
    else
        partial_length = (n_cycles - cycle) * cycle_duration;
        partial_events_idx = gait_events <= partial_length;
        total_events = total_events + sum(partial_events_idx);
    end
end
total_events = total_events + 1;  % Add final point

% Preallocate arrays
full_cycle_events = zeros(1, total_events);
full_hip_points = zeros(1, total_events);
full_knee_points = zeros(1, total_events);
full_ankle_points = zeros(1, total_events);

% Fill arrays
idx = 1;
for cycle = 0:n_cycles-1
    cycle_offset = cycle * cycle_duration;
    if cycle < n_cycles - 1 || mod(n_cycles, 1) == 0
        % Full cycle
        cycle_events = gait_events(1:end-1) + cycle_offset;
        n_events = length(cycle_events);
        full_cycle_events(idx:idx+n_events-1) = cycle_events;
        full_hip_points(idx:idx+n_events-1) = hip_keypoints(1:end-1);
        full_knee_points(idx:idx+n_events-1) = knee_keypoints(1:end-1);
        full_ankle_points(idx:idx+n_events-1) = ankle_keypoints(1:end-1);
        idx = idx + n_events;
    else
        % Partial cycle
        partial_length = (n_cycles - cycle) * cycle_duration;
        partial_events_idx = gait_events <= partial_length;
        cycle_events = gait_events(partial_events_idx) + cycle_offset;
        n_events = length(cycle_events);
        full_cycle_events(idx:idx+n_events-1) = cycle_events;
        full_hip_points(idx:idx+n_events-1) = hip_keypoints(partial_events_idx);
        full_knee_points(idx:idx+n_events-1) = knee_keypoints(partial_events_idx);
        full_ankle_points(idx:idx+n_events-1) = ankle_keypoints(partial_events_idx);
        idx = idx + n_events;
    end
end

% Add final point
full_cycle_events(idx) = n_cycles * cycle_duration;
full_hip_points(idx) = hip_keypoints(1);
full_knee_points(idx) = knee_keypoints(1);
full_ankle_points(idx) = ankle_keypoints(1);

time_keypoints = full_cycle_events * total_time / (n_cycles * cycle_duration);
smoothness_factor = smoothness / 10;

hip_trajectory = smooth_spline_interpolation(time_keypoints, full_hip_points, time_vector, smoothness_factor);
knee_trajectory = smooth_spline_interpolation(time_keypoints, full_knee_points, time_vector, smoothness_factor);
ankle_trajectory = smooth_spline_interpolation(time_keypoints, full_ankle_points, time_vector, smoothness_factor);

if smoothness >= 7
    filter_order = 3;
    cutoff_freq = 0.1;
    [b, a] = butter(filter_order, cutoff_freq, 'low');
    hip_trajectory = filtfilt(b, a, hip_trajectory);
    knee_trajectory = filtfilt(b, a, knee_trajectory);
    ankle_trajectory = filtfilt(b, a, ankle_trajectory);
end

%% Determine unit label and convert
if strcmp(save_data_format, 'rad')
    unit_label = 'radians';
    unit_conversion = pi/180;
else
    unit_label = 'degrees';
    unit_conversion = 1;
end

hip_trajectory_display = hip_trajectory * unit_conversion;
knee_trajectory_display = knee_trajectory * unit_conversion;
ankle_trajectory_display = ankle_trajectory * unit_conversion;

%% Create trajectory data structure
traj_data = struct();
traj_data.hip = hip_trajectory_display;
traj_data.knee = knee_trajectory_display;
traj_data.ankle = ankle_trajectory_display;
traj_data.time = time_vector;
traj_data.unit_label = unit_label;
traj_data.gait_cycle_time = gait_cycle_time;
traj_data.gait_speed = gait_speed;
traj_data.step_length = step_length;
traj_data.amplitude_scale = amplitude_scale;
traj_data.n_points = n_points;

%% Display information
fprintf('\n');
fprintf('══════════════════════════════════════════════════\n');
fprintf('  Lower Limb Exoskeleton Reference Trajectories Generated\n');
fprintf('══════════════════════════════════════════════════\n');
fprintf('\nBiomechanical Scaling Applied (Scientific References):\n');
fprintf('  [1] Lim et al. (2017) - Step length vs frequency effects\n');
fprintf('\nConfiguration:\n');
fprintf('  • Points per trajectory: %d\n', n_points);
fprintf('  • Number of gait cycles: %.1f\n', n_cycles);
fprintf('  • Gait speed: %.2f m/s (Ref: 1.2 m/s baseline)\n', gait_speed);
fprintf('  • Step length: %.2f m (Ref: 0.7 m baseline)\n', step_length);
fprintf('  • Amplitude scale: %.2f (%.0f%%)\n', amplitude_scale, amplitude_scale*100);
fprintf('  • Cycle duration: %.3f s\n', gait_cycle_time);
fprintf('  • Total duration: %.3f s\n', total_time);
fprintf('  • Smoothness level: %d/10\n', smoothness);
fprintf('  • Output units: %s\n', unit_label);
fprintf('\nJoint Ranges (after biomechanical scaling):\n');
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
function trajectory = smooth_spline_interpolation(time_points, angle_points, time_vector, smoothness_factor)
rough_traj = pchip(time_points, angle_points, time_vector);
if smoothness_factor >= 0.7
    window_size = max(3, round(length(time_vector) * 0.02));
    if mod(window_size, 2) == 0
        window_size = window_size + 1;
    end
    trajectory = smooth(rough_traj, window_size, 'sgolay', 3);
else
    trajectory = smooth(rough_traj, 'rloess');
end
end
function create_exoskeleton_plots(traj_data)
figure('Position', [100, 100, 1300, 900], 'Name', 'Exoskeleton Trajectories', 'NumberTitle', 'off');
colors = struct('hip', [0.8, 0.2, 0.2], 'knee', [0.2, 0.6, 0.8], 'ankle', [0.2, 0.8, 0.2]);
time_vec = traj_data.time;
hip_traj = traj_data.hip;
knee_traj = traj_data.knee;
ankle_traj = traj_data.ankle;
unit_label = traj_data.unit_label;
cycle_time = traj_data.gait_cycle_time;

t = tiledlayout(3, 2);
% Decrease space between tiles and the figure edges
t.TileSpacing = 'compact'; 
t.Padding = 'compact'; 

% Plot 1: All trajectories
nexttile
plot(time_vec, hip_traj, 'Color', colors.hip, 'LineWidth', 1.5); hold on;
plot(time_vec, knee_traj, 'Color', colors.knee, 'LineWidth', 1.5);
plot(time_vec, ankle_traj, 'Color', colors.ankle, 'LineWidth', 1.5);
xlabel('Time (s)', 'FontSize', 13, 'FontWeight', 'bold');
ylabel(['Joint Angle (' unit_label ')'], 'FontSize', 13, 'FontWeight', 'bold');
title('All Joint Trajectories vs Time', 'FontSize', 15, 'FontWeight', 'bold');
legend('Hip', 'Knee', 'Ankle', 'Location', 'best', 'FontSize', 11);
grid on;
range = max(knee_traj)-min(ankle_traj);
ylim([min(ankle_traj)-(10) max(knee_traj)+(range*0.1)])
xlim([min(time_vec) max(time_vec)])

% Plot 2: Single gait cycle
nexttile
cycle_samples = round(length(time_vec) / (max(time_vec) / cycle_time));
cycle_percent = linspace(0, 100, cycle_samples);
plot(cycle_percent, hip_traj(1:cycle_samples), 'Color', colors.hip, 'LineWidth', 1.5); hold on;
plot(cycle_percent, knee_traj(1:cycle_samples), 'Color', colors.knee, 'LineWidth', 1.5);
plot(cycle_percent, ankle_traj(1:cycle_samples), 'Color', colors.ankle, 'LineWidth', 1.5);
xline(60, 'k--', 'Alpha', 0.7, 'LineWidth', 1.5, 'DisplayName', 'Toe Off');
xline(0, 'k:', 'Alpha', 0.7, 'LineWidth', 1.5, 'DisplayName', 'Heel Strike');
xlabel('Gait Cycle (\%)', 'Interpreter', 'latex', 'FontSize', 13, 'FontWeight', 'bold');
ylabel(['Joint Angle (' unit_label ')'], 'Interpreter', 'latex', 'FontSize', 13, 'FontWeight', 'bold');
title('Single Gait Cycle Pattern', 'Interpreter', 'latex', 'FontSize', 15, 'FontWeight', 'bold');
legend('Hip', 'Knee', 'Ankle', 'Toe Off', 'Heel Strike', 'Interpreter', 'latex', 'Location', 'best', 'FontSize', 11);
grid on;

% Plot 3: Hip
nexttile
plot(time_vec, hip_traj, 'Color', colors.hip, 'LineWidth', 1.5);
xlabel('Time (s)', 'FontSize', 13, 'FontWeight', 'bold');
ylabel(['Hip Angle (' unit_label ')'], 'FontSize', 13, 'FontWeight', 'bold');
title('Hip Joint Trajectory', 'FontSize', 15, 'FontWeight', 'bold');
range = max(hip_traj)-min(hip_traj);
ylim([min(hip_traj)-(10) max(hip_traj)+(range*0.1)])
xlim([min(time_vec) max(time_vec)])
grid on;
yline(0, 'k--', 'Alpha', 0.5, 'DisplayName', 'Neutral');
legend('Hip Flexion/Extension', 'Neutral Position', 'FontSize', 11);

% Plot 4: Knee
nexttile
plot(time_vec, knee_traj, 'Color', colors.knee, 'LineWidth', 1.5);
xlabel('Time (s)', 'FontSize', 13, 'FontWeight', 'bold');
ylabel(['Knee Angle (' unit_label ')'], 'FontSize', 13, 'FontWeight', 'bold');
title('Knee Joint k', 'FontSize', 15, 'FontWeight', 'bold');
range = max(knee_traj)-min(knee_traj);
ylim([min(knee_traj)-(10) max(knee_traj)+(range*0.1)])
xlim([min(time_vec) max(time_vec)])
grid on;
yline(0, 'k--', 'Alpha', 0.5, 'DisplayName', 'Full Extension');
legend('Knee Flexion', 'Full Extension', 'FontSize', 11);

% Plot 5: Ankle
nexttile
plot(time_vec, ankle_traj, 'Color', colors.ankle, 'LineWidth', 1.5);
xlabel('Time (s)', 'FontSize', 13, 'FontWeight', 'bold');
ylabel(['Ankle Angle (' unit_label ')'], 'FontSize', 13, 'FontWeight', 'bold');
title('Ankle Joint Trajectory', 'FontSize', 15, 'FontWeight', 'bold');
range = max(ankle_traj)-min(ankle_traj);
ylim([min(ankle_traj)-(10) max(ankle_traj)+(range*0.1)])
xlim([min(time_vec) max(time_vec)])
grid on;
yline(0, 'k--', 'Alpha', 0.5, 'DisplayName', 'Neutral');
legend('Dorsi/Plantarflexion', 'Neutral Position', 'FontSize', 11);

% Plot 6: 3D Coordination
nexttile
plot3(hip_traj, knee_traj, ankle_traj, 'k-', 'LineWidth', 1.5);
xlabel(['Hip Angle (' unit_label ')'], 'FontSize', 13, 'FontWeight', 'bold');
ylabel(['Knee Angle (' unit_label ')'], 'FontSize', 13, 'FontWeight', 'bold');
zlabel(['Ankle Angle (' unit_label ')'], 'FontSize', 13, 'FontWeight', 'bold');
title('Joint Coordination Pattern', 'FontSize', 15, 'FontWeight', 'bold');
grid on; view(45, 30);

end
function verify_continuous_data(traj_data)
figure('Position', [100, 100, 700, 400], 'Name', 'Continuity Verification', 'NumberTitle', 'off');
colors = struct('hip', [0.8, 0.2, 0.2], 'knee', [0.2, 0.6, 0.8], 'ankle', [0.2, 0.8, 0.2]);
time_vec = traj_data.time;
hip_traj = traj_data.hip;
knee_traj = traj_data.knee;
ankle_traj = traj_data.ankle;
unit_label = traj_data.unit_label;
cycle_time = traj_data.gait_cycle_time;

cycle_samples = round(length(time_vec) / (max(time_vec) / cycle_time));
plot([hip_traj(1:cycle_samples); hip_traj(1:cycle_samples)], 'Color', colors.hip, 'LineWidth', 2.5); hold on;
plot([knee_traj(1:cycle_samples); knee_traj(1:cycle_samples)], 'Color', colors.knee, 'LineWidth', 2.5);
plot([ankle_traj(1:cycle_samples); ankle_traj(1:cycle_samples)], 'Color', colors.ankle, 'LineWidth', 2.5);
xline(cycle_samples, 'k--', 'LineWidth', 2, 'Alpha', 0.7, 'DisplayName', 'Cycle Boundary');
legend('Hip', 'Knee', 'Ankle', 'Cycle Boundary', 'FontSize', 11, 'Location', 'best');
ylabel(['Joint Angle (' unit_label ')'], 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Sample Points (2 Cycles)', 'FontSize', 12, 'FontWeight', 'bold');
grid on;
title('Continuity Verification: Two Consecutive Cycles', 'FontSize', 14, 'FontWeight', 'bold');
end
function save_exoskeleton_data(traj_data, plot_results)
time_vec = traj_data.time;
hip_traj = traj_data.hip;
knee_traj = traj_data.knee;
ankle_traj = traj_data.ankle;
unit_label = traj_data.unit_label;
gait_speed = traj_data.gait_speed;
step_length = traj_data.step_length;
amplitude_scale = traj_data.amplitude_scale;
exoskeleton_data = struct();
exoskeleton_data.time = time_vec;
exoskeleton_data.hip_angle = hip_traj;
exoskeleton_data.knee_angle = knee_traj;
exoskeleton_data.ankle_angle = ankle_traj;
exoskeleton_data.parameters.gait_speed = gait_speed;
exoskeleton_data.parameters.step_length = step_length;
exoskeleton_data.parameters.amplitude_scale = amplitude_scale;
exoskeleton_data.parameters.sample_rate = length(time_vec) / max(time_vec);
exoskeleton_data.info.units = unit_label;
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
fprintf(fid, '%% Amplitude Scale: %.2f\n', amplitude_scale);
fprintf(fid, '%% Units: %s\n', unit_label);
fprintf(fid, '%% Sample Rate: %.1f Hz\n', length(time_vec) / max(time_vec));
fprintf(fid, '%% Biomechanical Scaling References:\n');
fprintf(fid, '%%   [1] Oberg et al. (1993)\n');
fprintf(fid, '%%   [2] Kwon et al. (2015)\n');
fprintf(fid, '%%   [3] Lim et al. (2017)\n');
fprintf(fid, '%%   [4] Judge et al. (1996)\n');
fprintf(fid, '%% Columns: Time(s), Hip, Knee, Ankle\n');
for i = 1:length(time_vec)
    fprintf(fid, '%.4f\t%.6f\t%.6f\t%.6f\n', time_vec(i), hip_traj(i), knee_traj(i), ankle_traj(i));
end
fclose(fid);
fprintf('✓ Data exported to: exoskeleton_trajectories.txt\n');

hip_traj_arduino = hip_traj(1:10:length(hip_traj)) * 0.75;
knee_traj_arduino = knee_traj(1:10:length(knee_traj)) * 0.75;
ankle_traj_arduino = ankle_traj(1:10:length(ankle_traj)) * 0.75;
time_vec_arduino = time_vec(1:10:length(time_vec));

fid = fopen('exoskeleton_trajectories_arduino.txt', 'w');
fprintf(fid, 'float hip_r[');
fprintf(fid, '%u', length(hip_traj_arduino));
fprintf(fid, '] = {');
for i = 1:length(time_vec_arduino)
    if i == length(time_vec_arduino)
        fprintf(fid, '%.3f', hip_traj_arduino(i));
    else
        fprintf(fid, '%.3f,', hip_traj_arduino(i));
    end
end
fprintf(fid, '};\n');

fprintf(fid, 'float knee_r[');
fprintf(fid, '%u', length(knee_traj_arduino));
fprintf(fid, '] = {');
for i = 1:length(time_vec_arduino)
    if i == length(time_vec_arduino)
        fprintf(fid, '%.3f', knee_traj_arduino(i));
    else
        fprintf(fid, '%.3f,', knee_traj_arduino(i));
    end
end
fprintf(fid, '};\n');

fprintf(fid, 'float ankle_r[');
fprintf(fid, '%u', length(ankle_traj_arduino));
fprintf(fid, '] = {');
for i = 1:length(time_vec_arduino)
    if i == length(time_vec_arduino)
        fprintf(fid, '%.3f', ankle_traj_arduino(i));
    else
        fprintf(fid, '%.3f,', ankle_traj_arduino(i));
    end
end
fprintf(fid, '};\n');

halfLength = floor(length(hip_traj_arduino) / 2);
shiftedVectorHip = circshift(hip_traj_arduino, halfLength);
fprintf(fid, 'hip_l[');
fprintf(fid, '%u', length(hip_traj_arduino));
fprintf(fid, '] = {');
for i = 1:length(time_vec_arduino)
    if i == length(time_vec_arduino)
        fprintf(fid, '%.3f', shiftedVectorHip(i));
    else
        fprintf(fid, '%.3f,', shiftedVectorHip(i));
    end
end
fprintf(fid, '};\n');

shiftedVectorKnee = circshift(knee_traj_arduino, halfLength);
fprintf(fid, 'knee_l[');
fprintf(fid, '%u', length(knee_traj_arduino));
fprintf(fid, '] = {');
for i = 1:length(time_vec_arduino)
    if i == length(time_vec_arduino)
        fprintf(fid, '%.3f', shiftedVectorKnee(i));
    else
        fprintf(fid, '%.3f,', shiftedVectorKnee(i));
    end
end
fprintf(fid, '};\n');

shiftedVectorAnkle = circshift(ankle_traj_arduino, halfLength);
fprintf(fid, 'ankle_l[');
fprintf(fid, '%u', length(ankle_traj_arduino));
fprintf(fid, '] = {');
for i = 1:length(time_vec_arduino)
    if i == length(time_vec_arduino)
        fprintf(fid, '%.3f', shiftedVectorAnkle(i));
    else
        fprintf(fid, '%.3f,', shiftedVectorAnkle(i));
    end
end
fprintf(fid, '};\n');
fclose(fid);
fprintf('✓ Data exported to: exoskeleton_trajectories_arduino.txt\n');

if plot_results
    figure('Position', [100, 100, 1200, 400], 'Name', 'Arduino Phase Shift', 'NumberTitle', 'off');
    colors = struct('hip', [0.8, 0.2, 0.2], 'knee', [0.2, 0.6, 0.8], 'ankle', [0.2, 0.8, 0.2]);

    subplot(1,3,1);
    plot(hip_traj_arduino, 'Color', colors.hip, 'LineWidth', 2.5); hold on;
    plot(shiftedVectorHip, '-.', 'Color', colors.hip, 'LineWidth', 2.5);
    legend('Right', 'Left (Shifted)', 'FontSize', 10);
    ylabel(['Hip Angle (' unit_label ')'], 'FontSize', 11, 'FontWeight', 'bold');
    title('Hip', 'FontSize', 12, 'FontWeight', 'bold');
    grid on;

    subplot(1,3,2);
    plot(knee_traj_arduino, 'Color', colors.knee, 'LineWidth', 2.5); hold on;
    plot(shiftedVectorKnee, '-.', 'Color', colors.knee, 'LineWidth', 2.5);
    legend('Right', 'Left (Shifted)', 'FontSize', 10);
    ylabel(['Knee Angle (' unit_label ')'], 'FontSize', 11, 'FontWeight', 'bold');
    title('Knee', 'FontSize', 12, 'FontWeight', 'bold');
    grid on;

    subplot(1,3,3);
    plot(ankle_traj_arduino, 'Color', colors.ankle, 'LineWidth', 2.5); hold on;
    plot(shiftedVectorAnkle, '-.', 'Color', colors.ankle, 'LineWidth', 2.5);
    legend('Right', 'Left (Shifted)', 'FontSize', 10);
    ylabel(['Ankle Angle (' unit_label ')'], 'FontSize', 11, 'FontWeight', 'bold');
    title('Ankle', 'FontSize', 12, 'FontWeight', 'bold');
    grid on;

    sgtitle('Left/Right Leg Phase Shift', 'FontSize', 14, 'FontWeight', 'bold');
end
end