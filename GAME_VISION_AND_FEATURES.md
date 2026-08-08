# Resibo, Please — Game Vision and Features

This document separates the game that exists in the repository today from the longer-term design. It is a companion to `README.md`, the project context, and the candidate-experience roadmap; it does not replace them.

## CURRENT GAME

### Core premise

`Resibo, Please` is a fictional civic decision simulation. The player studies a city, investigates three mayoral candidates, votes, and then observes a deterministic term simulation. It teaches evidence evaluation and trade-off thinking rather than endorsing real candidates or giving official election guidance.

### Main menu, saves, and settings

- A responsive, illustrated main menu offers Continue/Start New City, How to Play, Visit Cities, and Settings.
- Five local city-save slots are supported. Starting over in an occupied context requires confirmation.
- Run setup currently includes city name, starting pressure, one to three priority concerns, candidate-field experience, assistance mode, campaign noise, and investigation time.
- Settings include English/Filipino language selection, reduced motion,
  high-contrast presentation, and dialogue sounds. About, credits, disclaimer,
  privacy information, and app version belong under Settings.
- Save data is versioned and migrated instead of silently discarding older supported saves.

### Procedural city foundation

- Every newly configured city has a world seed. The same seed and configuration reproduce the same city truth; ordinary new saves receive a fresh seed.
- The generator selects four to six active problems from twelve civic issue families: flooding/drainage, corruption/public funds, unfinished roads, illegal drugs/community safety, garbage/cleanliness, traffic/transport, water supply/contamination, healthcare capacity, employment quality, cost of living, government services, and education capacity.
- Setup priorities are guaranteed influence over the generated mix, while the remaining issues come from the seed. Severity, urgency, and trend also vary deterministically.
- A city is deliberately mixed rather than uniformly broken: active issues can be improving, stable, worsening, or rapidly worsening, and unrelated indicators may remain healthy.
- Each issue carries affected indicators/groups, possible causes, policy hooks, Chronicle hooks, community-voice hooks, future event hooks, a visual key, tags, and SDG links. These issue records are the shared roots for the City Brief and Chronicle and are ready to feed later term events.

### Pre-election City Brief

- The City hub is a frozen pre-election snapshot. It does not advance time or trigger consequential events.
- It presents a city overview, public-condition metrics, map hotspots, and the three most urgent issue cards first. Additional active conditions are available through progressive disclosure.
- Every issue shows its description, affected-resident estimate, severity, urgency, trend, related indicators, affected groups, possible causes, and plausible policy paths.
- All twelve issue families now resolve to authored Bayhaven artwork through a centralized visual-key catalog. Five reuse existing term-event scenes and seven use dedicated issue scenes; unknown future procedural keys retain a safe Flutter fallback.
- The hub links to the Chronicle, candidate dossiers, and ballot while keeping candidate faces and city facts separate.

### Chronicle and community voices

- Chronicle entries are structured, deterministic outputs tied to active city issues, not free-form AI claims.
- Most entries report issue-related records or community conditions. Roughly 15–30% are harmless civic flavor stories so the city feels inhabited rather than permanently catastrophic.
- Campaign-noise settings can add a clearly labeled unverified claim without changing the underlying city facts.
- Community voices are attached to actual issue families and vary by district, role, and sentiment. The feed includes concerned, frustrated, watchful, hopeful, and positive perspectives rather than treating every citizen as a complaint generator.
- Story IDs, voice IDs, and used template IDs are persisted for stable reopening and future anti-repeat/history behavior.

### Candidate investigation

- The current election has three authored candidate archetypes with structured Civic Archive biographies, career timelines, platforms, promises, concerns, and evidence files.
- Candidate pages use a dossier/political-cartoon presentation rather than default Flutter information screens.
- Evidence includes profiles, public records, budgets, fact-checks, platform material, debate answers, controversies, campaign media, and social posts with distinct reliability/truth states.
- Investigation points can be relaxed or limited. Profiles and explicitly free/unlocked records cost no points; paid evidence is charged once and remains available.
- Evidence relationships can unlock connected material. Players can view, bookmark, pin, and annotate relevant receipts.
- The Candidate Hub is organized as **Bio / Promises / Debate / Records**. Bio citations, promise records, and debate claims all lead into the same evidence reader and persisted investigation state. Campaign Pulse material remains available as the nested Campaign Trail under Promises.
- Neutral **Then vs Now** cards expose changes in public statements with source context; they do not automatically label a candidate hypocritical or dishonest.
- The content model includes an internal information-footprint field for future procedural generation, but it is not rendered as a player-facing score.
- The candidate experience also includes civic pulse content, questions, debate material, a receipt board, and persisted interaction state. The system avoids exposing a single hidden “best candidate” score.

### Fictional information ecosystem

- **CityBook** gives each authored candidate a recognizable social profile with a banner slot, portrait, handle, biography, party, attention count, Posts/About/Media tabs, and four authored posts. Posts support different message types, reactions, ten-comment threads generated from each post's subject and context, historical statements, issue links, related coverage, and receipt links. Reactions represent public sentiment only and never change truth or candidate scoring.
- Historical CityBook posts can open the existing neutral **Then vs Now** comparison. Evidence-linked claims open the same Evidence Reader and retain its investigation costs, unlocks, bookmarks, and persistence rules.
- Every world has three seed-stable fictional news outlets. Their names are selected deterministically, while structured traits describe sensationalism, depth, speed, tone, editorial aggression, and headline style.
- A major Chronicle entry creates one underlying news event and three compatible outlet framings. Each framing has its own headline, emphasis, summary, and full article, but all three preserve one factual event source rather than creating competing hidden truths.
- The full mobile article reader provides layered reading: headline and summary first, followed by article body, outlet style, related candidates, related city issues, evidence, and links for comparing the other coverage.
- Chronicle cards can open the three reports about their event. Candidate Hubs include a compact CityBook link and recent-coverage entry without displacing the fast Bio / Promises / Debate / Records path.
- Evidence Reader presentation now reflects source type. Public records use a reusable **Bayhaven Transparency Portal** treatment; budget, social-media, campaign, fact-check, debate, investigation, platform, and archive sources receive distinct visual treatments while retaining the normalized deep-reading view.
- A generic information relationship layer connects city problems, Chronicle entries, candidates, promises, debate material, CityBook posts, news events, coverage, and evidence using relationships such as supports, contradicts, references, disputes, updates, adds context, responds to, reports on, and originates from.
- CityBook posts, comments, reactions, outlet identities, underlying events, headlines, and article text are authored or derived deterministically from the saved world seed. Their stable IDs prepare later anti-repetition history without changing save schema 5.
- Profile banners, selected CityBook posts, Campaign Trail media, and news articles now use fixed-aspect-ratio authored artwork. News outlets covering the same event reuse the same underlying issue image, preserving the one-event/many-framings rule; unknown future media keys retain coded fallbacks.
- Two or three high-impact underlying news events receive deterministic R-8 TV
  reports. Chronicle cards, event coverage, and full articles link to the same
  report; the broadcast reuses the event ID, facts, impact, relationships,
  article IDs, and visual key instead of owning a second version of truth.
- The responsive broadcast screen uses an original fictional robot reporter,
  localized five-page visual-novel dialogue, tap/click/Enter/Space controls,
  reduced-motion behavior, and an optional persistent dialogue-blip setting.
  Watching a report is presentation-only and never mutates the city.

### Election and term loop

- The ballot asks the player to choose a candidate, identify the top issue, and record confidence.
- A winner presentation transitions from the pre-election snapshot into the term.
- The term engine is seeded and deterministic. It combines city indicators, problem weights, candidate policy knowledge, implementation, coalition skill, crisis response, budget discipline, integrity, and trade-offs.
- The term unfolds through staged events/updates and ends in a report showing indicator changes and explanations. Existing event artwork is used where available.
- Candidate/election/term behavior remains separate from the procedural city-foundation work described above.

### Technical boundaries

- Flutter owns menus, dossiers, cards, settings, navigation, accessibility, localization, and other information-heavy screens.
- Flame is reserved for a future animated city/simulation canvas; it is not required for ordinary UI screens.
- Simulation truth is local, structured, seeded, testable, and saveable. Presentation must never secretly rewrite it.

## PLANNED / FUTURE GAME

The items below are design direction, not claims about the current build. They should be delivered incrementally after the procedural city foundation is stable.

### Persistent city across elections

- A city should survive multiple administrations. Indicators, completed or failed projects, public trust, debt/budget pressure, institutional reforms, scandals, and unresolved problems should carry into the next election.
- Election cycles should become chapters in one city history rather than isolated resets.
- A “Then vs Now” view should compare the inherited city, the elected leader’s term, and the state handed to the next administration without reducing performance to one simplistic grade.

### Procedural elections and candidates

- Future elections should generate new names, identities, parties, careers, platforms, relationships, strengths, weaknesses, contradictions, and evidence histories from a seed.
- No candidate should be perfect. Advantages should create opportunity costs, institutional dependencies, or credible risks.
- The authored three-candidate election remains the reference slice until a procedural candidate generator can match its coherence and evidence quality.

### Procedural biography and life history

- Structured biographies, citations, and life-event timelines are implemented for Maya Vargas, Julian Pratt, and Victor Chen. A future generator may assemble equivalent records for new candidates.
- Procedural biography facts must be generated as structured truth first and then exposed through records of varying reliability. Flavor text must not invent consequential facts.

### Connections and accountability graph

- Candidates, donors, companies, agencies, advocates, relatives, projects, and evidence may form a navigable relationship graph.
- Connections should support both legitimate coalitions and conflicts of interest; a connection alone is not proof of wrongdoing.
- Evidence provenance, corroboration, dates, and confidence should remain visible.

### Debate evolution

- Debates may react to current city issues, candidate histories, exposed evidence, previous answers, and player-selected questions.
- Answers should be assembled from verified candidate state and strategy templates. Contradictions should arise from stored positions and records, not from arbitrary text generation.

### News and television expansion

- The Chronicle can grow into persistent city history with editions, follow-ups, corrections, editorials, public-service notices, and TV/news segments.
- Different outlets may frame the same verified facts differently, while source quality and missing context remain inspectable.
- Harmless culture, sports, weather, neighborhood, and human-interest stories should continue to keep the city believable.
- The implemented R-8 issue reports may later expand with additional fictional
  reporter personalities and harmless deterministic culture, sports, weather,
  neighborhood, or human-interest segments. Those additions must keep the same
  player-paced, accessible interaction rules and may not mutate simulation
  state.

### Information ecosystem expansion

- CityBook and news content should eventually be generated from structured candidate history, live campaign events, later Chronicle history, corrections, editorials, and public-service notices rather than relying mainly on the authored reference catalog.
- Long-running worlds should persist used comment, reaction, headline, article, and outlet-name template histories so later elections can avoid immediate repetition across a much larger generated catalog.
- News coverage may later include corrections, disputed-fact follow-ups, longer investigations, and candidate responses while retaining the current one-event/many-presentations rule.
- Any TV expansion must continue consuming the same underlying news-event
  objects used by Chronicle, CityBook, community voices, records, and articles.
  It must not create a separate version of truth.

### Plague Inc.-inspired city map

- A future interactive city map may visualize districts, infrastructure networks, issue hotspots, projects, emergencies, and changing public conditions.
- The map should summarize the same simulation state as the cards, not run a second hidden simulation.
- Flame is a suitable tool for animated overlays, event markers, and a living city canvas once the underlying district model exists.

### Asynchronous multiplayer

- Players may eventually publish privacy-safe city snapshots or compare administrations asynchronously.
- Possible modes include visiting a city, reviewing a friend’s public record, shared civic challenges, or comparing outcomes from the same seed.
- Multiplayer must never allow another player to corrupt the owner’s canonical save, and moderation/privacy requirements must be designed before sharing is enabled.

### AI presentation rule

AI may help present already-generated truth—for example, paraphrasing a structured news item, creating a voice variant, or producing visual concepts from an approved visual key. AI must not decide hidden simulation outcomes, invent evidence, alter candidate integrity, fabricate sources, or create facts that are absent from the deterministic game state. Any runtime AI feature must have a local deterministic fallback and must preserve save reproducibility.

### Delivery order

1. Stabilize and test the procedural issue library, City Brief, Chronicle, voices, persistence, and migrations.
2. Let post-election events consume the same issue hooks and add persistent city history.
3. Introduce district/map state and the Then vs Now record.
4. Prototype procedural candidates against the authored reference election.
5. Add deeper biography, connections, reactive debates, and richer media.
6. Consider asynchronous sharing only after deterministic state, privacy, and moderation are mature.
