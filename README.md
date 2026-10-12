# Closing Time

A tiny cozy mystery game about running one strange overnight shift at a roadside shop.

> Read the customers. Stock the shelves. Decide who to help before dawn.

## Current state

The overnight graybox slice is implemented in Godot 4.6 (Compatibility renderer). One scene contains:

- WASD/arrow movement through a compact shop
- Three shelf categories (`cold`, `warm`, `odd`) with visible stock counts
- Two seeded opening chores that must be completed at the correct shelf before the first customer
- Visible customers who enter, browse a shelf, wander a second browse point, walk to the register, and leave after service
- Useful customer questions on `Q`
- Register service with cash, trust, and stock consequences
- A seeded procedural shift: customer cast and order, incident schedule, starting stock, store condition, opening chores, and mystery thread all come from one seed
- Five authored night-shift incidents, selected without repeating a type in a shift
- Two-stage incident handling: notice the visible evidence, walk over and inspect it, then act on what you find
- A mop tool the recurring spill requires before it can be cleaned
- Persistent aftermath evidence so the shop remembers what happened
- Shift handoff summary at dawn
- `N` starts a fresh seeded shift without restarting the game

Same seed reproduces the same shift. A shift launched without a fixed seed uses the current time, so each run differs.

## Controls

| Key | Action |
| --- | --- |
| WASD / arrows | Move |
| `E` | Interact: take stock, serve, inspect and handle incidents, take the mop, start a shift |
| `Q` | Ask the waiting customer one useful question |
| `N` | Start a new seeded shift |

## Run

Play a random shift:

```bash
./play.sh
```

Play a specific, reproducible shift:

```bash
./play.sh 1001
```

Or open the folder in Godot 4 and run the project. `--shift-seed=<n>` after `--` sets the seed from the command line; the seed in play is shown as `SHIFT #<seed>` in the HUD.

Godot 4.6.3 (`4.6.3.stable.official.7d41c59c4`) is installed at `~/.local/bin/godot` on the development host.

The playtest runbook for the first human session is `production/playtests/runbook-overnight-graybox.md`.

## Verify

```bash
GODOT_BIN=/home/julie/.local/bin/godot ./tests/headless/run.sh
```

The suite runs the editor import plus every `tests/headless/*_test.gd` and fails on a non-zero status or any `SCRIPT ERROR`. It covers the opening-chore gate, the visible customer flow, seeded reproducibility, two-stage incident investigation, the mop requirement, aftermath evidence, rendering, and starting a new shift.

Automated headless tests do not replace a human playtest. Manual keyboard play and the blind playtest are still outstanding.

## Scope guardrails

- One shop
- One overnight shift
- Short replayable mystery
- Authored content pools with seeded combination, never generated prose
- No multiplayer, open world, crafting, farming, or procedural town simulation

## Asset note

Julie owns the paid LimeZu packs used for the planned art pass. We will keep the supplied license files and include attribution in-game:

```text
Pixel art assets by LimeZu
https://limezu.itch.io/
```

Raw source assets stay outside the repository and are never redistributed.
