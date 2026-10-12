# Overnight Graybox Vertical Slice

- Slug: overnight-graybox
- Layer: gameplay / prototype
- Priority: P0
- Status: Active

## Description

Prove the smallest complete Closing Time loop in Godot: complete the opening chores, call odd overnight customers who visibly enter and shop, ask useful questions, retrieve the requested item, serve them at the register, notice and handle night-shift incidents through visible evidence rather than text alone, and reach a dawn handoff. One seed must assemble the whole shift, and a different seed must produce a different one.

## Systems included

- Player movement and shelf/register/mop/incident interaction
- Shelf stock and held-item state
- Seeded opening chores that gate the first customer
- Visible customer entry, browsing, wandering, register wait, and exit
- Randomized overnight customer needs and issues
- Useful customer question
- Customer service and consequences
- Seeded procedural shift generation for the whole shift
- Authored night-shift incidents with visible environmental evidence
- Two-stage incident handling: inspect, then act
- Required incident tools, such as the mop for the recurring spill
- Persistent aftermath evidence
- Shift replay from a fresh seed
- Dawn handoff summary

## Dependencies

- Godot 4.x runtime available for execution
- Existing concept and systems docs
- No third-party asset import required for the slice to run

## ADR references

- None yet. Keep the slice single-scene and avoid speculative framework work.

## Stories

1. `story-graybox-runtime.md` — make the first slice run and interact.
2. `story-customer-loop.md` — add encounters and visible consequences.
3. `story-first-playtest.md` — run a blind playtest and record evidence.

## Acceptance criteria

A shift counts as accepted when, from one seed:

1. Two opening chores generate and block the first customer until completed at the correct shelf.
2. A wrong shelf does not complete a chore.
3. At least two customers physically enter, browse, wander, and wait at the register.
4. Serving the correct item changes cash, trust, and stock visibly; the wrong item does not.
5. At least two incidents generate without repeating a type.
6. Every incident shows evidence in the world before any text explains it.
7. Walking past an incident does not identify it; inspecting it at the location does.
8. The recurring spill cannot be resolved until the mop has been fetched from the utility corner.
9. Resolved incidents leave visible aftermath that survives to the end of the shift.
10. Same seed reproduces the shift; a different seed varies it.
11. Dawn reports sales, trust, safety, and handoff notes.
12. `N` starts a fresh seeded shift with chores restored and aftermath cleared.
13. The headless suite in `tests/headless/` passes with no `SCRIPT ERROR`.

## Interface notes

The player uses WASD/arrow keys to move, `E` to take/serve/call/inspect/take the mop, `Q` to ask a customer a useful question, and `N` to start a new shift. The slice must communicate shelf stock, held item, cash, customer count, current need/issue, incident location, shift seed, and the dawn handoff without external instructions. Incident evidence must be visible in the scene; text may label state but must not be the only evidence.

## Out of scope

- LimeZu asset import for customers and incident props
- Final art, audio, lighting, or weather
- Second shift or additional locations
- Save/load and progression between shifts
- Multiplayer or open-world systems
- Crafting, farming, upgrades, or complex economy
