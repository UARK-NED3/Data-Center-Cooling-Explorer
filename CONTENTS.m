% Data Center Cooling Explorer
% Version 0.3.0 (2026-10-06)
%
% Files
%   ExploreDataCenterCooling       - Guided lesson (plain-text live script).
%   DataCenterCoolingExplorer      - Interactive MATLAB app with prediction prompts.
%   src/calculateCoolingState      - Steady heat partition, coolant rise, and component temperature.
%   src/calculateWallCoupling      - Effectiveness-NTU coupling between component and coolant.
%   src/simulateComponentTransient - Exact one-node transient component model.
%   src/getExplorerPreset          - Synthetic teaching scenarios and prediction questions.
%   src/calculateFigurePosition    - Display-aware position for the Explorer window.
%   scripts/renderPreview          - Regenerate the README and listing images.
%   tests/runTests                 - Run the automated verification tests.
%
% The models are educational and assumption-driven. They are not calibrated
% predictions for a particular rack, cold plate, CDU, or facility.
