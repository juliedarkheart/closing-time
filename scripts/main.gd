extends Node2D
## First playable slice for Closing Time.
## Move with WASD or arrows. Press E at the register, then 1 or 2.

const PLAYER_SPEED: float = 220.0
const SHOP_RECT := Rect2(80.0, 70.0, 800.0, 400.0)
const REGISTER_RECT := Rect2(690.0, 165.0, 120.0, 90.0)

var player_position: Vector2 = Vector2(460.0, 360.0)
var cash: int = 24
var stock: int = 6
var trust: int = 0
var served_customers: int = 0
var current_encounter: int = -1
var awaiting_choice: bool = false
var dawn_reached: bool = false
var message: String = "The night shift begins. Check the register."
var message_time: float = 0.0

var encounters: Array[Dictionary] = [
    {"name": "The soaked traveler", "clue": "They keep looking at the road behind you.", "request": "They ask for a flashlight.", "one": "Sell the flashlight", "two": "Ask where they are going"},
    {"name": "The tired parent", "clue": "The child in the car wears a hospital bracelet.", "request": "They ask for something warm.", "one": "Offer soup", "two": "Point them toward the clinic"},
    {"name": "The last customer", "clue": "Their receipt already has tomorrow's date on it.", "request": "They ask if you saw anyone come through.", "one": "Tell the truth", "two": "Say nothing"}
]

func _ready() -> void:
    queue_redraw()

func _process(delta: float) -> void:
    if not awaiting_choice and not dawn_reached:
        var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
        player_position += direction * PLAYER_SPEED * delta
        player_position.x = clamp(player_position.x, SHOP_RECT.position.x + 24.0, SHOP_RECT.end.x - 24.0)
        player_position.y = clamp(player_position.y, SHOP_RECT.position.y + 24.0, SHOP_RECT.end.y - 24.0)
    if message_time > 0.0:
        message_time -= delta
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    if awaiting_choice:
        if event.keycode == KEY_1:
            _resolve_choice(1)
        elif event.keycode == KEY_2:
            _resolve_choice(2)
        return
    if event.is_action_pressed("interact") and REGISTER_RECT.grow(28.0).has_point(player_position):
        _start_next_encounter()

func _start_next_encounter() -> void:
    if served_customers >= encounters.size():
        dawn_reached = true
        message = "Dawn arrives. The shop is quiet again."
        message_time = 8.0
        return
    current_encounter = served_customers
    awaiting_choice = true
    message = encounters[current_encounter]["name"] + ": " + encounters[current_encounter]["request"]
    message_time = 8.0

func _resolve_choice(choice: int) -> void:
    var encounter: Dictionary = encounters[current_encounter]
    if stock <= 0:
        message = "You have nothing left to offer. The customer leaves."
    elif choice == 1:
        stock -= 1
        cash += 4
        trust += 1
        message = encounter["clue"] + " You chose: " + encounter["one"] + "."
    else:
        stock -= 1
        trust -= 1
        message = encounter["clue"] + " You chose: " + encounter["two"] + "."
    served_customers += 1
    awaiting_choice = false
    message_time = 6.0

func _draw() -> void:
    draw_rect(Rect2(0.0, 0.0, 960.0, 540.0), Color("101622"))
    draw_rect(SHOP_RECT, Color("2b3545"), true)
    draw_rect(SHOP_RECT, Color("91a4bd"), false, 4.0)
    draw_rect(Rect2(110.0, 100.0, 180.0, 270.0), Color("3c4d5b"), true)
    draw_rect(Rect2(330.0, 100.0, 180.0, 270.0), Color("3c4d5b"), true)
    draw_rect(Rect2(550.0, 100.0, 100.0, 270.0), Color("3c4d5b"), true)
    draw_rect(REGISTER_RECT, Color("b8815a"), true)
    draw_rect(REGISTER_RECT, Color("e8c18d"), false, 3.0)
    draw_string(ThemeDB.fallback_font, Vector2(708.0, 212.0), "REGISTER", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("fff1d6"))
    draw_circle(player_position, 18.0, Color("e6b875"))
    draw_circle(player_position, 18.0, Color("fff1d6"), false, 3.0)
    draw_string(ThemeDB.fallback_font, Vector2(30.0, 36.0), "CLOSING TIME  •  GRAYBOX SHIFT", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("f5d7a1"))
    draw_string(ThemeDB.fallback_font, Vector2(30.0, 510.0), "WASD / ARROWS: move     E: next customer     1 / 2: choose", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("c4cfdd"))
    draw_string(ThemeDB.fallback_font, Vector2(690.0, 110.0), "CASH: $%02d    STOCK: %02d" % [cash, stock], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("dce8f4"))
    draw_string(ThemeDB.fallback_font, Vector2(30.0, 495.0), "CUSTOMERS: %02d/03    TRUST: %02d" % [served_customers, trust], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("dce8f4"))
    if awaiting_choice:
        draw_string(ThemeDB.fallback_font, Vector2(310.0, 392.0), encounters[current_encounter]["clue"], HORIZONTAL_ALIGNMENT_LEFT, 350, 15, Color("f5d7a1"))
        draw_string(ThemeDB.fallback_font, Vector2(310.0, 414.0), "[1] " + encounters[current_encounter]["one"], HORIZONTAL_ALIGNMENT_LEFT, 350, 15, Color("dce8f4"))
        draw_string(ThemeDB.fallback_font, Vector2(310.0, 436.0), "[2] " + encounters[current_encounter]["two"], HORIZONTAL_ALIGNMENT_LEFT, 350, 15, Color("dce8f4"))
    elif message_time > 0.0 or served_customers == 0 or dawn_reached:
        draw_rect(Rect2(250.0, 420.0, 460.0, 42.0), Color("182130"), true)
        draw_string(ThemeDB.fallback_font, Vector2(270.0, 447.0), message, HORIZONTAL_ALIGNMENT_LEFT, 420, 16, Color("fff1d6"))
