# Instructor guide

## Intended use

This 15–20 minute activity is designed for an upper-level undergraduate or graduate course in heat transfer, thermal systems, electronics cooling, or data-center thermal management. It assumes that learners can interpret a steady energy balance and temperature difference. The app and live script use declared synthetic parameters; they are not a rack design or operating tool.

## Learning objectives

By the end of the activity, learners should be able to:

1. Explain why, for fixed liquid heat load, lower coolant mass flow produces a larger coolant temperature rise.
2. Identify why a model can close the energy balance yet give an impossible coolant-to-component temperature ordering.
3. Predict separately the effect of coolant flow and component-to-coolant resistance on component and return temperatures.
4. Interpret the thermal time constant from the transient response and connect it to $\tau=R_{\mathrm{eff}}C_{\mathrm{th}}$.

## Suggested 18-minute sequence

| Time | Activity | Instructor prompt | Evidence of understanding |
| --- | --- | --- | --- |
| 0–2 min | Frame the rack heat path | “Where can 10 kW of IT heat go?” | Learners distinguish the liquid and room-air heat paths. |
| 2–5 min | Run Section 1 | “Why is liquid flow practical when air flow is not?” | Learners compare volume flow requirements at the same heat rate and temperature rise. |
| 5–8 min | Use the Section 2 slider | “For the same $Q_{\mathrm{liquid}}$, what happens to $\Delta T$ when $\dot{m}$ decreases?” | Learners use $\Delta T=Q_{\mathrm{liquid}}/(\dot{m}c_p)$ and predict a larger coolant rise. |
| 8–12 min | Discuss Sections 3 and 4 | “Does an energy residual of zero prove that every predicted temperature is possible?” | Learners identify the counterexample, then explain why the component must remain at least as hot as the leaving coolant it heats. |
| 12–15 min | Open the Explorer | Require a Rise, Fall, or Stay the same prediction before loading Flow-limited loop and Lower thermal resistance. | Learners explain why lower flow raises the component temperature, whereas lower resistance changes the component temperature but not the liquid-loop return temperature in this model. |
| 15–18 min | Read the transient plot and transfer question | “What does the marked time constant mean, and what measurements would be needed for a physical rack comparison?” | Learners identify the approximately 63% response point and name load, flow, supply/return temperature, and component-temperature measurements. |

## Misconceptions the scenarios target

| Scenario or section | Likely misconception | Mechanism-based correction |
| --- | --- | --- |
| Section 2 / Flow-limited loop | “If the IT load is unchanged, only the return temperature changes.” | Lower flow reduces the coolant heat-capacity rate. The coolant warms more along the component, so the component must also become hotter to transfer the same liquid heat load. |
| Section 3 counterexample | “A zero energy-balance residual proves the model is valid.” | Conservation is necessary but not sufficient. The heat-transfer temperature ordering must also permit heat to flow from the component into the coolant. |
| Lower thermal resistance | “Reducing component-to-coolant resistance lowers the return temperature.” | With the same declared liquid heat load, flow, specific heat, and supply temperature, the energy balance fixes the return temperature. Lower resistance instead reduces the component temperature needed to drive that heat transfer. |
| Transient response | “The component reaches its final temperature after one time constant.” | A first-order response reaches about 63% of its total change after one time constant; it approaches the final value asymptotically. |

## Transfer question

Ask learners: “A laboratory rack reports IT load, coolant flow, and supply and return temperatures. What additional information would you request before judging whether this one-node model represents the rack, and what would agreement in return temperature establish?”

Expected reasoning: request component or cold-plate temperatures, the heat split to liquid and air, fluid properties and pressure, sensor locations and uncertainty, the time base, and the effective thermal mass. A matching return temperature supports the reported liquid-side energy balance for those conditions. It does not validate component-temperature prediction, spatial hotspots, manifold flow distribution, pressure drop, pump power, or behavior outside the tested conditions.

## Preparation and limits

- Open `ExploreDataCenterCooling.m` in MATLAB R2025a or later to display formatted narrative text and the embedded Section 2 slider. MATLAB R2023a can execute the lesson as a script.
- Use `DataCenterCoolingExplorer` for the prediction activity. The app uses synthetic inputs and base MATLAB only.
- Do not use the 85 °C cue as an equipment limit or the 100 °C boiling reference as a limit for pressurized loops.
- Keep the distinction visible between this teaching model, a calibrated rack model, and a design or operations decision.
