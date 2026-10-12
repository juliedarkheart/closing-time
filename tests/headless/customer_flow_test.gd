extends SceneTree
## Verifies the seeded customer flow: visible entry, browsing, register service, and dawn.

var failures: int = 0

func check(condition: bool, label: String) -> bool:
    if not condition:
        failures += 1
        print("FAIL: " + label)
    return condition

func make_game(seed_value: int) -> Node2D:
    var scene := load("res://scenes/main.tscn") as PackedScene
    var game := scene.instantiate()
    game.shift_seed = seed_value
    root.add_child(game)
    await process_frame
    for task in game.opening_tasks:
        game._take_item(task["category"])
    check(game.completed_opening_tasks == game.opening_tasks.size(), "opening tasks complete for seed %d" % seed_value)
    return game

func wait_for_customer(game: Node2D) -> bool:
    for step in range(140):
        if game.customer_phase == "waiting":
            return true
        game._update_customer(0.1)
    return check(false, "customer reached the register")

func serve_current_customer(game: Node2D) -> bool:
    if not wait_for_customer(game):
        return false
    var category: String = game.encounters[game.current_encounter]["category"]
    game.player_position = game.SHELF_RECTS[category].get_center()
    game._take_item(category)
    game.player_position = game.REGISTER_RECT.get_center()
    game._serve_customer()
    return true

func handle_active_incident(game: Node2D) -> void:
    game.player_position = game._incident_location_rect().get_center()
    game._interact()
    if game.incident_active and game._incident_needs_mop():
        game.player_position = game.MOP_RECT.get_center()
        game._interact()
        game.player_position = game._incident_location_rect().get_center()
    if game.incident_active:
        game._interact()
    check(not game.incident_active, "incident resolved in the shift run")

func _init() -> void:
    var first := await make_game(1001)
    var repeat := await make_game(1001)
    var different := await make_game(2002)

    check(first.shift_data["seed"] == repeat.shift_data["seed"], "same seed reproduces the shift")
    check(first.encounters == repeat.encounters, "same seed reproduces the customer cast")
    check(first.incident_plan == repeat.incident_plan, "same seed reproduces the incident schedule")
    check(first.shift_data["opening_tasks"] == repeat.shift_data["opening_tasks"], "same seed reproduces the opening tasks")
    check(first.encounters != different.encounters or first.incident_plan != different.incident_plan, "different seed varies the shift")
    check(first.incident_plan.size() >= 2, "at least two incidents scheduled")
    check(first.incident_plan.size() <= 3, "no more than three incidents scheduled")

    first.player_position = first.REGISTER_RECT.get_center()
    for customer_index in range(first.encounters.size()):
        first._start_next_encounter()
        if not serve_current_customer(first):
            break
        if first.incident_active:
            handle_active_incident(first)

    first.player_position = first.REGISTER_RECT.get_center()
    first._start_next_encounter()
    check(first.dawn_reached, "dawn reached after the last customer")
    check(first.served_customers == first.encounters.size(), "every customer served")
    check(first.aftermath.size() == first.incident_plan.size(), "every incident left aftermath evidence")
    for step in range(10):
        await process_frame
    check(first.draw_count > 0, "scene rendered")

    if failures == 0:
        print("customer flow pass: seed=%d tasks=%d customers=%d incidents=%d" % [first.shift_data["seed"], first.completed_opening_tasks, first.served_customers, first.incident_plan.size()])
    else:
        print("customer flow FAILED: %d checks failed" % failures)
    quit(1 if failures > 0 else 0)
