# Story: Graybox Runtime

- Epic: overnight-graybox
- Status: In Progress
- Priority: P0
- Layer: gameplay / prototype
- Points: 2

## Description

Make the current graybox open as a Godot project and provide a playable shop space with movement and register interaction.

## Acceptance Criteria

- [x] Project opens with `scenes/main.tscn` as the main scene.
- [ ] Player movement works with WASD and arrow keys in a manual run.
- [ ] Player remains inside the shop bounds in a manual run.
- [ ] `E` at the register changes stock, cash, and served-customer feedback in a manual run.
- [x] The HUD displays the interaction instructions and current values.
- [x] Headless Godot editor import passes.
- [x] Headless project run passes for 8 seconds with no reported errors.

## Technical Notes

Keep the first slice single-scene and use the existing `scripts/main.gd`. Do not import licensed assets for this story.

## Dependencies

Godot 4.6.3 executable is now installed.

## Test Strategy

Run the project interactively, perform movement in all four directions, interact at the register, resolve all three encounters with both choice keys, and observe the dawn result. Record any parser, input, or visual errors.
