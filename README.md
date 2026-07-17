# Resibo, Please

**Resibo, Please** is a fictional civic decision simulation about evidence, tradeoffs, and the long-term consequences of a vote. The current build is the local Bayhaven vertical slice described in [`resibo_please_project_context.md`](resibo_please_project_context.md).

All candidates, parties, media outlets, events, and city records are fictional. The project does not compare real politicians or provide advice about real elections.

## Current vertical slice

The prototype currently supports:

- a responsive Bayhaven city brief with three urgent problems;
- three candidate dossiers with visible strengths, concerns, and platforms;
- 27 evidence items across nine evidence categories;
- evidence reading and bookmarking without candidate scores or recommendations;
- a ballot with issue-priority and confidence reflection;
- a deterministic four-phase term simulation;
- an explanatory term report with same-seed replay;
- a lightweight Flame-rendered city layer inside Flutter screens;
- unit tests for seeded randomness and simulation tradeoffs;
- a widget smoke test for the opening flow.

Firebase, AI generation, authentication, networked city visits, and persistent saves are intentionally deferred until this local core loop is stable.

## Run locally

Requirements: Flutter with Dart 3.12 or later, plus Chrome or an Android toolchain.

```sh
flutter pub get
flutter run -d chrome
```

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

1. Add a versioned local run repository and save migration tests.
2. Complete candidate comparison, a local final summary, and a structured public snapshot preview.
3. Expand deterministic event and promise tracking tests.
4. Polish accessibility, narrow-screen navigation, and original visual assets.
5. Add Firebase and AI only after the offline vertical slice meets its definition of done.

The comprehensive product rules, safety constraints, research plan, and future phases remain in the project context document and should be updated before any conflicting implementation decision.
