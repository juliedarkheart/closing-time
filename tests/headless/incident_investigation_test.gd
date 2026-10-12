extends SceneTree
## Verifies that incidents must be physically observed, investigated, and then handled.

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
    check(game.completed_opening_tasks == game.opening_tasks.size(), "opening tasks complete")
    return game

func wait_for_customer(game: Node2D) -> bool:
    for step in range(120):
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

func investigate_and_resolve(game: Node2D) -> bool:
    var kind: String = game.active_incident["kind"]
    check(game.incident_stage == "observed", "incident starts observed")
    game.player_position = Vector2(250.0, 440.0)
    game._interact()
    check(game.incident_active, "incident still active away from the site")
    check(game.incident_stage == "observed", "walking past does not identify the incident")
    game.player_position = game._incident_location_rect().get_center()
    game._interact()
    check(game.incident_active, "incident still active after investigating")
    check(game.incident_stage == "inspected", "investigating identifies the incident")
    if game._incident_needs_mop():
        game._interact()
        check(game.incident_active, "spill cannot be resolved without the mop")
        check(not game.holding_mop, "mop not held yet")
        game.player_position = game.MOP_RECT.get_center()
        game._interact()
        check(game.holding_mop, "mop picked up at the utility corner")
        game.player_position = game._incident_location_rect().get_center()
    game._interact()
    check(not game.incident_active, "incident resolved")
    check(not game.holding_mop, "mop put away after use")
    check(game.aftermath.has(kind), "aftermath evidence recorded for " + kind)
    print("  incident handled: kind=%s aftermath=%d" % [kind, game.aftermath.size()])
    return true

func _init() -> void:
    var game := await make_game(1001)
    var incident_total: int = game.incident_plan.size()
    check(incident_total >= 2, "at least two incidents scheduled")
    var resolved := 0
    for customer_index in range(game.encounters.size()):
        game.player_position = game.REGISTER_RECT.get_center()
        game._start_next_encounter()
        if not serve_current_customer(game):
            break
        if game.incident_active:
            investigate_and_resolve(game)
            resolved += 1
    check(resolved == incident_total, "every scheduled incident was handled")
    check(game.aftermath.size() == incident_total, "aftermath evidence persisted")
    for step in range(10):
        await process_frame
    check(game.draw_count > 0, "scene rendered")
    game.player_position = game.REGISTER_RECT.get_center()
    game._start_next_encounter()
    check(game.dawn_reached, "dawn reached")
    var previous_seed: int = game.shift_seed
    game._start_new_shift()
    check(game.shift_seed != previous_seed, "new shift reseeded")
    check(game.served_customers == 0, "new shift resets serving")
    check(game.aftermath.is_empty(), "new shift clears aftermath")
    check(game.completed_opening_tasks == 0, "new shift restores opening tasks")
    check(game.opening_tasks.size() == 2, "new shift has two opening tasks")
    if failures == 0:
        print("incident investigation pass: seed=%d incidents=%d aftermath=%d draws=%d" % [previous_seed, incident_total, incident_total, game.draw_count])
    else:
        print("incident investigation FAILED: %d checks failed" % failures)
    quit(1 if failures > 0 else 0)
