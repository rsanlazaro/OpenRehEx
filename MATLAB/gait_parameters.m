%% gait_parameters.m
%  Illustrative reference table of common biomechanical gait parameters.
%
%  PURPOSE:
%    This script prints a formatted summary of typical gait parameters
%    reported in the biomechanics literature for healthy adults.
%    Values are grouped by gait condition (slow / normal / fast) and
%    include spatiotemporal, kinematic, and kinetic measures.
%
%  NOTE:
%    All values are population-based averages for illustrative purposes.
%    Individual variation can be significant.
%
%  KEY REFERENCES:
%    [1] Oberg et al. (1993)  - J Rehabil Res Dev
%    [2] Kadaba et al. (1990) - J Orthop Res
%    [3] Lim   et al. (2017)  - J Biomech
%    [4] Perry & Burnfield (2010) - Gait Analysis: Normal and Pathological Function
%    [5] Winter (1991)        - The Biomechanics and Motor Control of Human Gait
% =========================================================================

clc;
fprintf('\n');
fprintf('╔══════════════════════════════════════════════════════════════════════════╗\n');
fprintf('║          ILLUSTRATIVE BIOMECHANICAL GAIT PARAMETER REFERENCE            ║\n');
fprintf('╚══════════════════════════════════════════════════════════════════════════╝\n\n');

% -------------------------------------------------------------------------
%  1. SPATIOTEMPORAL PARAMETERS  (primary parameters)
% -------------------------------------------------------------------------
fprintf('┌──────────────────────────────────────────────────────────────────────────┐\n');
fprintf('│  1.  SPATIOTEMPORAL PARAMETERS                                           │\n');
fprintf('│      (primary characterisation of gait speed and step length)           │\n');
fprintf('└──────────────────────────────────────────────────────────────────────────┘\n\n');

fprintf('  %-35s  %-10s  %-10s  %-10s  %-8s\n', ...
        'Parameter', 'Slow', 'Normal', 'Fast', 'Unit');
fprintf('  %s\n', repmat('-', 1, 80));

% --- Gait Speed (the single most influential spatiotemporal parameter)
fprintf('  %-35s  %-10.2f  %-10.2f  %-10.2f  %-8s\n', ...
        'Gait Speed  *KEY*', 0.89, 1.40, 2.02, 'm/s');

% --- Step Length (second most influential spatiotemporal parameter)
fprintf('  %-35s  %-10.2f  %-10.2f  %-10.2f  %-8s\n', ...
        'Step Length  *KEY*', 0.58, 0.73, 0.87, 'm');

% --- Remaining spatiotemporal parameters
fprintf('  %-35s  %-10.2f  %-10.2f  %-10.2f  %-8s\n', ...
        'Stride Length', 1.16, 1.46, 1.74, 'm');
fprintf('  %-35s  %-10.1f  %-10.1f  %-10.1f  %-8s\n', ...
        'Cadence', 95, 113, 132, 'steps/min');
fprintf('  %-35s  %-10.2f  %-10.2f  %-10.2f  %-8s\n', ...
        'Gait Cycle Duration', 1.30, 1.06, 0.91, 's');
fprintf('  %-35s  %-10.0f  %-10.0f  %-10.0f  %-8s\n', ...
        'Stance Phase', 65, 62, 58, '%  cycle');
fprintf('  %-35s  %-10.0f  %-10.0f  %-10.0f  %-8s\n', ...
        'Swing Phase', 35, 38, 42, '%  cycle');
fprintf('  %-35s  %-10.0f  %-10.0f  %-10.0f  %-8s\n', ...
        'Double Support', 24, 18, 10, '%  cycle');
fprintf('  %-35s  %-10.2f  %-10.2f  %-10.2f  %-8s\n', ...
        'Step Width', 0.14, 0.12, 0.11, 'm');

fprintf('\n  * Gait speed and step length are the primary parameters driving\n');
fprintf('    joint angle amplitude changes across the hip, knee, and ankle.\n\n');

% -------------------------------------------------------------------------
%  2. HIP JOINT KINEMATICS
% -------------------------------------------------------------------------
fprintf('┌──────────────────────────────────────────────────────────────────────────┐\n');
fprintf('│  2.  HIP JOINT KINEMATICS  (sagittal plane)                             │\n');
fprintf('└──────────────────────────────────────────────────────────────────────────┘\n\n');

fprintf('  %-35s  %-10s  %-10s  %-10s  %-8s\n', ...
        'Parameter', 'Slow', 'Normal', 'Fast', 'Unit');
fprintf('  %s\n', repmat('-', 1, 80));
fprintf('  %-35s  %-10.1f  %-10.1f  %-10.1f  %-8s\n', ...
        'Peak Flexion  (swing)',         28.5, 32.2, 38.0, 'deg');
fprintf('  %-35s  %-10.1f  %-10.1f  %-10.1f  %-8s\n', ...
        'Peak Extension  (late stance)', -14.0, -19.0, -23.5, 'deg');
fprintf('  %-35s  %-10.1f  %-10.1f  %-10.1f  %-8s\n', ...
        'Total ROM', 42.5, 51.2, 61.5, 'deg');
fprintf('  %-35s  %-10.1f  %-10.1f  %-10.1f  %-8s\n', ...
        'Angle at Heel Strike', 20.0, 22.5, 26.0, 'deg (flex)');
fprintf('  %-35s  %-10.1f  %-10.1f  %-10.1f  %-8s\n', ...
        'Angle at Toe Off',     -10.0, -15.0, -20.0, 'deg (ext)');
fprintf('\n');

% -------------------------------------------------------------------------
%  3. KNEE JOINT KINEMATICS
% -------------------------------------------------------------------------
fprintf('┌──────────────────────────────────────────────────────────────────────────┐\n');
fprintf('│  3.  KNEE JOINT KINEMATICS  (sagittal plane)                            │\n');
fprintf('└──────────────────────────────────────────────────────────────────────────┘\n\n');

fprintf('  %-35s  %-10s  %-10s  %-10s  %-8s\n', ...
        'Parameter', 'Slow', 'Normal', 'Fast', 'Unit');
fprintf('  %s\n', repmat('-', 1, 80));
fprintf('  %-35s  %-10.1f  %-10.1f  %-10.1f  %-8s\n', ...
        'Peak Flexion  (swing)',       55.0, 65.0, 73.0, 'deg');
fprintf('  %-35s  %-10.1f  %-10.1f  %-10.1f  %-8s\n', ...
        'Loading Response Flexion',     8.0, 12.0, 17.0, 'deg');
fprintf('  %-35s  %-10.1f  %-10.1f  %-10.1f  %-8s\n', ...
        'Minimum  (mid-stance)',         2.0,  4.0,  6.0, 'deg');
fprintf('  %-35s  %-10.1f  %-10.1f  %-10.1f  %-8s\n', ...
        'Angle at Heel Strike',          8.0, 10.0, 13.0, 'deg (flex)');
fprintf('  %-35s  %-10.1f  %-10.1f  %-10.1f  %-8s\n', ...
        'Angle at Toe Off',             35.0, 42.0, 50.0, 'deg (flex)');
fprintf('\n');

% -------------------------------------------------------------------------
%  4. ANKLE JOINT KINEMATICS
% -------------------------------------------------------------------------
fprintf('┌──────────────────────────────────────────────────────────────────────────┐\n');
fprintf('│  4.  ANKLE JOINT KINEMATICS  (sagittal plane)                           │\n');
fprintf('└──────────────────────────────────────────────────────────────────────────┘\n\n');

fprintf('  %-35s  %-10s  %-10s  %-10s  %-8s\n', ...
        'Parameter', 'Slow', 'Normal', 'Fast', 'Unit');
fprintf('  %s\n', repmat('-', 1, 80));
fprintf('  %-35s  %-10.1f  %-10.1f  %-10.1f  %-8s\n', ...
        'Peak Dorsiflexion  (stance)',   10.0, 13.0, 15.5, 'deg');
fprintf('  %-35s  %-10.1f  %-10.1f  %-10.1f  %-8s\n', ...
        'Peak Plantarflexion  (push-off)', -14.0, -18.0, -22.0, 'deg');
fprintf('  %-35s  %-10.1f  %-10.1f  %-10.1f  %-8s\n', ...
        'Total ROM', 24.0, 31.0, 37.5, 'deg');
fprintf('  %-35s  %-10.1f  %-10.1f  %-10.1f  %-8s\n', ...
        'Angle at Heel Strike', 2.0, 0.0, -2.0, 'deg');
fprintf('  %-35s  %-10.1f  %-10.1f  %-10.1f  %-8s\n', ...
        'Angle at Toe Off', -12.0, -15.0, -20.0, 'deg (plant.)');
fprintf('\n');

% -------------------------------------------------------------------------
%  5. JOINT KINETICS  (moments)
% -------------------------------------------------------------------------
fprintf('┌──────────────────────────────────────────────────────────────────────────┐\n');
fprintf('│  5.  JOINT MOMENTS  (normalised to body mass)                           │\n');
fprintf('└──────────────────────────────────────────────────────────────────────────┘\n\n');

fprintf('  %-35s  %-10s  %-10s  %-10s  %-8s\n', ...
        'Parameter', 'Slow', 'Normal', 'Fast', 'Unit');
fprintf('  %s\n', repmat('-', 1, 80));
fprintf('  %-35s  %-10.2f  %-10.2f  %-10.2f  %-8s\n', ...
        'Peak Hip Extensor Moment', 0.65, 0.82, 1.05, 'N·m/kg');
fprintf('  %-35s  %-10.2f  %-10.2f  %-10.2f  %-8s\n', ...
        'Peak Hip Flexor Moment', 0.40, 0.55, 0.72, 'N·m/kg');
fprintf('  %-35s  %-10.2f  %-10.2f  %-10.2f  %-8s\n', ...
        'Peak Knee Extensor Moment', 0.50, 0.68, 0.90, 'N·m/kg');
fprintf('  %-35s  %-10.2f  %-10.2f  %-10.2f  %-8s\n', ...
        'Peak Ankle Plantarflexor Moment', 1.20, 1.50, 1.85, 'N·m/kg');
fprintf('\n');

% -------------------------------------------------------------------------
%  6. GAIT PHASE TIMINGS
% -------------------------------------------------------------------------
fprintf('┌──────────────────────────────────────────────────────────────────────────┐\n');
fprintf('│  6.  GAIT PHASE TIMINGS  (%% of gait cycle)                              │\n');
fprintf('└──────────────────────────────────────────────────────────────────────────┘\n\n');

fprintf('  %-30s  %-10s  %-10s\n', 'Phase / Event', 'Onset (%)', 'End (%)');
fprintf('  %s\n', repmat('-', 1, 55));
fprintf('  %-30s  %-10.0f  %-10.0f\n', 'Heel Strike (initial contact)',   0,   0);
fprintf('  %-30s  %-10.0f  %-10.0f\n', 'Loading Response',                0,  10);
fprintf('  %-30s  %-10.0f  %-10.0f\n', 'Mid Stance',                     10,  30);
fprintf('  %-30s  %-10.0f  %-10.0f\n', 'Terminal Stance',                30,  50);
fprintf('  %-30s  %-10.0f  %-10.0f\n', 'Pre-Swing  (Toe Off ~60%%)',      50,  60);
fprintf('  %-30s  %-10.0f  %-10.0f\n', 'Initial Swing',                  60,  73);
fprintf('  %-30s  %-10.0f  %-10.0f\n', 'Mid Swing',                      73,  87);
fprintf('  %-30s  %-10.0f  %-10.0f\n', 'Terminal Swing',                 87, 100);
fprintf('\n');

% -------------------------------------------------------------------------
%  7. SPEED–STEP LENGTH SENSITIVITY  (illustrative linear estimates)
% -------------------------------------------------------------------------
fprintf('┌──────────────────────────────────────────────────────────────────────────┐\n');
fprintf('│  7.  SPEED & STEP LENGTH SENSITIVITY ON JOINT ANGLES                    │\n');
fprintf('│      Approximate change per unit increase (based on Lim et al. 2017)   │\n');
fprintf('└──────────────────────────────────────────────────────────────────────────┘\n\n');

fprintf('  %-40s  %-12s  %-12s\n', 'Joint Angle Peak', ...
        'Δ / (m/s)', 'Δ / (m step)');
fprintf('  %s\n', repmat('-', 1, 68));
fprintf('  %-40s  %-12.2f  %-12.2f\n', 'Hip Flexion Peak   (deg)', 0.18,  6.54);
fprintf('  %-40s  %-12.2f  %-12.2f\n', 'Hip Extension Peak (deg)', -0.17,  5.71);
fprintf('  %-40s  %-12.2f  %-12.2f\n', 'Knee Flexion Peak  (deg)', 2.94,  6.61);
fprintf('  %-40s  %-12s  %-12s\n',    'Ankle  (minor coupling)',  '~0',  '~0');

fprintf('\n  Interpretation:\n');
fprintf('    • Increasing gait speed by 1 m/s raises peak knee flexion ~2.9 deg\n');
fprintf('    • Increasing step length by 1 m  raises peak hip flexion  ~6.5 deg\n');
fprintf('    • Ankle kinematics are less sensitive to these spatiotemporal changes\n\n');

% -------------------------------------------------------------------------
%  Footer
% -------------------------------------------------------------------------
fprintf('╔══════════════════════════════════════════════════════════════════════════╗\n');
fprintf('║  JOINT ANGLE SIGN CONVENTIONS (sagittal plane, right leg)              ║\n');
fprintf('╠══════════════════════════════════════════════════════════════════════════╣\n');
fprintf('║  Hip  :  (+) Flexion           (-)  Extension                          ║\n');
fprintf('║  Knee :  (+) Flexion           (-)  Extension  (hyperextension)        ║\n');
fprintf('║  Ankle:  (+) Dorsiflexion      (-)  Plantarflexion                     ║\n');
fprintf('╠══════════════════════════════════════════════════════════════════════════╣\n');
fprintf('║  REFERENCES                                                             ║\n');
fprintf('║  [1] Oberg et al. (1993)  J Rehabil Res Dev                            ║\n');
fprintf('║  [2] Kadaba et al. (1990) J Orthop Res                                 ║\n');
fprintf('║  [3] Lim   et al. (2017)  J Biomech                                    ║\n');
fprintf('║  [4] Perry & Burnfield (2010) Gait Analysis                            ║\n');
fprintf('║  [5] Winter (1991) Biomechanics and Motor Control of Human Gait        ║\n');
fprintf('╚══════════════════════════════════════════════════════════════════════════╝\n\n');