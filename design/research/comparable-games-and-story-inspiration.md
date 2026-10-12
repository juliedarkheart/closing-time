# Comparable Games and Story Inspiration

Research completed before expanding the Closing Time prototype.

## Short conclusion

Closing Time should not be a dialogue game with shop decoration around it. The strongest comparable designs make the player's work task the way they learn, help, fail, and change the story. That is the central problem of playable narrative: mechanics and story need to feel like one experience rather than alternating systems.[23]

The target combination is:

- **Gas Station Story:** separate but connected work layers: walking around the shop, point-of-sale, dialogue, and short task games.[15]
- **Strange Horticulture:** customer problems become small identification/deduction puzzles, and the item chosen changes the mystery.[17]
- **Coffee Talk and VA-11 HALL-A:** service is the narrative choice; the served item changes what customers reveal and what happens later.[18][21]
- **Papers, Please:** routine inspection becomes meaningful when information is incomplete, rules change, and decisions have visible human costs.[20]
- **Chilla's Art's The Convenience Store:** ordinary night-shift work creates a strong baseline for small, carefully timed disturbances; the game is short and uses a compact location with multiple endings.[16]
- **Potion Craft:** tactile preparation and inventory constraints can make a simple customer request feel like a real player task rather than a menu selection.[19]

The design lesson is not to copy any one game. It is to make a small number of store actions carry several kinds of meaning.

## What to borrow mechanically

### 1. Give every request a physical verb

A customer request should cause the player to do something in the shop:

- retrieve an item;
- check a temperature;
- clean or repair a station;
- compare a label or date;
- call someone from the back office;
- choose whether to sell, refuse, or make an exception.

The player should be able to describe what they did, not only which dialogue option they clicked. Gas Station Story explicitly separates the overworld, point-of-sale, dialogue, and mini-games, which is a useful model for a small commercial slice.[15]

### 2. Make questions produce usable information

A question should reveal a fact that changes the next action. Examples:

- “Is this for you?” reveals that the customer needs a specific temperature or quantity.
- “Where did you come from?” reveals a road, landmark, or missing-person clue.
- “Why this brand?” reveals a substitution the customer will or will not accept.
- “Do you need the phone?” creates a safety/help decision.

Coffee Talk shows the value of making service affect narrative progression rather than putting all agency in explicit dialogue buttons.[18] Closing Time should apply that idea to real shop work, while keeping the player physically active.

### 3. Use authored variation, not uncontrolled procedural story

Randomness should choose from authored encounter parts:

- customer archetype;
- practical request;
- visible tell;
- hidden complication;
- possible response;
- consequence;
- clue or follow-up flag.

The combination can vary, but every result must be understandable and testable. Strange Horticulture is a useful model because the shop's mystery grows through identifiable objects, clues, and deliberate item choices rather than random text soup.[17]

### 4. Let routine create the contrast

The first minutes should feel safe and ordinary: delivery, shelf facing, coffee cleanup, a normal sale. Then one detail should be wrong. Chilla's Art's convenience-store game uses the familiar night-shift setting as the baseline before introducing strange developments and curiosity-driven branches.[16]

For Closing Time, “cozy” means the player knows how the store works. “Mysterious” means the store occasionally asks them to decide whether the ordinary explanation is still enough.

### 5. Keep consequences legible and local

Do not build a huge branching tree. Track a few state values and customer flags:

- cash;
- stock and waste;
- cleanliness/safety;
- trust;
- curiosity or clue progress;
- whether a customer will return;
- whether the morning handoff is credible.

Papers, Please demonstrates how a small repeated decision can gain weight when the rules, evidence, and personal consequences change over time.[20] Closing Time can get similar weight with a much gentler tone and much smaller scope.

## What to avoid

- **Dialogue-only service:** Coffee Talk and VA-11 HALL-A prove that service can carry story, but their core actions are still narrow. Closing Time needs more store movement and task variety because the fantasy is “working the whole overnight shop,” not only listening behind a counter.[18][21]
- **Walking-simulator pacing:** Chilla's Art is a useful atmosphere reference, but its model is primarily walking and puzzle solving. It should inform our escalation and use of mundane chores, not define our whole loop.[16]
- **Full retail simulation:** realistic paperwork, fuel systems, vendors, and detailed compliance would bury the mystery. Borrow priorities from the job, not every procedure.
- **Random lore generation:** oddness without a practical response becomes flavor text. Every strange detail needs an observable consequence or a meaningful choice.
- **Constant horror escalation:** if every customer is alarming, nothing is comforting. Preserve quiet stretches, familiar regulars, and satisfying cleanup work.

## Night-shift craziness and parody

The overnight shift should also have a comic pressure layer: the player is trying to stock shelves and make the store feel welcoming while dealing with the kind of incidents that make a real clerk say, “I am not trained for this.” The comedy should come from timing, bureaucracy, contradictory priorities, and the store's inadequate procedures—not from treating addiction, homelessness, illness, or vulnerability as inherently funny.

### Incident families

| Incident | Player problem | Possible responses | Consequence space |
|---|---|---|---|
| Bathroom emergency | A customer is unconscious or unwell while someone waits at checkout | Check safely, call for help, secure the area, document it | Safety, time, trust, handoff |
| Shoplifting | A customer pockets an item during another task | Alert manager, confront cautiously, block the exit, let it go | Stock, safety, cash, reputation |
| Parking-lot sleeper | Someone is asleep in a running car | Observe from safety, call assistance, leave a note | Clue, time, safety |
| Impossible coupon | The coupon is invalid, bizarre, or clearly not for this store | Refuse, ask for clarification, accept and report it | Cash, customer mood, mystery |
| Recurring spill | A mess returns after being cleaned | Re-clean, inspect the source, mark it for handoff | Cleanliness, time, clue |

Each incident should have a humane baseline response that is easy to discover. The funny part is the collision with the rest of the shift: the bathroom call happens during a rush, the thief chooses the exact moment the cooler alarm starts, or the manager texts a useless policy screenshot instead of useful help.

### Design rule

Treat an incident as a playable interruption, not a cutscene. It should ask the player to move, inspect, choose, or document something, then leave a state change the player can see. Do not make the player a vigilante, medical professional, or police officer. The player is a clerk making a safe first response and deciding what can wait.

### Recommended escalation

1. **Absurd but harmless:** impossible coupon, customer arguing with the coffee machine, someone asking for directions to a place that is not on the map.
2. **Inconvenient:** recurring spill, blocked restroom, delivery mistake, shoplifter.
3. **Safety-sensitive:** passed-out customer, suspicious vehicle, electrical fault, aggressive customer.
4. **Mystery-linked:** an incident that appears ordinary until a later customer describes the same detail.

Do not make every incident supernatural. The funniest and strangest nights need ordinary problems mixed with the genuinely inexplicable ones.

## Storyline inspiration, transformed into original design seeds

These are structural inspirations only. Do not copy their plots, characters, names, dialogue, creatures, visual signatures, or distinctive reveals.

### A. The store as a crossroads

The Gas Station / roadside-night tradition treats an isolated shop as a place where travelers, locals, drifters, and impossible visitors briefly overlap.[24] The useful structure is **a fixed place that receives fragments of a larger world**.

Original Closing Time seed: customers arrive with unrelated problems that gradually share one mundane location: an abandoned service road, a missing mile marker, or a radio dead zone. The player learns the connection by stocking, cleaning, and serving—not by being assigned a detective quest.

### B. The customer who needs an ordinary item for an extraordinary reason

Strange Horticulture turns customer requests into problems where the correct object can help, harm, or redirect a person's story.[17] The useful structure is **ordinary retail knowledge becoming practical deduction**.

Original Closing Time seed: a customer asks for a normal product, but their explanation makes the player inspect condition, quantity, timing, or substitution. The player can satisfy the literal request, ask one useful question, or notice that the safest response is to involve another person.

### C. A refuge for people awake at the wrong hour

Coffee Talk frames a late-night shop as a place where people can speak more honestly because the rest of the world is quiet.[18] The useful structure is **the shop as emotional shelter**.

Original Closing Time seed: not every odd customer is a threat. Some are lonely, stranded, grieving, embarrassed, or simply unable to go home yet. The player can make the shop feel safe through small acts: a warm item, a phone call, directions, a clean seat, or remembering a prior preference.

### D. The routine slowly becomes unreliable

The Convenience Store and The Closing Shift use familiar work tasks, a compact location, and gradually stranger incidents to build tension.[16][22] The useful structure is **escalation through changed interpretation of familiar objects**.

Original Closing Time seed: a shelf is faced incorrectly, a receipt has a time that does not exist, a customer describes an aisle that is not in the store, or the outside light shows a vehicle that never entered. Keep these incidents ambiguous at first. The player can investigate, document, or leave a handoff note.

### E. Service choices become the branching system

Coffee Talk and VA-11 HALL-A use the served drink as a story choice instead of relying only on dialogue buttons.[18][21] The useful structure is **the player's practical response reveals their values**.

Original Closing Time seed: serve exactly what was requested, offer a safer substitute, give help without making a sale, refuse a suspicious request, or call for assistance. The story branches based on the pattern of actions, not one “good/bad” button.

## Recommended Closing Time narrative shape

### Frame

One overnight shift at a small roadside shop during a period of unusual road closures and unreliable radio service.

### Act 1: Familiar work

- Receive a small delivery.
- Stock and face shelves.
- Clean the coffee station.
- Serve one normal customer.
- Establish one friendly regular and one store rule.

### Act 2: The odd requests

- A customer needs an item for a reason that does not quite fit.
- A second customer contradicts the first customer's account.
- A store problem creates a real priority conflict: serve, clean, inspect, or investigate.
- The player can ask useful questions, but time and stock make every response imperfect.

### Act 3: The handoff decision

- The player finds a concrete clue, not a lore dump.
- A final customer needs help that may be unrelated—or may explain the earlier details.
- The player chooses what to record for morning and whether to leave the store problem unresolved.
- Dawn summary reflects operations, people helped, safety, and curiosity.

### Endings for the first story slice

Keep three endings, based on compact state checks:

1. **Clean Handoff:** the store is safe, the player helped people, and the mystery remains a question.
2. **Quiet Pattern:** the player follows the clues and records a credible connection, earning a new lead for the next shift.
3. **Missed Signal:** the player keeps the shop running but ignores or mishandles enough warning signs that the next shift inherits the problem.

No ending should require a hidden “correct” answer. The player should understand why their night ended that way.

## Build recommendation before more content

Do not add six customers or a large mystery yet. Build one complete encounter that proves the design:

1. A shelf is low or incorrectly faced.
2. A customer arrives with a practical request and a strange tell.
3. The player can ask one question.
4. The player must retrieve, inspect, substitute, or refuse an item.
5. A night-shift incident interrupts the store routine.
6. The player makes a safe first response while another task waits.
7. The player serves or helps the customer.
8. The result changes at least two visible state values and leaves one clue or handoff note.
9. The player can see what the morning handoff records.

If that encounter is satisfying, expand it into three authored encounter families. If it is not satisfying, more lore will not fix it.

## Sources

[15] https://store.steampowered.com/app/2741780/Gas_Station_Story
[16] https://chillas-art.itch.io/the-convenience-store
[17] https://store.steampowered.com/app/1574580/Strange_Horticulture
[18] https://www.togeproductions.com/project/coffee-talk
[19] https://store.steampowered.com/app/1210320/Potion_Craft_Alchemist_Simulator
[20] https://store.steampowered.com/app/239030/Papers_Please
[21] https://store.steampowered.com/app/447530/VA11_HallA_Cyberpunk_Bartender_Action
[22] https://store.steampowered.com/app/1843090/Chillas_Art_The_Closing_Shift
[23] https://gdcvault.com/play/1035559/Game-Narrative-Summit-Creating-Playable
[24] https://www.gasstationjack.com/about
