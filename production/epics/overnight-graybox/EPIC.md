# Overnight Graybox Vertical Slice

- Slug: overnight-graybox
- Layer: gameplay / prototype
- Priority: P0
- Status: Active

## Description

Prove the smallest complete Closing Time loop in Godot: move through the shop, serve customers, make meaningful choices, change cash and stock, discover one mystery clue, and reach a dawn summary.

## Systems included

- Player movement and interaction
- Customer encounter sequence
- Inventory, cash, and stock feedback
- Choice/consequence state
- Dawn summary and ending

## Dependencies

- Godot 4.x runtime available for execution
- Existing concept and systems docs
- No third-party asset import required for the first slice

## ADR references

- None yet. Keep the slice single-scene and avoid speculative framework work.

## Stories

1. `story-graybox-runtime.md` — make the first slice run and interact.
2. `story-customer-loop.md` — add three encounters and visible consequences.
3. `story-first-playtest.md` — run a blind playtest and record evidence.

## Interface notes

The player uses WASD/arrow keys to move and `E` to interact. The first slice must communicate cash, stock, customer count, current prompt, and the dawn result without requiring external instructions.

## Out of scope

- LimeZu asset import
- Final art, audio, lighting, or weather
- Second shift
- Procedural generation
- Multiplayer or open-world systems
- Crafting, farming, upgrades, or complex economy
