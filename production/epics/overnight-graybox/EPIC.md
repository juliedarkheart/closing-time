# Overnight Graybox Vertical Slice

- Slug: overnight-graybox
- Layer: gameplay / prototype
- Priority: P0
- Status: Active

## Description

Prove the smallest complete Closing Time loop in Godot: stock and face shelves, call odd overnight customers, ask useful questions, retrieve the requested item, serve them at the register, handle consequences, and reach a dawn handoff.

## Systems included

- Player movement and shelf/register interaction
- Shelf stock and held-item state
- Randomized overnight customer needs and issues
- Useful customer question
- Customer service and consequences
- Dawn handoff summary

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

The player uses WASD/arrow keys to move, `E` to take/serve/call, and `Q` to ask a customer a useful question. The first slice must communicate shelf stock, held item, cash, customer count, current need/issue, and the dawn handoff without external instructions.

## Out of scope

- LimeZu asset import
- Final art, audio, lighting, or weather
- Second shift
- Procedural generation
- Multiplayer or open-world systems
- Crafting, farming, upgrades, or complex economy
