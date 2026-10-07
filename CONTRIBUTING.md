# Contributing to Data Center Cooling Explorer

Thank you for considering a contribution. This repository is a small, synthetic, teaching-focused MATLAB package. Its purpose is to help learners reason from energy conservation, heat-transfer temperature ordering, and first-order thermal response; it is not a calibrated rack-design or operations tool.

## Useful contributions

- clarify a teaching explanation, figure label, or accessibility feature;
- improve MATLAB compatibility, tests, or the reproducible preview workflow;
- add a focused synthetic lesson scenario with a documented physical question and expected learning outcome; or
- repair an error in equations, units, limiting cases, or documentation.

Before proposing a substantial model extension, experimental comparison, or external dataset, open an issue first. Such changes need explicit data rights, source provenance, units, measurement definitions, uncertainty, and a decision about whether the result remains an educational illustration or becomes a validated model claim.

## Development workflow

1. Create a short-lived branch from `main`.
2. Keep one physical or teaching purpose per pull request.
3. State the inputs, SI units, assumptions, expected limiting behavior, and test evidence in the pull-request description.
4. Run the test suite in a clean MATLAB session:

   ```matlab
   addpath('tests')
   runTests
   ```

5. For app or documentation-image changes, run `scripts/renderPreview.m` and inspect the generated images and animation before submitting.
6. Do not add licensed, proprietary, operational, vendor, student, or personally identifying data. The public package must remain reproducible from its tracked source and declared synthetic parameters.

## Coding and documentation conventions

- Use SI units in calculations and label displayed quantities with units.
- Keep physical assumptions and exclusions explicit; do not present synthetic examples as measurements or validation.
- Add a focused regression test for changed numerical behavior, a physical limiting case, or a learner-visible interaction.
- Preserve the distinction between the source functions in `src/` and user-facing entry-point scripts in the repository root or `scripts/`.
- Explain changes in the changelog when they affect users, results, or released assets.

## License

By submitting a contribution, you agree that it may be distributed under the repository's [Apache License 2.0](LICENSE).
