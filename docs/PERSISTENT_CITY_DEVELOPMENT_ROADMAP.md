# Resibo, Please — Persistent City Development Roadmap

Last updated: October 13, 2026

## Overall objective

Transform the current single-election vertical slice into a persistent fictional
city whose conditions, politicians, evidence, promises, projects, and political
history continue across multiple administrations. Preserve the existing
offline-first, deterministic, fictional, evidence-literacy design.

## Status vocabulary

- **NOT STARTED** — no implementation has begun.
- **IN PROGRESS** — implementation is actively incomplete.
- **IMPLEMENTED — UNVERIFIED** — code is connected but the required checks have not all passed.
- **VERIFIED** — logic, persistence, navigation, UI, and relevant tests have passed.
- **BLOCKED** — progress requires an external decision or unavailable dependency.

## Milestones

| Milestone | Status | Scope |
| --- | --- | --- |
| 1. Continuous multi-election gameplay | IMPLEMENTED — UNVERIFIED | Persistent timeline, inherited city state, returning/new candidates, report-to-next-election flow, schema migration, multi-term tests |
| 2. Dynamic politician careers | IMPLEMENTED — UNVERIFIED | Bounded causal career evolution and returning-candidate political memory |
| 3. Resibo ng Bayan | IMPLEMENTED — UNVERIFIED | Persistent promise/accountability journal, predictions, recurring records, archived evidence, political-history UI |
| 4. Citizen actions | IMPLEMENTED — UNVERIFIED | Three deterministic consequential actions without rewriting observed history |
| 5. Civic progression | IMPLEMENTED — UNVERIFIED | Derived civic tracks, accomplishments, and bounded tool unlocks |
| 6. Procedural diversity | IMPLEMENTED — UNVERIFIED | Cross-term event, visual, issue, and news-framing memory |
| 7. UI/UX integration | IMPLEMENTED — UNVERIFIED | Responsive game-styled integration across all affected screens |
| 8. Integration and release readiness | IMPLEMENTED — UNVERIFIED | Full automated QA and production builds complete; external checks remain |

## Current progress

### Milestone 1 — IMPLEMENTED — UNVERIFIED

Completed before this roadmap:

- One five-candidate procedural election can be investigated and saved.
- One deterministic 365-day Living City term can be completed and reported.
- Save schema 10 restores investigation, predictions, election, term, simulation,
  and multi-administration state. Citizen actions persist inside the saved Living
  City event history without a competing save tree.

Verified implementation slice:

- [x] Add a durable administration-history domain model and codec.
- [x] Migrate version-8 saves through schemas 9 and 10 without discarding the
  current run.
- [x] Archive a completed administration once and only once.
- [x] Carry final indicators and issue states into the next election.
- [x] Generate a deterministic later-election seed.
- [x] Select eligible returning politicians plus new challengers.
- [x] Preserve returning identity, portrait, stable candidate ID, and hidden core truth.
- [x] Add a localized Term Report action that begins the next election.
- [x] Verify Election 1 → Term 1 → Election 2 → Term 2 → Election 3 and restore points.

Additional implementation completed October 12:

- [x] Add a responsive Political History timeline and immutable historical term receipt.
- [x] Expose the timeline from the inherited City Brief and prior Term Reports.
- [x] Strengthen returning-candidate biography, promises, debate answers, CityBook,
  news, and evidence with explicit prior-office references.
- [x] Restore and verify the second election and an in-progress second administration.
- [x] Verify short phone layouts for history and accountability screens with widget tests.

Remaining verification:

- Manually verify Term Report, inherited City Brief, Political History, and
  Resibo ng Bayan on an Android device and a short physical viewport.

### Milestone 2 — IMPLEMENTED — UNVERIFIED

Implemented slice:

- [x] Add a deterministic `CandidateCareerEvolutionEngine`.
- [x] Preserve identity, quality band, motivations, risks, career origin,
  personality, controversies, and relationships.
- [x] Apply bounded skill and pressure changes from completed projects, unresolved
  work, major crises, city-issue movement, budget health, public trust, and
  corruption pressure.
- [x] Carry the evolved truth into the next generated election without rerolling.
- [x] Keep numerical evolution hidden while publishing causal historical reasons.
- [x] Add deterministic, bounds, continuity, and integration tests.
- [x] Let one archived candidate periodically return after sitting out a ballot,
  preserving stable ID, name, portrait, and truth from the sealed election.
- [x] Add a neutral prior-campaign receipt to biography, timeline, evidence,
  public identity, and CityBook without treating electoral defeat as quality.
- [x] Persist bounded reform credibility, political fatigue, and institutional
  standing inside sealed candidate truth snapshots, with legacy-save defaults.
- [x] Let those career pressures affect difficult project delivery in small,
  bounded ways without exposing raw hidden values.
- [x] Add a new recurring controversy record only when a sealed administration
  contains procurement scrutiny or unverified leaked records; otherwise preserve
  the earlier controversy list exactly.

Remaining Milestone 2 verification:

- Manually inspect a returning officeholder after a scrutiny event and after an
  administration without one on Android.

### Milestone 3 — IMPLEMENTED — UNVERIFIED

Implemented slice:

- [x] Add a derived, persistent `AccountabilityJournal` over immutable election and
  administration snapshots; no duplicate save tree or schema migration is needed.
- [x] Link stable campaign promise IDs to administration project IDs.
- [x] Distinguish not started, in progress, partially delivered, delivered,
  delayed, abandoned, and blocked outcomes.
- [x] Explain incomplete work from the stored project state without automatically
  calling it a lie.
- [x] Add a responsive, bilingual Resibo ng Bayan screen with outcome filters.
- [x] Link Resibo ng Bayan from Political History.

Remaining Milestone 3 work:

- Manually verify long labels, both languages, and multi-term scrolling on a
  physical Android phone.

Completed additional slices:

- [x] Add optional pre-vote civic predictions and end-of-term reflection receipts.
- [x] Archive predictions with the administration and clear them for the next election.
- [x] Surface recurring promises and controversies from sealed multi-term records.
- [x] Navigate directly from accountability entries to immutable historical
  evidence snapshots.

### Milestone 4 — IMPLEMENTED — UNVERIFIED

Implemented first vertical slice:

- [x] Audit the precomputed 365-day simulation architecture before exposing actions.
- [x] Compare incremental daily generation, suffix regeneration, and a deterministic
  future-action overlay in `CITIZEN_ACTION_SIMULATION_DESIGN.md`.
- [x] Implement a pure deterministic `CitizenActionEngine` that never rewrites
  observed events or project milestones.
- [x] Add Request Public Records and Organize a Petition as limited actions.
- [x] Make success, compromise, or resistance depend on city conditions, issue
  difficulty, public trust, budget health, mayor capability, and a stable roll.
- [x] Persist pending and completed action outcomes in the existing Living City
  snapshot and restore them without rerolling.
- [x] Rebuild derived phase and final city snapshots while preserving event IDs,
  causal references, media records, and the observed prefix.
- [x] Add a responsive bilingual City Action hub with confirmation, pending state,
  resolved receipt, and game-styled controls.
- [x] Surface resolved outcomes as normal map/history events with usable tap targets.
- [x] Add engine, validation, codec, save/restore, and narrow-phone widget tests.
- [x] Add Challenge a Misleading Claim, unlocked only by a reliable qualifying
  source that the player actually reviewed during the election.
- [x] Persist the selected evidence ID on the outcome event and explain resisted
  challenges as limited reach or institutional resistance, never invalid evidence.
- [x] Capture and verify an explicit day checkpoint before every action, covering
  observed events, project milestones, indicators, and issue states.
- [x] Keep future-event and project rerolls prohibited until a separate versioned
  suffix-regeneration migration can restore a full generator checkpoint.

Remaining Milestone 4 verification:

- Manually verify action timing, marker behavior, and Filipino copy on Android.

### Milestone 5 — IMPLEMENTED — UNVERIFIED

Implemented first vertical slice:

- [x] Add a derived `CivicProgressionProfile` without a second mutable XP ledger.
- [x] Derive Research, Public Accountability, Civic Organizing, and Historical
  Analysis from unique election activity, sealed terms, and once-per-term actions.
- [x] Add ten neutral accomplishments with no required candidate or party choice.
- [x] Prevent duplicate farming through sets, immutable history, event IDs, and
  administration-scoped keys.
- [x] Add one real bounded tool benefit: accountability and organizing experience
  can shorten the matching civic-action response by 3–5 days, but never changes
  the deterministic success outcome.
- [x] Add a bilingual, responsive Civic Profile available from the first City Brief
  and from Political History.
- [x] Add progression, action-causality, routing, and phone-layout tests.
- [x] Add the optional Source Desk at Research Level 2. It groups visible dossier
  files by bookmark/review state and source type without unlocking evidence or
  revealing truth status.

Remaining Milestone 5 work:

- Manually verify the complete/locked accomplishment states in both languages.

### Milestone 6 — IMPLEMENTED — UNVERIFIED

Implemented first slice:

- [x] Feed prior administration event-template memory into later Living City terms.
- [x] Penalize recently repeated templates without banning them.
- [x] Preserve a higher recurrence floor when the underlying issue remains severe,
  so unresolved flooding, health, or transport conditions can plausibly recur.
- [x] Keep causal follow-up hooks exempt from the penalty so event chains remain coherent.
- [x] Preserve term-one deterministic output when no history exists.
- [x] Add deterministic multiplier, changed-selection, validity, and multi-election tests.
- [x] Add a bounded emerging-issue transition: at most one new authored concern
  per election and at most six active concerns, derived from inherited indicators,
  deterioration, growth pressure, and project outcomes.
- [x] Let one sufficiently improved concern leave the active agenda while retaining
  its immutable historical record.
- [x] Restore the exact later-election issue roster and inherited brief summary from
  local saves without adding a duplicate persistence model.
- [x] Give repeated issue events contextual public copy that acknowledges prior
  administrations and active delivery projects without changing event truth.
- [x] Stress-test three seeds through ten administrations each.
- [x] Track recently used artwork/marker-and-district combinations from sealed
  administrations and apply a bounded visual cooldown with a severe-issue floor.
- [x] Track each outlet's dominant recent framing and apply a bounded cooldown
  to later headlines and angles while preserving outlet identity, stable media
  IDs, event facts, and article summaries.

Remaining Milestone 6 verification:

- Manually compare later-administration coverage from all three outlets on Android.

### Milestone 7 — IMPLEMENTED — UNVERIFIED

- [x] Integrate Political History, historical receipts, Resibo ng Bayan,
  Civic Profile, Source Desk, later elections, and Citizen Actions with the
  established paper-and-ink game UI rather than default Material screens.
- [x] Use SafeArea and controlled scrolling across the new screens and overlays.
- [x] Cover the affected routes on a 390×844 phone viewport, including English
  and Filipino core-loop chrome.
- [x] Keep historical content immutable and keep hidden candidate values out of UI.

Remaining verification:

- Perform a physical Android pass for touch ergonomics, long Filipino labels,
  system gestures, and multi-term scrolling.

### Milestone 8 — IMPLEMENTED — UNVERIFIED

- [x] Run static analysis, the full automated suite, a production web build,
  and an Android release APK build after the final implementation slices.
- [x] Recheck credential patterns and retain the Supabase service-role guard.
- [x] Record APK size and SHA-256 in `RELEASE_READINESS_REPORT.md`.
- [x] Keep debug signing, live Supabase state, physical-device behavior, and
  unresolved audio provenance clearly identified as public-release blockers.

Remaining verification is external/manual: physical Android QA, live Supabase
V2 policy/API validation, audio licensing, and production release signing.

## Architectural decisions

1. **Append-only administration history.** Observed terms become immutable
   `AdministrationRecord` snapshots. The active election remains in the existing
   run fields so current screens do not need a competing state tree.
2. **World seed remains stable.** Later election rosters use a derived election
   seed keyed by term number. Living City continues to use the world seed plus
   its existing term-specific paths.
3. **Generated snapshots remain authoritative.** Current and historical
   `ProceduralElection` and `LivingTermSimulation` objects are serialized rather
   than rerun during navigation or restore.
4. **Eligibility rule for the first slice.** A mayor may serve at most two
   consecutive terms. When eligible, the incumbent returns. One deterministic
   previous losing candidate may also return; remaining places are new
   challengers. No role implies moral or competence quality.
5. **Inherited city state.** Final indicators and final issue severity/trend
   become the next pre-election city state. A deterministic transition can add
   one pressure-supported authored issue or retire one substantially improved
   concern, while keeping four to six active issues.
6. **Election-scoped investigation.** Active investigation points and UI
   selections reset for a new campaign, while their completed snapshot is kept
   in the administration history for later accountability/history screens.
7. **Derived accountability ledger.** Resibo ng Bayan is derived from saved
   election promises and administration projects. Those snapshots remain the
   source of truth, preventing ledger drift and avoiding duplicate persistence.
8. **Causal career evolution.** Returning officeholders change only through a
   deterministic, bounded transformation of their latest sealed administration.
   Foundational identity traits remain stable and raw values stay hidden.
9. **Predictions are reflection, not scoring.** At most two optional expectations
   are archived with each administration and compared only with observed indicator
   movement. They do not reveal a correct candidate.
10. **Citizen actions use a future overlay for the first slice.** The engine inserts
    a deterministic bounded outcome after the current day and recomputes derived
    snapshots. It does not reroll unrelated future history. This preserves old saves
    and prefix immutability while daily checkpoint/suffix regeneration remains a
    documented future engine upgrade.
11. **Civic progression is derived.** Unique investigation records, immutable
    administrations, and once-per-term action events are the authority. This avoids
    duplicate XP state and reward farming after save/restore.
12. **Cross-term repetition is weighted, not prohibited.** Recent templates receive
    pressure in later administrations, but severe unresolved issues retain a higher
    recurrence floor and causal follow-ups remain eligible.
13. **Comebacks use sealed ballot identity.** Every third election may include one
    archived politician who sat out the preceding ballot. Defeat is recorded only
    as participation, never converted into competence or morality.
14. **Evidence organization is a bounded civic unlock.** Source Desk changes only
    dossier ordering and uses visible metadata. It cannot reveal, discount, unlock,
    or score evidence for the player.
15. **Visual repetition uses pressure, not bans.** Archived non-project events
    contribute a compact visual-combination key. Later selection reduces that
    combination's weight, with a higher recurrence floor for severe issues and
    no penalty on required causal follow-ups.
16. **News variety never rewrites truth.** Each outlet retains three authored
    framing families. A saved administration contributes only its dominant recent
    angle to the next bounded cooldown; event IDs and factual summaries remain fixed.
17. **Career pressure is causal and hidden.** Reform credibility, political
    fatigue, and institutional standing are persisted with candidate truth and
    change only from sealed delivery, trust, corruption, budget, and crisis records.
    New controversy memory requires a matching historical scrutiny event.
18. **Evidence challenges preserve epistemic meaning.** A claim challenge uses
    only a reviewed, reliable source type. Resistance describes failure to gain
    traction and never mutates or discredits the underlying evidence.
19. **Every citizen action seals the observed day.** A derived checkpoint
    fingerprints the observed event and project prefix plus current civic state.
    The current overlay must preserve it exactly; suffix rerolls remain prohibited.

## Files changed

- `docs/PERSISTENT_CITY_DEVELOPMENT_ROADMAP.md`
- `lib/domain/models/political_timeline.dart`
- `lib/domain/models/accountability_journal.dart`
- `lib/domain/models/civic_prediction.dart`
- `lib/domain/models/citizen_action.dart`
- `lib/domain/models/civic_progression.dart`
- `lib/domain/models/candidate_generation.dart`
- `lib/domain/simulation/candidate_career_evolution_engine.dart`
- `lib/domain/simulation/citizen_action_engine.dart`
- `lib/domain/simulation/emerging_issue_engine.dart`
- `lib/domain/simulation/living_city_engine.dart`
- `lib/data/persistence/political_timeline_codec.dart`
- `lib/data/persistence/run_save_data.dart`
- `lib/data/persistence/procedural_election_codec.dart`
- `lib/domain/simulation/procedural_candidate_generator.dart`
- `lib/core/state/game_controller.dart`
- `lib/features/results/term_report_screen.dart`
- `lib/features/history/political_history_screen.dart`
- `lib/features/history/accountability_journal_screen.dart`
- `lib/features/history/historical_evidence_screen.dart`
- `lib/features/history/civic_progression_screen.dart`
- `lib/features/simulation/term_simulation_screen.dart`
- `lib/features/city/city_overview_screen.dart`
- `lib/app/router.dart`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_fil.arb`
- generated localization Dart files under `lib/l10n/`
- `test/domain/multi_election_timeline_test.dart`
- `test/domain/candidate_career_evolution_test.dart`
- `test/domain/accountability_journal_test.dart`
- `test/domain/civic_prediction_test.dart`
- `test/domain/citizen_action_engine_test.dart`
- `test/domain/civic_progression_test.dart`
- `test/domain/living_city_engine_test.dart`
- `test/domain/emerging_issue_engine_test.dart`
- `test/domain/procedural_candidate_generator_test.dart`
- `test/election_term_mvp_widget_test.dart`
- `test/persistence_widget_test.dart`
- `test/living_city_widget_test.dart`
- `test/core/game_controller_test.dart`
- `docs/CITIZEN_ACTION_SIMULATION_DESIGN.md`
- current overview/context Markdown files updated for schema 10

## Tests performed

- `flutter analyze` — **PASS**, no issues found.
- Focused multi-election tests — **PASS**, including same-incumbent and changed-winner paths, Election 3, restore, and schema-8 migration.
- Focused save/controller tests — **PASS**, 26 tests.
- Latest full `flutter test` — **PASS**, all **194** tests at the current
  checkpoint, including the
  ten-administration stress run and restore.
- Citizen-action engine tests — **PASS**, 4 tests.
- Citizen-action controller save/restore test — **PASS**.
- Citizen-action narrow-phone widget flow — **PASS**.
- Evidence-linked citizen action tests — **PASS**, including locked/unlocked
  qualification, saved evidence linkage, and observed-prefix checkpoint equality.
- Latest `flutter build web` — **PASS**, including the WebAssembly dry run.
- Civic-progression focused tests — **PASS**, including derived anti-farming
  ranks, bounded unlock causality, and phone navigation.
- Cross-term anti-repetition focused tests — **PASS**, including unresolved-issue
  recurrence and multi-election integrity.
- Ten-administration stability test — **PASS** through Election 11 with bounded
  indicators, valid event graphs, at least 30 event templates, candidate turnover,
  and exact local restore.
- Latest `flutter build web` — **PASS**, including the WebAssembly dry run,
  after the news-framing and career-memory changes.
- Latest configured Android release build — **PASS**; a fresh 101.6 MB classroom
  APK with the git-ignored Supabase defines was produced at
  `build/app/outputs/flutter-apk/app-release.apk`.
- Source Desk focused tests — **PASS**, including its locked state, Research
  Level 2 unlock, and a short-phone dossier interaction.
- Multi-seed stability tests — **PASS** for three distinct seeds through ten
  administrations each.
- News-framing focused tests — **PASS**, including bounded cooldown behavior and
  unchanged event IDs and factual summaries.
- Career-memory focused tests — **PASS**, including deterministic bounded changes,
  event-justified controversy memory, and legacy election-snapshot defaults.

Manual Android and Flutter Web interaction testing has not been performed in
this session. Milestone 1 therefore remains **IMPLEMENTED — UNVERIFIED**, not
fully verified.

## Known issues and safeguards

- Existing documentation edits and untracked midterm artifacts predate this
  roadmap and must not be overwritten or deleted.
- Music and reporter-dialogue provenance remain unresolved release blockers.
- Supabase V2 is optional and must remain independent from local multi-term play.
- The selected citizen-action overlay does not reroll unrelated future events.
  Project-changing actions remain blocked on the documented checkpoint/suffix design.

## Exact continuation instructions

1. Read `Master_Plan.md` and this roadmap.
2. Inspect `git status` and preserve unrelated user changes.
3. Run a new full test/build checkpoint after any further UI or simulation change.
4. No remaining Master Plan code milestone is known. Continue with the external
   verification checklist: physical Android QA, live Supabase V2 validation,
   audio provenance, and production signing before any public release claim.
5. Do not add a save migration for derived progression; add one only if future
   progression state cannot be reproduced from saved authoritative records.
6. Record changed files, exact results, limitations, and the next unfinished task here.
