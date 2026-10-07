function state = calculateCoolingState(input)
%CALCULATECOOLINGSTATE Apply a steady rack-level heat-split balance.
%
% This is an educational, synthetic model. It calculates the heat routed to
% a liquid loop and an air path, then applies Q = m_dot*c_p*DeltaT to the
% liquid path. When a component-to-coolant resistance is supplied, it also
% returns the steady component temperature from calculateWallCoupling. It is
% not a calibrated rack or facility design calculation.
%
% Required input fields, all in SI units except temperature in degC:
%   itLoad_W                    - IT electrical load converted to heat [W]
%   liquidCaptureFraction       - heat fraction routed to liquid [-]
%   coolantMassFlow_kg_s        - liquid-loop mass flow [kg/s]
%   coolantSpecificHeat_J_kgK   - coolant specific heat [J/(kg K)]
%   supplyTemperature_C         - liquid-loop supply temperature [degC]
%
% Optional input field:
%   thermalResistance_K_W       - component-to-coolant wall resistance [K/W]

validateSteadyInput(input);

liquidHeat_W = input.itLoad_W * input.liquidCaptureFraction;
airHeat_W = input.itLoad_W - liquidHeat_W;
capacityRate_W_K = input.coolantMassFlow_kg_s * input.coolantSpecificHeat_J_kgK;
coolantDeltaT_K = liquidHeat_W / capacityRate_W_K;

state = struct( ...
    'itLoad_W', input.itLoad_W, ...
    'liquidHeat_W', liquidHeat_W, ...
    'airHeat_W', airHeat_W, ...
    'capacityRate_W_K', capacityRate_W_K, ...
    'coolantDeltaT_K', coolantDeltaT_K, ...
    'returnTemperature_C', input.supplyTemperature_C + coolantDeltaT_K);

if isfield(input, 'thermalResistance_K_W')
    coupling = calculateWallCoupling(input.coolantMassFlow_kg_s, ...
        input.coolantSpecificHeat_J_kgK, input.thermalResistance_K_W);
    state.NTU = coupling.NTU;
    state.effectiveness = coupling.effectiveness;
    state.effectiveResistance_K_W = coupling.effectiveResistance_K_W;
    state.componentTemperature_C = input.supplyTemperature_C + ...
        liquidHeat_W * coupling.effectiveResistance_K_W;
end
end

function validateSteadyInput(input)
requiredFields = [ ...
    "itLoad_W", "liquidCaptureFraction", "coolantMassFlow_kg_s", ...
    "coolantSpecificHeat_J_kgK", "supplyTemperature_C"];

if ~isstruct(input) || ~all(isfield(input, requiredFields))
    error('DataCenterCooling:MissingInput', ...
        'Input must be a struct with all required cooling-state fields.');
end

if ~isscalar(input.itLoad_W) || ~isfinite(input.itLoad_W) || input.itLoad_W < 0
    error('DataCenterCooling:InvalidITLoad', ...
        'itLoad_W must be a finite, nonnegative scalar in W.');
end
if ~isscalar(input.liquidCaptureFraction) || ...
        ~isfinite(input.liquidCaptureFraction) || ...
        input.liquidCaptureFraction < 0 || input.liquidCaptureFraction > 1
    error('DataCenterCooling:InvalidLiquidCaptureFraction', ...
        'liquidCaptureFraction must be a scalar from 0 through 1.');
end
if ~isscalar(input.coolantMassFlow_kg_s) || ...
        ~isfinite(input.coolantMassFlow_kg_s) || input.coolantMassFlow_kg_s <= 0
    error('DataCenterCooling:InvalidMassFlow', ...
        'coolantMassFlow_kg_s must be a finite, positive scalar in kg/s.');
end
if ~isscalar(input.coolantSpecificHeat_J_kgK) || ...
        ~isfinite(input.coolantSpecificHeat_J_kgK) || ...
        input.coolantSpecificHeat_J_kgK <= 0
    error('DataCenterCooling:InvalidSpecificHeat', ...
        'coolantSpecificHeat_J_kgK must be a finite, positive scalar in J/(kg K).');
end
if ~isscalar(input.supplyTemperature_C) || ~isfinite(input.supplyTemperature_C)
    error('DataCenterCooling:InvalidSupplyTemperature', ...
        'supplyTemperature_C must be a finite scalar in degC.');
end
if isfield(input, 'thermalResistance_K_W') && ~isscalar(input.thermalResistance_K_W)
    error('DataCenterCooling:InvalidThermalResistance', ...
        'thermalResistance_K_W must be a finite, positive scalar in K/W.');
end
end
