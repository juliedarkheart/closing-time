# Story: Graybox Runtime

- Epic: overnight-graybox
- Status: Ready
- Priority: P0
- Layer: gameplay / prototype
- Points: 2

## Description

Make the current graybox open as a Godot project and provide a playable shop space with movement and register interaction.

## Acceptance Criteria

- [ ] Project opens with `scenes/main.tscn` as the main scene.
- [ ] Player movement works with WASD and arrow keys.
- [ ] Player remains inside the shop bounds.
- [ ] `E` at the register changes stock, cash, and served-customer feedback.
- [ ] The HUD displays the interaction instructions and current values.

## Technical Notes

Keep the first slice single-scene and use the existing `scripts/main.gd`. Do not import licensed assets for this story.

## Dependencies

Godot 4.x executable.

## Test Strategy

Run the project from Godot, perform movement in all four directions, interact once at the register, then interact until stock is empty. Record any parser, input, or visual errors.
