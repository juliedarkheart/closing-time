class_name IncidentEngine
extends RefCounted
## Selects authored night-shift incidents for one reproducible or random shift.

var randomizer := RandomNumberGenerator.new()
var definitions: Array[Dictionary] = [
    {
        "kind": "bathroom",
        "location": "bathroom",
        "title": "Someone is unresponsive in the bathroom.",
        "detail": "Keep the area clear and check safely.",
        "instruction": "Go there, keep the area clear, and press E to check safely.",
        "joke": "The manager's emergency policy sheet is missing page two.",
        "resolution": "You check from the doorway, call the manager, and keep customers away. Incident logged.",
        "stock_category": "",
        "stock_loss": 0,
        "safety_gain": 1,
        "handoff_gain": 1
    },
    {
        "kind": "shoplifting",
        "location": "odd_shelf",
        "title": "Someone took an item from the odd shelf.",
        "detail": "They are heading for the door.",
        "instruction": "Go to the shelf, document it, and let the manager handle the chase.",
        "joke": "The camera is pointed at the ceiling again.",
        "resolution": "You do not chase them. You note the description, call the manager, and log one missing item.",
        "stock_category": "odd",
        "stock_loss": 1,
        "safety_gain": 1,
        "handoff_gain": 1
    },
    {
        "kind": "coupon",
        "location": "register",
        "title": "The coupon is older than the employee handbook.",
        "detail": "It is from a store that closed seventeen years ago.",
        "instruction": "Return to the register, refuse it politely, and log the discrepancy.",
        "joke": "The barcode scans as: PLEASE SEE MANAGER.",
        "resolution": "You refuse the coupon, write down the register discrepancy, and discover the date is tomorrow.",
        "stock_category": "",
        "stock_loss": 0,
        "safety_gain": 0,
        "handoff_gain": 1
    },
    {
        "kind": "spill",
        "location": "warm_shelf",
        "title": "The coffee-station spill has returned.",
        "detail": "You already cleaned this exact puddle ten minutes ago.",
        "instruction": "Inspect the warm station and press E to find the source.",
        "joke": "The wet-floor sign is facing the wall for reasons nobody can explain.",
        "resolution": "You trace the spill to a leaking dispenser and leave a repair note for morning.",
        "stock_category": "",
        "stock_loss": 0,
        "safety_gain": 1,
        "handoff_gain": 1
    },
    {
        "kind": "parking_lot",
        "location": "register",
        "title": "Someone is asleep in a running car outside.",
        "detail": "You cannot see whether they are all right from the window.",
        "instruction": "Use the phone at the register to request a safe welfare check.",
        "joke": "The phone directory lists three managers and none of them work here anymore.",
        "resolution": "You request a welfare check without approaching the car and record the time.",
        "stock_category": "",
        "stock_loss": 0,
        "safety_gain": 1,
        "handoff_gain": 1
    }
]
var scheduled_incidents: Dictionary = {}

func _init(seed_value: int = 0) -> void:
    if seed_value == 0:
        randomizer.randomize()
    else:
        randomizer.seed = seed_value

func prepare_shift(customer_count: int) -> void:
    scheduled_incidents.clear()
    if customer_count <= 0:
        return
    var incident_count := randomizer.randi_range(2, min(3, customer_count))
    var available_indices: Array[int] = []
    for index in range(customer_count):
        available_indices.append(index)
    var available_definitions: Array[Dictionary] = definitions.duplicate(true)
    for incident_index in range(incident_count):
        if available_definitions.is_empty() or available_indices.is_empty():
            break
        var customer_slot := randomizer.randi_range(0, available_indices.size() - 1)
        var customer_index: int = available_indices[customer_slot]
        available_indices.remove_at(customer_slot)
        var definition_index := randomizer.randi_range(0, available_definitions.size() - 1)
        scheduled_incidents[customer_index] = available_definitions[definition_index]
        available_definitions.remove_at(definition_index)

func incident_for_customer(customer_index: int) -> Dictionary:
    return scheduled_incidents.get(customer_index, {})
