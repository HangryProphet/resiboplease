# Living City Simulation

The previous four-manual-phase MVP has been replaced by the automatic 365-day
Living Procedural City Simulation.

The current system includes:

- Pause, Day, Week, and Month controls plus a bounded YEAR-to-Day-365 command;
- four persistent critical-event interruption behaviors, defaulting to Pause &
  Notify rather than a forced modal;
- deterministic persisted World Conditions that change event weights and
  project progress while active, plus a source-tagged debug injector;
- a localized compact current-condition strip;
- persisted simulation date, speed, pause, and inspected markers;
- state-weighted procedural event timing and consequences;
- delayed causal event chains and cooldowns;
- candidate- and budget-influenced promise projects;
- a refined true-overhead illustrated navigation map whose initial camera
  shows only the central districts, with 27 normalized semantic anchors, 19
  persistent tappable landmarks, counter-scaled temporary markers, and custom
  zoom controls;
- deterministic weighted event placement across matching city facilities,
  radial marker de-cluttering, and acknowledged pins that clear from the map
  while their events remain in History and the Chronicle;
- a separate filtered Event History;
- date-gated Chronicle, News, TV, and CityBook presentations sharing saved
  event IDs; and
- four date-derived quarter summaries for the final report.

See [CITY_SIMULATION_ARCHITECTURE.md](CITY_SIMULATION_ARCHITECTURE.md) for the
authoritative models, algorithms, persistence format, performance decisions,
extension rules, and implementation file map.
