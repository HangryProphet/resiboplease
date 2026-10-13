# Citizen Action Simulation Design

## Status

**Chosen for the first vertical slice:** deterministic future-action overlay.

The overlay now records an explicit derived `SimulationDayCheckpoint` before
every action. The checkpoint fingerprints observed events, observed project
milestones, indicators, and issue states. The action is rejected if inserting
its future outcome changes that observed prefix. This does not yet authorize
future-event or project rerolls; a versioned suffix-regeneration migration is
still required before those become safe.

The current Living City engine generates all 365 days when the player confirms
their vote. The simulation clock reveals this immutable result over time; it
does not generate a new day when the clock advances. Consequential citizen
actions therefore cannot safely mutate the already-observed portion of the
term or secretly reroll the unseen future.

## Approaches considered

### Incremental daily simulation

Generate each day only when it is reached, storing the random-generator state,
project state, causal hooks, media state, and world-condition state.

- Best long-term flexibility for actions that influence later probabilities.
- Requires a new checkpoint format and a substantial Living City Engine
  rewrite.
- Risks changing existing deterministic terms and old saves if introduced in
  one migration.

### Deterministic future-suffix recalculation

Keep the observed prefix, restore an exact checkpoint on the action day, and
regenerate only later days using the action as an input.

- Lets later event selection react to changed conditions.
- Requires the engine to expose complete phase/day checkpoints, pending causal
  hooks, project states, media generation inputs, and deterministic RNG paths.
- The current saved simulation does not contain enough generator state to do
  this without reconstructing or changing old results.

### Deterministic future-action overlay (selected now)

Keep the existing generated term unchanged and insert one deterministic,
bounded action outcome on a future day. Recalculate derived phase snapshots
and final indicators from the same immutable initial state, existing events,
existing milestones, and the new outcome event.

- Preserves old saves and all existing event IDs.
- Never rewrites an event or milestone at or before the action day.
- Persists the action immediately because its future event is stored in the
  existing `LivingTermSimulation` save payload.
- Reopening the same save produces the same pending or completed outcome.
- Avoids navigation-based rerolls and duplicate actions.
- Has a clear limitation: unrelated pre-generated future events do not change
  probability yet. Only the inserted action outcome responds causally.

This is an honest, meaningful first slice rather than a cosmetic choice. A
future Living City Engine version may introduce explicit daily checkpoints and
suffix regeneration after migration and deterministic-regression coverage are
ready.

## Invariants

1. An action outcome day must be later than the current simulation day.
2. Events and project milestones at or before the current day are immutable.
3. Existing event IDs, order, content, media references, and causal links are
   not changed.
4. Action IDs and outcomes are derived from stable inputs, never UI state.
5. Each initial action type may be used at most once per administration.
6. Actions are unavailable before Day 30 and after Day 350.
7. Outcomes are bounded and may succeed, partially succeed, or be resisted.
8. The mayor is not controlled by the player. Capability, integrity, budget,
   trust, issue severity, and a deterministic roll affect the result.
9. Rebuilt phase event lists must exactly match the complete event history.
10. The saved simulation remains valid under `LivingTermSimulation.validate`.
11. An action captures the current day checkpoint and the post-action simulation
    must reproduce the same observed-prefix fingerprint exactly.
12. Evidence-linked actions persist the stable evidence ID on their outcome event.

## Initial action set

- **Request Public Records** — may expose, partially release, or withhold
  records. It can produce small trust and corruption-pressure changes.
- **Organize a Petition** — targets the currently most severe city issue. It
  may prompt a response, gain a limited concession, or be ignored. It can
  produce small issue, trust, and relevant-indicator changes.
- **Challenge a Misleading Claim** — requires a source the player actually
  reviewed during the election. Eligible support is a reliable fact-check,
  public record, budget document, or documented controversy that is not merely
  unverified. Success can produce a correction; a partial or resisted outcome
  describes limited reach or institutional resistance and never declares the
  supporting evidence invalid.

These actions are optional, limited, and surfaced through one City Action hub
instead of repeated modal interruptions.

## Future engine upgrade

Before implementing actions that change project selection or the probability
of unrelated events, add a versioned daily checkpoint containing:

- indicator and issue state;
- project state and pending milestones;
- unresolved causal hooks and chain state;
- world conditions;
- generator stream/checkpoint inputs;
- media generation state;
- applied citizen actions.

Then regression-test prefix immutability and suffix determinism across save and
restore before switching action effects to suffix regeneration.
