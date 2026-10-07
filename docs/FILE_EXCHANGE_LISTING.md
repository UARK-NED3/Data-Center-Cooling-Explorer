# File Exchange listing copy

## Title

Data Center Cooling Explorer: When Energy Balance Is Not Enough

If the title field is too short for the subtitle, use `Data Center Cooling Explorer` and open the summary with the subtitle's idea.

## Short description

A cooling model can account for every watt and still predict the impossible. Learners predict, test, and explain what sets coolant and component temperatures in a liquid-cooled rack.

## Full description

A cooling model can close its energy balance exactly and still predict coolant leaving hotter than the component that heats it. This lesson uses that failure to teach what sets the coolant and component temperatures in a liquid-cooled rack, where every watt of IT power becomes heat that must cross from a component into a coolant stream.

The guided live script builds the answer in five steps: why liquids carry heat with far less volume flow than air; how the energy balance sets the coolant temperature rise; the tempting shortcut that closes the energy balance yet breaks the second law at low flow; a wall-coupled (effectiveness–NTU) model that restores the second law; and the thermal time constant that sets how fast the component responds to a workload step.

The interactive Explorer then turns each idea into a prediction. Learners choose a scenario, commit to Rise, Fall, or Stay the same for one output, and only then see the scenario load, with an explanation of the computed change. Every view updates while a slider is dragged: the heat path, the transient response with its time constant, steady temperatures across the full flow range, and where the transient heat goes.

An included instructor guide provides four learning objectives, a suggested 15–20 minute classroom sequence, the misconceptions targeted by each scenario, and a transfer question for connecting the synthetic lesson to physical-rack measurements.

All inputs are synthetic and included only for education. The package is not a calibrated rack, cold-plate, CDU, pump, or facility model; do not use it for equipment selection or operational decisions.

## Suggested domain

Engineering

## Requirements

- Base MATLAB only. No additional toolboxes are required.
- Automated tests pass in MATLAB R2025b and R2023a.
- The live script uses the plain-text live-script format introduced in R2025a; earlier releases run the same file as an ordinary script.

## Suggested tags

`25yrcontest`, `data center`, `liquid cooling`, `heat transfer`, `thermodynamics`, `second law`, `thermal management`, `engineering education`, `live script`, `MATLAB app`

## Suggested screenshots

- `docs/explorer-demo.gif`: an animated walk-through. A learner predicts the flow-limited case, reads the explanation, and drags the coolant-flow slider. Put it first if File Exchange accepts animated images; otherwise lead with the next image.
- `docs/flow-limited-loop-preview.png`: the Explorer after a learner predicts the flow-limited case, with feedback visible.
- `docs/explorer-preview.png`: the moderate liquid-cooling baseline.
- `docs/lower-resistance-preview.png`: halving the resistance lowers the component temperature but leaves the return temperature unchanged.
- `docs/high-density-stress-preview.png`: the stress case, with the caution cue and the 1-atm boiling reference.

## Verification statement

The current version passes 26 automated tests in MATLAB R2025b and R2023a. The tests check the heat balance and limiting cases, the second-law bound across a parameter grid, the effectiveness–NTU limits, the exact transient solution against an independent `ode45` integration and an integrated energy balance, agreement between every prediction answer and the model, the app's prediction and live-update paths, an end-to-end run of the live script, and window placement on small or degenerate displays. The tests also pass in R2025b from a clean `git archive` extraction of the committed source with the default MATLAB path restored.

## Project links

- Repository: https://github.com/UARK-NED3/Data-Center-Cooling-Explorer
- Open in MATLAB Online: https://matlab.mathworks.com/open/github/v1?repo=UARK-NED3/Data-Center-Cooling-Explorer&file=ExploreDataCenterCooling.m
