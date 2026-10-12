extends SceneTree
## Verifies that a seeded shift starts with physical opening chores that gate the first customer.

var failures: int = 0

func check(condition: bool, label: String) -> bool:
    if not condition:
        failures += 1
        print("FAIL: " + label)
    return condition

func _init() -> void:
    var scene := load("res://scenes/main.tscn") as PackedScene
    var game := scene.instantiate()
    game.shift_seed = 1001
    root.add_child(game)
    await process_frame

    check(game.opening_tasks.size() == 2, "two opening tasks generated")
    check(game.completed_opening_tasks == 0, "opening tasks start incomplete")

    var first_category: String = game.opening_tasks[0]["category"]
    var wrong_category := "cold" if first_category != "cold" else "warm"
    game._take_item(wrong_category)
    check(game.completed_opening_tasks == 0, "wrong shelf does not complete a task")

    for task in game.opening_tasks:
        game._take_item(task["category"])
    check(game.completed_opening_tasks == 2, "both tasks completed at the right shelves")

    for step in range(10):
        await process_frame
    check(game.draw_count > 0, "scene rendered")

    game.player_position = game.REGISTER_RECT.get_center()
    game._start_next_encounter()
    check(game.customer_active, "customer can be called once chores are done")
    for step in range(120):
        if game.customer_phase == "waiting":
            break
        game._update_customer(0.1)
    check(game.customer_phase == "waiting", "customer browses then waits at the register")

    if failures == 0:
        print("opening task pass: tasks=%d customer=%s" % [game.completed_opening_tasks, game.encounters[0]["name"]])
    else:
        print("opening task FAILED: %d checks failed" % failures)
    quit(1 if failures > 0 else 0)
