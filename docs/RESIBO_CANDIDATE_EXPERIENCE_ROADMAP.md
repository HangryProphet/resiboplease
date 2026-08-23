# Resibo, Please — Candidate Experience Redesign Roadmap

> **August 2026 implementation update:** The candidate-facing screens described
> here are implemented and now consume a version-1 procedural five-candidate
> election in normal Create City runs. The original Maya/Julian/Victor catalog
> remains as a reference fixture. The later procedural-generation task also
> superseded this roadmap's temporary no-final-art restriction: the portrait
> pool now contains exactly seven approved reusable identities. See
> `PROCEDURAL_GENERATION.md` and `CURRENT_SYSTEM_REPORT.md` for current behavior.
>
> **Document scope:** Candidate-facing gameplay only  
> **Primary focus:** How players discover, judge, compare, and emotionally react to candidates  
> **Out of scope:** Term simulation, city-map interactions, multiplayer cities, and long-term administration systems  
> **Implementation rule:** Codex must prepare all image placements and asset interfaces, but must **not generate, download, or embed final candidate artwork yet**.

---

# 1. Purpose

The candidate-investigation phase is the central identity of **Resibo, Please**.

The goal is not to turn the candidate page into a larger database. The goal is to make investigating candidates feel like following a political controversy, watching a group-chat argument unfold, collecting receipts, and deciding which imperfect—or possibly dangerous—person deserves power.

The player should feel:

1. curiosity;
2. amusement;
3. suspicion;
4. anger or disbelief;
5. uncertainty;
6. pressure to decide.

The redesign must support different player types:

- players who prefer quick summaries;
- players who enjoy drama and scrolling;
- players who want detailed evidence;
- players who want to compare contradictions;
- players who like collecting and organizing information.

The existing evidence system should remain, but its presentation, pacing, and interconnections should change.

---

# 2. Core Design Direction

The candidate section should no longer feel primarily like:

> Candidate → category list → open many text files → vote

It should feel like:

> Candidate enters the campaign → the player sees claims and drama → suspicious leads appear → the player checks receipts → contradictions become visible → the player votes

The page should behave like a **campaign investigation hub**, not only a dossier archive.

---

# 3. Main Experience Structure

Each candidate receives a dedicated **Candidate Hub** with three main sections:

1. **Pulse**
2. **Dossier**
3. **Debate**

A fourth global feature exists across all candidates:

4. **Receipts Board**

These sections serve different player preferences without creating separate game modes.

---

# 4. Candidate Hub

The Candidate Hub is the landing page after selecting a candidate.

## 4.1 Header

The header should contain:

- candidate portrait slot;
- candidate name;
- party name;
- campaign slogan;
- current position being contested;
- short public identity;
- dossier progress;
- bookmark or pin control;
- tabs for Pulse, Dossier, and Debate.

Do not display:

- match percentage;
- overall score;
- recommendation;
- hidden integrity value;
- hidden corruption value;
- hidden policy rating;
- “good” or “bad” label.

## 4.2 Public identity

The header may display one short identity line such as:

- “Former health administrator turned reform candidate”
- “Business executive promising rapid job creation”
- “Quiet auditor campaigning on institutional repair”

This is not a score. It is a public-facing description.

## 4.3 Unresolved questions

The Candidate Hub may show one to three unresolved questions.

Examples:

- “Where will the housing budget come from?”
- “Did the employment program create permanent jobs?”
- “Why did three contractors donate to the campaign?”
- “Can this candidate secure council support?”

These should encourage investigation without revealing the answer.

---

# 5. Three Reading Depths

Every major content item should support three levels of reading.

## 5.1 Glance

Visible immediately:

- image placeholder or icon;
- short headline;
- one-sentence summary;
- source;
- date;
- evidence type;
- optional public-attention indicator.

The important topic should be understandable within a few seconds.

## 5.2 Inspect

Opened card:

- two to three short paragraphs;
- key figures;
- candidate response;
- missing context;
- related city issue;
- linked evidence.

## 5.3 Deep Dive

Optional detailed view:

- complete record;
- timeline;
- budget table;
- source details;
- related claims;
- contradictions;
- fact-check findings;
- player notes.

## 5.4 Rule

The main idea must be understandable from the Glance layer, but a better judgment should require Inspect or Deep Dive.

This allows casual players to continue while rewarding careful readers.

---

# 6. Pulse — Fast Campaign Feed

## 6.1 Purpose

Pulse is the fast-moving, entertaining surface of the candidate experience.

It should feel closer to scrolling through a campaign season than opening a formal archive.

## 6.2 Content types

Pulse may display:

- campaign advertisements;
- short fictional news stories;
- speech clips;
- social-media posts;
- polls;
- endorsements;
- resident reactions;
- protest reactions;
- scandal headlines;
- correction notices;
- fact-check alerts;
- campaign memes;
- public-event photos;
- short candidate statements.

## 6.3 Feed card anatomy

Each card may contain:

- image slot;
- source badge;
- headline;
- one-sentence summary;
- timestamp or fictional date;
- candidate tag;
- evidence type;
- open-details action;
- bookmark action;
- compare action;
- related-receipt indicator.

## 6.4 Feed pacing

The feed should not show every negative file first.

Recommended emotional order:

1. strongest public appeal;
2. humanizing story;
3. major promise;
4. complication;
5. defense;
6. contradiction;
7. unresolved question.

This prevents candidates from becoming predictable immediately.

## 6.5 Free versus investigation-cost content

Recommended rule:

- surface Pulse content is free to view;
- deeper verification may cost an investigation point;
- high-value investigations may cost two points;
- opening a discovered follow-up file may be free.

Example:

- campaign ad: free;
- budget breakdown: 1 point;
- donor-network investigation: 2 points;
- public fact-check unlocked from the claim: free after discovery.

---

# 7. Dossier — Structured Evidence Archive

## 7.1 Purpose

The Dossier remains the serious evidence center.

It should preserve the current evidence categories while organizing them more clearly.

## 7.2 Suggested sections

- Overview
- Platform
- Public Records
- Financial Records
- Campaign Material
- Public Claims
- Fact-Checks
- Debate References
- Controversies
- Bookmarks

## 7.3 Existing evidence categories to retain

- profile;
- platform;
- campaign advertisement;
- public record;
- budget document;
- social-media post;
- fact-check;
- controversy;
- debate answer.

## 7.4 Dossier item behavior

Each item should support:

- unopened state;
- opened state;
- bookmarked state;
- related-item state;
- contradiction state;
- fact-check available state;
- investigation cost;
- source-reliability cue.

## 7.5 Avoid information dumping

Do not show all detailed evidence at once.

Use:

- collapsible cards;
- filters;
- source badges;
- short summaries;
- visual grouping;
- progressive disclosure.

---

# 8. Debate — Group-Chat-Style Political Drama

## 8.1 Purpose

The Debate section is the primary entertainment feature of the redesign.

It should feel like scrolling through a heated group chat while still being an organized civic debate.

This is the strongest proposed feature and should be implemented before procedural generation.

## 8.2 Presentation

Use a vertically scrolling message history.

Participants:

- moderator;
- candidate A;
- candidate B;
- candidate C;
- optional fact-check bot or public-record reference;
- optional crowd or resident reaction layer.

Messages may include:

- opening statements;
- direct responses;
- interruptions;
- rebuttals;
- sarcasm;
- evasions;
- clarifications;
- attacks;
- referenced evidence;
- follow-up questions.

## 8.3 Debate topic structure

Recommended MVP:

- 3 debate topics;
- 8–15 messages per topic;
- one topic focused on each urgent city problem;
- one final accountability question.

Example topics:

- water contamination;
- unemployment;
- public-clinic capacity;
- budget feasibility;
- integrity;
- climate preparedness.

## 8.4 Message interactions

Each message may support:

- tap to open referenced evidence;
- bookmark statement;
- pin as receipt;
- compare with previous statement;
- mark as suspicious;
- view speaker profile;
- view public reaction;
- jump to related dossier item.

## 8.5 Debate styles

Each candidate should have a rhetorical style:

- technical;
- charismatic;
- emotional;
- sarcastic;
- aggressive;
- evasive;
- calm;
- statistic-heavy;
- story-driven;
- attack-focused;
- conciliatory.

Rhetorical style must not directly indicate truthfulness.

A dishonest candidate may debate well.  
An honest candidate may communicate poorly.

## 8.6 Debate algorithm

The debate should be generated from structured facts, not random prose.

For each topic:

1. identify the city problem;
2. identify each candidate’s relevant policy;
3. select one claim per candidate;
4. select one weakness or contradiction;
5. generate the moderator question;
6. generate initial responses;
7. generate at least one rebuttal pair;
8. attach evidence references;
9. validate that messages match candidate truth;
10. save the final debate history.

## 8.7 Debate message model

```json
{
  "id": "debate_message_001",
  "topic_id": "water_security",
  "speaker_id": "candidate_maya",
  "message_type": "claim",
  "text": "We will deploy mobile testing teams within the first month.",
  "referenced_evidence_ids": ["evidence_mobile_testing_plan"],
  "contradicted_by_ids": ["evidence_budget_gap"],
  "public_reaction": "mixed",
  "bookmarkable": true,
  "sequence": 4
}
```

---

# 9. Receipts Board

## 9.1 Purpose

The Receipts Board transforms reading into collection and comparison.

The player should be able to collect important claims and connect them to evidence.

## 9.2 Receipt types

- supported claim;
- contradicted claim;
- partially supported claim;
- missing context;
- unresolved allegation;
- promise without funding;
- accomplishment with hidden cost;
- campaign statement versus past record;
- debate statement versus fact-check.

## 9.3 Player actions

The player may:

- pin a claim;
- attach supporting evidence;
- attach contradicting evidence;
- write a short private note;
- compare two candidates;
- mark an unresolved question;
- sort by city issue;
- review receipts before voting.

## 9.4 Receipt connection example

```text
CLAIM
“Created 12,000 jobs.”

SUPPORTED BY
Employment report confirms 12,000 positions.

COMPLICATED BY
Only 3,400 positions lasted longer than six months.

CANDIDATE RESPONSE
“Temporary work kept families afloat during recovery.”
```

## 9.5 Avoid a one-answer puzzle

The board should not always mark connections automatically.

Some links may be suggested, but the player should still decide what matters.

---

# 10. Candidate Quality and Bad-Candidate Possibility

## 10.1 Important rule

The generator must allow genuinely bad candidates.

Not every candidate needs to be balanced into an equal mixture of good and bad traits.

Possible candidates include:

- highly capable but corrupt;
- honest but ineffective;
- charismatic and dangerous;
- well-meaning but unrealistic;
- competent and mostly good;
- genuinely poor in most important areas;
- manipulative and self-serving;
- strong only because the city’s current problem happens to match one skill.

## 10.2 Candidate quality bands

Suggested hidden quality bands:

- strong;
- capable but compromised;
- mixed;
- weak;
- dangerous.

These are internal generation bands and must never be shown to players.

## 10.3 Roster distribution

Do not force every election to contain:

- one good;
- one average;
- one bad.

Allow varied rosters:

- three mixed candidates;
- one strong and two weak;
- three poor candidates;
- two capable but compromised candidates;
- one dangerous candidate who is highly charismatic;
- one obviously poor candidate alongside two difficult choices.

The world should sometimes produce an election where every option is disappointing.

## 10.4 Bad does not always mean immediately obvious

A dangerous candidate may still have:

- a popular policy;
- a real accomplishment;
- strong communication;
- genuine supporters;
- understandable appeal.

However, the system may also generate a candidate who is clearly bad after minimal investigation.

That possibility is part of procedural variety.

## 10.5 No artificial fairness

Do not rewrite every candidate to be equally defensible.

The player’s challenge is to judge the roster generated for that world.

---

# 11. Candidate Truth Graph

## 11.1 Purpose

All candidate content should originate from a structured truth graph.

Do not generate disconnected articles, claims, and scandals independently.

## 11.2 Candidate truth data

Each candidate should define:

- background;
- motivations;
- policy priorities;
- leadership abilities;
- implementation skill;
- integrity;
- corruption risk;
- coalition skill;
- crisis response;
- budget discipline;
- communication style;
- public image;
- donors;
- allies;
- enemies;
- accomplishments;
- failures;
- controversies;
- promises;
- disputed claims;
- hidden risks.

## 11.3 Multi-perspective content

A single truth may create multiple artifacts.

Example truth:

> A candidate completed a flood-control project, but it exceeded budget and covered only wealthy districts.

Generated artifacts:

- campaign ad: “Flooding reduced by 40%.”
- public record: project completed;
- budget document: cost exceeded estimate;
- resident story: one district improved;
- opposition post: poorer districts ignored;
- fact-check: technically true but incomplete;
- debate answer: candidate defends prioritization.

## 11.4 Content relation types

Every evidence item should support one or more relations:

- supports;
- contradicts;
- adds context;
- updates;
- corrects;
- disputes;
- references;
- reveals consequence;
- exposes missing information.

---

# 12. Procedural Name Rules

## 12.1 Randomized names

Candidate names must be procedurally selected from configured fictional name pools.

## 12.2 No repetition inside one world

Once a full candidate name has appeared in a world, it must never appear again in that world.

Store used names in world save data.

```json
{
  "used_candidate_names": [
    "Maya Vargas",
    "Julian Pratt",
    "Victor Chen"
  ]
}
```

## 12.3 Recommended uniqueness levels

Prevent repetition of:

- full name;
- campaign slogan;
- party name within the same election;
- portrait identity key;
- candidate ID.

Optional:

- first names or surnames may eventually repeat after many generations;
- full-name duplication remains prohibited within one world.

## 12.4 Candidate ID

Do not use the name as the database ID.

Use a generated UUID or seeded ID.

```text
candidate_8f3a9c2e
```

## 12.5 Exhausted name pool

If the pool becomes exhausted:

1. generate a new unused first-name and surname combination;
2. check against world-used names;
3. retry with a maximum attempt count;
4. use a deterministic fallback generator;
5. never silently duplicate a full name.

---

# 13. Candidate Portrait Strategy

## 13.1 Current implementation rule

Do not generate final candidate portraits during this roadmap implementation.

Codex should only prepare:

- image slots;
- aspect ratios;
- asset identifiers;
- loading behavior;
- fallback behavior;
- transition behavior;
- accessibility labels.

## 13.2 Placeholder component

Create a reusable Flutter component such as:

```text
CandidateImageSlot
```

Suggested properties:

```dart
CandidateImageSlot(
  candidateId: candidate.id,
  assetKey: candidate.portraitAssetKey,
  aspectRatio: 4 / 5,
  fit: BoxFit.cover,
  semanticLabel: candidate.displayName,
  fallbackStyle: CandidateFallbackStyle.silhouette,
)
```

## 13.3 Placeholder appearance

Use a deliberate placeholder, not a broken-image icon.

Recommended placeholder:

- candidate-specific gradient;
- simple neutral silhouette;
- party-color border;
- candidate initials;
- small “ART PENDING” label in developer mode only.

Do not show “ART PENDING” in release builds.

## 13.4 Required portrait slots

Prepare slots for:

- roster thumbnail;
- Candidate Hub portrait;
- debate avatar;
- election card portrait;
- receipt thumbnail;
- term-leader portrait;
- result-summary portrait.

All slots should reference the same candidate identity.

## 13.5 Portrait states

Prepare asset keys for future use:

- neutral;
- campaign;
- debate;
- concerned;
- victorious;
- scandal, optional.

Only `neutral` is required initially.

## 13.6 Asset path convention

```text
assets/images/candidates/<candidate_identity_key>/
├── neutral.webp
├── campaign.webp
├── debate.webp
├── concerned.webp
└── thumbnail.webp
```

The folder may not exist yet. The code must use fallback placeholders until assets are added.

## 13.7 No runtime image generation yet

Do not:

- call an image-generation API;
- generate portraits from Codex;
- embed base64 images;
- download random online images;
- use real-politician photos;
- block UI development while waiting for art.

---

# 14. Image Placement Preparation

## 14.1 Feed image slots

Prepare reusable content-media slots with aspect ratios such as:

- 16:9 for news;
- 4:3 for reports;
- 1:1 for social posts;
- portrait for candidate appearances.

## 14.2 Evidence media model

```json
{
  "media_type": "image",
  "asset_key": "evidence_water_project_photo",
  "aspect_ratio": 1.777,
  "alt_text": "Candidate visiting a repaired water facility",
  "caption": "Campaign photograph released during the second week.",
  "is_available": false
}
```

## 14.3 Missing-asset behavior

When `is_available` is false:

- render a themed placeholder;
- preserve final layout size;
- show a content-type icon;
- keep the caption;
- avoid layout jumps.

## 14.4 Same-image-different-framing support

Prepare evidence items so multiple cards may reference the same image asset with:

- different crop;
- different caption;
- different source;
- different interpretation.

This will later support media-literacy scenarios.

---

# 15. Recommended Flutter Components

Create reusable components:

```text
CandidateHubPage
CandidateHeader
CandidateSectionTabs
CandidatePulseFeed
CampaignFeedCard
EvidencePreviewCard
EvidenceDeepDiveSheet
CandidateDossierView
DebateChatView
DebateMessageBubble
DebateTopicHeader
DebateEvidenceLink
ReceiptsBoardPage
ReceiptCard
ReceiptConnectionView
CandidateImageSlot
EvidenceMediaSlot
SourceBadge
TruthStatusBadge
InvestigationCostBadge
RelatedEvidenceChip
UnresolvedQuestionCard
CandidateComparisonSheet
```

---

# 16. Suggested Candidate Models

## 16.1 Candidate

```json
{
  "id": "candidate_8f3a9c2e",
  "display_name": "Maya Vargas",
  "party_id": "party_civic_alliance",
  "slogan": "Care that reaches every street.",
  "identity_key": "maya_vargas_001",
  "portrait_asset_key": "candidate_maya_vargas_neutral",
  "public_identity": "Former health administrator turned reform candidate",
  "rhetorical_style": "charismatic",
  "quality_band": "capable_but_compromised",
  "unresolved_question_ids": [
    "question_clinic_budget",
    "question_donor_dependency"
  ]
}
```

## 16.2 CandidateTruthProfile

Store separately from player-visible data.

```json
{
  "candidate_id": "candidate_8f3a9c2e",
  "general_competence": 71,
  "implementation_skill": 62,
  "integrity": 54,
  "corruption_risk": 48,
  "coalition_skill": 73,
  "communication": 85,
  "budget_discipline": 42,
  "policy_scores": {
    "health": 86,
    "water": 61,
    "employment": 45
  },
  "motivations": [
    "public_health_reform",
    "political_advancement"
  ],
  "hidden_risks": [
    "donor_dependency"
  ]
}
```

## 16.3 CandidateContentItem

```json
{
  "id": "content_001",
  "candidate_id": "candidate_8f3a9c2e",
  "surface": "pulse",
  "type": "campaign_ad",
  "headline": "Clinics in Every District",
  "summary": "Vargas promises expanded access during her first year.",
  "body": "...",
  "source_id": "source_vargas_campaign",
  "media": {
    "asset_key": "campaign_clinic_poster",
    "is_available": false
  },
  "related_evidence_ids": [
    "budget_clinic_expansion"
  ],
  "investigation_cost": 0
}
```

---

# 17. Development Roadmap

## Phase 1 — Data and Navigation Foundation

Implement:

- Candidate Hub route;
- Pulse, Dossier, and Debate tabs;
- Receipts Board route;
- candidate-content models;
- evidence-relation model;
- placeholder-image system;
- world-used-name registry.

No final art generation.

## Phase 2 — Static Authored Candidate Experience

Use the current three candidates.

For each candidate, author:

- 5–7 Pulse cards;
- 1 humanizing item;
- 1 strong promise;
- 1 complication;
- 1 defense;
- 1 contradiction;
- 1 unresolved question.

Do not procedurally generate yet.

## Phase 3 — Debate Chat MVP

Build:

- one debate;
- three topics;
- moderator messages;
- candidate responses;
- rebuttals;
- evidence links;
- bookmarks;
- receipt pins.

The debate should be fully scrollable and revisit-able.

## Phase 4 — Receipts Board

Implement:

- pinned claims;
- supporting evidence;
- contradicting evidence;
- private notes;
- candidate comparison;
- issue filtering.

## Phase 5 — Investigation Economy Revision

Implement:

- free surface content;
- paid deeper verification;
- one- and two-point investigations;
- unlocked follow-ups;
- persistent point usage.

## Phase 6 — Candidate Rebalance

Review each candidate.

Check:

- can a player dismiss this candidate immediately?
- does the candidate have real appeal?
- is a bad candidate allowed to remain bad?
- does every candidate have a distinct voice?
- do contradictions come from structured truth?

## Phase 7 — Procedural Candidate Schema

Only after the authored version works:

- generate hidden candidate truth;
- select quality band;
- select rhetorical style;
- generate candidate relationships;
- generate claims and disputes;
- generate evidence structure;
- generate debate outline;
- generate names from the unused pool.

## Phase 8 — Narrative Generation

AI may later write:

- headlines;
- summaries;
- debate messages;
- speeches;
- public reactions.

AI must not create hidden truth or simulation values.

## Phase 9 — Final Art Integration

After layouts are stable:

- generate or draw candidate portraits;
- create campaign images;
- create evidence illustrations;
- replace placeholders;
- test crops and aspect ratios;
- compress assets;
- verify visual consistency.

---

# 18. Codex Instructions

Codex must:

1. Preserve existing working investigation and save behavior.
2. Add the Candidate Hub structure.
3. Make Debate the centerpiece.
4. Keep Dossier as the structured archive.
5. Add Pulse as the quick-reading layer.
6. Add Receipts Board for player-curated evidence.
7. Implement progressive disclosure.
8. Prepare image slots with intentional placeholders.
9. Avoid generating or downloading final images.
10. Keep image dimensions stable when assets are missing.
11. Store used candidate names in world-save data.
12. Prevent repeated full names within one world.
13. Support genuine bad candidates in hidden generation rules.
14. Avoid exposing hidden quality bands.
15. Use authored content before procedural generation.
16. Keep the simulation system untouched unless required for data compatibility.
17. Add tests for name uniqueness and evidence relations.
18. Keep all candidate-facing screens responsive.
19. Preserve English and Filipino localization compatibility.
20. Update documentation when models change.

---

# 19. Acceptance Criteria

The redesign is complete when:

- selecting a candidate opens the Candidate Hub;
- Pulse, Dossier, and Debate work;
- Debate displays a scrollable group-chat-style history;
- debate messages can link to evidence;
- players can bookmark or pin statements;
- Receipts Board collects player-selected claims;
- quick readers can understand each item from short summaries;
- detailed readers can open deeper information;
- no candidate recommendation or match score appears;
- candidates may be strong, mixed, weak, or dangerous;
- candidate full names never repeat inside one world;
- missing images show polished placeholders;
- all final image positions are prepared;
- Codex has not generated any final image assets;
- the current three-candidate authored election remains playable;
- save data remains compatible or has a migration path.

---

# 20. Final Design Principle

The candidate experience should repeatedly create this feeling:

> “This candidate sounds convincing.”  
> “Wait, that detail is concerning.”  
> “Their defense makes some sense.”  
> “But the records still do not fully match.”  
> “I need to decide anyway.”

The Debate creates drama.  
Pulse creates curiosity.  
Dossier creates depth.  
Receipts create player ownership.

Together, these systems should make candidate investigation feel like gameplay rather than assigned reading.
# Implementation status

The authored three-candidate reference slice described in this roadmap is now
implemented. The Candidate Hub uses **Bio / Promises / Debate / Records**;
structured Civic Archive biographies, life-event timelines, numbered evidence
citations, issue-family promises, cross-content trails, and neutral Then-vs-Now
cards are connected to the existing evidence, investigation-point, Receipts
Board, and persistence systems. Candidate image positions use intentional
`CandidateImageSlot` fallbacks pending final art.

Procedural candidate generation, a large connections graph, multiplayer,
runtime AI writing, and other explicitly future items remain outside the
current authored MVP.
