# Story: Customer Loop

- Epic: overnight-graybox
- Status: Planned
- Priority: P0
- Layer: gameplay / prototype
- Points: 3

## Description

Replace the single register test with three short customer encounters that require a choice and produce visible consequences.

## Acceptance Criteria

- [ ] Three customers appear in a deterministic sequence.
- [ ] Each customer presents at least one observable clue.
- [ ] Each encounter offers at least two meaningful responses.
- [ ] A response changes at least one of cash, stock, trust, or mystery progress.
- [ ] The player can reach a dawn summary after the third encounter.

## Technical Notes

Use simple data-driven dictionaries or resources. Do not build a general dialogue framework yet.

## Dependencies

`story-graybox-runtime.md` must pass first.

## Test Strategy

Play the sequence twice with different responses and confirm the summary or tracked state differs. Verify there is no dead end when stock reaches zero.
