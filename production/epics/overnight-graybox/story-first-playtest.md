# Story: First Blind Playtest

- Epic: overnight-graybox
- Status: Planned
- Priority: P0
- Layer: QA / production
- Points: 1

## Description

Run the first blind test of the complete graybox segment and preserve evidence for the next scope decision.

## Acceptance Criteria

- [ ] A tester who has not been briefed can start the project.
- [ ] The tester reaches the first interaction without coaching.
- [ ] The tester completes at least three encounters or reports the exact blocker.
- [ ] The tester notices the mystery clue or reports that it was unclear.
- [ ] Results are recorded with build/commit, steps, observations, and follow-up.

## Technical Notes

Do not mark the slice accepted from code inspection alone. Godot runtime evidence is required.

## Dependencies

`story-customer-loop.md` must pass first.

## Test Strategy

Use the seeded report under `production/playtests/`, record observed behavior separately from interpretation, and mark unresolved items as pending retest.
