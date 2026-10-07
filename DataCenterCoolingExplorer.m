function app = DataCenterCoolingExplorer(varargin)
%DATACENTERCOOLINGEXPLORER Interactive, synthetic data-center cooling lesson.
%
% Run DataCenterCoolingExplorer from the project root. Choose a teaching
% scenario, predict how one output will change, then watch the Explorer
% load the scenario and explain the result. Drag any slider to see the heat
% split, coolant temperature rise, component temperature, and transient
% response update while you move it. This educational model is
% intentionally not a calibrated rack, cold-plate, or facility model.
%
% Name-value options:
%   'Visible'  - 'on' (default) or 'off' for automated tests and rendering.
%   'Position' - figure position [left bottom width height] in pixels. The
%                default fits the window to the screen.

parser = inputParser;
addParameter(parser, 'Visible', 'on', @(value) any(validatestring(value, {'on', 'off'})));
addParameter(parser, 'Position', [], @(value) isempty(value) || ...
    (isnumeric(value) && numel(value) == 4 && all(isfinite(value))));
parse(parser, varargin{:});

projectRoot = fileparts(mfilename('fullpath'));
addpath(fullfile(projectRoot, 'src'));

model = struct( ...
    'specificHeat_J_kgK', 4180, ...
    'thermalCapacitance_J_K', 30000, ...
    'stepTime_s', 60, ...
    'baseLoadFraction', 0.40, ...
    'cueTemperature_C', 85, ...
    'saturationTemperature_C', 100);
degC = [char(176) 'C'];
tauSymbol = char(964);

% Okabe-Ito colors are distinguishable with common color-vision deficiencies.
colors = struct( ...
    'navy', [0.05 0.16 0.29], ...
    'blue', [0 114 178] / 255, ...
    'sky', [86 180 233] / 255, ...
    'orange', [230 159 0] / 255, ...
    'vermillion', [213 94 0] / 255, ...
    'gray', [0.45 0.45 0.45], ...
    'ink', [0.10 0.10 0.10]);

customName = 'Custom slider values';
presetNames = [getExplorerPreset(), {customName}];
basePreset = getExplorerPreset('Moderate liquid cooling');
pendingPreset = [];
lessonMessage = basePreset.learningGoal;
lastState = struct();

position = parser.Results.Position;
if isempty(position)
    position = calculateFigurePosition(get(groot, 'ScreenSize'));
end
figureHandle = uifigure( ...
    'Name', 'Data Center Cooling Explorer', ...
    'Position', position, ...
    'Color', [0.97 0.98 0.99], ...
    'Visible', parser.Results.Visible);

root = uigridlayout(figureHandle, [2 2]);
root.RowHeight = {58, '1x'};
root.ColumnWidth = {390, '1x'};
root.Padding = [16 12 16 14];
root.RowSpacing = 10;
root.ColumnSpacing = 14;
root.BackgroundColor = figureHandle.Color;

header = uipanel(root, 'BorderType', 'none', 'BackgroundColor', colors.navy);
header.Layout.Row = 1;
header.Layout.Column = [1 2];
headerGrid = uigridlayout(header, [1 2]);
headerGrid.ColumnWidth = {'1x', 460};
headerGrid.Padding = [16 6 16 6];
headerGrid.BackgroundColor = colors.navy;
titleLabel = uilabel(headerGrid, ...
    'Text', 'Data Center Cooling Explorer', ...
    'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 24, ...
    'FontColor', 'white');
titleLabel.Layout.Column = 1;
subtitleLabel = uilabel(headerGrid, ...
    'Text', 'Predict, test, and explain how a liquid loop removes IT heat', ...
    'HorizontalAlignment', 'right', 'FontName', 'Arial', ...
    'FontSize', 13, 'FontColor', [0.82 0.92 0.98]);
subtitleLabel.Layout.Column = 2;

%% Scenario, prediction, and slider controls
controlPanel = uipanel(root, ...
    'Title', '1. Choose a scenario and predict', ...
    'FontWeight', 'bold', 'FontSize', 13, ...
    'BackgroundColor', 'white');
controlPanel.Layout.Row = 2;
controlPanel.Layout.Column = 1;
controlGrid = uigridlayout(controlPanel, [14 1]);
controlGrid.RowHeight = {30, 104, 30, 20, 40, 20, 40, 20, 40, 20, 40, 20, 40, '1x'};
controlGrid.RowSpacing = 6;
controlGrid.Padding = [12 10 12 10];
controlGrid.BackgroundColor = 'white';
controlGrid.Scrollable = 'on';

controls = struct();
valueLabels = struct();
controls.preset = uidropdown(controlGrid, 'Items', presetNames, ...
    'Value', basePreset.name, 'FontSize', 12, 'Tooltip', ...
    'Each named scenario changes the baseline in one deliberate way.');
controls.preset.Layout.Row = 1;

promptLabel = uilabel(controlGrid, 'Text', basePreset.learningGoal, ...
    'WordWrap', 'on', 'FontSize', 12, 'FontColor', colors.navy, ...
    'VerticalAlignment', 'top');
promptLabel.Layout.Row = 2;

buttonGrid = uigridlayout(controlGrid, [1 3]);
buttonGrid.Layout.Row = 3;
buttonGrid.Padding = [0 0 0 0];
buttonGrid.ColumnSpacing = 6;
buttonGrid.BackgroundColor = 'white';
choices = {'rise', 'Rise'; 'fall', 'Fall'; 'same', 'Stay the same'};
predictionButtons = matlab.ui.control.Button.empty(1, 0);
for choiceIndex = 1:size(choices, 1)
    predictionButtons(choiceIndex) = uibutton(buttonGrid, ...
        'Text', choices{choiceIndex, 2}, 'FontSize', 12, 'Enable', 'off', ...
        'Tooltip', 'Commit to a prediction; the scenario loads afterward.', ...
        'ButtonPushedFcn', @(~, ~) submitPrediction(choices{choiceIndex, 1}));
end

[controls.itLoad, valueLabels.itLoad] = addSlider(controlGrid, 4, ...
    'IT heat load (kW)', [1 100], basePreset.itLoad_kW, [1 25 50 75 100], {}, ...
    'Each watt of IT power becomes heat in this lesson.');
[controls.liquidCapture, valueLabels.liquidCapture] = addSlider(controlGrid, 6, ...
    'Liquid heat capture', [0 1], basePreset.liquidCaptureFraction, 0:0.25:1, ...
    {'0%', '25%', '50%', '75%', '100%'}, ...
    'Fraction of IT heat routed from the component to the liquid loop; the rest goes to room air.');
[controls.coolantFlow, valueLabels.coolantFlow] = addSlider(controlGrid, 8, ...
    'Coolant mass flow (kg/s)', [0.05 0.50], basePreset.coolantMassFlow_kg_s, ...
    [0.05 0.1 0.2 0.3 0.4 0.5], {}, ...
    'Mass flow through the liquid loop. Pressure drop and pump power are not modeled.');
[controls.supplyTemperature, valueLabels.supplyTemperature] = addSlider(controlGrid, 10, ...
    ['Coolant supply temperature (' degC ')'], [15 35], basePreset.supplyTemperature_C, ...
    15:5:35, {}, 'Fixed temperature of the coolant entering the component.');
[controls.thermalResistance, valueLabels.thermalResistance] = addSlider(controlGrid, 12, ...
    'Component-to-coolant resistance (K/kW)', [0.5 6], basePreset.thermalResistance_K_kW, ...
    [0.5 1 2 3 4 5 6], {}, ...
    'Wall resistance 1/UA between the component and the coolant; a synthetic value, not a cold-plate specification.');

scopeLabel = uilabel(controlGrid, 'WordWrap', 'on', 'FontSize', 10, ...
    'FontColor', colors.gray, 'VerticalAlignment', 'top', 'Text', sprintf([ ...
    'Simplified model: one lumped component at uniform temperature, constant ', ...
    'c_p = %d J/(kg K), and C_th = %d kJ/K. Not modeled: geometry, flow ', ...
    'distribution, pressure drop, controls, or sensor uncertainty.'], ...
    model.specificHeat_J_kgK, model.thermalCapacitance_J_K / 1000));
scopeLabel.Layout.Row = 14;

%% Plots and interpretation
viewGrid = uigridlayout(root, [3 2]);
viewGrid.Layout.Row = 2;
viewGrid.Layout.Column = 2;
viewGrid.RowHeight = {'1x', '1x', 150};
viewGrid.ColumnWidth = {'1x', '1x'};
viewGrid.Padding = [0 0 0 0];
viewGrid.RowSpacing = 10;
viewGrid.ColumnSpacing = 10;
viewGrid.BackgroundColor = figureHandle.Color;

axesHeatPath = uiaxes(viewGrid);
axesHeatPath.Layout.Row = 1;
axesHeatPath.Layout.Column = 1;
axesTemperature = uiaxes(viewGrid);
axesTemperature.Layout.Row = 1;
axesTemperature.Layout.Column = 2;
axesSweep = uiaxes(viewGrid);
axesSweep.Layout.Row = 2;
axesSweep.Layout.Column = 1;
axesBalance = uiaxes(viewGrid);
axesBalance.Layout.Row = 2;
axesBalance.Layout.Column = 2;

outputPanel = uipanel(viewGrid, ...
    'Title', '2. Interpret the result', ...
    'FontWeight', 'bold', 'FontSize', 13, 'BackgroundColor', 'white');
outputPanel.Layout.Row = 3;
outputPanel.Layout.Column = [1 2];
outputGrid = uigridlayout(outputPanel, [3 4]);
outputGrid.RowHeight = {40, '1x', 18};
outputGrid.ColumnWidth = {'1x', '1x', '1x', '1x'};
outputGrid.Padding = [12 4 12 6];
outputGrid.RowSpacing = 4;
outputGrid.BackgroundColor = 'white';
labels = struct();
labels.returnTemperature = addReadout(1, colors.blue, ...
    'Coolant leaving the component, from the energy balance.');
labels.coolantRise = addReadout(2, colors.blue, ...
    'Return minus supply temperature: Q_liquid/(m_dot c_p).');
labels.componentTemperature = addReadout(3, colors.vermillion, ...
    'Steady one-node component temperature: T_supply + Q_liquid R_eff.');
labels.timeConstant = addReadout(4, colors.ink, ...
    'tau = R_eff C_th; the component covers 63% of a step response in one time constant.');
labels.message = uilabel(outputGrid, 'FontSize', 12, ...
    'FontColor', colors.navy, 'WordWrap', 'on', 'VerticalAlignment', 'top');
labels.message.Layout.Row = 2;
labels.message.Layout.Column = [1 4];
labels.temperatureCue = uilabel(outputGrid, 'FontSize', 11, 'WordWrap', 'on');
labels.temperatureCue.Layout.Row = 3;
labels.temperatureCue.Layout.Column = [1 4];

heatPath = createHeatPath(axesHeatPath);
temperaturePlot = createTemperaturePlot(axesTemperature);
sweepPlot = createSweepPlot(axesSweep);
balancePlot = createBalancePlot(axesBalance);

sliderFields = {'itLoad', 'liquidCapture', 'coolantFlow', 'supplyTemperature', 'thermalResistance'};
for fieldIndex = 1:numel(sliderFields)
    fieldName = sliderFields{fieldIndex};
    controls.(fieldName).ValueChangingFcn = @(~, event) onSliderChanging(fieldName, event.Value);
    controls.(fieldName).ValueChangedFcn = @(~, ~) onSliderChanged();
end
controls.preset.ValueChangedFcn = @(source, ~) choosePreset(source.Value);

app = struct( ...
    'Figure', figureHandle, ...
    'Controls', controls, ...
    'Axes', struct('heatPath', axesHeatPath, 'temperature', axesTemperature, ...
        'sweep', axesSweep, 'balance', axesBalance), ...
    'Labels', labels, ...
    'ValueLabels', valueLabels, ...
    'PromptLabel', promptLabel, ...
    'PredictionButtons', predictionButtons, ...
    'Refresh', @refresh, ...
    'SelectPreset', @applyPreset, ...
    'ChoosePreset', @choosePreset, ...
    'SubmitPrediction', @submitPrediction, ...
    'GetState', @getState);
refresh();

    %% Interaction
    function onSliderChanging(fieldName, value)
        enterCustomMode();
        refresh(struct(fieldName, value));
    end

    function onSliderChanged()
        enterCustomMode();
        refresh();
    end

    function enterCustomMode()
        if strcmp(controls.preset.Value, customName) && isempty(pendingPreset)
            return
        end
        pendingPreset = [];
        setPredictionEnabled(false);
        controls.preset.Value = customName;
        promptLabel.Text = ['Custom values. Before you move a slider, predict which outputs ', ...
            'will rise, fall, or stay the same. Move one slider at a time.'];
        lessonMessage = ['Custom values. Watch the component and return temperatures: the ', ...
            'component must stay hotter than the coolant it heats.'];
    end

    function choosePreset(presetName)
        presetName = char(presetName);
        if strcmp(presetName, customName)
            enterCustomMode();
            refresh();
            return
        end
        preset = getExplorerPreset(presetName);
        controls.preset.Value = preset.name;
        if isempty(preset.prediction)
            applyPreset(preset);
            return
        end
        pendingPreset = preset;
        setPredictionEnabled(true);
        promptLabel.Text = sprintf('Predict first. %s', preset.prediction.prompt);
        lessonMessage = sprintf(['"%s" is selected but not loaded yet. Choose Rise, Fall, ', ...
            'or Stay the same; the sliders move after you commit to a prediction.'], preset.name);
        labels.message.Text = lessonMessage;
    end

    function applyPreset(preset)
        if ischar(preset) || isstring(preset)
            if strcmp(char(preset), customName)
                enterCustomMode();
                refresh();
                return
            end
            preset = getExplorerPreset(preset);
        end
        pendingPreset = [];
        setPredictionEnabled(false);
        controls.preset.Value = preset.name;
        controls.itLoad.Value = preset.itLoad_kW;
        controls.liquidCapture.Value = preset.liquidCaptureFraction;
        controls.coolantFlow.Value = preset.coolantMassFlow_kg_s;
        controls.supplyTemperature.Value = preset.supplyTemperature_C;
        controls.thermalResistance.Value = preset.thermalResistance_K_kW;
        promptLabel.Text = preset.learningGoal;
        lessonMessage = preset.learningGoal;
        refresh();
    end

    function submitPrediction(choice)
        if isempty(pendingPreset)
            return
        end
        choice = validatestring(choice, {'rise', 'fall', 'same'});
        preset = pendingPreset;
        prediction = preset.prediction;
        before = steadyStateForPreset(getExplorerPreset(prediction.baseline));
        applyPreset(preset);
        after = lastState.steady;

        beforeValue = before.(prediction.quantity);
        afterValue = after.(prediction.quantity);
        observed = classifyChange(beforeValue, afterValue);
        if strcmp(observed, choice)
            verdict = 'Your prediction matches.';
        else
            verdict = 'That differs from your prediction.';
        end
        lessonMessage = sprintf(['You predicted "%s". Compared with the %s baseline, the %s ', ...
            'went from %s to %s: it %s. %s Why: %s'], ...
            choiceText(choice), prediction.baseline, prediction.quantityLabel, ...
            formatQuantity(beforeValue, prediction), formatQuantity(afterValue, prediction), ...
            observedText(observed), verdict, prediction.explanation);
        labels.message.Text = lessonMessage;
        promptLabel.Text = sprintf('Prediction recorded. %s', preset.learningGoal);
    end

    function setPredictionEnabled(isEnabled)
        if isEnabled
            state = 'on';
            background = [0.90 0.95 1.00];
        else
            state = 'off';
            background = [0.96 0.96 0.96];
        end
        set(predictionButtons, 'Enable', state, 'BackgroundColor', background);
    end

    function state = getState()
        state = lastState;
    end

    %% Model evaluation and display
    function refresh(override)
        if nargin < 1
            override = struct();
        end
        values = readControls(override);
        input = modelInput(values.itLoad, values.liquidCapture, values.coolantFlow, ...
            values.supplyTemperature, values.thermalResistance);
        steady = calculateCoolingState(input);
        transient = simulateStep(input);

        updateValueLabels(values);
        updateHeatPath(steady);
        updateTemperaturePlot(transient, input, steady);
        updateSweepPlot(input, steady);
        updateBalancePlot(transient);
        updateReadouts(steady, transient);
        labels.message.Text = lessonMessage;
        lastState = struct('values', values, 'steady', steady, 'transient', transient);
    end

    function values = readControls(override)
        values = struct();
        for index = 1:numel(sliderFields)
            values.(sliderFields{index}) = controls.(sliderFields{index}).Value;
        end
        overrideFields = fieldnames(override);
        for index = 1:numel(overrideFields)
            values.(overrideFields{index}) = override.(overrideFields{index});
        end
    end

    function input = modelInput(itLoad_kW, liquidCapture, coolantFlow_kg_s, supply_C, resistance_K_kW)
        input = struct( ...
            'itLoad_W', 1000 * itLoad_kW, ...
            'liquidCaptureFraction', liquidCapture, ...
            'coolantMassFlow_kg_s', coolantFlow_kg_s, ...
            'coolantSpecificHeat_J_kgK', model.specificHeat_J_kgK, ...
            'supplyTemperature_C', supply_C, ...
            'thermalResistance_K_W', resistance_K_kW / 1000);
    end

    function steady = steadyStateForPreset(preset)
        steady = calculateCoolingState(modelInput(preset.itLoad_kW, ...
            preset.liquidCaptureFraction, preset.coolantMassFlow_kg_s, ...
            preset.supplyTemperature_C, preset.thermalResistance_K_kW));
    end

    function transient = simulateStep(input)
        coupling = calculateWallCoupling(input.coolantMassFlow_kg_s, ...
            input.coolantSpecificHeat_J_kgK, input.thermalResistance_K_W);
        timeConstant_s = coupling.effectiveResistance_K_W * model.thermalCapacitance_J_K;
        endTime_s = model.stepTime_s + max(240, 60 * ceil(5 * timeConstant_s / 60));
        time_s = [linspace(0, model.stepTime_s, 61), linspace(model.stepTime_s, endTime_s, 541)];
        time_s(62) = [];
        time_s = time_s(:);
        baseLoad_W = model.baseLoadFraction * input.itLoad_W;
        itLoad_W = baseLoad_W + (input.itLoad_W - baseLoad_W) .* (time_s >= model.stepTime_s);
        parameters = struct( ...
            'liquidCaptureFraction', input.liquidCaptureFraction, ...
            'coolantMassFlow_kg_s', input.coolantMassFlow_kg_s, ...
            'coolantSpecificHeat_J_kgK', input.coolantSpecificHeat_J_kgK, ...
            'supplyTemperature_C', input.supplyTemperature_C, ...
            'thermalResistance_K_W', input.thermalResistance_K_W, ...
            'thermalCapacitance_J_K', model.thermalCapacitance_J_K, ...
            'initialComponentTemperature_C', input.supplyTemperature_C + ...
                baseLoad_W * input.liquidCaptureFraction * coupling.effectiveResistance_K_W);
        transient = simulateComponentTransient(parameters, time_s, itLoad_W);
    end

    function updateValueLabels(values)
        valueLabels.itLoad.Text = sprintf('%.1f kW', values.itLoad);
        valueLabels.liquidCapture.Text = sprintf('%.0f%%', 100 * values.liquidCapture);
        valueLabels.coolantFlow.Text = sprintf('%.3f kg/s', values.coolantFlow);
        valueLabels.supplyTemperature.Text = sprintf('%.1f %s', values.supplyTemperature, degC);
        valueLabels.thermalResistance.Text = sprintf('%.2f K/kW', values.thermalResistance);
    end

    function updateReadouts(steady, transient)
        labels.returnTemperature.Text = sprintf('Liquid-loop return\n%.1f %s', ...
            steady.returnTemperature_C, degC);
        labels.coolantRise.Text = sprintf('Coolant temperature rise\n%.2f K', ...
            steady.coolantDeltaT_K);
        labels.componentTemperature.Text = sprintf('Steady component\n%.1f %s', ...
            steady.componentTemperature_C, degC);
        labels.timeConstant.Text = sprintf('Time constant %s\n%.0f s', ...
            tauSymbol, transient.timeConstant_s);

        if steady.returnTemperature_C >= model.saturationTemperature_C
            labels.temperatureCue.FontColor = colors.vermillion;
            labels.temperatureCue.Text = sprintf(['The coolant return reaches %.0f %s. Water ', ...
                'at atmospheric pressure boils near %d %s, so this single-phase, constant-c_p ', ...
                'model no longer applies; boiling (two-phase) cooling carries heat as latent heat.'], ...
                steady.returnTemperature_C, degC, model.saturationTemperature_C, degC);
        elseif steady.componentTemperature_C >= model.cueTemperature_C
            labels.temperatureCue.FontColor = colors.vermillion;
            labels.temperatureCue.Text = sprintf(['Caution: the one-node steady component ', ...
                'estimate is %.0f %s. Treat this as a cue to re-examine the assumed resistance ', ...
                'and flow, not as a hardware limit.'], steady.componentTemperature_C, degC);
        elseif steady.liquidHeat_W == 0
            labels.temperatureCue.FontColor = colors.gray;
            labels.temperatureCue.Text = ['No heat is routed to the liquid loop, so the ', ...
                'component and the coolant both stay at the supply temperature in this model.'];
        else
            labels.temperatureCue.FontColor = colors.gray;
            labels.temperatureCue.Text = sprintf(['Second-law check: the component (%.1f %s) ', ...
                'stays hotter than the coolant return (%.1f %s), as it must for heat to flow ', ...
                'into the coolant.'], steady.componentTemperature_C, degC, ...
                steady.returnTemperature_C, degC);
        end
    end

    %% Plot construction (once) and updates (every refresh)
    function handles = createHeatPath(axisHandle)
        hold(axisHandle, 'on');
        axis(axisHandle, [0 10 0 8]);
        axis(axisHandle, 'off');
        disableDefaultInteractivity(axisHandle);
        axisHandle.Toolbar.Visible = 'off';
        title(axisHandle, 'Heat path: where the IT heat goes', 'FontWeight', 'bold', ...
            'FontSize', 12, 'FontName', 'Arial');
        rectangle(axisHandle, 'Position', [0.3 3.1 2.4 1.6], 'Curvature', 0.08, ...
            'FaceColor', [0.93 0.95 0.98], 'EdgeColor', colors.navy, 'LineWidth', 1.4);
        rectangle(axisHandle, 'Position', [6.9 4.7 2.8 1.6], 'Curvature', 0.08, ...
            'FaceColor', [0.88 0.94 0.98], 'EdgeColor', colors.blue, 'LineWidth', 1.4);
        rectangle(axisHandle, 'Position', [6.9 1.5 2.8 1.6], 'Curvature', 0.08, ...
            'FaceColor', [1.00 0.95 0.86], 'EdgeColor', colors.orange, 'LineWidth', 1.4);
        handles.liquidArrow = quiver(axisHandle, 2.9, 4.25, 3.7, 1.05, 0, ...
            'Color', colors.blue, 'LineWidth', 2, 'MaxHeadSize', 0.3);
        handles.airArrow = quiver(axisHandle, 2.9, 3.55, 3.7, -1.2, 0, ...
            'Color', colors.orange, 'LineWidth', 2, 'MaxHeadSize', 0.3);
        textOptions = {'HorizontalAlignment', 'center', 'FontWeight', 'bold', ...
            'FontSize', 12, 'FontName', 'Arial'};
        handles.itText = text(axisHandle, 1.5, 3.9, '', 'Color', colors.navy, textOptions{:});
        handles.liquidText = text(axisHandle, 8.3, 5.5, '', 'Color', colors.blue, textOptions{:});
        handles.airText = text(axisHandle, 8.3, 2.3, '', 'Color', [0.55 0.35 0.00], textOptions{:});
        text(axisHandle, 4.75, 5.55, 'liquid capture', 'Color', colors.blue, ...
            'HorizontalAlignment', 'center', 'FontSize', 11, 'FontName', 'Arial');
        text(axisHandle, 4.75, 1.95, 'room air', 'Color', [0.55 0.35 0.00], ...
            'HorizontalAlignment', 'center', 'FontSize', 11, 'FontName', 'Arial');
        text(axisHandle, 5.0, 0.55, 'Arrow width is proportional to heat rate.', ...
            'Color', colors.gray, 'HorizontalAlignment', 'center', 'FontSize', 10, ...
            'FontName', 'Arial');
        hold(axisHandle, 'off');
    end

    function updateHeatPath(steady)
        share = steady.liquidHeat_W / max(steady.itLoad_W, eps);
        heatPath.itText.String = sprintf('IT load\n%.1f kW', steady.itLoad_W / 1000);
        heatPath.liquidText.String = sprintf('Liquid loop\n%.1f kW', steady.liquidHeat_W / 1000);
        heatPath.airText.String = sprintf('Room air\n%.1f kW', steady.airHeat_W / 1000);
        heatPath.liquidArrow.LineWidth = 0.75 + 7 * share;
        heatPath.airArrow.LineWidth = 0.75 + 7 * (1 - share);
    end

    function handles = createTemperaturePlot(axisHandle)
        hold(axisHandle, 'on');
        handles.supply = yline(axisHandle, basePreset.supplyTemperature_C, ':', 'Supply', ...
            'Color', colors.gray, 'LineWidth', 1.2, 'FontSize', 10, ...
            'LabelHorizontalAlignment', 'center', 'LabelVerticalAlignment', 'bottom', ...
            'HandleVisibility', 'off');
        xline(axisHandle, model.stepTime_s, '--', 'Color', colors.gray, 'LineWidth', 1, ...
            'HandleVisibility', 'off');
        handles.tauLine = xline(axisHandle, model.stepTime_s, ':', '', 'Color', colors.ink, ...
            'LineWidth', 1, 'FontSize', 10, 'LabelOrientation', 'horizontal', ...
            'LabelVerticalAlignment', 'top', 'LabelHorizontalAlignment', 'right', ...
            'HandleVisibility', 'off');
        handles.component = plot(axisHandle, NaN, NaN, '-', 'Color', colors.vermillion, ...
            'LineWidth', 2.2, 'DisplayName', 'Component');
        handles.coolantReturn = plot(axisHandle, NaN, NaN, '--', 'Color', colors.blue, ...
            'LineWidth', 2.0, 'DisplayName', 'Liquid return');
        handles.tauMarker = plot(axisHandle, NaN, NaN, 'o', 'MarkerSize', 7, ...
            'MarkerFaceColor', 'white', 'MarkerEdgeColor', colors.ink, 'LineWidth', 1.2, ...
            'HandleVisibility', 'off');
        styleAxes(axisHandle, 'Time (s)', ['Temperature (' degC ')'], ...
            sprintf('Response to a workload step at %d s (dashed line)', model.stepTime_s));
        legend(axisHandle, [handles.component handles.coolantReturn], 'Location', 'southeast');
        hold(axisHandle, 'off');
    end

    function updateTemperaturePlot(transient, input, steady)
        time_s = transient.time_s;
        set(temperaturePlot.component, 'XData', time_s, 'YData', transient.componentTemperature_C);
        set(temperaturePlot.coolantReturn, 'XData', time_s, 'YData', transient.returnTemperature_C);
        temperaturePlot.supply.Value = input.supplyTemperature_C;

        tau_s = transient.timeConstant_s;
        startTemperature_C = transient.componentTemperature_C(1);
        tauTemperature_C = startTemperature_C + ...
            (steady.componentTemperature_C - startTemperature_C) * (1 - exp(-1));
        lowest_C = input.supplyTemperature_C;
        highest_C = max([steady.componentTemperature_C; transient.returnTemperature_C]);
        span_K = max(highest_C - lowest_C, 1);
        set(temperaturePlot.tauMarker, 'XData', model.stepTime_s + tau_s, 'YData', tauTemperature_C);
        temperaturePlot.tauLine.Value = model.stepTime_s + tau_s;
        temperaturePlot.tauLine.Label = sprintf('\\tau = %.0f s: 63%% of the rise', tau_s);
        xlim(axesTemperature, [0 time_s(end)]);
        ylim(axesTemperature, [lowest_C - 0.12 * span_K, highest_C + 0.14 * span_K]);
    end

    function handles = createSweepPlot(axisHandle)
        hold(axisHandle, 'on');
        handles.saturation = yline(axisHandle, model.saturationTemperature_C, '-.', ...
            sprintf('Water boils at 1 atm (%d %s)', model.saturationTemperature_C, degC), ...
            'Color', colors.gray, 'LineWidth', 1.1, 'FontSize', 10, ...
            'LabelHorizontalAlignment', 'right', 'LabelVerticalAlignment', 'bottom', ...
            'HandleVisibility', 'off', 'Visible', 'off');
        handles.currentFlow = xline(axisHandle, basePreset.coolantMassFlow_kg_s, ':', ...
            'Color', colors.gray, 'LineWidth', 1, 'HandleVisibility', 'off');
        handles.component = plot(axisHandle, NaN, NaN, '-', 'Color', colors.vermillion, ...
            'LineWidth', 2.2, 'DisplayName', 'Component');
        handles.coolantReturn = plot(axisHandle, NaN, NaN, '--', 'Color', colors.blue, ...
            'LineWidth', 2.0, 'DisplayName', 'Liquid return');
        handles.componentPoint = plot(axisHandle, NaN, NaN, 'o', 'MarkerSize', 8, ...
            'MarkerFaceColor', colors.vermillion, 'MarkerEdgeColor', 'white', ...
            'HandleVisibility', 'off');
        handles.returnPoint = plot(axisHandle, NaN, NaN, 's', 'MarkerSize', 8, ...
            'MarkerFaceColor', colors.blue, 'MarkerEdgeColor', 'white', ...
            'HandleVisibility', 'off');
        styleAxes(axisHandle, 'Coolant mass flow (kg/s)', ['Temperature (' degC ')'], ...
            'Steady temperatures across coolant flow');
        xlim(axisHandle, controls.coolantFlow.Limits);
        legend(axisHandle, [handles.component handles.coolantReturn], 'Location', 'southwest');
        hold(axisHandle, 'off');
    end

    function updateSweepPlot(input, steady)
        limits = controls.coolantFlow.Limits;
        flow_kg_s = linspace(limits(1), limits(2), 181)';
        coupling = calculateWallCoupling(flow_kg_s, input.coolantSpecificHeat_J_kgK, ...
            input.thermalResistance_K_W);
        liquidHeat_W = input.itLoad_W * input.liquidCaptureFraction;
        component_C = input.supplyTemperature_C + liquidHeat_W .* coupling.effectiveResistance_K_W;
        return_C = input.supplyTemperature_C + liquidHeat_W ./ coupling.capacityRate_W_K;
        set(sweepPlot.component, 'XData', flow_kg_s, 'YData', component_C);
        set(sweepPlot.coolantReturn, 'XData', flow_kg_s, 'YData', return_C);
        set(sweepPlot.componentPoint, 'XData', input.coolantMassFlow_kg_s, ...
            'YData', steady.componentTemperature_C);
        set(sweepPlot.returnPoint, 'XData', input.coolantMassFlow_kg_s, ...
            'YData', steady.returnTemperature_C);
        sweepPlot.currentFlow.Value = input.coolantMassFlow_kg_s;

        supply_C = input.supplyTemperature_C;
        current_C = max(steady.componentTemperature_C, steady.returnTemperature_C);
        upper_C = min(max(component_C), supply_C + 3 * max(current_C - supply_C, 1));
        upper_C = max(upper_C, current_C);
        span_K = max(upper_C - supply_C, 1);
        yLimits = [supply_C - 0.06 * span_K, upper_C + 0.08 * span_K];
        ylim(axesSweep, yLimits);
        if yLimits(2) > model.saturationTemperature_C
            sweepPlot.saturation.Visible = 'on';
        else
            sweepPlot.saturation.Visible = 'off';
        end
    end

    function handles = createBalancePlot(axisHandle)
        hold(axisHandle, 'on');
        xline(axisHandle, model.stepTime_s, '--', 'Color', colors.gray, 'LineWidth', 1, ...
            'HandleVisibility', 'off');
        yline(axisHandle, 0, '-', 'Color', [0.75 0.75 0.75], 'HandleVisibility', 'off');
        handles.generated = plot(axisHandle, NaN, NaN, '-', 'Color', colors.ink, ...
            'LineWidth', 2.0, 'DisplayName', 'Heat into liquid path');
        handles.removed = plot(axisHandle, NaN, NaN, '--', 'Color', colors.sky, ...
            'LineWidth', 2.4, 'DisplayName', 'Heat removed by coolant');
        handles.stored = plot(axisHandle, NaN, NaN, '-.', 'Color', colors.vermillion, ...
            'LineWidth', 1.8, 'DisplayName', 'Storage rate, C_{th} dT/dt');
        styleAxes(axisHandle, 'Time (s)', 'Heat rate (kW)', 'Where the transient heat goes');
        legend(axisHandle, [handles.generated handles.removed handles.stored], 'Location', 'east');
        hold(axisHandle, 'off');
    end

    function updateBalancePlot(transient)
        time_s = transient.time_s;
        set(balancePlot.generated, 'XData', time_s, 'YData', transient.liquidLoad_W / 1000);
        set(balancePlot.removed, 'XData', time_s, 'YData', transient.heatToCoolant_W / 1000);
        set(balancePlot.stored, 'XData', time_s, 'YData', transient.storageRate_W / 1000);
        peak_kW = max(max(transient.liquidLoad_W) / 1000, 0.1);
        lowest_kW = min(0, min(transient.storageRate_W) / 1000);
        xlim(axesBalance, [0 time_s(end)]);
        ylim(axesBalance, [lowest_kW - 0.06 * peak_kW, 1.12 * peak_kW]);
    end

    %% Layout helpers
    function [slider, valueLabel] = addSlider(parent, row, labelText, limits, value, ...
            ticks, tickLabels, tooltipText)
        labelGrid = uigridlayout(parent, [1 2]);
        labelGrid.Layout.Row = row;
        labelGrid.ColumnWidth = {'1x', 90};
        labelGrid.Padding = [0 0 0 0];
        labelGrid.ColumnSpacing = 4;
        labelGrid.BackgroundColor = 'white';
        uilabel(labelGrid, 'Text', labelText, 'FontWeight', 'bold', ...
            'FontSize', 12, 'Tooltip', tooltipText);
        valueLabel = uilabel(labelGrid, 'FontSize', 12, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'right', 'FontColor', colors.blue);
        slider = uislider(parent, 'Limits', limits, 'Value', value, ...
            'MajorTicks', ticks, 'MinorTicks', [], 'FontSize', 10, 'Tooltip', tooltipText);
        if ~isempty(tickLabels)
            slider.MajorTickLabels = tickLabels;
        end
        slider.Layout.Row = row + 1;
    end

    function label = addReadout(column, color, tooltipText)
        label = uilabel(outputGrid, 'FontWeight', 'bold', 'FontSize', 13, ...
            'FontColor', color, 'Tooltip', tooltipText);
        label.Layout.Row = 1;
        label.Layout.Column = column;
    end
end

function styleAxes(axisHandle, xText, yText, titleText)
axisHandle.Box = 'on';
axisHandle.TickDir = 'in';
axisHandle.FontName = 'Arial';
axisHandle.FontSize = 11;
axisHandle.XGrid = 'on';
axisHandle.YGrid = 'on';
axisHandle.GridAlpha = 0.12;
xlabel(axisHandle, xText);
ylabel(axisHandle, yText);
title(axisHandle, titleText, 'FontWeight', 'bold', 'FontSize', 12);
end

function observed = classifyChange(beforeValue, afterValue)
tolerance = 1e-9 * max(1, abs(beforeValue));
if afterValue > beforeValue + tolerance
    observed = 'rise';
elseif afterValue < beforeValue - tolerance
    observed = 'fall';
else
    observed = 'same';
end
end

function text = choiceText(choice)
switch choice
    case 'rise'
        text = 'rise';
    case 'fall'
        text = 'fall';
    otherwise
        text = 'stay the same';
end
end

function text = observedText(observed)
switch observed
    case 'rise'
        text = 'rose';
    case 'fall'
        text = 'fell';
    otherwise
        text = 'stayed the same';
end
end

function text = formatQuantity(value, prediction)
text = sprintf('%.1f %s', value * prediction.displayScale, prediction.displayUnit);
end
