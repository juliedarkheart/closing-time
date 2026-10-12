extends SceneTree
## Verifies the two things the first playtest broke on:
##  1. no dialogue can be clipped (every line of worst-case text fits its panel)
##  2. the floor plan is a real convenience-store plan (zoning, aisles, clear floor)

var failures: int = 0

func check(condition: bool, label: String) -> bool:
    if not condition:
        failures += 1
        print("FAIL: " + label)
    return condition

func _init() -> void:
    var scene := load("res://scenes/main.tscn") as PackedScene
    var game := scene.instantiate() as ClosingTimeShift
    game.shift_seed = 1001
    root.add_child(game)
    await process_frame

    var font := ThemeDB.fallback_font

    # --- Text can never be clipped -----------------------------------------
    var engine := IncidentEngine.new(1001)
    var worst_entries: Array[String] = []
    for definition: Dictionary in engine.definitions:
        worst_entries.append(String(definition["title"]))
        worst_entries.append(String(definition["detail"]))
        worst_entries.append(String(definition["instruction"]))
        worst_entries.append(String(definition["joke"]))
        worst_entries.append(String(definition["resolution"]))
    worst_entries.append("You need the mop from the back room before you can clean this up.")
    for encounter: Dictionary in game.encounters:
        worst_entries.append(String(encounter["name"]))
        worst_entries.append(String(encounter["need"]))
        worst_entries.append(String(encounter["issue"]))
        worst_entries.append(String(encounter["question"]))
        worst_entries.append("Wrong item served. The customer leaves unconvinced.")
    check(worst_entries.size() > 20, "worst-case text corpus is populated")
    var widest := 0.0
    var widest_line := ""
    for entry in worst_entries:
        for line in game._wrap_text(entry, game.NOTICE_INNER_WIDTH, game.NOTICE_FONT_SIZE):
            var width: float = font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, game.NOTICE_FONT_SIZE).x
            if width > widest:
                widest = width
                widest_line = line
    check(widest <= game.NOTICE_INNER_WIDTH + 1.0, "widest wrapped line fits (%.0f px): %s" % [widest, widest_line])

    var tall_panel: Rect2 = game._notice_panel_rect("NIGHT-SHIFT INCIDENT", [
        "Someone is unresponsive in the bathroom.",
        "Go there, keep the area clear, and press E to check safely.",
        "The manager's emergency policy sheet is missing page two.",
        "You need the mop from the back room.",
    ])
    check(tall_panel.position.y >= game.FLOOR_RECT.position.y, "tallest incident panel stays on screen")
    check(tall_panel.end.y <= game.FLOOR_RECT.end.y, "panel bottom stays inside the store block")
    var short_panel: Rect2 = game._notice_panel_rect("", ["The night shift begins. The back door does not quite latch."])
    check(short_panel.position.y > tall_panel.position.y, "short message panel is shorter than the incident panel")

    # --- Floor plan sanity --------------------------------------------------
    var fixtures: Dictionary = {
        "register": game.REGISTER_RECT,
        "coffee": game.COFFEE_RECT,
        "gondola_a": game.GONDOLA_A_RECT,
        "gondola_b": game.GONDOLA_B_RECT,
        "cold_vault": game.COLD_VAULT_RECT,
        "restroom": game.RESTROOM_RECT,
        "back_room": game.BACK_ROOM_RECT,
    }
    var names: Array = fixtures.keys()
    for i in range(names.size()):
        for j in range(i + 1, names.size()):
            var first: Rect2 = fixtures[names[i]]
            var second: Rect2 = fixtures[names[j]]
            check(not first.intersects(second, true), "%s does not overlap %s" % [names[i], names[j]])
    for fixture_name in fixtures:
        var rect: Rect2 = fixtures[fixture_name]
        check(game.FLOOR_RECT.encloses(rect), String(fixture_name) + " sits inside the sales floor")

    # Aisles: 42-48 inches is the retail recommendation, 36 inches the minimum.
    var aisle: float = game.GONDOLA_B_RECT.position.x - game.GONDOLA_A_RECT.end.x
    check(aisle >= 40.0, "gondola aisle is walkable (%.0f px)" % aisle)
    check(game.COFFEE_RECT.end.y < game.GONDOLA_A_RECT.position.y, "front power aisle separates coffee island from gondolas")

    # Destination zoning: cold vault on the back wall, checkout at the front.
    check(game.COLD_VAULT_RECT.position.y > game.REGISTER_RECT.position.y, "cold vault is deeper in the store than the register")
    check(game.COLD_VAULT_RECT.end.y >= game.FLOOR_RECT.end.y - 12.0, "cold vault is set against the back wall")
    check(game.REGISTER_RECT.position.y <= game.FLOOR_RECT.position.y + 30.0, "register sits just inside the entrance")
    check(game.RESTROOM_RECT.position.y > game.FLOOR_RECT.get_center().y, "restroom is at the back of the store")
    check(game.BACK_ROOM_RECT.position.y > game.FLOOR_RECT.get_center().y, "back room is at the back of the store")
    check(game.CAMERA_POS.y <= game.FLOOR_RECT.position.y + 30.0, "camera is mounted at the front of the ceiling")

    # Orientation: entering the door you can see the register and the coffee island.
    var door: Vector2 = game.DOOR_RECT.get_center()
    check(game.DOOR_RECT.position.x > game.FLOOR_RECT.get_center().x, "entrance is on the front-right of the storefront")
    check(absf(game.REGISTER_RECT.get_center().x - door.x) < 300.0, "register is within sight of the entrance")
    check(absf(game.COFFEE_RECT.get_center().x - door.x) < 200.0, "coffee island is within sight of the entrance")
    check(game.ENTRY_RECT.position.y <= game.FLOOR_RECT.position.y + 1.0, "decompression zone starts at the door")

    # Walkable floor: spawn, approach points and the queue are clear of fixtures.
    var spawn: Vector2 = game.player_position
    for fixture_name in fixtures:
        var fixture: Rect2 = fixtures[fixture_name]
        check(not fixture.has_point(spawn), "spawn is clear of " + String(fixture_name))
    check(game.WALK_BOUNDS.has_point(spawn), "spawn is inside the walkable bounds")
    for category in game.APPROACH_POINTS:
        var approach: Vector2 = game.APPROACH_POINTS[category]
        var blocked := false
        for fixture_name in fixtures:
            var fixture: Rect2 = fixtures[fixture_name]
            if fixture.has_point(approach):
                blocked = true
        check(not blocked, "approach point for " + String(category) + " is in open floor")
        check(game.WALK_BOUNDS.has_point(approach), "approach point for " + String(category) + " is walkable")
    var queue: Vector2 = game.REGISTER_QUEUE_POINT
    check(not game.REGISTER_RECT.has_point(queue), "queue point sits in front of the counter")
    check(game.WALK_BOUNDS.has_point(queue), "queue point is walkable")

    # --- Objectives are actually stated ------------------------------------
    check(game.opening_tasks.size() == 2, "clipboard holds two opening tasks")
    for task: Dictionary in game.opening_tasks:
        var task_text := String(task["text"])
        check(task_text.length() > 8, "opening task has a real instruction: " + task_text)
        check(game.SHELF_RECTS.has(String(task["category"])), "opening task points at a real fixture")
    var first_task: Dictionary = game.opening_tasks[0]
    game.player_position = game.APPROACH_POINTS[String(first_task["category"])]
    var prompt: String = game._proximity_prompt()
    check(prompt.contains("[E]"), "pending opening task raises a proximity prompt")
    check(prompt.contains(String(first_task["text"])), "the prompt names the pending task")
    check(game._proximity_prompt_at(Vector2(20.0, 20.0)) == "", "no prompt when standing in the interface frame")

    if failures == 0:
        print("layout and ui pass: fixtures=%d aisle=%.0fpx widest_line=%.0fpx panel_h=%.0f" % [fixtures.size(), aisle, widest, tall_panel.size.y])
    else:
        print("layout and ui FAILED: %d checks failed" % failures)
    quit(1 if failures > 0 else 0)
