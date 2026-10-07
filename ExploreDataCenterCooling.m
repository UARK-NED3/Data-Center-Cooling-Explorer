%[text] # Data Center Cooling Explorer
%[text] Every watt of electrical power that a server draws becomes heat. To keep a processor within its operating range, that heat has to flow from the chip into a coolant and leave the rack with it. This live script asks one question: **what sets how hot the coolant and the component get?** It builds the answer in five short steps, then opens an interactive Explorer in which you predict, test, and explain.
%[text] All inputs are declared, synthetic assumptions chosen for teaching. The model is not a calibrated description of any rack, cold plate, or facility.
%[text:tableOfContents]{"heading":"Contents"}
projectRoot = fileparts(which('DataCenterCoolingExplorer'));
if isempty(projectRoot)
    error('DataCenterCooling:ProjectNotFound', ...
        'Run this live script from the Data-Center-Cooling-Explorer folder.');
end
addpath(fullfile(projectRoot, 'src'));
if ~exist('explorerVisible', 'var')
    explorerVisible = 'on';   % the automated tests set this to 'off'
end
degC = [char(176) 'C'];
cp_J_kgK = 4180;              % water-like coolant specific heat [J/(kg K)]
baseline = getExplorerPreset('Moderate liquid cooling');
colors = struct('blue', [0 114 178] / 255, 'orange', [230 159 0] / 255, ...
    'vermillion', [213 94 0] / 255, 'gray', [0.45 0.45 0.45]);
styleAxes = @(axisHandle) set(axisHandle, 'Box', 'on', 'TickDir', 'in', ...
    'FontName', 'Arial', 'FontSize', 11, 'XGrid', 'on', 'YGrid', 'on', 'GridAlpha', 0.12);
%%
%[text] ## 1. Why carry the heat in a liquid?
%[text] A fluid stream that warms by $\\Delta T$ carries heat at the rate $Q = \\rho\\,\\dot{V} c_p \\Delta T$. For the same heat and the same temperature rise, the required volume flow $\\dot{V}$ scales with $1/(\\rho c_p)$, the inverse of the fluid's volumetric heat capacity. Compare water and air carrying 10 kW with a 10 K rise.
heat_W = 10e3;                % heat to carry [W]
allowedRise_K = 10;           % allowed fluid temperature rise [K]
% Approximate properties near 25 degC and 1 atm.
water = struct('density_kg_m3', 997, 'specificHeat_J_kgK', 4180);
air = struct('density_kg_m3', 1.18, 'specificHeat_J_kgK', 1007);
waterFlow_L_min = 6e4 * heat_W / (water.density_kg_m3 * water.specificHeat_J_kgK * allowedRise_K);
airFlow_L_min = 6e4 * heat_W / (air.density_kg_m3 * air.specificHeat_J_kgK * allowedRise_K);
fprintf('Water: %.1f L/min. Air: %.0f L/min, about %.0f times the volume of water.\n', ...
    waterFlow_L_min, airFlow_L_min, airFlow_L_min / waterFlow_L_min);
figure('Visible', explorerVisible);
bars = bar([waterFlow_L_min, airFlow_L_min], 0.55, 'FaceColor', 'flat', 'BaseValue', 1);
bars.CData = [colors.blue; colors.orange];
set(gca, 'YScale', 'log', 'XTickLabel', {'Water', 'Air'});
styleAxes(gca);
ylim([1 1e6]);
text(1, 1.6 * waterFlow_L_min, sprintf('%.1f L/min', waterFlow_L_min), ...
    'HorizontalAlignment', 'center', 'FontName', 'Arial', 'FontWeight', 'bold');
text(2, 1.6 * airFlow_L_min, sprintf('%.0f L/min', airFlow_L_min), ...
    'HorizontalAlignment', 'center', 'FontName', 'Arial', 'FontWeight', 'bold');
ylabel('Volume flow (L/min)');
title('Volume flow needed to carry 10 kW with a 10 K rise');
%%
%[text] ## 2. The energy balance sets the coolant temperature rise
%[text] At steady state, the heat captured by the liquid loop leaves with the coolant:
%[text]{"align":"center"} $Q_{\\mathrm{liquid}} = f_{\\mathrm{liquid}}\\,Q_{\\mathrm{IT}} = \\dot{m}\\,c_p\\left(T_{\\mathrm{return}} - T_{\\mathrm{supply}}\\right)$
%[text] Halving the mass flow $\\dot{m}$ doubles the coolant temperature rise. Move the slider and watch the operating point slide along the curve.
coolantMassFlow_kg_s = 0.2; %[control:slider:5f1a]{"position":[24,27]}
liquidHeat_W = 1000 * baseline.itLoad_kW * baseline.liquidCaptureFraction;
flow_kg_s = linspace(0.05, 0.5, 181);
rise_K = liquidHeat_W ./ (flow_kg_s * cp_J_kgK);
selectedRise_K = liquidHeat_W / (coolantMassFlow_kg_s * cp_J_kgK);
fprintf('%.1f kW into the loop at %.3f kg/s raises the coolant temperature by %.1f K.\n', ...
    liquidHeat_W / 1000, coolantMassFlow_kg_s, selectedRise_K);
figure('Visible', explorerVisible);
plot(flow_kg_s, rise_K, '-', 'Color', colors.blue, 'LineWidth', 2);
hold on
plot(coolantMassFlow_kg_s, selectedRise_K, 'o', 'MarkerSize', 9, ...
    'MarkerFaceColor', colors.blue, 'MarkerEdgeColor', 'white');
hold off
styleAxes(gca);
xlabel('Coolant mass flow (kg/s)');
ylabel('Coolant temperature rise, \DeltaT (K)');
title(sprintf('%.0f kW routed to the liquid loop', liquidHeat_W / 1000));
%[text] **Predict before you run Section 3.** Keep the load, the heat split, and the component-to-coolant resistance fixed, and cut the flow from 0.20 to 0.08 kg/s. Will the component get hotter, get cooler, or stay at the same temperature?
%%
%[text] ## 3. A model that balances energy and still fails
%[text] A tempting shortcut treats the component as if it touched coolant at the supply temperature through a resistance $R_{\\mathrm{th}}$:
%[text]{"align":"center"} $T_{\\mathrm{component}} = T_{\\mathrm{supply}} + Q_{\\mathrm{liquid}}\\,R_{\\mathrm{th}}$
%[text] Pair it with the energy balance from Section 2 and every watt is accounted for. Run the section and compare the two temperatures.
resistance_K_W = baseline.thermalResistance_K_kW / 1000;
supply_C = baseline.supplyTemperature_C;
shortcutComponent_C = supply_C + liquidHeat_W * resistance_K_W * ones(size(flow_kg_s));
return_C = supply_C + rise_K;
lowFlow_kg_s = 0.08;
lowFlowReturn_C = supply_C + liquidHeat_W / (lowFlow_kg_s * cp_J_kgK);
fprintf(['At %.2f kg/s the shortcut puts the component at %.1f %s, but the coolant ', ...
    'leaves at %.1f %s.\n'], lowFlow_kg_s, shortcutComponent_C(1), degC, lowFlowReturn_C, degC);
violates = return_C > shortcutComponent_C;
figure('Visible', explorerVisible);
if any(violates)
    xregion(min(flow_kg_s(violates)), max(flow_kg_s(violates)), ...
        'FaceColor', colors.vermillion, 'FaceAlpha', 0.12, ...
        'DisplayName', 'Coolant hotter than component');
end
hold on
plot(flow_kg_s, shortcutComponent_C, '-.', 'Color', colors.vermillion, 'LineWidth', 2, ...
    'DisplayName', 'Component, shortcut model');
plot(flow_kg_s, return_C, '--', 'Color', colors.blue, 'LineWidth', 2, ...
    'DisplayName', 'Liquid return, energy balance');
hold off
styleAxes(gca);
ylim([supply_C, min(max(return_C), supply_C + 4 * (shortcutComponent_C(1) - supply_C))]);
xlabel('Coolant mass flow (kg/s)');
ylabel(['Temperature (' degC ')']);
legend('Location', 'northeast');
title('The shortcut closes the energy balance but breaks the second law');
%[text] Inside the shaded region, the shortcut accounts for every watt yet predicts coolant leaving hotter than the component that heats it. Heat cannot flow from a cooler solid into warmer coolant. **Conservation of energy is necessary, but it is not sufficient.** The shortcut fails because it ignores the coolant warming as it flows along the component, so it also predicts that flow has no effect on the component temperature.
%%
%[text] ## 4. Let the coolant warm along the wall
%[text] Treat the component as a uniform-temperature wall that heats the coolant as it flows past. With wall conductance $UA = 1/R_{\\mathrm{th}}$ and capacity rate $\\dot{m}c_p$, the standard heat-exchanger result is
%[text]{"align":"center"} $Q_{\\mathrm{liquid}} = \\varepsilon\\,\\dot{m}c_p\\left(T_{\\mathrm{component}} - T_{\\mathrm{supply}}\\right), \\qquad \\varepsilon = 1 - e^{-\\mathrm{NTU}}, \\qquad \\mathrm{NTU} = \\frac{UA}{\\dot{m}c_p}$
%[text] Because the effectiveness $\\varepsilon$ never exceeds 1, the coolant can approach the component temperature but never pass it. The Explorer uses this model.
coupling = calculateWallCoupling(flow_kg_s, cp_J_kgK, resistance_K_W);
wallComponent_C = supply_C + liquidHeat_W .* coupling.effectiveResistance_K_W;
steadyAt = @(flow) calculateCoolingState(struct('itLoad_W', 1000 * baseline.itLoad_kW, ...
    'liquidCaptureFraction', baseline.liquidCaptureFraction, 'coolantMassFlow_kg_s', flow, ...
    'coolantSpecificHeat_J_kgK', cp_J_kgK, 'supplyTemperature_C', supply_C, ...
    'thermalResistance_K_W', resistance_K_W));
baseState = steadyAt(baseline.coolantMassFlow_kg_s);
lowState = steadyAt(lowFlow_kg_s);
fprintf(['Component: %.1f %s at %.2f kg/s and %.1f %s at %.2f kg/s.\n', ...
    'Return: %.1f %s and %.1f %s. The component stays hotter than the coolant in both cases.\n'], ...
    baseState.componentTemperature_C, degC, baseline.coolantMassFlow_kg_s, ...
    lowState.componentTemperature_C, degC, lowFlow_kg_s, ...
    baseState.returnTemperature_C, degC, lowState.returnTemperature_C, degC);
figure('Visible', explorerVisible);
plot(flow_kg_s, shortcutComponent_C, '-.', 'Color', colors.gray, 'LineWidth', 1.5, ...
    'DisplayName', 'Component, shortcut model');
hold on
plot(flow_kg_s, wallComponent_C, '-', 'Color', colors.vermillion, 'LineWidth', 2.2, ...
    'DisplayName', 'Component, wall-coupled model');
plot(flow_kg_s, return_C, '--', 'Color', colors.blue, 'LineWidth', 2, ...
    'DisplayName', 'Liquid return');
plot([baseline.coolantMassFlow_kg_s lowFlow_kg_s], ...
    [baseState.componentTemperature_C lowState.componentTemperature_C], 'o', ...
    'MarkerSize', 8, 'MarkerFaceColor', colors.vermillion, 'MarkerEdgeColor', 'white', ...
    'HandleVisibility', 'off');
hold off
styleAxes(gca);
ylim([supply_C, min(max(wallComponent_C), supply_C + 4 * (baseState.componentTemperature_C - supply_C))]);
xlabel('Coolant mass flow (kg/s)');
ylabel(['Temperature (' degC ')']);
legend('Location', 'northeast');
title('With the coolant warming along the wall, lower flow heats the component');
%[text] This answers the prediction from Section 2. Lower flow makes the coolant warm more along the wall, so the component must run hotter to push the same heat into it. The shortcut predicted no change at all.
%%
%[text] ## 5. Thermal storage sets how fast the component responds
%[text] A component with heat capacity $C_{\\mathrm{th}}$ cannot change temperature instantly. After a workload step, the lumped energy balance
%[text]{"align":"center"} $C_{\\mathrm{th}}\\frac{dT_{\\mathrm{component}}}{dt} = Q_{\\mathrm{liquid}}(t) - \\frac{T_{\\mathrm{component}} - T_{\\mathrm{supply}}}{R_{\\mathrm{eff}}}, \\qquad R_{\\mathrm{eff}} = \\frac{1}{\\varepsilon\\,\\dot{m}c_p}$
%[text] has an exponential solution with time constant $\\tau = R_{\\mathrm{eff}}C_{\\mathrm{th}}$. One time constant after the step, the component has covered 63% of its temperature rise.
capacitance_J_K = 30e3;       % effective component heat capacity [J/K]
stepTime_s = 60;
time_s = linspace(0, 360, 721)';
itLoad_W = 1000 * baseline.itLoad_kW * (0.4 + 0.6 * (time_s >= stepTime_s));
baseCoupling = calculateWallCoupling(baseline.coolantMassFlow_kg_s, cp_J_kgK, resistance_K_W);
parameters = struct('liquidCaptureFraction', baseline.liquidCaptureFraction, ...
    'coolantMassFlow_kg_s', baseline.coolantMassFlow_kg_s, ...
    'coolantSpecificHeat_J_kgK', cp_J_kgK, 'supplyTemperature_C', supply_C, ...
    'thermalResistance_K_W', resistance_K_W, 'thermalCapacitance_J_K', capacitance_J_K, ...
    'initialComponentTemperature_C', supply_C + 0.4 * liquidHeat_W * baseCoupling.effectiveResistance_K_W);
response = simulateComponentTransient(parameters, time_s, itLoad_W);
tau_s = response.timeConstant_s;
fprintf('Time constant: %.0f s.\n', tau_s);
figure('Visible', explorerVisible);
plot(response.time_s, response.componentTemperature_C, '-', 'Color', colors.vermillion, ...
    'LineWidth', 2.2, 'DisplayName', 'Component');
hold on
plot(response.time_s, response.returnTemperature_C, '--', 'Color', colors.blue, ...
    'LineWidth', 2, 'DisplayName', 'Liquid return');
xline(stepTime_s, ':', 'Load step', 'Color', colors.gray, 'HandleVisibility', 'off', ...
    'LabelOrientation', 'horizontal', 'LabelHorizontalAlignment', 'left');
xline(stepTime_s + tau_s, ':', sprintf('\\tau = %.0f s after the step', tau_s), ...
    'Color', colors.gray, 'HandleVisibility', 'off', 'LabelOrientation', 'horizontal', ...
    'LabelVerticalAlignment', 'bottom');
hold off
styleAxes(gca);
xlabel('Time (s)');
ylabel(['Temperature (' degC ')']);
legend('Location', 'southeast');
title('Response to a step from 40% to 100% of the IT load');
%%
%[text] ## 6. Predict, test, and explain in the Explorer
%[text] The Explorer opens on the baseline case. Pick each named scenario from the menu. The Explorer asks you to predict how one output will change, loads the scenario only after you commit, and then explains the result. Afterward, drag the sliders: every view updates while you drag.
%[text] - **Flow-limited loop:** only the coolant flow changes.
%[text] - **Lower thermal resistance:** only the component-to-coolant resistance changes.
%[text] - **High-density stress test:** a demanding case that separates heat fractions from absolute heat rates. \
app = DataCenterCoolingExplorer('Visible', explorerVisible);
%%
%[text] ## 7. Transfer question
%[text] The Explorer's model satisfies both the energy balance and the second law, yet it is still not validated for any real rack. List the measurements and metadata you would need before comparing it with a physical system. Consider:
%[text] - the rack topology and the number and arrangement of cold plates;
%[text] - how the flow divides among parallel cold plates;
%[text] - the pressure drop and the pump operating point;
%[text] - where each temperature sensor sits, what it measures, and its uncertainty;
%[text] - the operating conditions during the measurement. \
%[text] Which of these would a matching return temperature confirm, and which would it leave untested?

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline","rightPanelPercent":40}
%---
%[control:slider:5f1a]
%   data: {"defaultValue":0.2,"label":"Coolant mass flow (kg/s)","max":0.5,"min":0.05,"run":"Section","runOn":"ValueChanging","step":0.01}
%---
