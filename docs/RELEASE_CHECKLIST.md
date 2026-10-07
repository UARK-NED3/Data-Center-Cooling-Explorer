# Release checklist

Use this checklist before a public GitHub or MATLAB Central File Exchange release.

- [ ] Run `addpath('tests'); runTests` in a clean MATLAB R2025b session.
- [ ] Open `ExploreDataCenterCooling.m` in the Live Editor (R2025a or later). Confirm that the formatted text, equations, and the coolant-flow slider in Section 2 render, and that moving the slider reruns the section.
- [ ] Click the README's **Open in MATLAB Online** badge and confirm that the live script opens and runs.
- [ ] Run `scripts/renderPreview.m` and inspect the four generated images.
- [ ] Confirm that the package contains no licensed, operational, vendor, or third-party telemetry.
- [ ] Confirm that every displayed parameter is labeled as synthetic, assumed, or derived.
- [ ] Confirm that documentation retains the non-validation and non-design-use limitation.
- [ ] Confirm the Apache-2.0 license and citation metadata are present, and that the version and date in `CITATION.cff`, `CHANGELOG.md`, and `CONTENTS.m` match the release tag.
- [ ] Create a signed or annotated release tag after final review.
- [ ] Link the File Exchange submission to the GitHub repository (required for the Apache-2.0 license) and sync from GitHub releases.
- [ ] Add the `25yrcontest` tag in File Exchange metadata.
- [ ] Verify the File Exchange listing has a short description, screenshots, license, and repository link.
