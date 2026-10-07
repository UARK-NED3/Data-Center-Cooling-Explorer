function tests = testCoolingCore
%TESTCOOLINGCORE Verification tests for the synthetic cooling lesson core.
% All inputs and outputs use SI units unless the field name states otherwise.
tests = functiontests(localfunctions);
end

%% Steady heat partition and energy balance
function testSteadyStatePartitionsHeatAndSetsCoolantRise(testCase)
state = calculateCoolingState(steadyInput(10000, 0.8, 0.20, 25));

verifyEqual(testCase, state.liquidHeat_W, 8000, 'AbsTol', 1e-12);
verifyEqual(testCase, state.airHeat_W, 2000, 'AbsTol', 1e-12);
verifyEqual(testCase, state.capacityRate_W_K, 0.20 * 4180, 'AbsTol', 1e-12);
verifyEqual(testCase, state.coolantDeltaT_K, 8000 / (0.20 * 4180), 'AbsTol', 1e-12);
verifyEqual(testCase, state.returnTemperature_C, 25 + 8000 / (0.20 * 4180), 'AbsTol', 1e-12);
end

function testHigherFlowReducesCoolantTemperatureRise(testCase)
base = steadyInput(50000, 1.0, 0.25, 25);
lowFlow = calculateCoolingState(base);
base.coolantMassFlow_kg_s = 0.50;
highFlow = calculateCoolingState(base);

verifyLessThan(testCase, highFlow.coolantDeltaT_K, lowFlow.coolantDeltaT_K);
verifyEqual(testCase, highFlow.coolantDeltaT_K, lowFlow.coolantDeltaT_K / 2, 'AbsTol', 1e-12);
end

function testNoLiquidCaptureLeavesCoolantUnchanged(testCase)
input = steadyInput(12000, 0, 0.10, 30);
input.thermalResistance_K_W = 1.5e-3;

state = calculateCoolingState(input);

verifyEqual(testCase, state.liquidHeat_W, 0, 'AbsTol', 1e-12);
verifyEqual(testCase, state.returnTemperature_C, 30, 'AbsTol', 1e-12);
verifyEqual(testCase, state.componentTemperature_C, 30, 'AbsTol', 1e-12);
verifyEqual(testCase, state.airHeat_W, 12000, 'AbsTol', 1e-12);
end

function testInvalidInputsAreRejected(testCase)
input = steadyInput(1000, 1.1, 0.10, 25);
verifyError(testCase, @() calculateCoolingState(input), ...
    'DataCenterCooling:InvalidLiquidCaptureFraction');

input = steadyInput(1000, 0.5, 0.10, 25);
input.thermalResistance_K_W = 0;
verifyError(testCase, @() calculateCoolingState(input), ...
    'DataCenterCooling:InvalidThermalResistance');
verifyError(testCase, @() calculateWallCoupling(-0.1, 4180, 1e-3), ...
    'DataCenterCooling:InvalidMassFlow');
end

%% Wall coupling and the second law
function testCoolantReturnNeverExceedsComponentTemperature(testCase)
for load_W = [1e3 2e4 1e5]
    for flow_kg_s = [0.05 0.08 0.20 0.50]
        for resistance_K_W = [0.5e-3 1.5e-3 6e-3]
            input = steadyInput(load_W, 0.9, flow_kg_s, 25);
            input.thermalResistance_K_W = resistance_K_W;
            state = calculateCoolingState(input);
            verifyLessThan(testCase, state.returnTemperature_C, state.componentTemperature_C);
        end
    end
end
end

function testFormerFlowLimitedCaseNoLongerViolatesSecondLaw(testCase)
% Version 0.2.0 referenced the resistance to the supply temperature, which put
% this case's coolant return (72.8 degC) above its component (49.0 degC).
input = steadyInput(20e3, 0.8, 0.08, 25);
input.thermalResistance_K_W = 1.5e-3;

state = calculateCoolingState(input);

verifyEqual(testCase, state.returnTemperature_C, 25 + 16e3 / (0.08 * 4180), 'AbsTol', 1e-9);
verifyGreaterThan(testCase, state.componentTemperature_C, state.returnTemperature_C);
verifyGreaterThan(testCase, state.componentTemperature_C, 25 + 16e3 * 1.5e-3);
end

function testWallCouplingMatchesEffectivenessRelation(testCase)
coupling = calculateWallCoupling(0.20, 4180, 1.5e-3);

expectedNTU = (1 / 1.5e-3) / (0.20 * 4180);
verifyEqual(testCase, coupling.NTU, expectedNTU, 'RelTol', 1e-12);
verifyEqual(testCase, coupling.effectiveness, 1 - exp(-expectedNTU), 'RelTol', 1e-12);
verifyEqual(testCase, coupling.effectiveResistance_K_W, ...
    1 / ((1 - exp(-expectedNTU)) * 0.20 * 4180), 'RelTol', 1e-12);
end

function testWallCouplingRecoversLimitingCases(testCase)
% Very high flow: the coolant barely warms, so R_eff approaches the wall resistance.
highFlow = calculateWallCoupling(1e3, 4180, 1.5e-3);
verifyEqual(testCase, highFlow.effectiveResistance_K_W, 1.5e-3, 'RelTol', 1e-3);

% Negligible wall resistance: the coolant leaves at the component temperature,
% so R_eff approaches 1/(m_dot c_p).
idealWall = calculateWallCoupling(0.20, 4180, 1e-9);
verifyEqual(testCase, idealWall.effectiveResistance_K_W, 1 / (0.20 * 4180), 'RelTol', 1e-9);
end

function testLowerFlowRaisesComponentTemperature(testCase)
flow_kg_s = linspace(0.05, 0.50, 46);
coupling = calculateWallCoupling(flow_kg_s, 4180, 1.5e-3);
component_C = 25 + 8000 .* coupling.effectiveResistance_K_W;

verifyTrue(testCase, all(diff(component_C) < 0), ...
    'Component temperature should fall monotonically as coolant flow rises.');
end

function testLowerResistanceLeavesReturnTemperatureUnchanged(testCase)
input = steadyInput(10e3, 0.8, 0.20, 25);
input.thermalResistance_K_W = 1.5e-3;
baseline = calculateCoolingState(input);
input.thermalResistance_K_W = 0.75e-3;
improved = calculateCoolingState(input);

verifyEqual(testCase, improved.returnTemperature_C, baseline.returnTemperature_C, 'AbsTol', 1e-12);
verifyLessThan(testCase, improved.componentTemperature_C, baseline.componentTemperature_C);
end

%% Transient model
function testTransientMatchesIndependentODESolution(testCase)
parameters = transientParameters(0.8, 0.20, 1.5e-3, 30000);
coupling = calculateWallCoupling(0.20, 4180, 1.5e-3);
time_s = linspace(0, 300, 301)';
step_s = 60;
itLoad_W = 4000 + 6000 .* (time_s >= step_s);
parameters.initialComponentTemperature_C = 25 + 0.8 * 4000 * coupling.effectiveResistance_K_W;

simulation = simulateComponentTransient(parameters, time_s, itLoad_W);

% Integrate each constant-load segment separately so ode45 never steps across
% the discontinuity.
derivative = @(load_W) @(~, temperature_C) (0.8 * load_W - ...
    (temperature_C - 25) / coupling.effectiveResistance_K_W) / 30000;
options = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[~, before_C] = ode45(derivative(4000), time_s(time_s <= step_s), ...
    parameters.initialComponentTemperature_C, options);
[~, after_C] = ode45(derivative(10000), time_s(time_s >= step_s), before_C(end), options);
reference_C = [before_C; after_C(2:end)];

verifyEqual(testCase, simulation.componentTemperature_C, reference_C, 'AbsTol', 1e-6);
end

function testTransientIntegratedEnergyBalanceCloses(testCase)
parameters = transientParameters(0.8, 0.20, 1.5e-3, 30000);
time_s = (0:0.01:240)';
itLoad_W = 5000 + 5000 .* (time_s >= 30);

simulation = simulateComponentTransient(parameters, time_s, itLoad_W);

% Zero-order-hold heat input integrates exactly with left rectangles; the
% heat removed is smooth, so the trapezoidal rule is accurate on this grid.
heatIn_J = sum(simulation.liquidLoad_W(1:end-1) .* diff(time_s));
heatOut_J = trapz(time_s, simulation.heatToCoolant_W);
stored_J = 30000 * (simulation.componentTemperature_C(end) - simulation.componentTemperature_C(1));
verifyEqual(testCase, heatIn_J - heatOut_J, stored_J, 'RelTol', 1e-4);
verifyLessThan(testCase, simulation.returnTemperature_C, simulation.componentTemperature_C + 1e-12);
end

function testTransientReaches63PercentAfterOneTimeConstant(testCase)
parameters = transientParameters(1.0, 0.20, 2e-3, 10000);
coupling = calculateWallCoupling(0.20, 4180, 2e-3);
time_s = linspace(0, 400, 4001)';
itLoad_W = 5000 * ones(size(time_s));

simulation = simulateComponentTransient(parameters, time_s, itLoad_W);

verifyEqual(testCase, simulation.timeConstant_s, coupling.effectiveResistance_K_W * 10000, ...
    'RelTol', 1e-12);
steady_C = 25 + 5000 * coupling.effectiveResistance_K_W;
atTau_C = interp1(time_s, simulation.componentTemperature_C, simulation.timeConstant_s);
verifyEqual(testCase, (atTau_C - 25) / (steady_C - 25), 1 - exp(-1), 'AbsTol', 1e-4);
verifyEqual(testCase, simulation.componentTemperature_C(end), steady_C, 'AbsTol', 1e-3);
end

%% Teaching scenarios
function testModeratePresetProvidesAReproducibleTeachingCase(testCase)
preset = getExplorerPreset('Moderate liquid cooling');

verifyEqual(testCase, preset.itLoad_kW, 10);
verifyEqual(testCase, preset.liquidCaptureFraction, 0.80, 'AbsTol', 1e-12);
verifyEqual(testCase, preset.coolantMassFlow_kg_s, 0.20, 'AbsTol', 1e-12);
verifyEqual(testCase, preset.supplyTemperature_C, 25, 'AbsTol', 1e-12);
verifyEqual(testCase, preset.thermalResistance_K_kW, 1.5, 'AbsTol', 1e-12);
verifyEmpty(testCase, preset.prediction);
end

function testControlledScenariosChangeOneInput(testCase)
baseline = getExplorerPreset('Moderate liquid cooling');
fields = {'itLoad_kW', 'liquidCaptureFraction', 'coolantMassFlow_kg_s', ...
    'supplyTemperature_C', 'thermalResistance_K_kW'};
scenarios = { ...
    'Flow-limited loop', 'coolantMassFlow_kg_s'; ...
    'Lower thermal resistance', 'thermalResistance_K_kW'};
for index = 1:size(scenarios, 1)
    preset = getExplorerPreset(scenarios{index, 1});
    changed = fields(cellfun(@(field) preset.(field) ~= baseline.(field), fields));
    verifyEqual(testCase, changed, scenarios(index, 2), ...
        sprintf('"%s" should change exactly one input relative to the baseline.', ...
        scenarios{index, 1}));
end
end

function testPredictionAnswersAgreeWithModel(testCase)
names = getExplorerPreset();
for index = 1:numel(names)
    preset = getExplorerPreset(names{index});
    if isempty(preset.prediction)
        continue
    end
    before = calculateCoolingState(presetInput(getExplorerPreset(preset.prediction.baseline)));
    after = calculateCoolingState(presetInput(preset));
    change = after.(preset.prediction.quantity) - before.(preset.prediction.quantity);
    switch preset.prediction.expectedChange
        case 'rise'
            verifyGreaterThan(testCase, change, 0, names{index});
        case 'fall'
            verifyLessThan(testCase, change, 0, names{index});
        case 'same'
            verifyEqual(testCase, change, 0, 'AbsTol', 1e-9, names{index});
    end
end
end

function testUnknownPresetIsRejected(testCase)
verifyError(testCase, @() getExplorerPreset('Unknown case'), ...
    'DataCenterCooling:UnknownPreset');
end

%% Interactive Explorer
function testExplorerLaunchesAndRefreshesAHiddenFigure(testCase)
app = launchHiddenExplorer(testCase);

verifyTrue(testCase, isvalid(app.Figure));
verifyTrue(testCase, contains(app.Labels.returnTemperature.Text, 'Liquid-loop return'));
verifyTrue(testCase, contains(app.Labels.temperatureCue.Text, 'Second-law check'));

initialRise = app.Labels.coolantRise.Text;
app.Controls.coolantFlow.Value = 0.40;
app.Refresh();
verifyNotEqual(testCase, app.Labels.coolantRise.Text, initialRise);
end

function testSliderDragUpdatesOutputsBeforeRelease(testCase)
app = launchHiddenExplorer(testCase);
initialRise = app.Labels.coolantRise.Text;

app.Controls.coolantFlow.ValueChangingFcn(app.Controls.coolantFlow, struct('Value', 0.10));

verifyEqual(testCase, app.Controls.coolantFlow.Value, 0.20, 'AbsTol', 1e-12);
verifyNotEqual(testCase, app.Labels.coolantRise.Text, initialRise);
verifyEqual(testCase, app.Controls.preset.Value, 'Custom slider values');
state = app.GetState();
verifyEqual(testCase, state.values.coolantFlow, 0.10, 'AbsTol', 1e-12);
end

function testPredictionGateLoadsScenarioOnlyAfterPrediction(testCase)
app = launchHiddenExplorer(testCase);

app.ChoosePreset('Flow-limited loop');
verifyEqual(testCase, app.Controls.coolantFlow.Value, 0.20, 'AbsTol', 1e-12);
verifyEqual(testCase, string(app.PredictionButtons(1).Enable), "on");
verifyTrue(testCase, contains(app.PromptLabel.Text, 'Predict first'));

app.SubmitPrediction('rise');
verifyEqual(testCase, app.Controls.coolantFlow.Value, 0.08, 'AbsTol', 1e-12);
verifyEqual(testCase, string(app.PredictionButtons(1).Enable), "off");
verifyTrue(testCase, contains(app.Labels.message.Text, 'it rose'));
verifyTrue(testCase, contains(app.Labels.message.Text, 'Your prediction matches'));
end

function testIncorrectPredictionStillExplainsResult(testCase)
app = launchHiddenExplorer(testCase);

app.ChoosePreset('Lower thermal resistance');
app.SubmitPrediction('fall');

verifyTrue(testCase, contains(app.Labels.message.Text, 'stayed the same'));
verifyTrue(testCase, contains(app.Labels.message.Text, 'differs from your prediction'));
verifyTrue(testCase, contains(app.Labels.message.Text, 'Why:'));
end

function testExplorerShowsTemperatureAndBoilingCues(testCase)
app = launchHiddenExplorer(testCase);

app.SelectPreset('High-density stress test');
verifyEqual(testCase, app.Controls.itLoad.Value, 40, 'AbsTol', 1e-12);
verifyTrue(testCase, contains(app.Labels.temperatureCue.Text, 'Caution'));

app.Controls.itLoad.Value = 100;
app.Controls.coolantFlow.Value = 0.05;
app.Refresh();
verifyTrue(testCase, contains(app.Labels.temperatureCue.Text, 'boil'));
end

function testLegendsListOnlyDataSeries(testCase)
app = launchHiddenExplorer(testCase);

temperatureLegend = app.Axes.temperature.Legend;
verifyEqual(testCase, string(temperatureLegend.String), ["Component", "Liquid return"]);
sweepLegend = app.Axes.sweep.Legend;
verifyEqual(testCase, string(sweepLegend.String), ["Component", "Liquid return"]);
end

function testGuidedLessonLiveScriptRunsHidden(testCase)
projectRoot = fileparts(fileparts(mfilename('fullpath')));
existingFigures = findall(groot, 'Type', 'figure');
cleanup = onCleanup(@() deleteNewFigures(existingFigures)); %#ok<NASGU>
explorerVisible = 'off'; %#ok<NASGU>

run(fullfile(projectRoot, 'ExploreDataCenterCooling.m'));

verifyTrue(testCase, isvalid(app.Figure));
verifyEqual(testCase, string(app.Figure.Visible), "off");
verifyGreaterThan(testCase, lowState.componentTemperature_C, baseState.componentTemperature_C);
verifyTrue(testCase, any(violates), 'The shortcut model should violate the second law at low flow.');
end

%% Layout
function testFigurePositionFitsSmallDisplays(testCase)
position = calculateFigurePosition([0 0 640 480]);

verifyGreaterThanOrEqual(testCase, position(1), 10);
verifyGreaterThanOrEqual(testCase, position(2), 10);
verifyLessThanOrEqual(testCase, position(1) + position(3), 640);
verifyLessThanOrEqual(testCase, position(2) + position(4), 480);

verifyEqual(testCase, calculateFigurePosition([0 0 1920 1080]), [240 100 1440 880]);
end

function testFigurePositionIgnoresUnreportedDisplay(testCase)
% A degenerate ScreenSize such as [1 1 1 1] must not shrink the window to 1 by 1 px.
verifyEqual(testCase, calculateFigurePosition([1 1 1 1]), [1 1 1440 880]);
verifyEqual(testCase, calculateFigurePosition([1 1 300 200], [800 600]), [1 1 800 600]);
end

%% Helpers
function input = steadyInput(itLoad_W, liquidCaptureFraction, coolantMassFlow_kg_s, supplyTemperature_C)
input = struct( ...
    'itLoad_W', itLoad_W, ...
    'liquidCaptureFraction', liquidCaptureFraction, ...
    'coolantMassFlow_kg_s', coolantMassFlow_kg_s, ...
    'coolantSpecificHeat_J_kgK', 4180, ...
    'supplyTemperature_C', supplyTemperature_C);
end

function input = presetInput(preset)
input = steadyInput(1000 * preset.itLoad_kW, preset.liquidCaptureFraction, ...
    preset.coolantMassFlow_kg_s, preset.supplyTemperature_C);
input.thermalResistance_K_W = preset.thermalResistance_K_kW / 1000;
end

function parameters = transientParameters(liquidCaptureFraction, coolantMassFlow_kg_s, ...
        thermalResistance_K_W, thermalCapacitance_J_K)
parameters = struct( ...
    'liquidCaptureFraction', liquidCaptureFraction, ...
    'coolantMassFlow_kg_s', coolantMassFlow_kg_s, ...
    'coolantSpecificHeat_J_kgK', 4180, ...
    'supplyTemperature_C', 25, ...
    'thermalResistance_K_W', thermalResistance_K_W, ...
    'thermalCapacitance_J_K', thermalCapacitance_J_K, ...
    'initialComponentTemperature_C', 25);
end

function app = launchHiddenExplorer(testCase)
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(projectRoot);
app = DataCenterCoolingExplorer('Visible', 'off');
testCase.addTeardown(@() deleteIfValid(app.Figure));
end

function deleteIfValid(graphicObject)
if isvalid(graphicObject)
    delete(graphicObject);
end
end

function deleteNewFigures(existingFigures)
allFigures = findall(groot, 'Type', 'figure');
for index = 1:numel(allFigures)
    if ~any(allFigures(index) == existingFigures)
        delete(allFigures(index));
    end
end
end
