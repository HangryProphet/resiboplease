# Resibo, Please — Project Context Handoff

> Source-led audit completed: **October 11, 2026**
> Audited branch/commit: `v1.0` at `561e7d6804f2b77b6dc91728b98549e821bed20a`
> Scope: repository inspection and Markdown reconciliation only
> Verification note: the app, analyzer, tests, builds, migrations, and live API were **not run** during this audit.

This is the fastest reliable entry point for a developer or AI assistant returning to the project. Runtime source is authoritative when it conflicts with older planning prose. The longer `resibo_please_project_context.md` remains the product/design history.

## A. Project overview

**Resibo, Please** is a fictional civic decision simulation built in Flutter. The player configures a Philippine-inspired city, studies its problems, investigates five imperfect mayoral candidates, casts a vote, and observes a deterministic 365-day first term. The educational center is evidence literacy: claims, records, framing, promises, contradictions, source quality, and consequences are connected without exposing a “best candidate” score.

The implemented vertical slice is local-first. Sembast stores five versioned city slots. Supabase is optional and limited to anonymous ownership of sanitized completed-city gallery snapshots. All candidates, parties, residents, outlets, records, and events are fictional; the game is not official election advice.

Current major boundaries:

- a repeatable configured-city → investigation → vote → term → report → next-election loop;
- exactly five procedural candidates in normal runs;
- one deterministic 365-day administration, not yet repeated elections;
- Flutter owns information-heavy screens; Flame is limited to light atmosphere;
- simulation code creates truth; presentation layers only frame or reveal it;
- runtime generative AI is not used;
- network availability is never required for the local game.

## B. Implemented features by module

### Application shell, routes, and lifecycle

Primary files: `lib/main.dart`, `lib/app/app.dart`, `lib/app/router.dart`, `lib/app/theme.dart`.

- Initializes settings, local persistence, gallery cache, audio, and the optional Supabase client.
- Uses `go_router` for menu, gallery, city, candidate, evidence, news, TV, ballot, simulation, and report routes.
- Uses Android immersive-sticky system UI handling in Flutter and native `MainActivity` support.
- Applies locale, reduced-motion, high-contrast, and audio settings app-wide.
- Uses route-aware music contexts: menu, investigation, and simulation.
- Initialization failures have memory/unavailable fallbacks instead of blocking local play.

### Main menu and local saves

Primary files: `lib/features/home/home_screen.dart`, `lib/core/state/game_controller.dart`, `lib/data/persistence/`, `lib/domain/models/save_data.dart`.

- Illustrated political-cartoon menu with animated randomized splash text.
- Responsive phone/wide layouts and controlled scrolling on short screens.
- Conditional **Continue City** and secondary **Start New City** behavior.
- Five local Sembast save slots with creation, continuation, deletion, and overwrite confirmation.
- Resume destination follows state: City before voting, Simulation during the term, Report at day 365.
- Save schema is version **9** with migrations for supported older saves.
- Completed terms are archived as immutable administration records containing
  their election, investigation snapshot, and Living City result.
- Later elections inherit final indicators and issue states, retain eligible
  returning identities, and deterministically fill the roster with challengers.
- Saves persist configured city truth, generated election, investigation state, vote, simulation, map-marker inspection, settings-linked state, and final progress.

Known limit: saves are device/browser-local; no cloud-save synchronization or account recovery exists.

### Settings

Primary files: `lib/features/settings/`, `lib/core/settings/`.

- System, English, and Filipino language choices.
- Reduced motion and high contrast.
- SFX enable/volume, dialogue sound, music enable/volume.
- Critical-event interruption: Auto Open, Pause & Notify, Notify Only, or Never Interrupt.
- About, credits, disclaimer, privacy information, app version, and reset controls.

Known limit: UI chrome is localized more completely than generated/authored narrative text; parts of narrative content remain English.

### City configuration and pre-election City Brief

Primary files: `lib/features/run_setup/`, `lib/features/city/`, `lib/domain/simulation/city_issue_generator.dart`, `lib/data/seed_content/city_issue_library.dart`.

Run setup captures seven dimensions:

1. city name;
2. starting pressure: stable, strained, or crisis;
3. one to three priority concerns;
4. candidate field: unproven, mixed, or seasoned;
5. assistance: guided or standard;
6. campaign noise: clear, typical, or noisy;
7. investigation allowance: relaxed, 12 points, or 7 points.

The generator chooses four to six distinct active issues from twelve families and guarantees that selected setup priorities influence the mix. Severity, urgency, trend, affected groups, indicators, possible causes, policies, visual keys, and SDG links are deterministic from the world seed. A guard prevents every issue from appearing uniformly worsening.

Implemented issue families: flooding/drainage, corruption/public funds, unfinished roads, drugs/community safety, garbage, traffic/transport, water, healthcare, employment, cost of living, government services, and education.

The City Brief is a frozen pre-election view. It shows deterministic metrics, urgent concerns, issue detail, affected-resident estimates, policy directions, artwork, and resident voices. It does not advance time or generate consequential events.

### Chronicle and community voices

Primary files: `lib/features/chronicle/`, pre-election generation/state code under `lib/domain/simulation/` and `lib/core/state/`.

- Issue-rooted local stories plus a limited amount of harmless city-life flavor.
- Optional clearly unverified material in noisier campaigns without changing truth.
- Resident voices vary by issue, district, role, and sentiment.
- IDs, ordering, and selected templates are persisted for stable reopening.
- Entries link to related comparative news coverage when available.

### Procedural candidate generation

Primary files: `lib/domain/simulation/procedural_candidate_generator.dart`, `lib/domain/simulation/seed_derivation.dart`, `lib/domain/models/procedural_election.dart`, `lib/data/seed_content/procedural_candidate_library.dart`.

- Candidate generator version: **1**.
- Exactly five candidates per normal Create City run.
- Five nonduplicated portraits selected from seven approved reusable identities.
- Gender-compatible fictional names and unique IDs/full names within the election.
- Seed paths isolate portraits, identity, truth, history, platform, biography, CityBook, news, debate, and evidence so changes in one path do not automatically reroll another.
- Generated election snapshots are serialized into the save and restored rather than regenerated during navigation.
- Career origins include career politician, public administrator, professional, business, celebrity/media, community, advocacy, and public safety.
- Hidden structured truth includes competence, implementation, integrity, corruption risk, coalition, communication, budget, crisis, adaptability, experience, populism, ambition, policy scores, motivation, risks, personality, controversy, relationships, and information footprint.
- Quality bands are independently rolled; no candidate is guaranteed to be perfect or obviously correct.
- Maya Vargas, Julian Pratt, and Victor Chen remain an authored fallback/debug fixture for older or explicit fixture contexts.

Per generated candidate, the current graph includes five life-history events, four issue-linked promises, nine evidence records, biography sections/citations, one Then-vs-Now comparison, two unresolved questions, five or six Campaign Trail items, four to seven CityBook posts, one candidate news event with three outlet coverages, and participation in the three-topic debate.

### Candidate investigation UI

Primary files: `lib/features/candidates/`, `lib/features/evidence/`, `lib/features/receipts/`, `lib/features/debate/` where present, and shared widgets in `lib/core/widgets/`.

- Candidate roster leads to a styled Candidate Hub.
- Hub sections are Bio, Promises, Debate, and Records; Campaign Trail is nested under Promises.
- Biography uses a Civic Archive treatment with sections, timeline, and citations.
- Promise pages connect policy claims to history and evidence.
- Then-vs-Now comparisons are neutral and source-linked.
- Debate contains exactly three issue topics, a moderator, all five candidate answers, responses/rebuttals, and record checks.
- Dossier supports Overview, Platform, and filtered Evidence views.
- Evidence Reader changes presentation by source type while preserving one normalized evidence model.
- Receipts Board stores pins, bookmarked evidence, questions, suspicious debate statements, issue filters, comparison of up to two candidates, and private notes.
- Raw hidden values, quality bands, match percentages, and recommendations are never shown.

Investigation points form one global allowance across all five candidates. Profiles and explicitly free/unlocked records cost zero. Paid records cost one or two points once; reopening is free. Evidence relationships can unlock connected records.

### CityBook, news, and TV

Primary files: `lib/features/citybook/`, `lib/features/news/`, `lib/features/tv/`, `lib/domain/simulation/information_ecosystem_engine.dart`, `lib/domain/simulation/tv_broadcast_engine.dart`.

- CityBook profiles and posts derive from saved candidate history/truth rather than an unrelated social generator.
- Every candidate post has ten deterministic contextual comments and reaction distributions.
- Reactions represent sentiment, not factual truth or score changes.
- Three seeded fictional outlets present compatible but differently framed coverage of one underlying event.
- Articles provide layered reading and links to related candidates, issues, evidence, and alternate coverage.
- R-8 TV reports use five localized dialogue pages, related event art, player-paced progression, optional dialogue sound, reduced-motion support, and audio ducking.
- Pre-election TV selects two or three reports; term contexts may use up to five preferred living-event reports.
- Future term media is date-gated by the current simulation day.

### Ballot and winner reveal

Primary files: `lib/features/election/` and vote methods in `lib/core/state/game_controller.dart`.

- Styled ballot captures candidate, top issue, and confidence.
- Confirmation prevents accidental submission.
- Winner presentation transitions the selected candidate into office.
- Casting the vote generates and persists the complete deterministic term, then starts at day 0 paused state as implemented.

### Living City simulation

Primary files: `lib/domain/simulation/living_city_engine.dart`, `lib/domain/simulation/term_engine.dart`, `lib/data/seed_content/living_city_event_library.dart`, `lib/domain/models/living_city_simulation.dart`, `lib/features/simulation/`.

- Living City generation version: **4**.
- A complete 365-day year is generated once from the configured city, elected candidate, promises, budget, world seed, and deterministic random paths.
- The player observes the elected administration; the player is not the mayor and has no direct budget/policy controls.
- Eleven indicators cover food security, poverty reduction, public health, education quality, water security, employment quality, urban resilience, climate resilience, budget health, public trust, and corruption pressure.
- Event categories include issue, indicator, administration, external, positive, political, city life, and rare.
- The authored library currently declares **47** `LivingEventTemplate` entries.
- Eligibility, weights, prerequisites, state, cooldowns, repeat rules, rare caps, candidate abilities, projects, budget, and active world conditions influence selection.
- Eight natural world conditions are selected for the year from weather, economic, utility, logistics, health, school, and festival conditions. They alter weights/progress without forcing outcomes.
- Long quiet stretches increase event probability; project-event days reduce competing random-event probability.
- Delayed causal chains retain parent-event IDs, allowing follow-ups such as rainfall → flooding → runoff → clinic pressure or roadworks → congestion → complaints.
- Up to three promise-derived projects are created; fallback issue projects fill gaps. Four seeded quarter reviews advance projects using candidate ability, budget, difficulty, and conditions.
- Effects are bounded and the completed year is saved, so reopening does not reroll history.

Clock controls expose Pause, Day, Week, Month, and bounded Year progression. Day/Week/Month advance 1/7/30 logical days; Year fast-forwards in bounded batches to day 365. Critical interruption settings affect presentation/pause behavior, not generated truth.

### Living City map and event history

Primary files: `lib/features/simulation/living_city_screen.dart`, related map widgets/catalogs under `lib/features/simulation/` and `lib/data/seed_content/`, asset `assets/images/city/bayhaven_topdown_map_districts.png`.

- True overhead illustrated city map using `InteractiveViewer`.
- Initial scale shows a partial central area; pan and zoom range support exploration.
- 27 normalized semantic anchors and 19 persistent tappable landmarks.
- City Hall surfaces mayor, trust, budget, active condition, and projects.
- Up to nine visible temporary event pins; pins are visually counter-scaled while retaining approximately 48×48 mobile tap targets.
- Placement is deterministic, facility-aware, and spread to reduce overlap.
- Inspecting a marker clears its temporary pin but keeps the event in History and Chronicle.
- History filters include All, Major, Projects, and Community.

Known limit: map content is one large raster rather than streamed tiles; lower-end device memory/performance still requires real-device validation.

### Term report and publishing

Primary files: `lib/features/report/`, publishing/gallery state in `lib/core/state/` and `lib/data/gallery/`.

- Report summarizes gains, setbacks, indicator movement, phase/quarter history, major events, projects, context, and selected leader.
- Supports replay with the same seed.
- Completed results can open the Public/Private publication flow.
- Published data is a deliberately small snapshot, not the save file.

### Public City Gallery API

Primary files: `lib/data/gallery/city_gallery_api_service.dart`, `lib/data/gallery/city_gallery_repository.dart`, `lib/domain/models/public_city_snapshot.dart`, gallery screens under `lib/features/gallery/`, SQL in `docs/SUPABASE_CITY_GALLERY_V2.sql`.

- Optional Supabase Anonymous Auth creates a hidden owner identity.
- Player chooses one validated unique display name (3–24 characters).
- Explicit PostgREST `GET`, `POST`, `PATCH`, and `DELETE` requests use `http` with 12-second timeouts and typed failures.
- Explore lists up to 50 newest public cities.
- My Cities lists public and private snapshots owned by the current anonymous user.
- Debounced server-side profile search returns selected players' public cities.
- Owners can change only privacy or delete their own remote snapshot.
- Public and owned caches are separate; offline fallback is read-only and used only for network/server failure.
- Local gameplay and saves remain available when gallery setup/networking fails.

Known limits: anonymous identity is not recoverable after app data is cleared or on another device; live project configuration and policies were not verified in this audit; there is no moderation workflow beyond the constrained schema.

## C. Architecture and state management

```text
lib/
├── main.dart                 boot, dependencies, system UI
├── app/                      app widget, theme, router
├── core/
│   ├── state/                central GameController and app coordination
│   ├── settings/             persistent preferences
│   ├── audio/                SFX/music/dialogue services
│   ├── localization/         module localization helpers
│   └── widgets/              shared game-styled controls
├── data/
│   ├── seed_content/         authored procedural libraries and fixtures
│   ├── persistence/          Sembast repository, codecs, migrations
│   └── gallery/              Supabase REST/cache/auth adapters
├── domain/
│   ├── models/               typed immutable game records
│   └── simulation/           deterministic generators/engines
├── features/                 route/screen-oriented Flutter UI
└── game/                     limited Flame atmosphere/canvas support
```

State is primarily coordinated by a `ChangeNotifier`-based `GameController`; Riverpod supplies the application scope but is not the principal domain-state model. Domain models and engines avoid UI dependencies. Codecs serialize generated snapshots and player interactions. Repositories isolate Sembast and gallery transport.

Important invariants:

- generation is seeded and versioned;
- candidate and term snapshots are persisted;
- UI/media never invents a second truth;
- date gates prevent future events from leaking early;
- private investigation data never enters public gallery serialization;
- settings alter presentation or pacing, not hidden outcomes;
- failures in audio/gallery/optional media must not block gameplay.

## D. End-to-end gameplay flow

1. Main Menu: start, continue, tutorial, gallery, or settings.
2. Save Slots: choose an empty slot or explicitly replace an existing run.
3. Configure City: choose seven setup dimensions; create a world seed.
4. City Brief: review issues, metrics, artwork, resident voices, and Chronicle.
5. Information phase: compare outlet coverage, CityBook, TV, and city records.
6. Candidate roster: inspect five generated candidates.
7. Investigation: Bio → Promises/Campaign Trail → Debate → Records/Evidence; collect receipts and notes.
8. Ballot: choose a candidate, top issue, and confidence; confirm.
9. Winner reveal: selected candidate becomes mayor and the year is generated.
10. Living City: advance the clock, inspect map events/landmarks/projects/history, and read synchronized Chronicle/News/TV/CityBook updates.
11. Term Report: review outcomes, projects, indicator movement, and context.
12. Optional Gallery: publish a sanitized Public or Private snapshot and browse other public cities.

## E. Procedural generation contract

- The world seed plus generator version and a named subsystem path determine output.
- New saves normally receive a fresh seed; same seed/config/version reproduces the same underlying generated content.
- Candidate generator version 1 and Living City generator version 4 must be treated as compatibility boundaries.
- Adding or reordering random draws inside a shared path can alter saved-world reproduction; use new isolated paths or bump the relevant generation version for rule-breaking changes.
- Once created, procedural elections and full-year simulations are persisted. Navigation and restore consume snapshots, not fresh generation.
- City setup parameters influence issue mix, candidate experience distribution, public-information volume, assistance, and investigation economy without directly selecting a winner.
- Hidden truth is structured first. Biography, campaign content, CityBook, debate, evidence, news, and simulation must reference that structure.
- Do not expose raw hidden scores or collapse the election into a recommendation.

## F. Living City simulation details

The year is generated sequentially because each day's resulting state influences later eligibility and weights. The simulation stores day-indexed events, parent links, conditions, projects, reviews, indicator changes, budget/trust movement, and final state. The presentation clock reveals this saved year progressively.

Event timing uses a low daily base chance, escalating pressure after quiet periods, a strong safeguard after very long quiet stretches, causal-hook bonuses, and project-day damping. Templates impose prerequisites, cooldowns, repetition rules, severity, map/location hints, effects, and possible follow-ups. This produces variation without allowing unconstrained prose or impossible events.

Project progress is not a simple promise-success flag. It incorporates elected-candidate implementation/budget/cooperation characteristics, project difficulty, city budget, and active conditions. Four quarterly reviews create auditable milestones and effects.

The map is a view of saved simulation state. Marker positions, news, Chronicle, CityBook, TV, and report entries share stable event IDs. Changing presentation must not mutate event truth.

## G. Candidate information systems

The candidate experience is one connected evidence graph:

```text
hidden truth + structured history
        ├── biography and citations
        ├── promises and Then-vs-Now
        ├── Campaign Trail
        ├── evidence records and relationships
        ├── debate claims and record checks
        ├── CityBook posts/comments/reactions
        └── candidate news and TV references
                     ↓
              Receipts Board
                     ↓
                  Ballot
```

All five candidates are intentionally imperfect. Quantity of coverage is not quality. Reaction volume is not truth. Career origin is not moral quality. A controversy can be true, misleading, unresolved, contextual, or contradicted according to the saved evidence model. Investigation costs create scarcity, while free profiles and relationship unlocks prevent a hard lockout.

When extending candidate content:

- create structured facts before presentation prose;
- keep IDs stable across every reference;
- preserve evidence reliability/truth distinctions;
- produce all five candidate variants where required;
- preserve neutral language and fictional framing;
- add deterministic tests for same-seed stability and cross-reference integrity;
- never let UI-local random values alter candidate truth.

## H. Database and API integration

Runtime configuration uses compile-time defines:

```text
SUPABASE_URL
SUPABASE_ANON_KEY
```

Real local values belong in an ignored `config/*.local.json` file and must not be committed. The client requires HTTPS and rejects a service-role JWT. Never put a database password or service-role key in the app.

Authoritative SQL: `docs/SUPABASE_CITY_GALLERY_V2.sql`.

V2 tables:

- `player_profiles`: authenticated anonymous user ID, unique normalized display name, timestamps;
- `city_snapshots`: owner, privacy, bounded summary fields, up to eight bounded major issues/events, timestamps.

RLS is enabled and forced. Authenticated users can search limited profiles, manage only their own profile/snapshots, read public snapshots plus their own private snapshots, and update only snapshot privacy. The unauthenticated database role has no table access. V2 intentionally deletes incompatible ownerless V1 rows during migration; `docs/SUPABASE_CITY_GALLERY.sql` is legacy and should not be rerun.

The public schema excludes seed, full save, hidden candidate truth, evidence history, bookmarks, notes, and investigation behavior.

## I. UI, assets, localization, and audio

### Visual direction

- Hand-drawn political cartoon / paper-and-ink aesthetic.
- Dark navy, cream, red, blue, and green palette.
- Chunky outlined, beveled, tactile controls rather than default Material buttons.
- Information-dense screens use progressive disclosure and themed cards/readers.
- Main menu preserves its illustrated civic background, candidates, logo, and game-like hierarchy.

Asset highlights:

- seven reusable candidate portraits;
- main-menu background and candidate group;
- overhead Bayhaven district map;
- 12 issue visual mappings (five shared event scenes and seven dedicated issue scenes);
- CityBook banners/posts, R-8 reporter, event scenes, branded adaptive icon;
- Lilita One and Luckiest Guy fonts.

Unknown/missing images use intentional Flutter fallbacks. Avoid adding labels, markers, or UI directly into map art because Flutter renders them separately.

### Localization

Flutter ARB/localization plus module helpers provide English and Filipino interface coverage. Treat the current product as partially bilingual: navigation and common controls are broadly localized, but generated/authored narrative libraries are not fully translated.

### Audio

`GameAudioService` provides 16 mapped Kenney CC0 SFX using four reusable low-latency players and duplicate throttling. One looping music player handles menu/investigation/simulation contexts, fade transitions, lifecycle pause/resume, settings volume, and TV ducking. Playback/missing-file failures are caught.

`assets/audio/dialogue/reporter_robot_blip.wav` is the optional R-8 dialogue blip. Its original provenance is unverified. Current music files also lack recorded redistribution provenance and must remain classroom placeholders until replaced or documented.

## J. Known limitations and status

### Implemented and stable by source inspection

- complete first-election vertical slice;
- procedural five-candidate election and evidence ecosystem;
- versioned five-slot local persistence;
- deterministic 365-day Living City and report;
- map/markers/history/projects/world conditions;
- English/Filipino settings and accessibility/audio preferences;
- optional Supabase V2 gallery client and defensive failure handling;
- branded Android label and adaptive launcher icon.

“Stable” here means structurally implemented and covered by repository tests; it does not claim this audit executed those tests.

### Implemented but needs current manual/environment verification

- physical Android layout, gestures, immersive mode, audio loudness, lifecycle restore, and lower-end performance;
- live Supabase Anonymous Auth, V2 schema/RLS, and GET/POST/PATCH/DELETE behavior;
- final APK install behavior and network access on the target phone;
- exact Filipino completeness and text overflow across all generated strings;
- release/report modal layout fixes and all short-screen paths;
- music/dialogue asset provenance.

### Incomplete or deferred

- second and later elections, persistent administration history, end-run choice, and terminal city failure;
- cloud save/account recovery and cross-device local-run synchronization;
- recovered/community identity after anonymous account loss;
- gallery moderation, reporting, richer safe comparison, and production operations;
- full narrative localization;
- runtime AI generation;
- production signing, Play Store setup, telemetry/crash reporting, and public-release legal/privacy review;
- broader content libraries and final licensed music/audio provenance.

### Historical/superseded documentation

- three-candidate MVP passages refer to the authored fixture, not normal runs;
- Firebase plans predate the implemented Supabase gallery and remain future-design history;
- the August 25 release report's missing-APK/default-icon statements are no longer current;
- Living City generation version 2 and save schema 4/6/8 references are obsolete; current values are 4 and 9.

### TODO/FIXME audit

No actionable `TODO` or `FIXME` markers were found in application source during this inspection. Placeholder/fallback classes and localization placeholder metadata are intentional mechanisms, not automatically unfinished tasks. Absence of markers does not remove the deferred work listed above.

### Verification history caveat

The October 13, 2026 implementation checkpoint passes `flutter analyze`, all
194 Flutter tests, `flutter build web`, and `flutter build apk --release`.
The current classroom APK is at
`build/app/outputs/flutter-apk/app-release.apk`; physical Android interaction,
live Supabase V2 policies, audio provenance, and production signing remain
external release checks.

## K. Key source-file index

| Concern | Primary source |
| --- | --- |
| Boot/system UI/dependency setup | `lib/main.dart` |
| Routes | `lib/app/router.dart` |
| Theme | `lib/app/theme.dart` |
| Central run state | `lib/core/state/game_controller.dart` |
| Settings | `lib/core/settings/`, `lib/features/settings/` |
| Audio | `lib/core/audio/` |
| Save model/schema | `lib/data/persistence/run_save_data.dart` |
| Political timeline | `lib/domain/models/political_timeline.dart`, `lib/data/persistence/political_timeline_codec.dart` |
| Local repository/migrations/codecs | `lib/data/persistence/` |
| Run setup | `lib/features/run_setup/` |
| City Brief/Chronicle | `lib/features/city/`, `lib/features/chronicle/` |
| City issue generation/library | `lib/domain/simulation/city_issue_generator.dart`, `lib/data/seed_content/city_issue_library.dart` |
| Candidate generation | `lib/domain/simulation/procedural_candidate_generator.dart` |
| Candidate content library | `lib/data/seed_content/procedural_candidate_library.dart` |
| Seed isolation | `lib/domain/simulation/seed_derivation.dart` |
| Candidate UI | `lib/features/candidates/` |
| Evidence/Receipts | `lib/features/evidence/`, `lib/features/receipts/` |
| Information ecosystem | `lib/domain/simulation/information_ecosystem_engine.dart` |
| CityBook/News/TV UI | `lib/features/citybook/`, `lib/features/news/`, `lib/features/tv/` |
| TV generation | `lib/domain/simulation/tv_broadcast_engine.dart` |
| Election | `lib/features/election/` |
| Living City engine | `lib/domain/simulation/living_city_engine.dart` |
| Term adapter | `lib/domain/simulation/term_engine.dart` |
| Living event templates | `lib/data/seed_content/living_city_event_library.dart` |
| Living models/codecs | `lib/domain/models/living_city_simulation.dart`, `lib/data/persistence/living_city_codec.dart` |
| Simulation UI/map/history | `lib/features/simulation/` |
| Report | `lib/features/report/` |
| Gallery API/repository/cache | `lib/data/gallery/` |
| Gallery models/UI | `lib/domain/models/public_city_snapshot.dart`, `lib/features/gallery/` |
| Gallery database contract | `docs/SUPABASE_CITY_GALLERY_V2.sql` |
| Android manifest/activity/build | `android/app/src/main/AndroidManifest.xml`, `android/app/src/main/kotlin/com/resiboplease/game/MainActivity.kt`, `android/app/build.gradle.kts` |
| Assets/dependencies | `pubspec.yaml`, `assets/` |
| Tests | `test/` |

## L. Recommended next priorities

1. **Run a controlled release verification pass when authorized.** Execute analyzer/tests, build with the intended Supabase defines, install the exact release artifact, and record device/API results rather than relying on historical reports.
2. **Complete a physical-phone UX sweep.** Check short screens, safe areas, all back paths, report/publish dialogs, map memory/gestures, audio continuity, lifecycle restore, and Filipino overflow.
3. **Verify production-like Supabase V2.** Confirm Anonymous Sign-Ins, applied V2 SQL, RLS/grants, profile uniqueness, privacy changes, deletion, offline behavior, and clean-device identity limitations.
4. **Resolve release blockers.** Replace or document all audio provenance, create a real release keystore, remove debug signing from production builds, and perform privacy/legal review.
5. **Finish election history before expanding scope.** Add the political-history UI, explicit prior-office campaign memory, and an end-run/final-history experience to the implemented continuation foundation.
6. **Expand content through existing contracts.** Add event/candidate/issue variants using isolated seeds, stable IDs, evidence graphs, and regression tests rather than adding disconnected prose.
7. **Finish bilingual narrative coverage.** Inventory domain-generated strings and translate them without changing IDs or simulation truth.
8. **Keep network scope narrow.** Improve gallery moderation/recovery only after local gameplay and data minimization remain protected.

## Documentation authority order

For future work, use this order when documents disagree:

1. current source and persisted-schema contracts;
2. this handoff;
3. `README.md`, `GAME_VISION_AND_FEATURES.md`, `docs/CURRENT_SYSTEM_REPORT.md`;
4. focused architecture/API documents;
5. roadmaps and the long historical project-context specification.

Do not silently change seeds, generation versions, persistence fields, public JSON, SQL policies, or fictional-neutrality rules. Document compatibility-impacting changes alongside the code that introduces them.
