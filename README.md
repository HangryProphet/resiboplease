# Resibo, Please

**Resibo, Please** is a fictional civic decision simulation about evidence, tradeoffs, and the long-term consequences of a vote. The current build is the local Bayhaven vertical slice described in [`resibo_please_project_context.md`](resibo_please_project_context.md).

All candidates, parties, media outlets, events, and city records are fictional. The project does not compare real politicians or provide advice about real elections.

## Current vertical slice

The prototype currently supports:

- a responsive Bayhaven city brief with three urgent problems;
- a game-styled Candidate Files roster with full portraits, city case files,
  qualitative experience context, and per-candidate investigation progress;
- responsive candidate dossiers with Overview, Platform, and filtered Evidence
  folders, source-check readers, investigation costs, and bookmarks;
- a seeded candidate-field algorithm that changes operating tradeoffs without
  creating a blanket upgrade or exposing a pre-election score;
- 27 evidence items across nine evidence categories;
- evidence reading and bookmarking without candidate scores or recommendations;
- a ballot with issue-priority and confidence reflection;
- a deterministic four-phase term simulation;
- an explanatory term report with same-seed replay;
- five versioned local city slots that survive refreshes and app restarts;
- automatic persistence for evidence usage, bookmarks, votes, and term progress;
- English and Filipino game text with persistent accessibility settings;
- a lightweight Flame-rendered city layer inside Flutter screens;
- unit tests for seeded randomness, candidate tradeoff audits, qualitative
  dossier profiles, simulation outcomes, save migrations, and restoration;
- widget tests for the opening, configuration, Settings, City Archive, and
  candidate investigation flows.

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
- Candidate capabilities remain in the domain layer and are not rendered before voting.
- A run and candidate ID produce a stable simulation seed.
- Flutter owns information-heavy screens; Flame owns only the city canvas.

## Near-term roadmap

1. Carry the final city state into a deterministic second election.
2. Add election/term history, an end-run choice, and a local final summary.
3. Add a score-free candidate comparison and a structured public snapshot preview.
4. Expand deterministic event and promise tracking tests.
5. Add Firebase and AI only after the offline multi-election loop is stable.

The comprehensive product rules, safety constraints, research plan, and future phases remain in the project context document and should be updated before any conflicting implementation decision.
