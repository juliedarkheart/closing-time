# Closing Time Continuation

## Current state

- Repository: `https://github.com/juliedarkheart/closing-time`
- Branch: `main`
- Project path: `/home/julie/hermes-workspace/closing-time`
- Godot 4.6.3 at `~/.local/bin/godot` (`4.6.3.stable.official.7d41c59c4`), Compatibility renderer
- Stage: prototype, slice `overnight-graybox`
- Verification: `GODOT_BIN=/home/julie/.local/bin/godot ./tests/headless/run.sh` (passing)

## Working

- Hands-on store loop: opening chores, shelf retrieval, register service, useful questions.
- Visible customers: entry, browse, wander, register wait, exit, with per-customer generated browse points.
- Seeded procedural shift covering customer cast and order, incident schedule, starting stock, store condition, opening chores, and mystery thread.
- Five authored incidents with no duplicate type inside a shift.
- Two-stage incident handling: visible evidence in the world, then inspect, then act. Text labels the state; it is not the only evidence.
- Spill requires fetching the mop from the utility corner before it can be cleaned.
- Aftermath evidence persists after resolution (wet-floor sign, shelf gap, cleared bathroom tag, abandoned coupon, parked car).
- `N` starts a new seeded shift.
- Headless suite: opening-chore gate, customer flow, seeded reproducibility, incident investigation, mop requirement, aftermath, render check, new-shift reset.

## Not verified

- Human playtest by keyboard at the desktop (headless tests only).
- Blind playtest with recorded reactions.
- LimeZu art pass beyond the fridge and checkout sprites.
- Audio, lighting, weather, second shift.

## Next actions

1. Run a human keyboard playtest of one full shift and record it in `production/playtests/`.
2. Add the remaining visual incident evidence for exterior/parking-lot and shelf-gap cases.
3. Expand incident count and authored incident pool so repeated shifts vary more.
4. Grow the customer loop: multiple customers waiting at once, queue pressure, and per-customer browsing differences that matter.

## Guardrails

- Do not commit raw LimeZu assets (`licensed_assets/` stays ignored).
- Do not claim manual acceptance from headless execution alone.
- Do not describe an incident only in text when the world can show it.
