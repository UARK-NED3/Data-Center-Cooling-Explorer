# Changelog

All notable changes are documented here.

## [0.3.0] - 2026-10-06

### Fixed

- The component temperature now comes from a wall-coupled (effectiveness–NTU) model. Earlier versions referenced the thermal resistance to the supply temperature, which made the component temperature independent of coolant flow and let the coolant return exceed the component temperature at low flow (72.8 °C return from a 49.0 °C component in the v0.2.0 flow-limited scenario).
- The flow-limited scenario now changes only the coolant flow; v0.2.0 also doubled the IT load, which confounded the comparison.
- The transient legend no longer lists the load-step reference line as `data1`.
- The Explorer now fits its default window within small displays instead of selecting the full preferred size when the screen is below 800 by 600 pixels.

### Added

- A plain-text live script (R2025a format) that builds the lesson in five sections, with rendered equations, an embedded coolant-flow slider, and the supply-referenced shortcut as a counterexample that conserves energy but violates the second law.
- A predict-before-load step in the Explorer: named scenarios load only after the learner predicts Rise, Fall, or Stay the same, and the Explorer explains the computed change.
- A "Lower thermal resistance" scenario showing that the return temperature does not depend on the component-to-coolant resistance.
- Live updates while a slider is dragged.
- A steady flow-sweep view with the operating point and a 1-atm boiling reference, a time-constant readout, and second-law and boiling cues.
- `calculateWallCoupling`, an Open in MATLAB Online badge, and two additional listing images.

### Changed

- The transient model evaluates the exact exponential solution for a load held constant between samples; `ode45` now serves only as an independent reference in the tests.
- Replaced the energy-residual readout and tests, which were zero by construction, with a time-constant readout and independent checks against `ode45`, an integrated energy balance, and limiting cases.
- Displayed temperatures in °C, adopted the Okabe–Ito palette with redundant line styles, sized the window to the screen, and made the control column scrollable.
- Rewrote the README to open with the physics, state the scope once, and drop the contest planning notes.

## [0.2.0] - 2026-10-05

### Added

- Guided MATLAB lesson entry point with a prediction and transfer question.
- Three reproducible synthetic teaching scenarios and a custom-slider mode.
- Numeric slider readouts, a one-node temperature cue, `CONTENTS.m`, and File Exchange listing copy.

### Changed

- Revised the default case to a moderate liquid-cooling scenario and improved the app’s plot and layout readability.

## [0.1.1] - 2026-10-05

### Fixed

- Rendered README equations with GitHub-supported math delimiters.
- Clarified public-facing model-scope language.

## [0.1.0] - 2026-10-05

### Added

- Interactive MATLAB Explorer for synthetic liquid-cooling heat partition and transient thermal response.
- Tested steady and one-node transient model functions with energy-conservation checks.
- Reproducible application preview and explicit educational-model limitations.
