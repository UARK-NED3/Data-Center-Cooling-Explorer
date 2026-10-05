# Release checklist

Use this checklist before a public GitHub or MATLAB Central File Exchange release.

- [ ] Run `addpath('tests'); runTests` in a clean MATLAB R2025b session.
- [ ] Run `scripts/renderPreview.m` and inspect the generated image.
- [ ] Confirm that the package contains no licensed, operational, vendor, or third-party telemetry.
- [ ] Confirm that every displayed parameter is labeled as synthetic, assumed, or derived.
- [ ] Confirm that documentation retains the non-validation and non-design-use limitation.
- [ ] Confirm the Apache-2.0 license and citation metadata are present.
- [ ] Create a signed or annotated `v1.0.0` Git tag after final review.
- [ ] Package the tagged release for MATLAB Central File Exchange.
- [ ] Add the `25yrcontest` tag in File Exchange metadata.
- [ ] Verify the File Exchange listing has a short description, screenshots, license, and repository link.
