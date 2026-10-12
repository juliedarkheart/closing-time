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
        var direction := Vector2.ZERO
        if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
            direction.x -= 1.0
        if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
            direction.x += 1.0
        if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
            direction.y -= 1.0
        if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
            direction.y += 1.0
        direction = direction.normalized()
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
        if event.keycode == KEY_1 or event.keycode == KEY_KP_1 or event.physical_keycode == KEY_1:
            _resolve_choice(1)
        elif event.keycode == KEY_2 or event.keycode == KEY_KP_2 or event.physical_keycode == KEY_2:
            _resolve_choice(2)
        return
    if event.keycode == KEY_E or event.physical_keycode == KEY_E:
        if REGISTER_RECT.grow(28.0).has_point(player_position):
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
        message = encounter["clue"] + "\nYou chose: " + encounter["one"] + "."
    else:
        stock -= 1
        trust -= 1
        message = encounter["clue"] + "\nYou chose: " + encounter["two"] + "."
    served_customers += 1
    awaiting_choice = false
    message_time = 6.0

func _draw() -> void:
    draw_rect(Rect2(0.0, 0.0, 960.0, 540.0), Color("101622"))
    draw_rect(Rect2(20.0, 14.0, 920.0, 42.0), Color("182130"), true)
    draw_rect(SHOP_RECT, Color("2b3545"), true)
    draw_rect(SHOP_RECT, Color("91a4bd"), false, 4.0)
    draw_rect(Rect2(110.0, 100.0, 180.0, 270.0), Color("4a5c68"), true)
    draw_rect(Rect2(110.0, 100.0, 180.0, 270.0), Color("78909c"), false, 3.0)
    draw_rect(Rect2(330.0, 100.0, 180.0, 270.0), Color("566451"), true)
    draw_rect(Rect2(330.0, 100.0, 180.0, 270.0), Color("91a87b"), false, 3.0)
    draw_rect(Rect2(550.0, 100.0, 100.0, 270.0), Color("66524b"), true)
    draw_rect(Rect2(550.0, 100.0, 100.0, 270.0), Color("b88c75"), false, 3.0)
    draw_string(ThemeDB.fallback_font, Vector2(126.0, 126.0), "COLD", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("dbe9ef"))
    draw_string(ThemeDB.fallback_font, Vector2(346.0, 126.0), "WARM", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("e7f0cf"))
    draw_string(ThemeDB.fallback_font, Vector2(566.0, 126.0), "ODD", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("f3d5c7"))
    draw_rect(REGISTER_RECT, Color("b8815a"), true)
    draw_rect(REGISTER_RECT, Color("e8c18d"), false, 3.0)
    draw_string(ThemeDB.fallback_font, Vector2(708.0, 212.0), "REGISTER", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("fff1d6"))
    draw_circle(player_position, 18.0, Color("e6b875"))
    draw_circle(player_position, 18.0, Color("fff1d6"), false, 3.0)
    draw_string(ThemeDB.fallback_font, Vector2(30.0, 42.0), "CLOSING TIME  •  GRAYBOX SHIFT", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("f5d7a1"))
    draw_rect(Rect2(20.0, 478.0, 920.0, 44.0), Color("182130"), true)
    draw_string(ThemeDB.fallback_font, Vector2(36.0, 502.0), "CUSTOMERS: %02d/03    TRUST: %02d" % [served_customers, trust], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("dce8f4"))
    draw_string(ThemeDB.fallback_font, Vector2(430.0, 502.0), "WASD / ARROWS: move     E: register     1 / 2: choose", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("c4cfdd"))
    draw_rect(Rect2(650.0, 72.0, 210.0, 40.0), Color("182130"), true)
    draw_string(ThemeDB.fallback_font, Vector2(668.0, 98.0), "CASH: $%02d    STOCK: %02d" % [cash, stock], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("dce8f4"))
    if awaiting_choice:
        draw_rect(Rect2(240.0, 338.0, 480.0, 126.0), Color("101622"), true)
        draw_rect(Rect2(240.0, 338.0, 480.0, 126.0), Color("e8c18d"), false, 2.0)
        draw_string(ThemeDB.fallback_font, Vector2(260.0, 362.0), encounters[current_encounter]["name"], HORIZONTAL_ALIGNMENT_LEFT, 440, 18, Color("fff1d6"))
        draw_string(ThemeDB.fallback_font, Vector2(260.0, 384.0), encounters[current_encounter]["request"], HORIZONTAL_ALIGNMENT_LEFT, 440, 15, Color("dce8f4"))
        draw_string(ThemeDB.fallback_font, Vector2(260.0, 408.0), encounters[current_encounter]["clue"], HORIZONTAL_ALIGNMENT_LEFT, 440, 15, Color("f5d7a1"))
        draw_string(ThemeDB.fallback_font, Vector2(260.0, 432.0), "[1] " + encounters[current_encounter]["one"], HORIZONTAL_ALIGNMENT_LEFT, 440, 15, Color("dce8f4"))
        draw_string(ThemeDB.fallback_font, Vector2(260.0, 454.0), "[2] " + encounters[current_encounter]["two"], HORIZONTAL_ALIGNMENT_LEFT, 440, 15, Color("dce8f4"))
    elif message_time > 0.0 or served_customers == 0 or dawn_reached:
        draw_rect(Rect2(250.0, 400.0, 460.0, 62.0), Color("101622"), true)
        draw_rect(Rect2(250.0, 400.0, 460.0, 62.0), Color("e8c18d"), false, 2.0)
        var message_lines := message.split("\n")
        for line_index in range(min(message_lines.size(), 2)):
            draw_string(ThemeDB.fallback_font, Vector2(270.0, 422.0 + line_index * 20.0), message_lines[line_index], HORIZONTAL_ALIGNMENT_LEFT, 420, 16, Color("fff1d6"))
