% Data Center Cooling Explorer
% Version 0.3.1 (2026-10-06)
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
%   scripts/renderDemoAnimation    - Regenerate the animated README demo.
%   tests/runTests                 - Run the automated verification tests.
%   docs/INSTRUCTOR_GUIDE.md        - Suggested 15-20 minute classroom use.
%   CONTRIBUTING.md                 - Contribution and verification guidance.
%
% The models are educational and assumption-driven. They are not calibrated
% predictions for a particular rack, cold plate, CDU, or facility.
