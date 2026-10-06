# File Exchange listing copy

## Title

Data Center Cooling Explorer

## Short description

An interactive MATLAB learning experience for exploring how IT heat load, liquid heat capture, coolant flow, and effective thermal resistance affect liquid-loop temperature rise and a one-node transient thermal response.

## Full description

Every watt of IT electrical load becomes heat that a cooling system must remove. This interactive lesson guides users through a synthetic liquid-cooling heat balance and a one-node transient component model. Start with a moderate liquid-cooling case, predict what will happen when flow falls, and compare the result with a flow-limited loop and a high-density stress test.

The Explorer calculates liquid and air heat partition, coolant return temperature, transient component temperature, and temporary component energy storage. It also makes a central modeling lesson explicit: matching $Q=\dot{m}c_p\Delta T$ is necessary for conservation, but it does not validate a prediction for a real rack. Rack topology, flow distribution, cold-plate behavior, pressure drop, sensor definitions, and uncertainty remain necessary for a physical comparison.

All inputs are synthetic and are included only for education. This package is not a calibrated rack, cold-plate, CDU, pump, or facility model; do not use it for equipment selection or operational decisions.

## Requirements

- MATLAB R2025b used for verification.
- Base MATLAB only. No additional toolboxes are required.

## Suggested tags

`25yrcontest`, `data center`, `liquid cooling`, `heat transfer`, `thermal management`, `engineering education`, `MATLAB app`

## Suggested screenshots

- `docs/explorer-preview.png` — moderate liquid-cooling starting case.
- `docs/flow-limited-loop-preview.png` — same teaching frame with lower coolant flow.
- `docs/high-density-stress-preview.png` — stress case with the interpretive temperature cue.

## Verification statement

Version 0.2.0 passed 11 automated MATLAB R2025b tests, including heat-balance reconstruction, limiting cases, transient conservation, preset selection, the interactive refresh path, and the guided lesson launcher. The release archive will be tested from a clean extraction before publication.

## Project link

https://github.com/UARK-NED3/Data-Center-Cooling-Explorer
