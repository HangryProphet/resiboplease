# Resibo, Please

**Resibo, Please** is a fictional civic decision simulation about evidence, tradeoffs, and the long-term consequences of a vote. The current build is the local Bayhaven vertical slice described in [`resibo_please_project_context.md`](resibo_please_project_context.md). See [`GAME_VISION_AND_FEATURES.md`](GAME_VISION_AND_FEATURES.md) for a strict separation between implemented features and future design.

All candidates, parties, media outlets, events, and city records are fictional. The project does not compare real politicians or provide advice about real elections.

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
- CityBook profiles for Maya Vargas, Julian Pratt, and Victor Chen with authored
  posts, sentiment reactions, curated comments, historical context, and links
  to relevant news and receipts;
- a responsive Candidate Hub for every candidate with Bio, Promises, Debate,
  and Records sections, public identity, unresolved questions, rhetorical
  style, and investigation progress;
- a structured Civic Archive biography for each authored candidate with an
  infobox, variable article sections, a compact career timeline, and numbered
  citations that open the real evidence reader;
- nine structured campaign promises connected to procedural city issue
  families, past history, evidence, and neutral Then-vs-Now context cards;
- six authored Campaign Trail cards per candidate (nested under Promises) with
  glance, inspect, and evidence-linked Deep Dive reading levels;
- a three-topic, 32-message group-chat debate with rebuttals, record checks,
  reactions, evidence links, bookmarks, pins, and suspicious-statement flags;
- responsive candidate dossiers with Overview, Platform, and filtered Evidence
  folders, source-check readers, evidence relationships, costs, and bookmarks;
- a persistent Receipts Board for pinned claims, debate statements, unresolved
  questions, evidence bookmarks, private notes, issue filtering, and a
  player-controlled two-candidate comparison;
- a seeded candidate-field algorithm that changes operating tradeoffs without
  creating a blanket upgrade or exposing a pre-election score;
- 27 evidence items across nine evidence categories;
- evidence reading and bookmarking without candidate scores or recommendations;
- source-specific evidence presentation, including a Bayhaven Transparency
  Portal treatment for public records, while preserving the normalized Evidence
  Reader and concise evidence cards;
- a game-styled ballot with candidate portraits, issue-priority and confidence
  reflection, confirmation, and an animated winner reveal;
- a deterministic four-phase term timeline drawing two illustrated major
  events from five authored event families plus lightweight text updates;
- an illustrated explanatory term report with gains, setbacks, event history,
  decision context, and same-seed replay;
- five versioned local city slots that survive refreshes and app restarts;
- automatic persistence for evidence costs and unlocks, receipt collections,
  notes, candidate-name history, Chronicle selections, votes, and term progress,
  with save migration;
- English and Filipino game text with persistent reduced-motion,
  high-contrast, and dialogue-sound settings;
- a lightweight Flame atmosphere on the main menu and compressed raster city
  scenes for information-heavy gameplay screens;
- unit tests for authored content integrity, evidence relations, candidate-name
  uniqueness, seeded randomness, candidate tradeoff audits, simulation
  outcomes, save migrations, and restoration;
- widget tests for the opening, configuration, Settings, City Archive,
  pre-election City Brief, Chronicle, candidate investigation, and the complete
  ballot-to-term-report loop.

Firebase, AI generation, authentication, networked city visits, and multiple-election history remain deferred until the offline persistent loop is stable.

## Run locally

Requirements: Flutter with Dart 3.12 or later, plus Chrome or an Android toolchain.

```sh
flutter pub get
flutter run -d chrome --web-port 7357
```

Use the same web port between development launches. Browser saves live in IndexedDB and are scoped to the page origin, which includes the port.

Verification:

```sh
flutter analyze
flutter test
flutter build web
```

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
- A run and candidate ID produce a stable simulation seed.
- Flutter owns information-heavy screens; Flame owns only the city canvas.

## Near-term roadmap

1. Carry the final city state into a deterministic second election.
2. Add election/term history, an end-run choice, and a local final summary.
3. Add a structured public snapshot preview for asynchronous city visits.
4. Expand deterministic event and promise tracking tests.
5. Add procedural candidate generation on top of the implemented schema and
   world-level name registry.
6. Add Firebase and AI only after the offline multi-election loop is stable.

The comprehensive product rules, safety constraints, research plan, and future phases remain in the project context document and should be updated before any conflicting implementation decision.
