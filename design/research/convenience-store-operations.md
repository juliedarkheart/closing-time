# Convenience Store Operations Research

## What real overnight work gives us

Wawa's customer-service role combines customer service, food and beverage preparation, register work, housekeeping, stocking cold cases and grocery aisles, coffee supplies, and food-service supplies.[10]

Independent c-store operations checklists group recurring work into cash/register, foodservice, coolers, restrooms, forecourt, age-restricted products, and shift handoff notes.[11][12] That gives Closing Time a credible task structure without simulating an entire chain.

Food safety is useful as a readable game pressure. The FDA Food Code is a model for safe retail food handling, and common c-store checklists use cold holding at 41°F or below and hot holding at 135°F or above as the visible thresholds.[12][13] The game can simplify this into check the cooler, check the hot case, and respond when one drifts out of range.

Spills and hazards should be actionable rather than decorative. OSHA records a convenience-store clerk injury caused by slipping on a fuel spill, and its retail safety guidance emphasizes keeping walkways clear and cleaning or marking spills promptly.[14]

## Closing Time task model

### Player actions

- **Stock:** carry a case from the backroom and fill a shelf; rotate older product forward.
- **Face:** pull products to the front so low stock and missing items are visible.
- **Temperature check:** use the thermometer on the cold case or hot case; log a reading.
- **Clean:** wipe the coffee station, clear a spill, empty a bin, or mop a marked area.
- **Serve:** scan the customer's requested item, take payment, and return change/receipt.
- **Question:** ask one useful question that reveals a need, urgency, or clue. It must change a later decision.
- **Handoff:** record a problem for morning rather than magically fixing every problem alone.

### Pressure model

The shift is a short prioritization puzzle. Customers arrive while tasks become due. The player cannot do everything immediately, so they decide whether to:

- serve a waiting customer;
- finish stocking before the morning rush;
- check a questionable cooler;
- clean a spill before someone slips;
- investigate a strange customer or leave it for the handoff note.

There is no harsh real-time fail state in the first slice. Instead, neglected tasks create visible consequences: empty shelves reduce sales, missed temperature checks spoil food, an uncleared spill causes a safety incident, and an incomplete handoff lowers the dawn score.

## First playable operations slice

One compact shop, one eight-to-twelve-minute overnight shift:

1. Receive a small delivery in the backroom.
2. Stock and face three shelf groups: cold, warm, and odd.
3. Check one cooler and one hot-hold unit.
4. Serve three customers with actual item retrieval and checkout.
5. Clean one coffee-station task and one spill.
6. Ask one useful question during one customer interaction.
7. Complete a dawn handoff showing sales, waste, safety, cleanliness, and clues.

## What stays out

- Full fuel-pump simulation
- Lottery and tobacco compliance systems
- Vendor ordering and invoices
- Employee scheduling
- Detailed cash accounting
- Real legal compliance as a game system
- A giant checklist UI

The game borrows the rhythm and priorities of the job, not its paperwork burden.

## Sources

[10] https://careers.wawa.com/us/en/customer-service-associate-jd
[11] https://www.xenia.team/articles/daily-convenience-store-checklist-for-successful-business
[12] https://maintainiq.com/checklist/convenience-store-opening-closing-checklist-pdf/
[13] https://www.fda.gov/food/fda-food-code/food-code-2022
[14] https://www.osha.gov/ords/imis/accidentsearch.accident_detail?id=139694.015
