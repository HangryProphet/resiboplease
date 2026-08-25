# Resibo, Please

**Resibo, Please** is a fictional civic decision simulation about evidence, tradeoffs, and the long-term consequences of a vote. The current build is the local Bayhaven vertical slice described in [`resibo_please_project_context.md`](resibo_please_project_context.md). See [`GAME_VISION_AND_FEATURES.md`](GAME_VISION_AND_FEATURES.md) for a strict separation between implemented features and future design.

All candidates, parties, media outlets, events, and city records are fictional. The project does not compare real politicians or provide advice about real elections.

The post-election MVP now includes a deterministic **365-day Living Procedural City Simulation**: automatic time, Pause/Day/Week/Month/Year controls, state-weighted civic events and causal follow-ups, promise projects, an interactive city map, shared Chronicle/News/TV/CityBook records, and a complete year report. See [`docs/CITY_SIMULATION_ARCHITECTURE.md`](docs/CITY_SIMULATION_ARCHITECTURE.md) for its architecture and extension rules.

## Current vertical slice

The prototype currently supports:

- a seeded procedural city foundation that selects four to six active problems
  from twelve civic issue families while preserving setup priorities;
- a responsive pre-election City Brief with an illustrated concern map,
  deterministic city metrics, progressive issue case files, detail sheets, and
  lightweight reusable issue placeholders;
- a read-only City Chronicle with issue-rooted local news, 15–30% harmless
  civic flavor, varied fictional resident voices, persisted template history,
  a lightweight community illustration, and links from major entries into
  comparative news coverage;
- a seed-stable fictional information ecosystem with three editorially distinct
  news outlets, one underlying event behind three compatible framings, and a
  layered full-article reader;
- two to three deterministic R-8 TV reports for major underlying news events,
  with localized player-paced dialogue, reduced-motion behavior, optional
  dialogue sounds, and direct Chronicle/article links;
- a Supabase REST city gallery using hidden Anonymous Auth ownership, one
  display name, explicit GET/POST/PATCH/DELETE and JSON processing, Public or
  Private publishing, Explore, My Cities, player search, safe failure states,
  and separate lightweight offline caches;
- exactly five seed-generated mayoral candidates in every normally created
  city, selected without duplication from a reusable pool of seven
  gender-tagged portrait identities;
- stable fictional Filipino-friendly names, occupations, parties, slogans,
  histories, personality/presentation styles, hidden tradeoffs, controversies,
  relationships, and information footprints generated from isolated sub-seeds;
- procedural CityBook profiles with four to seven truth-linked posts per
  candidate, sentiment reactions, ten contextual comments per post, historical
  context, and links to relevant news and receipts;
- a responsive Candidate Hub for every generated candidate with Bio, Promises, Debate,
  and Records sections, public identity, unresolved questions, rhetorical
  style, and investigation progress;
- a structured Civic Archive biography for each candidate with an
  infobox, variable article sections, a compact career timeline, and numbered
  citations that open the real evidence reader;
- four structured campaign promises per candidate connected to active city issue
  families, past history, evidence, and neutral Then-vs-Now context cards;
- five or six Campaign Trail cards per candidate (nested under Promises) with
  glance, inspect, and evidence-linked Deep Dive reading levels;
- a three-topic generated group-chat debate with all five candidates, rebuttals, record checks,
  reactions, evidence links, bookmarks, pins, and suspicious-statement flags;
- responsive candidate dossiers with Overview, Platform, and filtered Evidence
  folders, source-check readers, evidence relationships, costs, and bookmarks;
- a persistent Receipts Board for pinned claims, debate statements, unresolved
  questions, evidence bookmarks, private notes, issue filtering, and a
  player-controlled two-candidate comparison;
- seeded candidate-field and campaign-noise settings that alter experience and
  public-information volume without rerolling identities, creating a blanket
  upgrade, or exposing a pre-election score;
- 45 generated evidence items per election across nine evidence categories;
- evidence reading and bookmarking without candidate scores or recommendations;
- source-specific evidence presentation, including a Bayhaven Transparency
  Portal treatment for public records, while preserving the normalized Evidence
  Reader and concise evidence cards;
- a game-styled ballot with candidate portraits, issue-priority and confidence
  reflection, confirmation, and an animated winner reveal;
- a deterministic 365-day post-election year that automatically processes
  state-weighted issue, indicator, administration, external, positive,
  political, everyday-life, and rare events instead of following one fixed plot;
- Pause, Day, Week, Month, and Year speeds, persisted calendar progress, and
  configurable auto-pause for important/critical developments;
- an expanded 90-degree overhead city map that opens on a partial central view
  with meaningful room to explore using drag, pinch/mouse zoom, and custom zoom
  controls; 27 stable semantic locations, 19 tappable persistent landmarks,
  compact de-cluttered event markers with full mobile tap targets, marker
  acknowledgement, and a filtered chronological Event History;
- promise-derived administration projects with four seeded quarter reviews,
  multi-stage progress, candidate-ability influence, budget/trust effects, and
  map/history visibility;
- an illustrated explanatory term report with gains, setbacks, event history,
  decision context, and same-seed replay;
- five versioned local city slots that survive refreshes and app restarts;
- automatic persistence for evidence costs and unlocks, receipt collections,
  notes, candidate-name history, Chronicle selections, votes, simulation date,
  speed, pause state, inspected markers, and the generated year history, with
  save migration;
- English and Filipino game text with persistent reduced-motion,
  high-contrast, dialogue-sound, UI-sound, music, SFX-volume, music-volume, and
  simulation auto-pause settings;
- a centralized, cached UI sound system using a cohesive CC0 Kenney pack, plus
  graceful optional music contexts for menu, investigation, and simulation;
- a lightweight Flame atmosphere on the main menu and compressed raster city
  scenes for information-heavy gameplay screens;
- unit tests for procedural determinism, unique portrait/name/ID assignments,
  gender-compatible naming, sub-seed isolation, cross-system reference
  integrity, save round trips, authored-fixture integrity, simulation outcomes,
  migrations, and restoration;
- widget tests for the opening, configuration, Settings, City Archive,
  pre-election City Brief, Chronicle, candidate investigation, and the complete
  ballot-to-term-report loop.

Email/password accounts, cloud saves, AI generation, richer social features,
and multiple-election history remain deferred. Anonymous Supabase ownership is
used only for the small sanitized gallery, the only current networked feature.

## Run locally

Requirements: Flutter with Dart 3.12 or later, plus Chrome or an Android toolchain.

```sh
flutter pub get
flutter run -d chrome --web-port 7357
```

To connect the Public City Gallery, first apply
[`docs/SUPABASE_CITY_GALLERY_V2.sql`](docs/SUPABASE_CITY_GALLERY_V2.sql), enable
Anonymous Sign-Ins in Supabase Authentication, then add
`--dart-define=SUPABASE_URL=...` and
`--dart-define=SUPABASE_ANON_KEY=...` to the run command. See
[`API_INTEGRATION.md`](API_INTEGRATION.md) for the API contract and security
setup.

Use the same web port between development launches. Browser saves live in IndexedDB and are scoped to the page origin, which includes the port.

Verification:

```sh
flutter analyze
flutter test
flutter build web
```

### Audio

UI sound effects are included and can be controlled from Settings. Music files
at the expected paths currently have unrecorded provenance and must be treated
as classroom placeholders until their redistribution licenses are confirmed.
See [`AUDIO_ASSET_SOURCES.md`](AUDIO_ASSET_SOURCES.md). The game remains fully
usable if those optional music files are removed.

### Android classroom build

With Android Studio/SDK and an accepted Android SDK license installed:

```sh
flutter doctor -v
flutter build apk --release
```

The expected artifact is `build/app/outputs/flutter-apk/app-release.apk`.
The current Gradle configuration uses debug signing for a classroom/demo APK;
configure a private release keystore before any app-store or public release.

## Architecture

```text
lib/
├── app/                 theme and routing
├── core/                app state and reusable widgets
├── data/seed_content/   fixed Bayhaven scenario truth
├── data/persistence/    versioned local run saves and repository adapters
├── domain/models/       immutable typed game data
├── domain/simulation/   deterministic outcome rules
├── features/            screen-oriented Flutter UI
├── game/                Flame city visualization
└── main.dart            application entry point
```

Important boundaries:

- Simulation rules create the true state; presentation never changes it.
- Pre-election news, voices, and affected-resident estimates are deterministic
  context derived from the configured starting state; they never advance time.
- Candidate capabilities remain in the domain layer and are not rendered before voting.
- A versioned world seed is split into stable subsystem paths; generated
  candidate reality is then serialized into the city save and never rerolled
  during navigation or restore.
- A run and candidate ID produce a stable simulation seed.
- Flutter owns information-heavy screens; Flame owns only the city canvas.

## Near-term roadmap

1. Carry the final city state into a deterministic second election.
2. Add election/term history, an end-run choice, and a local final summary.
3. Add moderation and richer comparisons to the implemented public snapshot
   gallery without expanding its private-data surface.
4. Expand deterministic event and promise-outcome tracking tests.
5. Expand the procedural content libraries without changing saved version-1
   election snapshots.
6. Add Firebase and AI only after the offline multi-election loop is stable.

The comprehensive product rules, safety constraints, research plan, and future phases remain in the project context document and should be updated before any conflicting implementation decision.
