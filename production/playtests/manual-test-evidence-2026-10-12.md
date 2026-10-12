# Manual Playtest Evidence

- Date: 2026-10-12
- Slice: overnight-graybox
- Build: local desktop run after project-path repair
- Window: `Closing Time (DEBUG)`, 960x540
- Acceptance status: Desktop input smoke passed; full blind playtest pending

## Checks performed

- Project launched from `/home/julie/hermes-workspace/closing-time`.
- Godot created a visible game window.
- Window was moved on-screen successfully.
- Movement input was sent with `D` and `W`.
- `E`, `1`, `2` input sequence was sent across all three encounter steps.
- Godot process remained alive after the sequence.

## Evidence limits

This was an automated desktop input smoke test. It proves the corrected project launches visibly and accepts the input path without crashing. It does not replace a human blind playtest or visually confirm each displayed choice/result.

## Path repair

The old literal Windows path was removed. The repo now lives at `/home/julie/hermes-workspace/closing-time`, and no project file references `C:\\Users\\Julie\\workspace`.

## Follow-up

- Run one human blind playtest.
- Confirm the player can visually reach the register and understand the first clue without coaching.
