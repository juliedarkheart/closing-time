# Playtest Runbook — Overnight Graybox (Session 1)

- Slice: overnight-graybox
- Session type: new player experience + feature-specific (visible incidents)
- Session number: 1
- Fixed seed: **1001** (reproduces the shift the automated suite verifies)
- Build: see `git log -1` at the time of the session

## Launch

```bash
cd /home/julie/hermes-workspace/closing-time
./play.sh 1001
```

Controls: `WASD`/arrows move, `E` interact, `Q` ask, `N` new shift.
HUD shows `SHIFT #<seed>` in the top right — record it if it is not 1001.

## Session goals

1. Can the player complete the opening chores and serve the first customer with no coaching?
2. Does the player notice incident evidence in the world *before* reading the incident panel?
3. Does the mop requirement read as real shop work, or as unexplained friction?
4. After dawn, does the player want to press `N` and play another shift?

## What to watch for

- Hesitation longer than ~3 seconds with the screen idle → likely confusion point.
- Pressing `E` on the wrong thing → the visual affordance is not reading.
- Reading the incident panel first instead of looking at the shop → evidence is not salient enough.
- Trying to interact with the spill before fetching the mop → check the message is clear.
- Reaction to the aftermath markers (wet-floor sign, shelf gap, cleared bathroom, coupon, car).

## Debrief questions

1. What did you do first?
2. What was confusing or frustrating, and what did you expect to happen instead?
3. What was the most fun moment?
4. What was the least fun moment?
5. Would you play another shift? Why or why not?
6. One thing to improve.

## Recording

Write results to `production/playtests/report-2.md`, keeping observed behavior separate from interpretation. Mark anything unresolved as pending retest. Do not claim the slice accepted from headless tests alone.
