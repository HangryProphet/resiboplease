# RESIBO, PLEASE — MASTER DEVELOPMENT PLAN
## Persistent Political Simulation, Civic Gameplay, and Replayability

We are returning to development of Resibo, Please, a Flutter-based fictional civic decision simulation game.

This is a MAJOR development update intended to transform the existing single-election experience into a persistent, replayable political simulation with meaningful player progression and long-term consequences.

Your task is to implement this project incrementally, in a controlled and maintainable way, until the defined development milestones are completed.

This is a long-running master task. You may not complete it within one Codex session or usage window. Therefore, persistent checkpoints and resumable implementation are REQUIRED.

Do not interpret this prompt as permission to rush, replace existing working systems, or build everything at once.

The first and most important deliverable is a fully functional multi-election continuation system.

---

# 1. READ THE EXISTING PROJECT FIRST

Before modifying code, inspect the current repository thoroughly.

Start with

- `RESIBO_PROJECT_CONTEXT_HANDOFF.md`
- `GAME_VISION_AND_FEATURES.md`
- `README.md`
- `docsCURRENT_SYSTEM_REPORT.md`
- `docsCITY_SIMULATION_ARCHITECTURE.md`
- Existing architectural documents and project roadmaps
- `libcorestategame_controller.dart`
- `libdomainsimulation`
- `libdomainmodels`
- `libdatapersistence`
- `libdataseed_content`
- `libfeatures`
- Relevant tests and save migrations

Inspect actual source code whenever documentation and implementation disagree.

Important existing architecture

- Flutter and go_router
- ChangeNotifier-based GameController
- Riverpod application scoping
- Sembast local saves
- Deterministic world seeds and isolated generation paths
- Five procedural mayoral candidates
- Structured candidate history and hidden truth
- Candidate evidence graph
- CityBook, Chronicle, News, TV, Receipts Board
- 365-day Living City simulation
- World conditions, projects, events, and causal chains
- Interactive map and event history
- Term Report
- Supabase optional public gallery

Current known contracts

- Five local save slots
- Save schema version 8 at the last documentation audit
- Candidate generator version 1
- Living City generator version 4
- One completed term per game in the old implementation

Verify actual versions before working.

Do not silently break old saves or deterministic behavior.

Most importantly

ALGORITHM CREATES TRUTH. PRESENTATION DISPLAYS TRUTH.

The game remains fully fictional, offline-first, and does not require generative AI or external language models.

---

# 2. DEVELOPMENT MANAGEMENT — VERY IMPORTANT

This project will require multiple implementation sessions.

Create a persistent development roadmap

`docsPERSISTENT_CITY_DEVELOPMENT_ROADMAP.md`

This document should contain

- Overall objective
- Implementation milestones
- Current progress
- Completed tasks
- In-progress tasks
- Remaining tasks
- Important architectural decisions
- Files changed
- Tests performed and results
- Known issues
- Exact continuation instructions

Use clear statuses

- NOT STARTED
- IN PROGRESS
- IMPLEMENTED — UNVERIFIED
- VERIFIED
- BLOCKED

Keep this roadmap updated throughout development.

At the beginning of each future session

1. Read this roadmap.
2. Check the actual repository state and changes.
3. Identify the first unfinished milestone.
4. Continue from that point.
5. Avoid reimplementing completed features.

Do not repeatedly redesign the architecture unless a real problem requires it.

Do not claim a milestone is finished merely because its UI exists.

A feature is complete only when its underlying logic, persistence, navigation, UI, tests, and expected interactions are implemented.

Prioritize working vertical slices over unfinished foundations spread across many modules.

If the session is nearing its limit, stop at a coherent checkpoint, document the remaining work, and give a concise continuation summary.

Do not push to GitHub or rewrite repository history without authorization.

---

# 3. THE NEW CORE GAMEPLAY LOOP

The current game ends after one election and its 365-day simulation.

This must change.

## Old gameplay

Create City → Investigate → Vote → Simulate Term → Term Report → EndReplay

## New gameplay

Create City → Investigate → Vote → Simulate Term → Term Report → Next Election → New Term → Repeat

The same fictional city must continue across elections.

Each administration inherits the city left behind by the previous mayor.

Examples of persistent state

- City indicators
- Existing issues and trends
- Budget and financial pressure
- Public trust
- Corruption pressure
- Completed projects
- Unfinished projects
- Failed or abandoned projects
- Unresolved crises
- Public infrastructure improvements
- Institutional changes
- Previous promises
- Prior election results
- Political history
- Candidate relationships
- Candidate career development
- Player investigation history
- Player civic actions
- Player progression

The city must NEVER reset to its original starting condition when a new election begins.

However, the player must retain the ability to voluntarily start a completely new city or replay a historical scenario.

## Core design goal

After Election 1, the player should want to continue because they are curious about what happens next.

Every election must have recognizable continuity and new uncertainty.

The world must remember its past.

---

# MILESTONE 1 — IMPLEMENT CONTINUOUS MULTI-ELECTION GAMEPLAY

HIGHEST PRIORITY. COMPLETE THIS FIRST.

Do not begin major new civic or progression features until this milestone works end to end.

## 1.1 Persistent political timeline

Introduce a proper model for a city that survives multiple administrations.

Use or extend existing models rather than creating competing sources of truth.

Design appropriate structures for

- Persistent City State
- Election Cycle
- Administration Record
- Candidate Career History
- Term Outcome
- Project History
- City Historical Events
- Current Election State

These names are suggestions, not mandatory class names.

Each administration should have

- Administrationterm index
- Elected mayor ID
- Starting and final city state
- Election details
- Promises made
- Projects undertaken
- Significant civic events
- Important political developments
- Performance outcomes
- Beginning and ending dates
- Persistent consequences

The game must distinguish

1. The permanent city timeline
2. The current election
3. The current administration
4. Historical administrations

Use a consistent time model, such as term index plus day within the term.

Prevent ambiguity between Day 365 of one administration and Day 1 of another.

## 1.2 Continue after the Term Report

Modify the existing Term Report.

Once a term is completed, present a clear action such as

CONTINUE TO NEXT ELECTION

Maintain existing replayhistoryreport actions where appropriate.

The player should not be forced to create another city.

When continuing

1. Save the finished administration.
2. Carry forward relevant city state.
3. Advance the political timeline.
4. Prepare the next fictional election.
5. Generate the next candidate roster.
6. Generate current campaign content.
7. Open a new pre-election City Brief.
8. Allow investigation and voting again.
9. Generatesimulate the next administration.

Do not reroll historical city facts.

Do not delete the previous election.

Do not accidentally reopen the old Term Report instead of the next election.

## 1.3 Returning candidates and new challengers

The next election must not always consist of five entirely new politicians.

Possible candidate types include

- Current incumbent
- Previous losing candidates
- Returning politicians from earlier elections
- New political challengers
- Political outsiders
- Previously retired or defeated politicians attempting a comeback

The candidate selection system should use plausible eligibility and weighted logic.

An incumbent can run again if allowed by the fictional rules of the game.

Define a simple, consistent fictional eligibility system. Document it clearly.

Do not assign fixed roles such as one good candidate, one bad candidate, and one outsider.

A returning politician must retain their original identity

- Same stable candidate ID
- Same portrait
- Same core identity
- Same established historical facts
- Previous election appearances
- Previous offices held
- Previous achievements and controversies

Their new campaign material should reflect subsequent history and present circumstances.

Generate new candidates when required to fill a five-candidate roster.

Avoid accidental duplicated identities, portraits, or contradictory records within the same election.

## 1.4 Inherited city conditions

The next administration must start from the actual previous final conditions.

For example

Election 1
- Flooding severe
- Budget health weak
- Public trust moderate

After Administration 1
- Flooding improving
- Budget health strained
- Public trust lower

Election 2 should begin from those resulting conditions, with appropriate new developments.

Do not reset issues to their original seed values.

Some issues should

- Improve
- Worsen
- Remain unresolved
- Become inactive or resolved
- Reappear after deterioration
- Develop into related problems

Permit a limited number of emerging issues based on existing city indicators and history.

Respect the current twelve civic issue families unless extension is genuinely necessary.

Do not create an unlimited number of active problems that makes the UI or simulation unusable.

## 1.5 Persistence and backward compatibility

Extend local saves safely.

Existing version-8 saves, or whatever version is verified in source, must migrate to the new system where possible.

An old single-term save should become a valid city timeline containing its historical first administration.

Do not delete unsupported saves silently.

Introduce schema migrations with explicit compatibility rules.

Preserve

- Seeded generation
- Candidate identities
- Evidence and bookmarks
- Completed term outcomes
- Inspected events
- Player notes
- Reporthistory access
- Gallery publication references where applicable

Test save restoration at the following points

- During investigation
- Before voting
- During simulation
- At Term Report
- At the transition to the next election
- During the second election
- During the second administration
- After multiple completed administrations

Avoid generating the same election twice because of app restart or navigation.

## 1.6 Multi-term testing

At minimum, verify

- Complete Election 1
- Complete Administration 1
- Begin Election 2
- Investigate returningnew candidates
- Elect the same incumbent if eligible
- Elect a different candidate in another test
- Complete Administration 2
- Begin Election 3
- Save and restore all major stages
- Confirm historical records remain intact

Do not consider Milestone 1 complete until these flows work.

---

# MILESTONE 2 — DYNAMIC POLITICIAN CAREERS

Politicians should evolve across elections.

A candidate is not a permanent immutable collection of hidden stats.

But do NOT simply randomize morality or competence every year.

## 2.1 Preserve foundational character traits

Candidates should have relatively persistent characteristics such as

- Background
- Personality
- Career origin
- Personal motivations
- Core political tendencies
- Initial integrity
- Initial competencies
- Policy strengths
- Established relationships

These create continuity.

## 2.2 Add evolving political attributes

Consider dynamic attributes such as

- Governing experience
- Administrative skill
- Political ambition
- Coalition dependence
- Integrity pressure
- Corruption exposure
- Public reputation
- Crisis experience
- Policy knowledge
- Institutional relationships
- Reform credibility
- Political fatigue

Use appropriately bounded values.

Not all attributes need player-facing numbers.

## 2.3 Character evolution through causality

Candidate evolution should be affected by

- Their previous decisions
- Their successes
- Their failures
- Administration outcomes
- Crises encountered
- Scandals
- Political alliances
- Public pressure
- Financial pressure
- Long-term ambitions
- Prior promises
- Institutional constraints

Examples

A talented but inexperienced mayor might improve their administrative competence after one difficult term.

A reform-minded mayor may face pressure from powerful allies or contractors.

A previously controversial politician may gradually rebuild credibility through documented actions.

An ineffective leader might remain ineffective.

A corrupt politician might continue corrupt practices.

A capable leader might make serious mistakes.

Nothing should guarantee improvement or decline.

Changes should be explainable through game history rather than unexplained random stat adjustments.

## 2.4 Political memory

A returning candidate's

- Biography
- Campaign promises
- Debate responses
- CityBook posts
- News coverage
- Evidence
- Then-vs-Now records

must account for relevant past events.

For example, a former mayor who failed a flood-control project must not be presented as if that administration never occurred.

The player should be able to inspect the politician's previous electoral and administrative history.

Do not expose raw hidden stats or label a candidate as objectively goodbad.

---

# MILESTONE 3 — RESIBO NG BAYAN THE ACCOUNTABILITY SYSTEM

This should become one of the game's signature mechanics.

Build on the existing Receipts Board, evidence system, promises, Chronicle, and Term Report.

Do not replace them with an unrelated second evidence system.

## 3.1 Persistent accountability records

Create a city-wide historical record of

- Campaign promises
- Evidence supporting those promises
- Actions taken in office
- Project progress
- Project failures
- Major controversies
- Public statements
- Election outcomes
- Administration results
- Important corrections or additional context

Link records using stable IDs.

A politician's older promises should remain inspectable during later elections.

## 3.2 Promise tracking

Promises should have meaningful outcomes such as

- Not started
- In progress
- Partially delivered
- Delivered
- Delayed
- Abandoned
- Blocked by documented circumstances

Do not automatically label every incomplete promise as a lie.

A promise can fail despite genuine effort.

A politician can also take credit for a project that was started by a previous administration.

Track both original ownership and later contributions.

## 3.3 Player predictions and reflections

Before voting, allow the player to optionally record a limited number of predictions.

For example

- I expect this candidate to improve healthcare.
- I believe this candidate will prioritize infrastructure.
- I am concerned about this candidate's transparency.

At the end of the term, compare these predictions with actual outcomes.

Do not simply score whether the player voted for the hidden strongest candidate.

The goal is reflection and evidence-based decision-making.

Make this interaction quick and optional, not an essay-writing requirement.

## 3.4 Political history interface

Create a usable screen that allows the player to inspect

- Previous elections
- Previous mayors
- Administration summaries
- Promise records
- City changes over time
- Recurring political controversies
- Returning politicians

Use the existing game's visual identity.

The history should tell a coherent story across multiple terms.

---

# MILESTONE 4 — MEANINGFUL CITIZEN ACTIONS DURING THE TERM

Currently, the player mainly observes the administration after voting.

Introduce limited but meaningful citizen participation.

The player remains a citizen, not the mayor.

Do not introduce direct government budget allocation or mayoral policy management.

## 4.1 Citizen actions

Initial actions may include

- Request public records
- Investigate a civic issue
- Collect or verify community complaints
- Submit a formal concern
- Organize a petition
- Request a public hearing
- Challenge a misleading claim using evidence
- Continue observing without intervening

Start with a small, polished collection of actions.

Do not create dozens of superficial buttons.

## 4.2 Gameplay impact

Citizen actions may influence

- Availability of evidence
- Public awareness
- Public trust
- Political pressure
- Probability of an official response
- Investigation opportunities
- News coverage
- Accountability records
- Administrative response priorities

However, they must not guarantee that the mayor obeys the player.

Results should depend on

- Current city conditions
- Evidence quality
- Administrative capability
- Mayor characteristics
- Budget limitations
- Institutional cooperation
- Public support
- Existing political pressure
- Relevant world conditions

The game should show a plausible explanation for the outcome.

## 4.3 Important simulation architecture issue

The current implementation generates the complete 365-day administration at voting time.

That is incompatible with meaningful mid-term actions if future outcomes remain permanently fixed.

Before implementing consequential citizen actions

1. Inspect the existing simulation architecture.
2. Identify how to support citizen actions without rewriting already observed history.
3. Compare a deterministic incremental daily simulation with a safe deterministic future-suffix recalculation model.
4. Choose the approach that best preserves current save compatibility, performance, deterministic event generation, and existing tests.
5. Document the decision.
6. Implement and test the necessary simulation change BEFORE presenting citizen actions as consequential.

Preserve the established timeline

- Past events remain immutable.
- Already completed projects are not rewritten.
- Player actions are persisted.
- Future simulation can respond causally.
- Reopening the same save reproduces the same history.
- No hidden reroll occurs on page navigation.
- No duplicate event IDs or contradictory causal chains appear.

Do not disguise purely cosmetic choices as meaningful simulation decisions.

## 4.4 Avoid turning gameplay into nonstop interruptions

Citizen actions should arise at meaningful points.

Use

- Optional city-action hub
- Relevant event prompts
- Limited opportunities
- Clear notifications
- Reasonable cooldowns

Respect the current Critical Event Interruption setting.

The player should still be able to advance through a term smoothly.

---

# MILESTONE 5 — CIVIC PROGRESSION AND ACCOMPLISHMENTS

Add a meaningful sense of player progress.

But do not turn the game into a traditional RPG where politicians receive arbitrary player-selected upgrades.

## 5.1 Player progression

The player develops civic knowledge, investigation capabilities, and influence.

Potential progression areas

- Research
- Media Literacy
- Community Network
- Public Accountability
- Civic Organizing
- Historical Analysis

Start with a small number of meaningful progression paths.

Progression should come from relevant activity and milestones, not endless grinding.

## 5.2 Meaningful unlocks

Possible rewards

- Better evidence organization
- Additional source-comparison tools
- Deeper historical comparisons
- More efficient civic requests
- New public accountability opportunities
- Additional investigation choices
- Cosmetic journal or profile customization

Do not grant magical certainty about candidate morality or hidden truth.

Do not permanently lock essential voting information behind grinding.

Upgrades should improve the player's available tools, not automatically improve politicians.

## 5.3 Accomplishments

Create clear long-term achievements, such as

- Complete three elections
- Complete five elections
- Document a recurring campaign promise
- Follow a major city project across administrations
- Investigate a controversy using multiple sources
- Successfully obtain public records
- See a major civic issue recover
- Track a candidate's political comeback

Avoid achievements that require voting for a specific predetermined candidate.

## 5.4 Long-term goals

A major motivation should be watching the city develop over time.

Introduce meaningful milestones such as

- Survive several administrations
- Improve previously neglected services
- Recover from a major crisis
- Preserve improvements across multiple mayors
- Identify a repeated failure of accountability
- Build a detailed political history

Do not promise a permanently perfect city.

The player should feel accomplishment through progress, discovery, and historical continuity.

---

# MILESTONE 6 — STRONGER PROCEDURAL WORLD AND ANTI-REPETITION

This is very important.

The game must remain interesting across multiple elections.

The existing library contains 47 Living City event templates according to the last documentation audit.

That is a useful foundation, but may become repetitive over many administrations.

Do not solve repetition by simply duplicating events under different names.

## 6.1 Compositional procedural content

Expand the content system using combinations of

- Civic issue families
- Districtlocation
- Current severity
- Active world conditions
- Prior political history
- Candidate traits
- Project state
- Available budget
- Public trust
- Political alliances
- Institutional capacity
- Recent events
- Causal chains
- Seasonal context
- Administration priorities

Where practical, separate

1. Structured event logic
2. Eligibility and consequences
3. Contextual event parameters
4. Presentation variations

This should allow the same broad issue to create different situations depending on the world state.

## 6.2 Expand authored content strategically

Expand the existing libraries where needed

- Civic event templates
- Positive developments
- Rare events
- Community-life events
- Political controversies
- Recovery events
- Administrative setbacks
- Project developments
- Candidate historical records
- News headlinecoverage variants
- CityBook postcomment variants
- Debate response variants
- Long-term civic consequences

Do not blindly generate enormous amounts of low-quality text.

Prioritize meaningful variation, consistent facts, and plausible consequences.

## 6.3 Anti-repetition memory

Track useful historical information

- Recently used event templates
- Recent news framing
- Repeated candidate statements
- Past unresolved problems
- Previous project failures
- Frequently occurring event families
- Recent visualcontent combinations
- Prior election narratives

Use weighted selection, cooldowns, contextual changes, and bounded repetition penalties.

However, repetition should not be completely prohibited.

For example, a city with unresolved flooding SHOULD experience related recurring problems.

The important distinction is that the circumstances, consequences, and surrounding political context should evolve.

## 6.4 Emerging city problems

Allow long-running conditions to produce new civic problems.

For example

- Industrial expansion increases employment but strains water supply.
- Improved roads stimulate commerce but increase traffic pressure.
- Budget shortages reduce hospital capacity.
- Poor maintenance reverses earlier flood-control progress.
- Continued administrative reform improves services but creates short-term political resistance.

Use rules and limits to avoid runaway escalation.

Make these developments visible in the City Brief and city history.

## 6.5 Long-run simulation stability

Test simulations across multiple elections and administrations.

Look for

- Impossible indicator values
- Runaway budget growthdecline
- Permanent extreme conditions
- Repeated identical events
- Incompatible events
- Broken event chains
- Duplicated identities
- Contradictory historical records
- Excessively frequent crises
- Completely inactive cities
- Unbounded save growth
- Excessive generationloading times

Build deterministic stress tests covering both short and long timelines.

Use seed-based reproducibility.

If a generation rule changes incompatibly, handle versioning and migration explicitly.

---

# MILESTONE 7 — UIUX, NAVIGATION, AND COMPLETENESS

This milestone must not be overlooked.

One of the existing project's weaknesses has been occasional unfinished UI details

- Default Flutter buttons appearing in custom screens
- Inconsistent colors
- Unequal button dimensions
- Missing images
- Incorrect portraits
- Overflow on smaller phones
- Awkward back navigation
- Placeholder text
- Missing contextual actions

Do not allow new features to recreate these problems.

## 7.1 Preserve the game's visual identity

Resibo, Please should retain its

- Hand-drawn political-cartoon style
- Navy, cream, muted red, and supporting accent colors
- Outlined and tactile game-style buttons
- Consistent rounded panels and borders
- Illustrated civicpolitical theme
- Consistent fonts
- Clear visual hierarchy

Avoid default blue Material buttons or unstyled Flutter controls.

Use existing reusable widgets wherever possible.

Create shared components only when they genuinely reduce duplication.

Do not redesign the entire game unnecessarily.

## 7.2 Complete every new screen

For each new feature, verify that the following exist where applicable

- Proper page title
- Clear back navigation
- Correct contextual header
- Main action
- Secondary actions
- Confirmation for destructive actions
- Loading state
- Empty state
- Error state
- Disabled state
- Suitable fallback data
- Relevant explanations
- Accessible touch targets
- Consistent button styling
- Correct screen transitions
- Appropriate visual assets
- EnglishFilipino strings where supported

Do not leave screens as technical demonstrations with unfinished controls.

## 7.3 Screen integration

Review the major gameplay screens affected by multi-election support

- Main Menu
- Save Slots
- City Configuration
- City Brief
- Candidate Roster
- Candidate Hub
- Biography
- Promises
- Debate
- RecordsEvidence
- Receipts Board
- CityBook
- Chronicle
- News
- TV
- Ballot
- Winner Reveal
- Living City
- MapHistory
- Term Report
- New Election
- Political History
- Accountability Journal
- Citizen Actions
- Player Progression
- Visit Cities
- Settings

Ensure navigation and contextual information are correct.

For example

A returning mayor's dossier should include prior office history when available.

The City Brief should reflect inherited city conditions during later elections.

The Term Report should clearly indicate which administration has just ended.

A historical report should not accidentally show the current mayor's portrait.

## 7.4 Asset consistency

Use existing approved assets when possible.

Do not replace candidate portraits with unrelated images.

Do not assign different portrait identities to a returning candidate.

Use intentional fallbacks for missing artwork.

Avoid external copyrighted artwork, unverified music, and other assets that would block eventual public release.

If a required new asset cannot be generated or licensed safely, implement a polished placeholder using existing approved game artwork or code-drawn elements and record the limitation.

## 7.5 Accessibility and devices

Verify

- Short Android screens
- Small phones
- Common screen aspect ratios
- Landscapewide layouts where supported
- Android immersive mode
- Statusnavigation bar interactions
- Reduced motion
- High contrast
- Larger text where practical
- Tap targets
- Long candidate and city names
- Text overflow
- Flutter web layout where currently supported

Preserve responsiveness rather than using arbitrary pixel offsets.

---

# MILESTONE 8 — FINAL INTEGRATION, QA, AND RELEASE READINESS

Once the major gameplay features are implemented, perform a comprehensive integration review.

## 8.1 Full gameplay tests

Test at minimum

1. Fresh installationnew save
2. Complete initial city setup
3. Investigate multiple candidates
4. Cast a vote
5. Simulate Administration 1
6. Review Term Report
7. Continue to Election 2
8. Investigate returning and new candidates
9. Vote for the incumbent
10. Complete another administration
11. Continue to Election 3
12. Vote for a different politician
13. Review inherited city state
14. Review persistent accountability records
15. Perform citizen actions where applicable
16. Verify civic progression
17. Close and reopen the application at different stages
18. Verify historical reports
19. Verify save migrations
20. Verify the game still works offline

Add automated tests where suitable.

## 8.2 Deterministic simulation tests

Verify

- Same seedconfigurationhistoryactions → same outcomes
- Different seeds produce meaningful variation
- Old save compatibility
- Candidate identity continuity
- Multiple-term history integrity
- Promiseproject continuity
- Bounded hidden-stat evolution
- Event chain integrity
- Citizen action causality
- Correct electionterm indexing
- No repeated reward farming
- No unbounded save growth

## 8.3 Supabase compatibility

The existing Supabase gallery should remain optional and privacy-safe.

Do not alter its schema unnecessarily.

A newly completed administration may be eligible for publishing a sanitized snapshot.

If adapting gallery support

- Preserve owner-only modification
- Preserve PublicPrivate visibility
- Preserve GETPOSTPATCHDELETE behavior
- Preserve local gameplay independence
- Do not upload entire campaign histories, private notes, hidden politician stats, or raw save data
- Avoid breaking old published snapshots

Treat backend changes as a separate compatibility and security concern.

## 8.4 Commands and verification

Run appropriate verification commands once implementation reaches meaningful checkpoints

- `flutter analyze`
- `flutter test`
- `flutter build web`
- `flutter build apk --release` when Android tooling is available

Avoid wasteful repeated full builds after every trivial change.

If testing fails, diagnose and fix the actual failure.

Do not claim a test passed unless executed successfully.

Distinguish automated results from manual verification that still requires a physical phone.

## 8.5 Release considerations

This is intended to become a publicly released game eventually.

Identify any remaining blockers, including

- Unlicensed background music
- Unverified audio provenance
- Production release signing
- Android performance
- Crash handling
- Save-data resilience
- Privacylegal documentation
- Supabase authentication recovery limitations
- Community moderationsecurity
- App StoreGoogle Play requirements

Do not quietly treat placeholder assets or debug signing as public-release ready.

Actual store submission is NOT part of this task.

---

# IMPORTANT DESIGN RESTRICTIONS

These rules apply to ALL milestones.

## Rule 1 — No runtime generative AI

Do not integrate

- OpenAI API
- Gemini API
- Local LLM inference
- AI-generated live candidate dialogue
- AI-generated political outcomes
- External text-generation dependencies

Use structured procedural generation, deterministic simulation, authored content libraries, and contextual templates.

## Rule 2 — Do not make the player a mayor

The player is a voter and citizen.

They may investigate, vote, organize, question, and influence public pressure.

They must not directly control the mayor's hidden stats, allocate city budgets, or command government agencies.

## Rule 3 — No secretly perfect candidate

Candidates can be capable, ineffective, honest, compromised, inexperienced, charismatic, or contradictory in various combinations.

Do not force every roster to contain obvious goodneutralbad candidates.

Do not expose a candidate recommendation percentage.

## Rule 4 — Respect historical truth

Once a past event has occurred and been observed, its truth must not change because of later generation or navigation.

The system can reveal new context, corrections, or previously unknown evidence, but must retain historical provenance.

## Rule 5 — No arbitrary upgrades

Candidate evolution must come from modeled experiences and consequences.

Player progression should improve civic tools and choices, not magically improve the elected mayor.

## Rule 6 — Maintain player agency

Player choices should have appropriate consequences.

Citizen actions must not guarantee success.

Different choices should produce distinguishable outcomes where the system permits them.

## Rule 7 — Keep politics fictional

Do not introduce real candidates, real parties, or personalized political endorsements.

Fictional controversies and political incentives may be inspired by broad real-world patterns, but all game entities must remain fictional.

## Rule 8 — Do not sacrifice existing features

Preserve established game functionality, including

- Investigation economy
- Evidence relationships
- Candidate biographies
- Debate
- CityBook
- News and TV
- Chronicle
- Receipts Board
- Simulation clock
- Interactive city map
- Settings
- Local saves
- Optional Supabase gallery

Avoid replacing working systems with simplified temporary implementations.

## Rule 9 — No fake completion

Do not report a milestone as complete if

- Navigation is missing
- UI is unfinished
- Saveload is broken
- The screen uses temporary debug widgets
- Required state is not persisted
- Existing tests fail without explanation
- The feature is only partially connected

Clearly report remaining issues.

## Rule 10 — Keep the project maintainable

Prefer

- Clear domain models
- Reusable UI components
- Modular eventcontent libraries
- Stable IDs
- Versioned generators
- Save migrations
- Deterministic tests
- Bounded algorithms
- Readable code
- Small, reviewable changes

Avoid gigantic single-file implementations and unnecessary dependencies.

---

# IMPLEMENTATION ORDER — DO NOT SKIP

Follow this sequence

PHASE A — Persistent multi-election foundation

Complete the full transition from Administration 1 to Election 2 and beyond.

PHASE B — Dynamic candidate careers

Returning politicians retain identities and evolve plausibly.

PHASE C — Resibo ng Bayan

Persistent promises, evidence, political history, and predictions.

PHASE D — Citizen actions

Introduce meaningful limited intervention and adjust simulation architecture safely.

PHASE E — Civic progression

Add useful long-term abilities, milestones, and achievements.

PHASE F — Procedural diversity

Expand content, integrate historical variation, and reduce repetitive events.

PHASE G — UIUX integration

Review and finish all new and modified screens.

PHASE H — Full testing and release-readiness review

Validate all major gameplay loops and document remaining public-release blockers.

The phase order may accommodate small supporting fixes, but do not bypass multi-election continuity in favor of easier cosmetic features.

---

# COMPLETION CRITERIA

The project update is complete when

1. A player can continue the same city beyond Election 1.
2. Multiple elections preserve city state and political history.
3. The candidate roster includes believable returning and new politicians.
4. Returning politicians retain consistent identities and evolve through modeled experiences.
5. Historical promises and outcomes can be inspected.
6. Citizen actions create meaningful, bounded consequences.
7. Player progression provides useful goals and rewards.
8. Procedural content incorporates history and avoids excessive identical repetition.
9. The existing investigation and media systems continue working.
10. Saving and loading works across administrations.
11. The new UI is consistent with the game's established design.
12. Automated verification is performed and results are documented.
13. Public release blockers are identified without falsely claiming release readiness.

Do not require every possible feature or event variation to exist. The goal is a complete, coherent, playable system with sensible extension points.

---

# SESSION COMPLETION INSTRUCTIONS

At the end of each Codex session

1. Update `docsPERSISTENT_CITY_DEVELOPMENT_ROADMAP.md`.
2. Record the current milestone and progress.
3. List changed files.
4. Record tests executed and their results.
5. Describe any blockers or incomplete work.
6. Identify the exact next implementation task.
7. Provide a short continuation message.

If implementation remains incomplete, provide a concise continuation prompt that refers to the roadmap so the next Codex session can resume without repeating this entire master instruction.

Do not mark the full project complete until all required milestones have been honestly evaluated.

---

# BEGIN NOW

First inspect the current codebase and documentation.

Create the persistent roadmap.

Then begin MILESTONE 1 CONTINUOUS MULTI-ELECTION GAMEPLAY.

Implement the smallest complete and testable multi-election vertical slice first

First Election → First Term → Term Report → Second Election → Second Term → Second Term Report → Third Election

Preserve existing saves and features.

After Milestone 1 is implemented and verified, continue through the remaining milestones according to the roadmap and available execution time.

Do not spend the first session merely writing a plan. Begin actual implementation after a focused architectural review.

The long-term objective is to transform Resibo, Please from a single-term civic simulation into a persistent fictional political world where elections, politicians, city conditions, evidence, civic participation, and player decisions create a meaningful evolving history.