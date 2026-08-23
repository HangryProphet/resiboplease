# Living City Simulation

## Purpose

The post-election game is an observer simulation. The player elects a mayor, advances four broad phases of a term, and inspects how the city changes. The player does not directly control the mayor, allocate individual budget lines, or choose event outcomes.

The simulation is deterministic for a world seed, generation version, term number, elected candidate, and starting scenario. A save stores the generated history so future content or balance changes cannot rewrite an existing city.

## Indicators, issues, and events

- **Indicators** are the reusable 0–100 measurements: food security, poverty reduction, public health, education quality, water security, employment quality, urban resilience, climate resilience, budget health, public trust, and corruption pressure.
- **Issues** are concrete active problems. Each issue has its own severity and trend and points to one or more indicators.
- **Events** are dated occurrences during a term. They may result from an issue, an indicator threshold, the administration, an outside shock, a positive opportunity, politics, ordinary city life, or a rare seeded surprise.

Changing an indicator does not automatically create a duplicate issue. Events change indicators and may raise or lower the severity of a related issue.

## Term structure

Each term contains four player-paced phases:

1. First 100 Days
2. Pressure and Response
3. Midterm Record
4. Final-Year Reckoning

Each phase contains four or five internal events plus one milestone for every tracked administration project. Phase 2 and phase 4 guarantee a major or rare development. The existing five illustrated crisis families remain available for the two large phase cards.

The event library is `lib/data/seed_content/living_city_event_library.dart`. It covers all eight event categories and includes follow-up pairs such as flood to cleanup, water break to repair, clinic surge to mobile units, factory closure to job fair, and road failure to temporary shuttles.

## Determinism and selection

The engine derives isolated sub-seeds with paths such as:

`term:{term}:phase:{phase}:event:{slot}`

An extra random draw in one project or event therefore does not silently reroll candidate generation, city issues, or another phase. Event templates are filtered by phase range, issue family, indicator threshold, required chain hook, cooldown, and prior selection. Eligible templates receive weights from base probability, issue severity, category diversity, slot, and recovery hooks. City-life and positive events are deliberately included so the city is not only a crisis feed.

## Candidate influence

The engine consumes a `CandidateTruthSnapshot`. Procedural candidates use their persisted hidden truth profile; authored candidates use existing capabilities. The simulation considers relevant policy knowledge, implementation, integrity, corruption risk, coalition skill, communication, budget discipline, crisis response, adaptability, and experience.

These values alter impact magnitude and project delivery but do not remove uncertainty. There is no perfect candidate and nobody is guaranteed to solve every issue.

## Promise and project lifecycle

Up to three elected-candidate promises become `AdministrationProject` records. If promise data is unavailable, two platform projects are chosen using issue pressure and policy fit.

Projects store cost, difficulty, priority, corruption exposure, public visibility, progress, state, promise status, effects, and four milestones. The domain supports planning, implementation, construction, delays, stalls, investigation, completion, and cancellation. The current MVP advances, completes, or delays work while preserving extension points for later terms.

Budget remains deliberately broad. Projects and events change `budgetHealth`; the engine bounds phase-level fiscal damage and clamps every indicator from 0 to 100. This is not a detailed accounting simulator.

## One truth, several presentations

`CityEvent` is the saved source of truth. Its stable ID is reused by:

- the administration section of the Chronicle;
- an `UnderlyingNewsEvent` adapter and `NewsCoverage`;
- selected City 8 TV reports;
- CityBook posts and contextual comments;
- map markers and the final report.

Those surfaces can frame an event differently but cannot create competing factual histories.

## Interactive map

The term screen reuses `assets/images/city/bayhaven_base.png` in a Flutter `Stack`. Recent revealed events create lightweight markers at normalized district coordinates. Selecting a marker opens its date, factual summary, explanation, and indicator effects. Markers are widgets instead of separate raster assets, keeping the map responsive and inexpensive. They do not require continuous animation, so reduced-motion behavior remains safe.

## Persistence

Save schema 7 stores a complete `living_city` snapshot: initial and final indicators/issues, projects and milestones, phases, events, Chronicle entries, news coverage, TV event IDs, CityBook posts/comments, the final summary, and generation version.

Schema 6 saves migrate with `living_city: null`. If a legacy completed save has no snapshot, the deterministic engine creates one from the saved scenario and candidate. New saves restore their persisted history instead of rerolling it.

## Extension rules

To add an event, create a `LivingEventTemplate` with a stable unique ID. Prefer existing indicators and issue families. Use prerequisites and follow-up hooks for causal chains, and cooldowns for repeatable event families. A new enum or save field requires a schema migration and codec test.

Do not put random selection inside widgets or media screens. UI surfaces consume the saved simulation. Never expose the hidden truth snapshot directly to the player.

## Verification

Tests cover same-seed determinism, different-seed variation, prerequisites, cooldowns, bounded state, project progression, reference validation, JSON-safe persistence, cross-media event identity, map-marker inspection, candidate tradeoffs, and the complete Flutter suite.
