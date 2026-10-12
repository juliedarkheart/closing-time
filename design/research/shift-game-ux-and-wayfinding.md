# Shift-Game UX, Wayfinding and Readability — Research

Purpose: the first playtest failed on three things a player should never have to fight:
text was clipped, the opening tasks were invisible, and interactable objects did not
announce themselves. This documents the established patterns for fixing all three, and
draws the line between deliberate friction and accidental friction.

## Sources

- *Wayfinding* — The Level Design Book — https://book.leveldesignbook.com/process/blockout/wayfinding
- Roblox documentation — *Proximity prompts* (object, action and key; activation distance) — https://create.roblox.com/docs/en-us/ui/proximity-prompts.md
- *Visual Design of Games — Papers, Please* — The Mechanics of Magic — https://mechanicsofmagic.com/2022/04/18/visual-design-of-games-papers-please/
- Paradox Interactive — *Dev Diary #51: Tutorial* (progressive, opt-in onboarding) — https://www.paradoxinteractive.com/games/victoria-3/news/dev-diary-51-tutorials
- *Teaching Mechanics Without a Tutorial Screen* — Flukz — https://flukz.org/devlog/onboarding-without-tutorial-screen/

## Wayfinding

Players build a mental map from five kinds of element: **paths** they move along,
**edges** that bound areas, **districts** that share a look, **nodes** where paths meet,
and **landmarks** they navigate by. Three behavioural rules follow from the research and
are directly usable:

1. Players look where they are moving.
2. Players look at contrast — colour, shape, lighting, movement.
3. Players do not look up unless something draws their eye there.

Guidance should be treated as a ladder from subtle to explicit, starting subtle and
escalating only in response to playtesting. The relevant rungs for this game: a landmark
first, then identification signage, then directional signage, then an explicit objective
list. The Level Design Book is blunt that the final rung is legitimate — the goal is to
give players tools and information, not to trick them into the critical path.

Signage divides into four kinds: **informational** (hours, wifi), **directional**
(arrows at decision points), **identification** (you have arrived; a label on the thing),
and **regulatory** (what you may not do). A shop should mostly use identification signage
on fixtures and directional signage at junctions.

## Proximity prompts

The standard interaction pattern: an interactable announces (a) that it can be
interacted with, (b) the name of the action, and (c) the key that performs it, only while
the player is inside an activation range. Prompts are range-limited and normally one
prompt per key, so the screen does not fill with competing labels.

Applied here: standing at a fixture shows `[E] Face the cooler`, standing at the counter
with a customer waiting shows `[E] Serve The tired parent`. The prompt is drawn at the
object, not in a corner, so it reads as property of the thing rather than a HUD element.

## Deliberate friction versus accidental friction

Papers, Please is often cited for cramped, overlapping, hostile UI — and the point of
that design debate is that its friction is *intentional*: the desk is meant to feel
overwhelming, and cleaning it up would remove the experience. The lesson worth taking is
the distinction, not the style. Friction a designer chose is design. Friction the player
meets by accident — clipped text, an unstated objective, an invisible interactable — is
just a bug wearing a mechanic's coat. Closing Time wants the *workload* to feel heavy and
the *interface* to feel calm and legible.

## Onboarding

Progressive onboarding defers a mechanic until the moment it is needed. A modal that
explains everything up front interrupts exactly the rhythm the game is trying to build,
and players retain a mechanic better when the level demands it a second before the game
names it. Applied here: the clipboard shows the current objective rather than the whole
system, and incident handling is taught the first time an incident appears, not in a
preface.

## Applied rules for Closing Time

1. **Nothing is clipped.** Wrap text to the panel, size the panel to the wrapped text.
   `draw_string()` with a fixed width truncates; that was the bug.
2. **The objective is always on screen.** A shift clipboard lists the current tasks with
   tick marks, and counts progress against the shift totals.
3. **Every interactable announces itself** with a proximity prompt naming the object and
   the action.
4. **Fixtures carry identification signage** — COLD DRINKS, COFFEE · HOT FOOD, DRY GOODS,
   SNACKS, FRONT COUNTER, RESTROOM, BACK ROOM — so the floor plan is readable without a
   tutorial.
5. **Districts read as districts.** Floor, fixtures and exterior each have a distinct
   value and hue, so the layout is legible at a glance from the wide shot.
6. **Failure explains itself.** Any refused action says why in the same box that would
   have confirmed it.
7. **Escalate in response to playtesting.** If a player still misses something, the next
   rung is a directional cue toward the target, not a longer sentence of text.
