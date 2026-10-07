function coupling = calculateWallCoupling(coolantMassFlow_kg_s, coolantSpecificHeat_J_kgK, thermalResistance_K_W)
%CALCULATEWALLCOUPLING Effective resistance from a uniform-temperature component to a coolant stream.
%
% The component is treated as a uniform-temperature wall that heats a
% single-phase coolant stream entering at the supply temperature. With wall
% conductance UA = 1/R_th and coolant capacity rate C_dot = m_dot*c_p,
%
%   NTU           = UA/C_dot
%   effectiveness = 1 - exp(-NTU)
%   Q_to_coolant  = effectiveness*C_dot*(T_component - T_supply)
%
% so the effective component-to-supply resistance is 1/(effectiveness*C_dot).
% Because effectiveness <= 1, the coolant return temperature cannot exceed the
% component temperature. This is the standard result for a heat exchanger
% with one stream at uniform temperature; it is a teaching model, not a
% cold-plate correlation.
%
% Inputs may be scalars or arrays of a common size (for parameter sweeps):
%   coolantMassFlow_kg_s       - coolant mass flow [kg/s], positive
%   coolantSpecificHeat_J_kgK  - coolant specific heat [J/(kg K)], positive
%   thermalResistance_K_W      - component-to-coolant wall resistance [K/W], positive

validatePositive(coolantMassFlow_kg_s, 'coolantMassFlow_kg_s', 'DataCenterCooling:InvalidMassFlow');
validatePositive(coolantSpecificHeat_J_kgK, 'coolantSpecificHeat_J_kgK', 'DataCenterCooling:InvalidSpecificHeat');
validatePositive(thermalResistance_K_W, 'thermalResistance_K_W', 'DataCenterCooling:InvalidThermalResistance');

capacityRate_W_K = coolantMassFlow_kg_s .* coolantSpecificHeat_J_kgK;
conductance_W_K = 1 ./ thermalResistance_K_W;
NTU = conductance_W_K ./ capacityRate_W_K;
effectiveness = -expm1(-NTU);

coupling = struct( ...
    'capacityRate_W_K', capacityRate_W_K, ...
    'conductance_W_K', conductance_W_K, ...
    'NTU', NTU, ...
    'effectiveness', effectiveness, ...
    'effectiveResistance_K_W', 1 ./ (effectiveness .* capacityRate_W_K));
end

function validatePositive(value, name, identifier)
if ~isnumeric(value) || isempty(value) || any(~isfinite(value(:))) || any(value(:) <= 0)
    error(identifier, '%s must contain finite, positive values.', name);
end
end
