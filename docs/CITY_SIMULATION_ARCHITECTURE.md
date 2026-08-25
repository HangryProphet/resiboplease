# Living Procedural City Simulation Architecture

## Purpose and implemented scope

The post-election game simulates one complete fictional year after the player
votes. The player is an observer, not the mayor. City Hall makes decisions from
the elected candidate's saved hidden attributes, promises, the inherited city,
and deterministic procedural variation.

The implementation creates a complete 365-day year by evaluating logical days
in order when the vote is sealed. This is not a fixed story: every selection is
made against the city state produced by all earlier days. The completed year is
then serialized. `simulationDay` controls which saved developments have become
visible. This design guarantees that reopening a save cannot reroll history or
leak future events into information screens.

## Runtime flow

```text
Winner confirmed
  -> TermEngine
  -> LivingCityEngine evaluates Days 1-365
       -> project review, when scheduled
       -> daily event probability
       -> prerequisite filtering
       -> state-weighted selection
       -> bounded effects
       -> causal follow-up hooks
       -> quarter checkpoint
  -> complete LivingTermSimulation is persisted

SimulationClock
  -> requests a logical Day / Week / Month batch (1 / 7 / 30 days)
  -> YEAR asks the controller to finish in bounded logical batches
  -> GameController applies visibility progress
  -> the interruption preference may cap the batch at a critical saved event
  -> map and information surfaces rebuild from eventsThroughDay(day)
```

`SimulationClock` owns only a lightweight periodic timer. It never selects an
event and never owns random state. The controller owns current progress, and the
domain engine owns truth. Rendering FPS therefore cannot change outcomes.

## Calendar and speed controls

The calendar has 365 simulated days. Display dates use a fictional Year number
and normal month/day names.

| Control | Logical behavior | Real scheduling |
|---|---:|---:|
| Pause | no processed days | no timer |
| Day | 1 day per pulse | 1 second |
| Week | 7 days per pulse | 1 second |
| Month | 30 days per pulse | 1 second |
| Year | bounded command to Day 365 | immediate logical batches |

The old four-phase term structure remains as date-derived quarters:

- Q1: Days 1-91
- Q2: Days 92-182
- Q3: Days 183-273
- Q4: Days 274-365

Quarters group report sections and project reviews. They no longer require an
Advance Phase button.

YEAR does not render 365 separate UI updates. It processes bounded logical
batches through the same day-advance path and reaches Day 365 exactly. The
Critical Event Interruption preference can cap a requested batch at the first
critical/rare event:

- Auto Open: pause and open the event;
- Pause & Notify (default): pause and show a player-opened notice;
- Notify Only: show a notice without pausing; or
- Never Interrupt: no automatic notice, pause, or modal.

The setting uses shared preferences. The current speed and pause state are part
of the city save.

## Deterministic seed paths

The system uses the existing world seed and `SeedDerivation`. Important paths
include:

```text
term:{term}:day:{day}:event-roll
term:{term}:day:{day}:event-selection
term:{term}:day:{day}:event:{template}:effects
term:{term}:day:{day}:event:{event}:hook:{hook}
term:{term}:project:{project}:quarter:{quarter}:review-day
term:{term}:day:{day}:project:{project}
```

The Living City generation version is `2`. An extra draw in one event or
project path cannot consume the candidate generator's stream or reroll another
day. Identical world/candidate/input/version data reproduce an identical saved
year. Different world seeds change event timing, selection, location offsets,
chains, and project results.

## City state

The simulation reuses the existing bounded `CityIndicatorSet`:

- food security;
- poverty reduction;
- public health;
- education quality;
- water security;
- employment quality;
- urban resilience;
- climate resilience;
- budget health;
- public trust; and
- corruption pressure.

Concrete starting problems become `CityIssueState` records with their own
severity and trend. Events may change both indicators and related issue
severity. `overallCityCondition` reverses corruption pressure before averaging
the broad condition and reports Thriving, Improving, Stable, Strained,
Deteriorating, or Crisis.

`budgetHealth` is deliberately broad. The player does not allocate funds.
`corruptionPressure` remains simulation truth and is not shown as a raw mayor
score. It appears indirectly through delays, procurement records, audits,
budget effects, news, and project results.

## Procedural event selection

Reusable `LivingEventTemplate` objects provide safe fictional facts, base
effects, prerequisites, and presentation metadata. They do not specify one
year's order.

Each day receives an isolated probability roll. Chance rises after quiet
periods and when a causal follow-up is eligible, but a day with a project event
is less likely to receive another event. This keeps the year busy without
producing several crises every few days.

Before weighting, the engine filters templates by:

- quarter range;
- one-use/repeat rules;
- template, chain, issue, and location cooldowns;
- minimum gap after a major/critical/rare event;
- maximum rare-event count;
- required causal hook and its eligibility window;
- indicator-above or indicator-below prerequisites; and
- presence of the related issue family.

Eligible weight is based on:

```text
base template weight
  x active issue severity
  x follow-up relevance
  x recent category diversity
  x positive-city-condition modifier
  x public trust / corruption political modifier
  x administration competence / project relevance
  x late-year positive and city-life balance
  x isolated small random variation
```

Randomness therefore chooses between plausible events rather than ignoring the
world. The event pools cover issue-driven, indicator-driven, administration,
external shock, positive opportunity, political, everyday city life, and rare
developments. Neutral events can have an empty effect map.

## Consequences and candidate influence

Negative effect magnitude is softened by relevant policy knowledge, crisis
response, and implementation ability. Positive effect magnitude is strengthened
by capacity. Corruption-pressure changes use integrity and corruption risk.
Every effect is small and then clamped by `CityIndicatorSet.apply`; issue
severity remains between 0 and 100.

Public trust is not treated as competence. It can rise from visible completion,
transparent records, or a fortunate community event and fall after disruption,
delays, criticism, or poor communication.

## Causal chains and echoes

A source template can create one or more pending follow-up hooks. Each saved hook
receives a deterministic delay and expiry window. A follow-up is ineligible
before that delay, expires if unused, consumes its required hook when selected,
and stores the source `parentEventId`.

Implemented chains include:

- heavy rain -> flooding -> possible water contamination -> clinic response;
- Central Avenue roadworks -> congestion -> business complaints;
- drainage overflow -> community cleanup;
- water-main failure -> repair;
- clinic surge -> mobile units;
- factory closure -> job fair;
- road failure -> temporary shuttles; and
- procurement questions -> records release/audit follow-up.

The Event History can identify later chapters, while every chapter remains its
own dated `CityEvent`.

## Projects and promises

Up to three elected-candidate promises become `AdministrationProject` objects.
If promise data is unavailable, issue/policy fit creates two fallback platform
projects. Projects keep cost, difficulty, priority, corruption exposure,
visibility, progress, state, promise status, outcome effects, and milestones.

Every project receives one independently seeded review day in each quarter.
Progress considers:

- implementation and general competence;
- coalition skill;
- budget discipline and current fiscal health;
- relevant policy knowledge;
- experience;
- project difficulty and corruption exposure; and
- isolated seeded variation.

The implemented path can pass through proposed, planning, procurement,
implementation, under construction, delayed, and completed states. The model
also supports funded, awaiting funding, stalled, partially completed,
cancelled, and under investigation states for later content.

Each milestone stores its own indicator and issue effects. This permits exact
`indicatorsThroughDay(day)` and `issuesThroughDay(day)` reconstruction without
running random logic again.

## Map anchors and markers

The Living City base map is the purpose-built square raster
`assets/images/city/bayhaven_topdown_map_districts.png`. It is a strict
90-degree orthographic overhead view with roof footprints, connected streets,
the western river, bridges, civic center, neighborhoods, and visually distinct
service districts spread across the city. The former perspective skyline
`bayhaven_base.png` remains available for non-map scenes but is not rendered on
this screen. One reusable raster is used instead of hundreds of building
widgets. `InteractiveViewer` supplies mobile pinch zoom, touch drag, web mouse
zoom, and mouse drag; custom Resibo controls also zoom and reset the camera. The
initial camera opens at 1.65x over the central civic districts, showing only
part of the city; the player can pan into the northern institutional belt,
western river corridor, eastern commercial/public-safety blocks, southern
communities, or southeastern industrial/logistics zone.

The centralized registry in `bayhaven_map_anchors.dart` defines 27 stable
normalized anchors. Every anchor carries a stable ID, localization key, anchor
type, simulation district, normalized position, and a permanent-landmark flag.
The 19 persistent landmarks cover City Hall, civic plaza, government services,
news headquarters, hospital, university, school district, public market,
shopping mall, police headquarters, water facilities, Riverside, gated
subdivision, waste center, transport terminal, fire/disaster center, sports
area, industrial zone, and warehouse/logistics area. The remaining anchors
provide residential, road, commercial, and civic event-placement geography.

Events use deterministic weighted semantic routing before district fallback.
For example, health events favor the hospital, education events favor the
school or university, flooding favors the river community or water facility,
and jobs or supply events favor industry, the mall, or logistics. This produces
believable variety without changing simulation consequences. Events sharing a
location receive deterministic radial spreading, avoid permanent landmark
centers, and maintain minimum separation where space permits.

Persistent landmarks and temporary event markers are separate UI layers.
Landmark dots are 25 logical pixels with generous invisible tap regions; most
labels appear only after zooming to reduce overview clutter. At most nine
temporary markers are rendered, prioritized by importance and recency. Their
visible pins are 30 logical pixels inside counter-scaled 48-pixel tap targets.
All marker positions remain attached to their normalized map coordinates while
zooming and panning.

Marker lifetime is 0 days for ambient events, 9 for minor, 24 for important,
50 for critical, and 36 for rare events. Opening a temporary marker records its
event ID as inspected and immediately removes that pin from the map. The event
itself remains permanently available in Event History and the linked Chronicle
and media records. Missing or clearing a marker therefore has no gameplay
penalty. Reduced Motion stops pulsing while retaining the marker and tap target.

City Hall and all other configured service landmarks are permanent tap targets.
City Hall's styled sheet displays the mayor, public trust, budget health, broad
city condition, and project progress as of the current simulated date. Other
landmarks use lightweight localized sheets showing their role and recent
location-specific developments.

## Event History and information presentation

The map remains primary. Event History is a separate game-styled bottom sheet
with All, Major, Projects, and Community filters plus unread state.

Opening an event shows its saved location, date, importance, illustration when
available, factual summary, explanation, indicator effects, causal-chain note,
and only relevant actions.

`CityEvent` is the one source of truth for:

```text
CityEvent
  -> map marker
  -> neutral Event History
  -> LivingChronicleEntry
  -> three NewsCoverage framings
  -> selected R-8 TV report
  -> CityBook post and ten contextual comments
  -> final report
```

`GameController.informationEcosystem` passes a
`visibleThroughDay(simulationDay)` view. Future Chronicle entries, articles,
TV reports, and CityBook reactions are therefore unavailable before their event
date. Presentation systems may frame the same fact differently but retain the
same event ID.

## Persistence and migration

Save schema `8` stores:

- the complete generated `LivingTermSimulation`;
- current simulated day;
- selected speed;
- pause state;
- inspected event IDs;
- indicators and issue checkpoints;
- projects, milestones, and milestone effects;
- events, importance, day, location, marker lifetime, and parent link;
- Chronicle entries, news coverages, TV event references, CityBook posts and
  comments; and
- deterministic World Conditions with start, duration, intensity, and
  natural/sandbox source; and
- the existing vote/investigation/candidate data.

Schema 7 saves migrate their old revealed-phase count to Day 0, 91, 182, 273,
or 365 and begin paused at Day speed. Older saved Living City fields receive
safe date/location/importance defaults in the codec. Generated past events are
loaded from JSON rather than rerun.

## Performance decisions

- Game logic operates on 365 discrete days, never 60 updates per second.
- YEAR processes bounded remaining-day batches synchronously and stops exactly
  at Day 365 or at an enabled critical-event interruption.
- There are no individual citizens, vehicles, buildings, or road simulation.
- One map raster is reused and wrapped in a repaint boundary.
- Permanent landmarks and temporary events are compact counter-scaled widgets;
  no district is built from individual Flutter building widgets.
- Marker rendering is capped at nine active widgets.
- Event artwork is reused by visual key rather than generated per event.
- Media screens consume cached structured records and perform no random draws.
- The controller only rebuilds when a logical batch or user action changes
  state.

This creates the illusion of a large reactive city while remaining suitable for
low-end and mid-range Android devices.

## Main implementation files

- `lib/domain/models/living_city_simulation.dart`
- `lib/domain/simulation/living_city_engine.dart`
- `lib/domain/simulation/simulation_clock.dart`
- `lib/data/seed_content/living_city_event_library.dart`
- `lib/data/persistence/living_city_codec.dart`
- `lib/data/persistence/run_save_data.dart`
- `lib/core/state/game_controller.dart`
- `lib/core/settings/app_settings_controller.dart`
- `lib/features/simulation/term_simulation_screen.dart`
- `lib/domain/simulation/information_ecosystem_engine.dart`
- `lib/features/city/city_chronicle_screen.dart`
- `lib/l10n/living_city_localizations.dart`

## Extension rules

1. Add authored templates with stable IDs; never put random selection in a
   widget.
2. Add prerequisites and hooks to structured state, not narrative text checks.
3. Keep effects bounded and proportional to importance.
4. Give new locations stable normalized anchors.
5. Reuse the saved event ID across every presentation.
6. Persist any new consequential field and add a schema migration.
7. Do not expose hidden candidate truth or raw corruption scores pre-election.
8. Keep the player an observer unless a separate design explicitly authorizes a
   new gameplay role.
