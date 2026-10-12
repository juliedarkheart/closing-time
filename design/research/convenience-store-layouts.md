# Convenience Store Layouts — Research

Purpose: stop inventing a shop floor. The first graybox put three shelves in a row and a
register in the corner, which is not what a convenience store looks like. This documents
how real stores are laid out so the game's floor plan can be modelled on one.

## Sources

- JayComp Development — *Convenience Store Floor Plans & Layout Strategies* — https://jaycompdevelopment.com/convenience-store-floor-plans/
- JayComp Development — *Convenience Store Layout: Turning Square Footage Into Revenue* — https://jaycompdevelopment.com/convenience-store-layout/
- JayComp Development — *Gondola Shelving Layout for Convenience Stores* — https://jaycompdevelopment.com/gondola-shelving-layout/
- National Retail Solutions — *How to Lay Out Your Convenience Store for Maximum Impulse Sales* — https://nrsplus.com/blog/how-to-lay-out-your-convenience-store/
- Construction Methodology — *7-Eleven Store Construction Guide* (standard 2,400–3,200 sq ft zone and category tables) — https://constructionmethodology.com/construction-guides/convenience-store-construction-guide/7-eleven-store-construction-guide/
- Oak Ridge National Laboratory — *Defining the Prototype Convenience Store Building Characteristics*, ORNL/TM-2022/2822 (typical floor layout, space area distribution) — https://info.ornl.gov/sites/publications/Files/Pub189705.pdf

## Layout families

- **Grid** — parallel gondola runs, aisles perpendicular to the checkout counter. The
  industry standard for convenience retail: highest shelving density, instantly
  predictable, easiest to restock. This is the layout a player already has a mental
  model for, which is exactly what a small game wants.
- **Loop / racetrack** — a perimeter path with a lower center island. Guarantees exposure
  to every department and keeps sightlines open, but wastes floor space.
- **Free-flow / angular** — angled fixtures, browsing-friendly, upscale feel, poor
  inventory density. Used for premium formats.
- **Forced path** — route customers through everything before checkout. Rarely used in
  pure convenience because it is too slow.

For Closing Time: **grid**, with the loop's sightline advantage borrowed via low center
fixtures.

## Dimensions that matter

- **Aisle width** — 36 in is the ADA minimum, 42–48 in is the comfortable recommendation.
- **Fixture heights ("stadium effect")** — 72–84 in against perimeter walls, 54–60 in for
  the runs nearest the walls, 42–48 in for the center store closest to the checkout. The
  tiering is a loss-prevention decision: a cashier must be able to see the whole floor.
- **Decompression zone** — the first 5–15 ft inside the door. Customers are still
  adjusting to the space and rarely register anything placed there. Keep it clear.
- **Entry orientation** — within about two seconds of walking in, a customer should be
  able to see where the cooler is, where the register is, and where the category they
  usually buy lives.
- **Right-turn rule** — most shoppers drift right on entry.

## Zoning rules

- **Destination items go at the back.** Cold beverages and coffee are the reasons people
  come in, so they are placed as far from the door as practical. That forces a walk past
  high-margin impulse categories. Put the cooler next to the door and the customer is in
  and out without seeing the store.
- **The cold-vault approach path is the most valuable merchandising corridor** in the
  store. It gets lined with chips, candy and snacks.
- **The checkout counter is the highest-conversion impulse zone.** Sub-$3 items, kept
  clean, rotated seasonally.
- **Checkout goes near the entrance** in most formats, so staff have sight of the door and
  customers are not walked back through the store to pay. Queue geometry matters more than
  position: the line must not block the entry or the highest-traffic aisle.
- **Cooler door sequencing** — highest-margin beverages at eye level in the center doors;
  water and carbonated soft drinks anchor the edges.
- **Food service sits on natural sightlines from the entrance**, with its own ordering and
  pickup space so the food queue does not block retail aisles.

## Space budget

Standard 7-Eleven format, 2,400–3,200 sq ft:

| Zone | Share | Function |
| --- | --- | --- |
| Sales floor | 70% | customer shopping, clear sightlines, flexible fixtures |
| Hot food / kitchen | 8% | food prep and service |
| Storage / receiving | 10% | inventory, direct delivery access |
| Walk-in cooler | 5% | back-stock refrigeration |
| Back office | 3% | management, safe, records |
| Restrooms | 3% | customer facilities |
| Mechanical | 1% | HVAC and electrical |

Sales floor category allocation: cold beverages 25%, snacks and candy 20%, tobacco 10%,
hot food and coffee 15%, grocery 15%, health and beauty 7.5%, automotive and misc 7.5%.

Equipment footprints worth knowing: a three-door beverage cooler is roughly 6 ft × 2 ft ×
7 ft; a walk-in cooler is about 8 ft × 10 ft × 8 ft; roller grills, coffee brewers and hot
food warmers are counter-scale units.

## How the game uses this

The playfield is now a top-down read of that plan:

| Game zone | Real-world basis |
| --- | --- |
| Parking strip above the glass frontage | forecourt and lot in front of the store |
| Entrance right of center in the storefront | right-turn rule, arrival from the lot |
| Decompression zone just inside the door | first 5–15 ft kept clear |
| Front counter, front-right, facing the glass | checkout near the entrance with sight of the door and lot |
| Coffee and hot food island, front-center | food service on the entrance sightline, its own prep space |
| Two dry-goods and snack gondola runs down the middle, 44 px aisle | grid layout, 42–48 in aisles, stadium-effect sightlines |
| Cold vault along the back wall | destination category pushed to the back so customers walk the store |
| Restroom at the back, off the floor | restrooms in the service zone, not the entry |
| Back room with the mop and bucket | storage/receiving, cleaning supplies |
| Ceiling camera at the front | security coverage sighted from the counter |

Playable translation of the numbers: 44 px between gondola runs stands in for the 42–48 in
recommendation, and the store is deliberately arranged so the register cannot see the
back corner — which is what makes the shoplifting incident possible at all.
