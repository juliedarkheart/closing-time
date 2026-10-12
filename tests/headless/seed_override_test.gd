extends SceneTree
## Verifies the --shift-seed CLI override used for reproducible playtests.

func check(condition: bool, label: String) -> bool:
    if not condition:
        print("FAIL: " + label)
        return false
    return true

func _init() -> void:
    var args := OS.get_cmdline_user_args()
    var expected := 0
    for argument in args:
        if argument.begins_with("--shift-seed="):
            expected = int(argument.trim_prefix("--shift-seed="))
    var scene := load("res://scenes/main.tscn") as PackedScene
    var game := scene.instantiate()
    root.add_child(game)
    await process_frame
    print("cli_seed_args=%s resolved_seed=%d expected=%d" % [str(args), game.shift_seed, expected])
    if not check(expected != 0, "test ran with --shift-seed"):
        quit(1)
        return
    if not check(game.shift_seed == expected, "scene used the CLI seed override"):
        quit(1)
        return
    var generator := ShiftGenerator.new(expected)
    var reference := generator.generate_shift(3)
    if not check(game.encounters == reference["encounters"], "seeded customer cast matches the generator"):
        quit(1)
        return
    print("seed override pass: seed=%d customers=%d incidents=%d" % [game.shift_seed, game.encounters.size(), game.incident_plan.size()])
    quit(0)
