%% Data Center Cooling Explorer
% An interactive thermal-fluid lesson for understanding why a correct heat
% balance alone does not validate a model of a real data-center rack.
%
% All parameters in this lesson are synthetic, declared assumptions. The
% lesson does not represent a measured rack, vendor product, or facility.

%% Learning question
% How do IT heat load, liquid heat capture, coolant flow, and effective
% component-to-coolant resistance change coolant temperature rise and a
% one-node transient component-temperature response?
%
% Before opening the Explorer, make a prediction: if the liquid heat
% fraction stays fixed but coolant flow decreases, which outputs should
% change and which should not?

%% Open the interactive Explorer
% Begin with "Moderate liquid cooling." Then compare it with
% "Flow-limited loop" and "High-density stress test." The on-screen
% prompts explain the intended comparison.
if ~exist('explorerVisible', 'var')
    explorerVisible = 'on';
end
app = DataCenterCoolingExplorer('Visible', explorerVisible); %#ok<NASGU>

%% Transfer question
% A matching Q = m_dot*c_p*DeltaT balance does not identify rack topology,
% flow distribution, cold-plate resistance, pressure drop, or sensor error.
% List the measurements and metadata that would be required before comparing
% this simplified model with a physical rack.
