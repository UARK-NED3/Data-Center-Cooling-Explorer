# File Exchange listing copy

## Title

Data Center Cooling Explorer

## Short description

An interactive MATLAB live script and app in which learners predict, test, and explain how IT heat load, coolant flow, and thermal resistance set the coolant and component temperatures in a liquid-cooled rack.

## Full description

Every watt of IT power becomes heat, and in a liquid-cooled rack that heat must cross from a component into a coolant stream. This lesson asks what sets how hot the coolant and the component get.

The guided live script builds the answer in five steps: why liquids carry heat with far less volume flow than air; how the energy balance sets the coolant temperature rise; a tempting shortcut that closes the energy balance exactly yet predicts coolant leaving hotter than the component; a wall-coupled (effectiveness–NTU) model that restores the second law; and the thermal time constant that sets how fast the component responds to a workload step.

The interactive Explorer then turns each idea into a prediction. Learners choose a scenario, commit to Rise, Fall, or Stay the same for one output, and only then see the scenario load, with an explanation of the computed change. Every view updates while a slider is dragged: the heat path, the transient response with its time constant, steady temperatures across the full flow range, and where the transient heat goes.

All inputs are synthetic and included only for education. The package is not a calibrated rack, cold-plate, CDU, pump, or facility model; do not use it for equipment selection or operational decisions.

## Suggested domain

Engineering

## Requirements

- Base MATLAB only. No additional toolboxes are required.
- Automated tests pass in MATLAB R2025b and R2023a.
- The live script uses the plain-text live-script format introduced in R2025a; earlier releases run the same file as an ordinary script.

## Suggested tags

`25yrcontest`, `data center`, `liquid cooling`, `heat transfer`, `thermodynamics`, `thermal management`, `engineering education`, `live script`, `MATLAB app`

## Suggested screenshots

- `docs/flow-limited-loop-preview.png`: the Explorer after a learner predicts the flow-limited case, with feedback visible.
- `docs/explorer-preview.png`: the moderate liquid-cooling baseline.
- `docs/lower-resistance-preview.png`: halving the resistance lowers the component temperature but leaves the return temperature unchanged.
- `docs/high-density-stress-preview.png`: the stress case, with the caution cue and the 1-atm boiling reference.

## Verification statement

Version 0.3.0 passed 24 automated tests in MATLAB R2025b and R2023a. The tests check the heat balance and limiting cases, the second-law bound across a parameter grid, the effectiveness–NTU limits, the exact transient solution against an independent `ode45` integration and an integrated energy balance, agreement between every prediction answer and the model, the app's prediction and live-update paths, and an end-to-end run of the live script. The tests also passed in R2025b from a clean `git archive` extraction of the committed source with the default MATLAB path restored.

## Project links

- Repository: https://github.com/UARK-NED3/Data-Center-Cooling-Explorer
- Open in MATLAB Online: https://matlab.mathworks.com/open/github/v1?repo=UARK-NED3/Data-Center-Cooling-Explorer&file=ExploreDataCenterCooling.m
