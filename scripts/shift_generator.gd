class_name ShiftGenerator
extends RefCounted
## Builds one authored-but-randomized overnight shift from a seed.

var randomizer := RandomNumberGenerator.new()
var incident_engine: IncidentEngine

var customer_blueprints: Array[Dictionary] = [
    {"name": "The soaked traveler", "category": "cold", "need": "They need a flashlight to find a lost bag.", "issue": "They keep looking at the road behind you.", "question": "Ask what they saw on the road."},
    {"name": "The tired parent", "category": "warm", "need": "They need something warm for the child in the car.", "issue": "The child wears a hospital bracelet.", "question": "Ask if they need directions."},
    {"name": "The last customer", "category": "odd", "need": "They need a roll of quarters for the payphone.", "issue": "Their receipt already has tomorrow's date.", "question": "Ask why they are out this late."},
    {"name": "The stranded mechanic", "category": "odd", "need": "They need tape and a dry place to fix a hose.", "issue": "Their work van has no license plate.", "question": "Ask where the van came from."},
    {"name": "The midnight nurse", "category": "warm", "need": "They need coffee before driving to the next town.", "issue": "They have hospital ink on both hands.", "question": "Ask which way the hospital is."},
    {"name": "The silent teenager", "category": "cold", "need": "They need water and somewhere bright to wait.", "issue": "They keep checking a phone with no signal.", "question": "Ask who they are waiting for."},
    {"name": "The trucker with no truck", "category": "warm", "need": "They need coffee and a place to sit for five minutes.", "issue": "They know the name of the previous clerk.", "question": "Ask where they parked."},
    {"name": "The woman with the umbrella", "category": "cold", "need": "They need batteries for a radio that is only static.", "issue": "There is no rain outside, but their coat is soaked.", "question": "Ask which station they are trying to reach."},
    {"name": "The regular on the wrong night", "category": "odd", "need": "They need the same snack they buy every Thursday.", "issue": "They insist it is Thursday, and the calendar says Monday.", "question": "Ask what happened before they arrived."}
]

var mystery_threads: Array[Dictionary] = [
    {"name": "The missing mile marker", "clue": "Several customers refer to a road sign that is not on any map."},
    {"name": "The wrong radio station", "clue": "Different radios repeat the same voice beneath the static."},
    {"name": "The extra receipt", "clue": "The register prints one receipt more than the number of sales."},
    {"name": "The closed service road", "clue": "Customers arrive from a road the county says has been blocked for years."}
]

var shift_conditions: Array[String] = [
    "The cooler hums louder than usual.",
    "The coffee machine is one warning light away from retirement.",
    "The back door does not quite latch.",
    "The store radio only gets one station tonight."
]

var opening_task_templates: Array[Dictionary] = [
    {"category": "cold", "text": "Face the cooler before the first rush."},
    {"category": "warm", "text": "Wipe the warm station before it becomes a problem."},
    {"category": "odd", "text": "Check the odd shelf for anything out of place."}
]


func _init(seed_value: int = 0) -> void:
    if seed_value == 0:
        randomizer.randomize()
        seed_value = randomizer.seed
    else:
        randomizer.seed = seed_value
    incident_engine = IncidentEngine.new(seed_value + 1)

func generate_shift(customer_count: int) -> Dictionary:
    var encounters: Array[Dictionary] = []
    var available := customer_blueprints.duplicate(true)
    # Small in-aisle offsets: big offsets push browsing customers into fixtures.
    var browse_offsets: Array[Vector2] = [Vector2(-16.0, 10.0), Vector2(14.0, 12.0), Vector2(-12.0, -14.0), Vector2(16.0, -10.0)]
    for index in range(min(customer_count, available.size())):
        var selected := randomizer.randi_range(0, available.size() - 1)
        var encounter: Dictionary = available[selected].duplicate(true)
        encounter["browse_offset"] = browse_offsets[randomizer.randi_range(0, browse_offsets.size() - 1)]
        encounter["browse_pause"] = randomizer.randf_range(0.6, 1.2)
        encounters.append(encounter)
        available.remove_at(selected)

    incident_engine.prepare_shift(encounters.size())
    var mystery_index := randomizer.randi_range(0, mystery_threads.size() - 1)
    var condition_index := randomizer.randi_range(0, shift_conditions.size() - 1)
    var opening_tasks: Array[Dictionary] = []
    var available_tasks: Array[Dictionary] = opening_task_templates.duplicate(true)
    for task_index in range(2):
        var selected_task := randomizer.randi_range(0, available_tasks.size() - 1)
        var task: Dictionary = available_tasks[selected_task].duplicate(true)
        task["completed"] = false
        opening_tasks.append(task)
        available_tasks.remove_at(selected_task)

    var starting_stock := {
        "cold": randomizer.randi_range(2, 3),
        "warm": randomizer.randi_range(2, 3),
        "odd": randomizer.randi_range(2, 3)
    }
    return {
        "seed": randomizer.seed,
        "encounters": encounters,
        "incidents": incident_engine.scheduled_incidents.duplicate(true),
        "starting_stock": starting_stock,
        "mystery": mystery_threads[mystery_index],
        "condition": shift_conditions[condition_index],
        "opening_tasks": opening_tasks
    }
