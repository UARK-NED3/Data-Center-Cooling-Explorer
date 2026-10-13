# LinkedIn outreach package

Use this package to promote the Explorer without turning an educational model
into a design or validation claim. Confirm the release, links, and visual asset
immediately before publishing; social posts are not automatically published by
this repository.

## Post 1 — Explorer launch or update

**Visual:** `docs/explorer-demo.gif` (first choice) or
`docs/flow-limited-loop-preview.png` with alt text: “Data Center Cooling
Explorer showing a learner's prediction, the computed temperature response, and
the coolant-flow slider.”

**Draft:**

> Every watt of IT power becomes heat, but an energy balance alone is not
> enough to describe where that heat goes.
>
> We created the Data Center Cooling Explorer, a base-MATLAB lesson and
> interactive app for learning how coolant flow, component-to-coolant thermal
> resistance, and thermal storage shape temperatures in a liquid-cooled rack.
> Learners make a prediction before revealing a scenario, then inspect the heat
> path, transient response, and flow-dependent temperatures.
>
> One central lesson is deliberately counterintuitive: a model can close its
> energy balance and still violate the second law. The Explorer uses that
> failure to motivate a wall-coupled heat-transfer model.
>
> All values are synthetic, declared teaching assumptions. This is not a
> calibrated rack, cold-plate, CDU, or facility-design tool.
>
> Try it in MATLAB Online or download it from File Exchange:
> https://www.mathworks.com/matlabcentral/fileexchange/184880-data-center-cooling-explorer
>
> #DataCenterCooling #LiquidCooling #HeatTransfer #EngineeringEducation #MATLAB

## Post 2 — A physics lesson, not a black box

**Visual:** `docs/flow-limited-loop-preview.png`.

**Draft:**

> A useful engineering teaching example: a liquid-cooling model can conserve
> energy and still predict coolant leaving hotter than the component heating it.
>
> The Data Center Cooling Explorer makes that failure visible. It first shows
> the tempting shortcut, then replaces it with a wall-coupled
> effectiveness–NTU model. The resulting model keeps the coolant return below
> the component temperature and shows why increasing flow lowers the component
> temperature.
>
> The point is not to provide a rack design answer. It is to help students and
> practitioners recognize the physical checks that should accompany a compact
> thermal model.
>
> The open lesson includes automated equation and limiting-case tests, plus a
> guided MATLAB script and app:
> https://github.com/UARK-NED3/Data-Center-Cooling-Explorer
>
> #ThermalManagement #SecondLaw #DataCenterCooling #MATLAB

## Post 3 — Classroom or self-study invitation

**Visual:** `docs/explorer-preview.png`.

**Draft:**

> What should a learner predict before touching a liquid-cooling model?
>
> In the Data Center Cooling Explorer, the learner predicts whether a defined
> change will make a temperature rise, fall, or stay the same. Only then does
> the app reveal the scenario and explain the computed response.
>
> The 15–20 minute activity connects energy balance, thermal resistance,
> heat-exchanger behavior, and transient thermal storage. It uses only base
> MATLAB and runs in MATLAB Online.
>
> The inputs are synthetic and intentionally limited to an educational,
> one-node model—not a validated facility or equipment model.
>
> Instructor guide and source:
> https://github.com/UARK-NED3/Data-Center-Cooling-Explorer
>
> #EngineeringEducation #HeatTransfer #MATLAB #DataCenterCooling

## Pre-publication check

- Confirm that the cited GitHub tag and File Exchange version match.
- Confirm that the selected asset was generated from the intended release.
- Retain the synthetic-input and non-design-use boundary in the post.
- Do not claim measured-rack validation, energy savings, equipment suitability,
  or field performance.
- Check the post’s rendered links and alt text before publishing.
