# Closing Time

A tiny cozy mystery game about running one strange overnight shift at a roadside shop.

> Read the customers. Stock the shelves. Decide who to help before dawn.

## Current state

The first graybox slice is implemented in Godot 4. It currently contains one scene with:

- WASD/arrow movement
- A compact shop layout
- A register interaction using `E`
- Three deterministic customer encounters
- Two choices per encounter using `1` and `2`
- Cash, stock, trust, customer count, and mystery-clue feedback
- A dawn result after the third customer

## Run

Open this folder in Godot 4 and run the project. Godot 4.6.3 is installed at `~/.local/bin/godot` on the development host. Headless editor import and an 8-second headless project run passed at commit `e9c5fee`.

Manual input testing is still pending.

## Scope guardrails

- One shop
- One overnight shift
- Short replayable mystery
- No multiplayer, open world, crafting, farming, or procedural town simulation

## Asset note

Julie owns the paid LimeZu packs used for the planned art pass. We will keep the supplied license files and include attribution in-game. Raw source assets will not be redistributed.
