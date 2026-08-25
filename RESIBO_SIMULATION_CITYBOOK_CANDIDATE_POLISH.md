# Resibo, Please — Simulation, CityBook, Candidate Variety & UI Polish Pass

> **Purpose:** Focused implementation specification for the next development pass.  
> **Scope:** Living City simulation controls/events, CityBook polish, candidate-background variety, hardcoded/generic UI cleanup, and City Brief cleanup.  
> **Important:** Preserve the existing procedural city, candidate truth, evidence, election, 365-day simulation, Chronicle, News, TV, and save systems unless a change below explicitly requires modification.

---

# 1. Read the Current Project First

Before coding, inspect the current repository and read:

- `README.md`
- `CURRENT_SYSTEM_REPORT.md`
- `GAME_VISION_AND_FEATURES.md`
- candidate generation models
- CityBook models/UI
- Living City simulation clock
- event engine
- map-marker system
- Chronicle / News / TV integrations
- City Brief / City Hub
- localization strings
- theme / custom UI components
- save/persistence schema

Do not assume documentation is newer than the code.

After inspection, give a **short implementation report** explaining:

1. where critical-event auto-opening currently happens;
2. why Year fast-forward currently behaves incorrectly;
3. how CityBook profile pictures are clipped/rendered;
4. how CityBook comment metadata/reactions are currently produced;
5. how candidate career/background archetypes are currently selected;
6. which candidate/campaign screens still contain hardcoded or default-looking UI;
7. which City Brief widget contains the “tap a city marker” helper.

Then implement the changes below.

---

# 2. Living City — Stop Forced Critical Popups

## Current Problem

Critical events can automatically open a popup/modal.

This is disruptive when the player wants to let the city run and inspect events only when they choose.

Critical events may still:

- auto-pause;
- show a visible marker;
- create a notification;
- enter Event History;
- appear in Chronicle/News/TV when eligible.

But they should **not always force-open the event modal**.

## New Event Interruption Setting

Add a player setting such as:

### Critical Event Interruption

Options:

- **Auto Open** — pause and open the event automatically.
- **Pause & Notify** — pause simulation and show notification/marker, but do not open the modal.
- **Notify Only** — simulation continues; show marker/notification.
- **Never Interrupt** — no automatic popup or pause; event still enters history.

Recommended default:

**Pause & Notify**

This keeps critical events noticeable without hijacking the screen.

If the project already has auto-pause settings, integrate this cleanly instead of creating overlapping settings.

## Important Rule

Opening an event should remain a player action unless `Auto Open` is explicitly selected.

---

# 3. Fix the Year Fast-Forward Bug

## Current Problem

The **Year** control currently updates the date/month strangely instead of cleanly progressing to the end of the simulated year.

Fix this at the simulation-clock level.

## Canonical Time State

Use one canonical value such as:

```text
simulationDay = 1..365
```

The displayed:

- month;
- day;
- quarter;
- year progress

must be **derived from the canonical simulated day**, not independently incremented state that can become desynchronized.

## Year Button Behavior

Treat **YEAR** as a fast-forward command rather than “add an arbitrary number of months.”

Expected flow:

```text
Player presses YEAR
        ↓
Process remaining simulated days
in bounded logical batches
        ↓
Respect event generation and chains
        ↓
If interruption settings require a stop,
pause on qualifying event
        ↓
Player resumes YEAR if desired
        ↓
Reach Day 365 exactly
```

Requirements:

- never overshoot Day 365;
- never wrap months incorrectly;
- do not lose events during batching;
- do not skip project progression;
- do not change results simply because Year speed was selected;
- Day/Week/Month/Year must use the same simulation engine;
- only processing speed differs.

Add tests specifically for:

- Day 11 → YEAR → Day 365;
- Month mode → YEAR midway;
- pause during Year fast-forward;
- auto-pause during Year fast-forward;
- resume afterward;
- end-of-year report triggers once;
- no duplicated events from batch boundaries.

---

# 4. Add Persistent “World Conditions”

The Living City should feel more like a world simulation rather than only reacting to its starting issues.

Add a structured **World Condition / External Pressure** layer.

These are temporary conditions that may last several simulated days or weeks and influence the event engine.

Examples:

## Weather Conditions

- Sunny Stretch
- Heavy Rain
- Severe Thunderstorms
- Heat Wave
- Strong Typhoon
- Monsoon Period

## Economic Conditions

- Oil Price Crisis
- Fuel Price Drop
- Supply Shortage
- Regional Economic Slowdown
- Business Expansion Period
- Construction Material Price Increase

## Infrastructure / Utility Conditions

- Regional Power Instability
- Water-Supply Pressure
- Telecommunications Outage
- Port/Logistics Disruption

## Public / Seasonal Conditions

- Festival Week
- School Opening Period
- Holiday Rush
- Flu/Dengue Season
- Exam/Graduation Period

These must be fictional game conditions, not claims about real current events.

---

# 5. World Conditions Must Affect Probabilities, Not Script Outcomes

Example:

```text
STRONG TYPHOON
Duration: 4 simulated days
```

It may modify:

- flood-event probability ↑
- road-closure probability ↑
- power-interruption probability ↑
- water-contamination probability ↑
- transport reliability ↓
- project construction speed ↓
- emergency-response checks ↑

But it should NOT automatically mean:

```text
Day 2 = flood
Day 3 = hospital crisis
```

The normal procedural engine still determines what actually occurs.

Another example:

```text
OIL PRICE CRISIS
Duration: 30 simulated days
```

Possible modifiers:

- transport cost pressure ↑
- cost-of-living pressure ↑
- logistics/business pressure ↑
- public sentiment events ↑
- market-price stories ↑
- administration budget pressure slightly ↑
- public-transport policy relevance ↑

Another:

```text
SUNNY STRETCH
Duration: 10 days
```

Possible modifiers:

- flood probability ↓
- outdoor/festival events ↑
- construction progress slightly ↑
- heat-related event probability may rise if prolonged

World conditions should create **new possibility spaces**, not predetermined stories.

---

# 6. Optional Sandbox / “World Events” Control

The player remains primarily the voter/observer in normal gameplay.

Do NOT force god-mode controls into the canonical simulation.

However, create or prepare an optional:

## Sandbox / Scenario Controls

This may live behind:

- a clearly labeled Sandbox button;
- developer/testing menu;
- optional post-game mode;
- settings toggle if appropriate.

Possible manual actions:

- Trigger Strong Typhoon
- Trigger Sunny Period
- Trigger Oil Crisis
- Trigger Economic Boom
- Trigger Regional Power Problem
- Trigger Festival Week

This allows the player to experiment with the city like a lightweight WorldBox-style simulation.

### Important

Manual injected conditions should be marked internally as:

```text
source = sandbox
```

They should not pretend to be naturally rolled world history.

If Sandbox mode is active, the game may label the run accordingly if needed.

Do not let this feature interfere with ordinary deterministic saves.

If adding a full player-facing Sandbox UI is too large for this pass, implement the **WorldCondition architecture and a developer/debug injector first**, document the future public Sandbox UI, and keep normal procedural generation working.

---

# 7. Recommended Additional Living-City Mechanics

Add only where they fit cleanly.

The most useful additions are:

## A. Forecast / Current Conditions Strip

A small compact simulation element can show:

```text
CURRENT CONDITION
Strong Rain • 3 days remaining
```

or:

```text
Sunny • No major external pressure
```

Do not turn this into a real weather app.

## B. Event Chain History

When an event belongs to a continuing chain, let the player inspect previous stages.

Example:

```text
Central Avenue
JAN 12 — Construction began
FEB 04 — Traffic worsened
MAR 17 — Project delayed
```

## C. Emerging Issue Creation

A major chain may create a **new active city issue** that did not exist at world creation.

Example:

```text
Repeated power failures
        ↓
Business disruptions
        ↓
New active issue:
Utility Reliability
```

Only do this for meaningful persistent situations.

## D. Recovering / Resolved Issues

Issues should also be able to:

- improve;
- become dormant;
- resolve;
- return later under new conditions.

The city should not only accumulate problems forever.

---

# 8. CityBook Candidate Profile Picture Fix

## Current Problem

Candidate CityBook profile photos are visibly cropped incorrectly and the square/white image background can be seen inside the circular profile picture.

Fix this globally.

## Requirements

Use a proper reusable profile-avatar component.

Conceptually:

```dart
ClipOval(
  child: Image.asset(
    candidatePortrait,
    fit: BoxFit.cover,
  ),
)
```

But follow existing project architecture.

Requirements:

- portrait fully covers circular frame;
- no visible square corners;
- no white square background;
- consistent crop across candidates;
- correct focal positioning;
- no stretching;
- reusable for CityBook comments/profile/avatar contexts.

If portrait source assets contain unwanted baked white backgrounds:

1. prefer a proper transparent-background version if available;
2. otherwise crop/fill the frame so the square edge cannot appear;
3. regenerate/clean the portrait asset only if necessary.

Do not independently regenerate candidate identities if an asset edit can preserve their existing appearance.

---

# 9. Remove Overly Obvious CityBook “Suspicious Account” Hints

## Current Problem

Some comments/accounts explicitly reveal clues such as:

- account is new;
- comment repeated campaign wording;
- coordinated-campaign warning;
- similar suspicious labels.

These give the player too much of the answer.

Remove these obvious player-facing hints.

## Important

Do NOT necessarily delete the hidden metadata.

The generator may still internally know:

- account age archetype;
- coordinated behavior;
- campaign affiliation probability;
- repeated wording;
- troll/volunteer/skeptic archetype.

But do not render labels that effectively say:

> “This account is suspicious.”

The player should infer suspicious behavior from:

- wording;
- repeated talking points;
- comment patterns;
- article/evidence context;
- later investigations.

Keep the game neutral.

---

# 10. CityBook Comment Reactions

Add a Facebook-like reaction summary to comments.

## Presentation

At the bottom-left edge of a comment bubble, show:

- up to **3 dominant reaction icons**;
- total reaction count.

Example conceptually:

```text
😂 ❤️ 👍  284
```

No explanatory labels such as:

```text
Laugh: 50
Angry: 20
```

The player recognizes the icons visually.

Use the existing CityBook reaction icon language if available.

Potential reaction types:

- Like
- Love
- Laugh
- Wow/Shock
- Sad
- Angry
- optional existing Resibo reaction if already supported

Do not redesign the whole CityBook reaction system if post-level reactions already work.

---

# 11. Procedural Comment Reaction Logic

Comment reactions must be generated procedurally and deterministically from the comment + parent post.

Do NOT assign thousands of reactions randomly with no relation to context.

Inputs may include:

- parent post engagement/reach;
- candidate attention level;
- comment archetype;
- comment sentiment;
- comment tone;
- agreement/disagreement with parent post;
- sarcasm/humor;
- controversy visibility;
- seeded randomness.

## Tone → Reaction Bias Examples

### Sarcastic / Funny

Bias toward:

- Laugh
- Like
- Wow

### Angry criticism

Bias toward:

- Angry
- Like
- Sad

### Sympathetic / Emotional

Bias toward:

- Love
- Sad
- Like

### Supportive

Bias toward:

- Like
- Love

### Shocking allegation

Bias toward:

- Wow
- Angry
- Laugh depending on tone

### Neutral factual comment

Mostly:

- Like
- occasional Wow
- lower engagement

These are weights, not fixed outputs.

---

# 12. Comment Reaction Count Scaling

Reaction counts should approximately fit the scale of the parent post.

Examples:

If parent post has:

```text
78 reactions
```

a normal comment should not casually have:

```text
12,000 reactions
```

If parent post has:

```text
48,000 reactions
```

top comments may plausibly have:

- thousands;
- hundreds;
- dozens.

Generate a distribution where:

- a few comments may perform unusually well;
- most comments have less engagement than the post;
- some have very little engagement;
- some have zero visible reactions.

### Important

Not every comment needs reactions.

Recommended rough target:

- majority have some reactions;
- a meaningful minority have none/very few.

This makes the feed feel natural.

---

# 13. Comment Reaction Dominance

Display the top three reaction types by count.

Example internal distribution:

```text
Laugh: 120
Like: 84
Love: 37
Angry: 11
Sad: 2
```

UI:

```text
😂 👍 ❤️  254
```

The ordering should come from actual generated counts.

Do not hardcode the same three icons for every comment.

Persist generated reaction summaries so reopening CityBook does not reroll them.

---

# 14. Expand Procedural Candidate Backgrounds Beyond Politicians

## Current Problem

Generated candidates frequently feel like they were already politicians/public officials before running.

Increase background variety.

The game must be capable of generating **true political outsiders**.

Possible outsider backgrounds:

- famous fictional actor/actress;
- television/media personality;
- business owner;
- corporate executive;
- entrepreneur;
- doctor;
- teacher/professor;
- lawyer;
- engineer;
- athlete;
- community organizer;
- NGO/nonprofit leader;
- content/media personality;
- retired police/public-safety professional;
- labor leader.

Do not use real celebrities.

---

# 15. Candidate Career-Origin Categories

Give candidate generation a higher-level origin type.

Example:

```text
careerOrigin:
- career_politician
- public_administrator
- professional
- business
- celebrity_media
- community
- advocacy
- public_safety
```

Then generate history appropriate to that origin.

## Career Politician

May have:

- previous elections;
- council history;
- many public projects;
- large evidence footprint;
- political controversies.

## Business Owner

May have:

- company history;
- employment claims;
- business controversies;
- donations/relationships;
- little direct government record.

## Actor / Celebrity

May have:

- media history;
- endorsements;
- charities;
- old interviews/posts;
- huge CityBook engagement;
- very limited administrative record.

## Professional

May have:

- technical achievements;
- licenses;
- professional associations;
- limited campaign experience.

## Community Organizer

May have:

- grassroots projects;
- advocacy;
- community endorsements;
- limited formal-budget experience.

---

# 16. Information Footprint Must React to Candidate Origin

This is important.

Do NOT generate the same kind of dossier for every candidate.

A celebrity outsider may have:

- huge CityBook presence;
- old interviews;
- many public opinions;
- endorsements;
- few government procurement records.

A business owner may have:

- company/project history;
- employment statistics;
- business disputes;
- donation/contract relationships;
- limited election history.

A career politician may have:

- public records;
- projects;
- budgets;
- voting history;
- many controversies;
- old campaign promises.

A community organizer may have:

- community testimonials;
- advocacy materials;
- few institutional records.

Candidate origin should affect:

- Biography sections;
- CityBook volume;
- Records categories;
- News history;
- Debate experience;
- public attention;
- evidence availability.

Do not fabricate government records for someone who never held public office merely because the old evidence template expects them.

---

# 17. Outsider Candidate Frequency

Do NOT hardcode:

```text
Candidate #4 is always an actor.
```

Use procedural weighted roster generation.

The system should allow:

- no outsider in some elections;
- one outsider commonly;
- occasionally two;
- very rarely an unusually outsider-heavy field if weights allow.

Prevent all five candidates from accidentally using essentially the same career origin unless the seed intentionally produces a plausible unusual field and anti-duplication rules permit it.

The goal is **variety**, not a guaranteed celebrity slot.

---

# 18. Outsider Quality Must Still Be Independent

Do NOT assume:

```text
celebrity = bad
business owner = corrupt
career politician = experienced/good
```

Generate quality independently.

Possible combinations:

- competent business owner;
- incompetent business owner;
- sincere actor with good advisers;
- celebrity populist with no feasible policy;
- brilliant technical outsider;
- corrupt career politician;
- highly effective career politician;
- honest but inexperienced organizer.

Background affects available evidence and experience, not moral verdict.

---

# 19. Scan for Hardcoded Player-Facing Text

There are still player-facing strings that appear visually inconsistent/hardcoded, including areas such as Campaign Hub and **Then vs Now**.

Example from the current build:

```text
View context
```

appears as plain green text and looks disconnected from the established game UI.

Perform a focused scan of touched candidate/campaign pages for:

- hardcoded strings;
- unlocalized labels;
- default text buttons;
- raw `TextButton`;
- Material-green/blue text;
- default fonts;
- default Flutter containers/cards;
- generic icons;
- generic dropdowns;
- inconsistent link styling.

Do NOT redesign every screen in the application.

Clean the relevant candidate/Campaign Hub/Then-vs-Now/CityBook areas encountered during this pass.

---

# 20. Then vs Now — Fix “View Context”

Replace the plain green `View context` presentation with a proper Resibo-styled interaction.

Possible design:

- small parchment button;
- compact outlined game button;
- receipt/tab-like control;
- custom icon + label;
- expandable contextual strip.

It should visually belong to the same game as:

- Bio;
- Promises;
- Debate;
- Records.

Use localized text.

No raw default Material link styling.

---

# 21. Candidate UI Styling Rule

Every candidate-facing screen should preserve the game art direction.

Do not leave:

- default Material blue;
- default green TextButton;
- generic white cards;
- default system font where custom typography is expected;
- unstyled circular progress indicators;
- default dialogs;
- default Flutter buttons.

Reuse existing:

- dark outlines;
- cream/parchment surfaces;
- chunky game controls;
- established typography;
- satirical/document visual language.

---

# 22. City Brief / Pre-Election City Page Cleanup

## Current Problem

The city artwork includes the helper:

> “Tap a city marker to open its concern file.”

This is no longer necessary and adds clutter.

Remove this helper from the City page.

Do not replace it with another permanent tutorial banner.

If marker interaction requires onboarding, teach it once through:

- first-run tooltip;
- How to Play;
- temporary tutorial overlay.

Then let the artwork breathe.

---

# 23. Enlarge the City Name

After removing the helper instruction, improve the prominence of the current city name.

The City Brief should immediately communicate:

> “This is MY generated city.”

Make the city name:

- larger;
- visually important;
- consistent with game typography;
- responsive to longer procedural names.

Do not let extremely long names overflow.

Use adaptive sizing/truncation only when necessary.

Keep the main city artwork visible and uncluttered.

---

# 24. City Map Marker Presentation

On the pre-election City Brief:

- markers can remain;
- do not add unnecessary instructional text;
- avoid marker crowding;
- use existing custom art direction;
- keep labels clean.

Do not confuse this frozen pre-election map with the later Living City simulation map.

---

# 25. Preserve Procedural Truth

All changes in this pass must preserve the project's core rule:

> **Algorithm creates truth. Presentation describes truth.**

CityBook reactions must not rewrite candidate truth.

Public popularity must not become integrity.

World conditions influence event probabilities but do not directly dictate narrative outcomes.

Candidate career origin must not dictate morality.

Manual Sandbox conditions must not silently masquerade as naturally generated canonical events.

---

# 26. Save/Persistence Changes

Persist where necessary:

- critical interruption preference;
- generated comment reaction summaries;
- candidate career-origin data;
- world conditions;
- world-condition duration/state;
- sandbox-source flag where applicable.

Do not reroll CityBook comment reactions on every open.

Do not regenerate candidate origins on reload.

Do not duplicate world conditions after save/load.

Use save migrations if schema changes require them.

---

# 27. Procedural Determinism

Continue using derived world seeds.

Create isolated seeds for new systems where appropriate, for example:

```text
worldSeed
├── candidateOrigins
├── cityBookCommentReactions
├── worldConditions
└── externalEventTiming
```

Adding reaction generation must NOT reroll:

- candidate identity;
- portrait;
- biography;
- city problems;
- simulation event history.

World conditions should use deterministic generation during ordinary gameplay.

Sandbox-injected conditions are explicit user actions and should be stored as such.

---

# 28. Tests

Add/update tests for:

## Critical Event Behavior

- Auto Open opens modal.
- Pause & Notify pauses without opening.
- Notify Only does not pause/open.
- Never Interrupt does neither.
- Event still enters history in every mode.

## Year Fast Forward

- reaches exactly Day 365;
- does not corrupt month/day;
- respects interruption preference;
- resumes correctly;
- preserves event generation;
- produces final report once.

## World Conditions

- condition duration decreases correctly;
- modifiers affect event weights;
- expired conditions stop modifying weights;
- same seed produces same natural world-condition history;
- sandbox conditions are tagged/persisted.

## CityBook

- avatar crop contains no square background;
- reaction totals are deterministic;
- top three reaction icons reflect generated counts;
- reaction counts scale reasonably with parent post engagement;
- some comments may have zero reactions;
- suspicious-account labels are not rendered.

## Candidate Origins

- outsider careers can generate;
- career politician still generates;
- roster is not hardcoded to contain a specific outsider;
- information footprint/content types adapt to career origin;
- candidate quality remains independent of career origin.

## Localization/UI

- no new hardcoded English string in localized candidate components;
- View Context uses localization;
- removed City Brief helper does not leave layout gap.

---

# 29. Performance

Keep this pass lightweight.

Do not introduce:

- continuous heavy calculations for reactions;
- recalculation of all CityBook reactions every frame/open;
- large unnecessary caches;
- expensive world-condition evaluation every render.

Generate structured values once when appropriate and persist/cache them.

The existing simulation tick should remain the driver for world-condition duration/effects.

---

# 30. Documentation

Update:

- `GAME_VISION_AND_FEATURES.md`
- `CURRENT_SYSTEM_REPORT.md`

Document what is actually implemented.

Add the following design directions to the game vision:

- configurable critical-event interruption;
- world/external conditions;
- optional Sandbox/Scenario event injection;
- comment-level CityBook reactions;
- broader candidate career origins and political outsiders;
- cleaned candidate UI/localization.

Do not claim the public Sandbox UI is implemented if only the underlying architecture/debug controls were completed.

---

# 31. Recommended Implementation Order

Work approximately in this order:

1. Inspect/report current architecture.
2. Fix Year fast-forward bug first.
3. Add critical-event interruption preference.
4. Add WorldCondition data model.
5. Integrate procedural World Conditions into event weighting.
6. Add developer/sandbox condition injection if feasible.
7. Fix CityBook avatar clipping.
8. Remove explicit suspicious-account/comment hints.
9. Add deterministic comment reaction generation.
10. Add comment reaction UI.
11. Expand candidate career-origin generator.
12. Adapt generated information footprint/content to origin.
13. Scan and clean hardcoded/default candidate UI.
14. Fix Then vs Now “View Context.”
15. Remove City Brief marker helper.
16. Increase City Brief city-name prominence.
17. Add tests.
18. Run:
    - `flutter analyze`
    - `flutter test`
    - `flutter build web`
19. Update documentation.

---

# 32. Final Experience Target

The Living City should be something the player can leave running without the interface constantly interrupting them.

A strong typhoon may form.

The player sees:

```text
STRONG TYPHOON
3 simulated days remaining
```

Flood risk rises.

A road project slows.

An unrelated community event may still happen elsewhere.

The player may let the simulation continue or pause and inspect events.

Critical developments can notify without forcibly opening a modal.

Year fast-forward reliably reaches the end of the year.

Meanwhile, CityBook should feel much more like a believable social platform:

- clean circular candidate portraits;
- no game-generated labels shouting that an account is suspicious;
- comments have varied social reactions;
- popular posts produce plausible high-engagement comments;
- smaller posts have smaller engagement;
- sarcasm tends to receive Laugh reactions;
- anger tends to attract Angry reactions;
- not every comment is popular.

Candidate fields should also become more surprising.

The player might encounter:

- a career politician;
- a doctor;
- a business owner;
- an actor;
- a community organizer.

Their available information should reflect the lives they actually had.

Finally, all touched UI must look intentionally designed for **Resibo, Please**, not like raw Flutter components.

The goal of this pass is not simply more features.

It is to make the existing game feel:

- less mechanically obvious;
- less intrusive;
- more socially believable;
- more procedurally varied;
- more polished;
- more alive.
