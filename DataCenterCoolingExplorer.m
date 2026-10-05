function app = DataCenterCoolingExplorer(varargin)
%DATACENTERCOOLINGEXPLORER Interactive, synthetic data-center cooling lesson.
%
% Run DataCenterCoolingExplorer from the project root. Move the sliders to
% explore heat partition, coolant temperature rise, and the transient
% response of a lumped component connected to a fixed-temperature liquid
% loop. This educational model is intentionally not a calibrated rack,
% cold-plate, or facility model.

parser = inputParser;
addParameter(parser, 'Visible', 'on', @(value) any(validatestring(value, {'on', 'off'})));
parse(parser, varargin{:});

projectRoot = fileparts(mfilename('fullpath'));
addpath(fullfile(projectRoot, 'src'));

colors = struct( ...
    'navy', [0.05 0.16 0.29], ...
    'blue', [0.12 0.47 0.71], ...
    'cyan', [0.18 0.72 0.85], ...
    'orange', [0.95 0.55 0.16], ...
    'red', [0.80 0.24 0.20], ...
    'gray', [0.36 0.40 0.45]);

figureHandle = uifigure( ...
    'Name', 'Data Center Cooling Explorer', ...
    'Position', [80 80 1420 800], ...
    'Color', [0.97 0.98 0.99], ...
    'Visible', parser.Results.Visible);

root = uigridlayout(figureHandle, [2 2]);
root.RowHeight = {64, '1x'};
root.ColumnWidth = {'0.33x', '0.67x'};
root.Padding = [18 14 18 18];
root.RowSpacing = 10;
root.ColumnSpacing = 14;

header = uipanel(root, 'BorderType', 'none', 'BackgroundColor', colors.navy);
header.Layout.Row = 1;
header.Layout.Column = [1 2];
headerGrid = uigridlayout(header, [1 2]);
headerGrid.ColumnWidth = {'1x', 320};
headerGrid.Padding = [16 6 16 6];
headerGrid.BackgroundColor = colors.navy;
titleLabel = uilabel(headerGrid, ...
    'Text', 'Data Center Cooling Explorer', ...
    'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 25, ...
    'FontColor', 'white');
titleLabel.Layout.Column = 1;
subtitleLabel = uilabel(headerGrid, ...
    'Text', 'A synthetic heat-transfer learning model', ...
    'HorizontalAlignment', 'right', 'FontName', 'Arial', ...
    'FontSize', 13, 'FontColor', [0.82 0.92 0.98]);
subtitleLabel.Layout.Column = 2;

controlPanel = uipanel(root, ...
    'Title', '1. Choose a cooling scenario', ...
    'FontWeight', 'bold', ...
    'BackgroundColor', 'white');
controlPanel.Layout.Row = 2;
controlPanel.Layout.Column = 1;
controlGrid = uigridlayout(controlPanel, [12 1]);
controlGrid.RowHeight = {24, 44, 24, 44, 24, 44, 24, 44, 24, 44, 28, '1x'};
controlGrid.Padding = [14 10 14 12];

controls = struct();
controls.itLoad = addSlider(controlGrid, 1, 'IT heat load [kW]', [1 100], 25, ...
    'Each watt of IT power is treated as heat in this lesson.');
controls.liquidCapture = addSlider(controlGrid, 3, 'Liquid heat capture [-]', [0 1], 0.80, ...
    'Fraction of IT heat routed from the component to the liquid loop.');
controls.coolantFlow = addSlider(controlGrid, 5, 'Coolant mass flow [kg/s]', [0.05 0.50], 0.20, ...
    'Mass flow through the liquid loop; pressure drop is not modeled.');
controls.supplyTemperature = addSlider(controlGrid, 7, 'Coolant supply temperature [degC]', [15 35], 25, ...
    'Fixed upstream supply temperature for the one-node transient model.');
controls.thermalResistance = addSlider(controlGrid, 9, 'Component-to-coolant resistance [K/kW]', [0.5 6], 3, ...
    'A synthetic effective resistance; not a cold-plate specification.');

notePanel = uipanel(controlGrid, 'Title', '2. Read the model boundary', ...
    'FontWeight', 'bold', 'BackgroundColor', [0.96 0.98 1.00]);
notePanel.Layout.Row = 12;
noteGrid = uigridlayout(notePanel, [2 1]);
noteGrid.RowHeight = {72, '1x'};
noteGrid.Padding = [8 4 8 6];
scopeText = uilabel(noteGrid, ...
    'Text', {'Included: heat partition, Q = m_dot c_p DeltaT, thermal resistance,', ...
             'and component thermal storage.'}, ...
    'FontSize', 11, 'FontColor', colors.navy, 'VerticalAlignment', 'top');
scopeText.Layout.Row = 1;
limitsText = uilabel(noteGrid, ...
    'Text', {'Not established: a specific rack, cold plate, pump, pressure drop,', ...
             'hotspots, controls, sensor uncertainty, or operational performance.'}, ...
    'FontSize', 11, 'FontColor', colors.red, 'VerticalAlignment', 'top');
limitsText.Layout.Row = 2;

viewPanel = uipanel(root, 'BorderType', 'none', 'BackgroundColor', [0.97 0.98 0.99]);
viewPanel.Layout.Row = 2;
viewPanel.Layout.Column = 2;
viewGrid = uigridlayout(viewPanel, [3 2]);
viewGrid.RowHeight = {'1x', '1x', 74};
viewGrid.ColumnWidth = {'1x', '1x'};
viewGrid.Padding = [0 0 0 0];
viewGrid.RowSpacing = 10;
viewGrid.ColumnSpacing = 10;

axesHeatPath = uiaxes(viewGrid);
axesHeatPath.Layout.Row = 1;
axesHeatPath.Layout.Column = 1;
axesTemperature = uiaxes(viewGrid);
axesTemperature.Layout.Row = 1;
axesTemperature.Layout.Column = 2;
axesPartition = uiaxes(viewGrid);
axesPartition.Layout.Row = 2;
axesPartition.Layout.Column = 1;
axesBalance = uiaxes(viewGrid);
axesBalance.Layout.Row = 2;
axesBalance.Layout.Column = 2;

outputPanel = uipanel(viewGrid, ...
    'Title', '3. Interpret the result', ...
    'FontWeight', 'bold', 'BackgroundColor', 'white');
outputPanel.Layout.Row = 3;
outputPanel.Layout.Column = [1 2];
outputGrid = uigridlayout(outputPanel, [1 4]);
outputGrid.ColumnWidth = {'1x', '1x', '1x', '1.9x'};
outputGrid.Padding = [12 3 12 3];
labels = struct();
labels.returnTemperature = uilabel(outputGrid, 'FontWeight', 'bold', ...
    'FontColor', colors.blue, 'FontSize', 13);
labels.coolantRise = uilabel(outputGrid, 'FontWeight', 'bold', ...
    'FontColor', colors.blue, 'FontSize', 13);
labels.balance = uilabel(outputGrid, 'FontWeight', 'bold', ...
    'FontColor', colors.gray, 'FontSize', 13);
labels.message = uilabel(outputGrid, 'FontSize', 12, ...
    'FontColor', colors.navy, 'WordWrap', 'on');

sliderFields = fieldnames(controls);
for fieldIndex = 1:numel(sliderFields)
    controls.(sliderFields{fieldIndex}).ValueChangedFcn = @(~, ~) refresh();
end

app = struct( ...
    'Figure', figureHandle, ...
    'Controls', controls, ...
    'Axes', struct('heatPath', axesHeatPath, 'temperature', axesTemperature, ...
        'partition', axesPartition, 'balance', axesBalance), ...
    'Labels', labels, ...
    'Refresh', @refresh);
refresh();

    function slider = addSlider(parent, row, labelText, limits, defaultValue, tooltipText)
        label = uilabel(parent, 'Text', labelText, 'FontWeight', 'bold', ...
            'FontSize', 12, 'Tooltip', tooltipText);
        label.Layout.Row = row;
        slider = uislider(parent, 'Limits', limits, 'Value', defaultValue, ...
            'MajorTicks', linspace(limits(1), limits(2), 5), 'Tooltip', tooltipText);
        slider.Layout.Row = row + 1;
    end

    function refresh()
        input = struct( ...
            'itLoad_W', controls.itLoad.Value * 1000, ...
            'liquidCaptureFraction', controls.liquidCapture.Value, ...
            'coolantMassFlow_kg_s', controls.coolantFlow.Value, ...
            'coolantSpecificHeat_J_kgK', 4180, ...
            'supplyTemperature_C', controls.supplyTemperature.Value);
        steady = calculateCoolingState(input);

        time_s = linspace(0, 300, 301)';
        baseLoad_W = 0.40 * input.itLoad_W;
        itLoad_W = baseLoad_W + (input.itLoad_W - baseLoad_W) .* (time_s >= 60);
        resistance_K_W = controls.thermalResistance.Value / 1000;
        parameters = struct( ...
            'liquidCaptureFraction', input.liquidCaptureFraction, ...
            'coolantMassFlow_kg_s', input.coolantMassFlow_kg_s, ...
            'coolantSpecificHeat_J_kgK', input.coolantSpecificHeat_J_kgK, ...
            'supplyTemperature_C', input.supplyTemperature_C, ...
            'thermalResistance_K_W', resistance_K_W, ...
            'thermalCapacitance_J_K', 30000, ...
            'initialComponentTemperature_C', input.supplyTemperature_C + ...
                baseLoad_W * input.liquidCaptureFraction * resistance_K_W);
        transient = simulateComponentTransient(parameters, time_s, itLoad_W);

        drawHeatPath(axesHeatPath, steady, colors);
        drawTemperaturePlot(axesTemperature, transient, colors);
        drawPartitionPlot(axesPartition, steady, colors);
        drawBalancePlot(axesBalance, transient, colors);

        labels.returnTemperature.Text = sprintf('Liquid-loop return\n%.1f degC', ...
            steady.returnTemperature_C);
        labels.coolantRise.Text = sprintf('Coolant temperature rise\n%.2f K', ...
            steady.coolantDeltaT_K);
        labels.balance.Text = sprintf('Steady energy residual\n%.2e W', ...
            steady.energyResidual_W);
        labels.message.Text = sprintf(['At %.0f kW, the liquid loop carries %.0f%% of the heat. ', ...
            'The plots show what follows from declared assumptions; measured topology and ', ...
            'sensor metadata are still required to validate a real rack.'], ...
            input.itLoad_W / 1000, 100 * input.liquidCaptureFraction);
    end
end

function drawHeatPath(axisHandle, steady, colors)
cla(axisHandle);
hold(axisHandle, 'on');
axis(axisHandle, [0 10 0 8]);
axis(axisHandle, 'off');
title(axisHandle, 'Heat path: what is being balanced', 'FontWeight', 'bold');
rectangle(axisHandle, 'Position', [0.6 3.1 2.0 1.6], ...
    'FaceColor', [0.92 0.95 0.98], 'EdgeColor', colors.navy, 'LineWidth', 1.4);
text(axisHandle, 1.6, 3.9, sprintf('IT load\n%.1f kW', steady.itLoad_W / 1000), ...
    'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', colors.navy);
rectangle(axisHandle, 'Position', [6.9 4.9 2.2 1.3], ...
    'FaceColor', [0.84 0.95 0.98], 'EdgeColor', colors.blue, 'LineWidth', 1.4);
text(axisHandle, 8.0, 5.55, sprintf('Liquid loop\n%.1f kW', steady.liquidHeat_W / 1000), ...
    'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', colors.blue);
rectangle(axisHandle, 'Position', [6.9 1.4 2.2 1.3], ...
    'FaceColor', [1.00 0.94 0.85], 'EdgeColor', colors.orange, 'LineWidth', 1.4);
text(axisHandle, 8.0, 2.05, sprintf('Air path\n%.1f kW', steady.airHeat_W / 1000), ...
    'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', [0.60 0.30 0.04]);
quiver(axisHandle, 2.8, 4.2, 3.5, 1.1, 0, 'Color', colors.blue, ...
    'LineWidth', 2, 'MaxHeadSize', 0.35);
quiver(axisHandle, 2.8, 3.5, 3.5, -1.25, 0, 'Color', colors.orange, ...
    'LineWidth', 2, 'MaxHeadSize', 0.35);
text(axisHandle, 4.6, 5.7, 'liquid capture', 'Color', colors.blue, ...
    'HorizontalAlignment', 'center');
text(axisHandle, 4.6, 1.5, 'remaining heat', 'Color', [0.60 0.30 0.04], ...
    'HorizontalAlignment', 'center');
hold(axisHandle, 'off');
end

function drawTemperaturePlot(axisHandle, transient, colors)
cla(axisHandle);
plot(axisHandle, transient.time_s, transient.componentTemperature_C, ...
    'Color', colors.red, 'LineWidth', 2.1, 'DisplayName', 'Component');
hold(axisHandle, 'on');
plot(axisHandle, transient.time_s, transient.returnTemperature_C, ...
    'Color', colors.blue, 'LineWidth', 2.1, 'DisplayName', 'Liquid return');
xline(axisHandle, 60, ':', 'Load step', 'Color', colors.gray, 'LabelVerticalAlignment', 'bottom');
grid(axisHandle, 'on');
xlabel(axisHandle, 'Time [s]');
ylabel(axisHandle, 'Temperature [degC]');
title(axisHandle, 'Transient response after a workload step', 'FontWeight', 'bold');
legend(axisHandle, 'Location', 'best');
hold(axisHandle, 'off');
end

function drawPartitionPlot(axisHandle, steady, colors)
cla(axisHandle);
bars = bar(axisHandle, [steady.liquidHeat_W, steady.airHeat_W] ./ 1000, 0.58);
bars.FaceColor = 'flat';
bars.CData = [colors.blue; colors.orange];
axisHandle.XTick = [1 2];
axisHandle.XTickLabel = {'Liquid loop', 'Air path'};
ylabel(axisHandle, 'Heat rate [kW]');
title(axisHandle, 'Declared heat partition', 'FontWeight', 'bold');
grid(axisHandle, 'on');
for index = 1:2
    text(axisHandle, index, bars.YData(index), sprintf('%.1f', bars.YData(index)), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontWeight', 'bold');
end
end

function drawBalancePlot(axisHandle, transient, colors)
cla(axisHandle);
plot(axisHandle, transient.time_s, transient.liquidLoad_W ./ 1000, ...
    'Color', colors.navy, 'LineWidth', 2, 'DisplayName', 'Heat to liquid');
hold(axisHandle, 'on');
plot(axisHandle, transient.time_s, transient.heatToCoolant_W ./ 1000, ...
    'Color', colors.cyan, 'LineWidth', 2, 'DisplayName', 'Heat to coolant');
plot(axisHandle, transient.time_s, ...
    (transient.liquidLoad_W - transient.heatToCoolant_W) ./ 1000, ...
    '--', 'Color', colors.red, 'LineWidth', 1.4, 'DisplayName', 'Stored heat rate');
grid(axisHandle, 'on');
xlabel(axisHandle, 'Time [s]');
ylabel(axisHandle, 'Heat-rate scale [kW]');
title(axisHandle, 'Where transient heat goes', 'FontWeight', 'bold');
legend(axisHandle, 'Location', 'best');
hold(axisHandle, 'off');
end
