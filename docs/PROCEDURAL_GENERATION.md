# Procedural Candidate Generation

> October 2026 source audit: normal Create City runs generate five candidates
> with candidate generation version 1 and persist their snapshot in local save
> schema 10. The authored three-candidate catalog is a fallback/debug fixture.
> Later elections can supply eligible returning identities; those candidates
> retain their stable ID, name, portrait, core truth, party, and archetype while
> the current campaign graph is regenerated from a term-specific election seed.

This document describes the implemented version-1 mayoral candidate generator.
It is the developer contract for maintaining deterministic worlds and
cross-system candidate consistency.

## Runtime contract

- A normal **Create City** action generates one mayoral election.
- Every election contains exactly five candidates.
- Five unique portraits are selected from a reusable pool of seven.
- Full names, candidate IDs, and portrait assignments are unique in one world.
- Portrait gender selects a compatible fictional first-name pool.
- The same world seed, configuration, and generation version reproduce the
  same initial election.
- The generated election is persisted after creation. Save restoration decodes
  the stored snapshot and does not call the generator again.
- Maya Vargas, Julian Pratt, and Victor Chen remain authored reference fixtures.

## Generation pipeline

```text
world seed + generation version + city configuration
  -> procedural city problems
  -> five-of-seven portrait selection
  -> stable candidate IDs and compatible names
  -> hidden CandidateTruthProfile
  -> structured life history
  -> promises and evidence graph
  -> Biography and quick summary
  -> Campaign Trail and CityBook
  -> shared issue-rooted debate
  -> one candidate event with three news framings
  -> ProceduralElection validation
  -> schema-10 save snapshot
```

City problems are generated first and passed into the candidate generator.
They bias career fit, lead issues, policy strengths, and promises. They do not
require every candidate to match the city, so poor-fit candidates remain
possible.

## Seed isolation

`SeedDerivation.derive` hashes the world seed, generation version, and a stable
path. The generator never shares one continuous random stream between all
subsystems. Current paths include concepts such as:

```text
portraitSelection
candidate:0:id
candidate:0:name
candidate:0:identity
candidate:0:truth
candidate:0:history
candidate:0:platform
candidate:0:content
candidate:0:citybook
candidate:0:news
election:debate
```

Consequently, adding a CityBook random draw does not consume randomness that
would otherwise choose a name, portrait, another candidate's history, or a city
issue. Generator rule changes must increment `generationVersion` when they
would change the meaning of reproducibility for a newly generated world.

## Portrait pool

`candidatePortraitPool` contains exactly seven `CandidatePortrait` records.
Each record stores:

- stable portrait ID;
- asset path;
- `CandidateGender.male` or `CandidateGender.female`;
- approximate age group; and
- visual archetype key.

The first three records reuse the original authored candidate art. Portraits
04-07 are new transparent political-cartoon foreground assets. A seeded
Fisher-Yates shuffle chooses five records, once each. Portrait IDs are visual
identities, not candidate IDs and not permanent names.

## Truth before presentation

`CandidateTruthProfile` is the single hidden source for candidate reality. It
extends existing capability data instead of replacing the term engine. It can
hold:

- general competence and implementation skill;
- integrity and corruption risk;
- coalition, communication, budget, and crisis abilities;
- adaptability and experience;
- populism and ambition;
- policy/domain scores;
- motivations, hidden risks, and personality tags;
- information footprint;
- structured controversies with verified, supported, partial, disputed,
  unresolved, misleading, or false statuses; and
- structured donors, allies, contractors, rivals, organizations, employers,
  or advocacy relationships, with potential-conflict metadata.

Quality bands are rolled independently. The generator does not force one good,
one average, and one bad candidate. Strong, mixed, weak, compromised, and
dangerous combinations can coexist in any distribution. Rhetorical style is
separate from quality.

The player never sees the raw truth profile or quality band. Public summaries,
questions, records, and competing presentations provide clues instead.

## Structured content and reference integrity

Each candidate currently receives:

- five history events;
- four promises tied to active issue families;
- nine evidence records;
- a variable-section Civic Archive biography with real evidence citations;
- one neutral statement comparison;
- two unresolved questions;
- five or six Campaign Trail items;
- four to seven CityBook posts with ten comments each;
- messages across three shared debate topics;
- one underlying candidate-record news event; and
- three outlet coverages of that same event.

Promises link to history and evidence. Biography statements and timeline items
link to evidence. Campaign Trail and CityBook claims reuse accomplishments,
failures, promises, controversies, corrections, and comparisons. Debate
messages link to actual promises, history events, comparisons, other messages,
and evidence. All three news articles frame one underlying event rather than
creating three realities.

`ProceduralElection.validate()` rejects missing or duplicate roster records,
orphaned evidence/history/promise/comparison/debate references, unknown
CityBook candidates or threads, and unknown news events/candidates. Keep this
validation at the end of generation and after save decoding.

## Configuration effects

- `CandidateField` changes generated experience while preserving independent
  strengths, weaknesses, integrity, and risk.
- `CampaignNoise.clear`, `typical`, and `noisy` change the amount of public
  Campaign Trail/CityBook material. They do not reroll candidate IDs, names,
  portraits, or hidden truth.
- Starting pressure and selected concerns first affect city problems; those
  problems then bias candidate backgrounds and promises.
- Investigation time, assistance, and accessibility settings remain player/UI
  rules and do not alter candidate truth.

## Persistence

Save schema 6 adds `procedural_election`. `ProceduralElectionCodec` serializes
and restores the complete generated candidate world:

- generation version and portrait IDs;
- candidates, capabilities, and evidence;
- hidden truth, controversies, and relationships;
- biographies, timelines, promises, comparisons, and information relations;
- Candidate Hub profiles, questions, Campaign Trail, and debate;
- CityBook profiles, posts, reactions, and comment threads; and
- underlying candidate news events and three-outlet coverage.

Mutable player state such as opened files, point charges, bookmarks, pins,
notes, vote, and term progress remains in `RunSaveData` beside that snapshot.
Schema-5 saves migrate with no procedural snapshot and use the authored
fallback. This avoids breaking existing local cities.

## Main implementation files

- `lib/domain/simulation/procedural_candidate_generator.dart`
- `lib/domain/simulation/seed_derivation.dart`
- `lib/domain/models/procedural_election.dart`
- `lib/domain/models/candidate_generation.dart`
- `lib/domain/models/candidate_portrait.dart`
- `lib/data/seed_content/procedural_candidate_library.dart`
- `lib/data/persistence/procedural_election_codec.dart`
- `lib/data/persistence/run_save_data.dart`
- `lib/core/state/game_controller.dart`
- `lib/domain/simulation/information_ecosystem_engine.dart`

Normal UI screens consume the active run's candidate list and active
`CandidateExperienceCatalog`; they do not own a second generator.

## Automated verification

`test/domain/procedural_candidate_generator_test.dart` covers:

- same-seed complete-election equality;
- different-seed roster variation;
- exactly five candidates;
- unique IDs, names, and portraits;
- portrait/name gender compatibility;
- stable, path-specific, version-specific sub-seeds;
- city-issue isolation;
- campaign-noise identity isolation;
- promise-to-active-issue validity;
- complete cross-system reference validation; and
- full procedural codec round trips.

Controller tests additionally verify that generated identity, portraits,
evidence, and Campaign Trail IDs survive repository save and restore.

## Safe extension rules

When expanding a content library:

1. Keep consequential facts structured before presentation prose.
2. Reuse stable references rather than repeating an unlinked fact string.
3. Give new random behavior its own derived seed path.
4. Do not derive database identity from candidate names or portraits.
5. Keep hidden scores out of pre-election UI.
6. Extend the codec and validation together when adding persisted fields.
7. Increment the generation version when new generation rules intentionally
   change reproducibility for new worlds.
8. Never regenerate an existing saved election merely because libraries grew.
