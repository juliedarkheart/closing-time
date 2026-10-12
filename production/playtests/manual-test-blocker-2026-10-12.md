# Manual Playtest Blocker

- Date: 2026-10-12
- Slice: overnight-graybox
- Status: Blocked in current session

The host has no graphical session: `DISPLAY` and `WAYLAND_DISPLAY` are empty. Godot 4.6.3 headless import and project execution pass, but this does not prove keyboard input or player-facing behavior.

Manual acceptance requires a graphical Godot run with WASD/arrows, `E`, `1`, and `2` tested. Do not mark the graybox runtime story or the slice accepted until that evidence exists.
