extends Node2D
## First playable operations slice for Closing Time.
## Move with WASD/arrows. E interacts with shelves/register. Q asks a customer a question.

const PLAYER_SPEED: float = 220.0
const SHOP_RECT := Rect2(80.0, 70.0, 800.0, 400.0)
const REGISTER_RECT := Rect2(690.0, 165.0, 120.0, 90.0)
const BATHROOM_RECT := Rect2(690.0, 355.0, 120.0, 90.0)
const SHELF_RECTS := {
    "cold": Rect2(110.0, 100.0, 180.0, 270.0),
    "warm": Rect2(330.0, 100.0, 180.0, 270.0),
    "odd": Rect2(550.0, 100.0, 100.0, 270.0),
}
const FRIDGE_PATH := "res://licensed_assets/limezu/modern_interiors/extracted/moderninteriors-win/3_Animated_objects/32x32/spritesheets/animated_fridge_white_32x32.png"
const CHECKOUT_PATH := "res://licensed_assets/limezu/modern_interiors/extracted/moderninteriors-win/3_Animated_objects/32x32/spritesheets/animated_grocery_store_checkout_roller_32x32.png"

var player_position: Vector2 = Vector2(460.0, 360.0)
var cash: int = 24
var trust: int = 0
var served_customers: int = 0
var current_encounter: int = -1
var customer_active: bool = false
var question_used: bool = false
var held_item: String = ""
var shelf_stock: Dictionary = {"cold": 2, "warm": 2, "odd": 2}
var dawn_reached: bool = false
@export var shift_seed: int = 0
var incident_active: bool = false
var active_incident: Dictionary = {}
var safety_score: int = 0
var handoff_notes: int = 0
var message: String = "The night shift begins. Stock the shelves, then check the register."
var message_time: float = 0.0
var encounters: Array[Dictionary] = []
var randomizer := RandomNumberGenerator.new()
var shift_generator: ShiftGenerator
var shift_data: Dictionary = {}
var incident_plan: Dictionary = {}
var fridge_sheet: Texture2D
var checkout_sheet: Texture2D

func _ready() -> void:
    fridge_sheet = _load_local_texture(FRIDGE_PATH)
    checkout_sheet = _load_local_texture(CHECKOUT_PATH)
    var seed_value := shift_seed
    if seed_value == 0:
        seed_value = int(Time.get_unix_time_from_system())
    randomizer.seed = seed_value
    shift_generator = ShiftGenerator.new(seed_value)
    shift_data = shift_generator.generate_shift(3)
    encounters = shift_data["encounters"]
    shelf_stock = shift_data["starting_stock"]
    incident_plan = shift_data["incidents"]
    message = "The night shift begins. %s" % shift_data["condition"]
    queue_redraw()

func _process(delta: float) -> void:
    if not dawn_reached:
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
    if event.keycode == KEY_Q or event.physical_keycode == KEY_Q:
        _ask_question()
    elif event.keycode == KEY_E or event.physical_keycode == KEY_E:
        _interact()

func _interact() -> void:
    if incident_active:
        if _incident_location_rect().grow(28.0).has_point(player_position):
            _resolve_active_incident()
        else:
            message = "The active incident needs attention first. Do not chase trouble across the whole store."
            message_time = 4.0
        return
    if customer_active and REGISTER_RECT.grow(28.0).has_point(player_position):
        _serve_customer()
        return
    if not customer_active and REGISTER_RECT.grow(28.0).has_point(player_position):
        _start_next_encounter()
        return
    for category in SHELF_RECTS:
        if SHELF_RECTS[category].grow(20.0).has_point(player_position):
            _take_item(category)
            return

func _start_next_encounter() -> void:
    if incident_active:
        message = "You cannot call the next customer while the active incident is unresolved."
        message_time = 4.0
        return
    if served_customers >= encounters.size():
        dawn_reached = true
        message = "Dawn arrives. Sales: $%02d. Trust: %02d. Safety: %02d. Handoff notes: %02d." % [cash, trust, safety_score, handoff_notes]
        message_time = 8.0
        return
    if held_item != "":
        message = "Your hands are full. Put the item back or serve the waiting customer."
        message_time = 4.0
        return
    current_encounter = served_customers
    customer_active = true
    question_used = false
    message = encounters[current_encounter]["name"] + " arrives. Read the need, then find the right shelf."
    message_time = 6.0

func _take_item(category: String) -> void:
    if customer_active == false:
        message = "No customer is waiting. Stock check first, then call someone in."
    elif held_item != "":
        message = "You are already carrying the %s item." % held_item
    elif int(shelf_stock[category]) <= 0:
        message = "The %s shelf is empty. The customer will have to wait." % category
    else:
        shelf_stock[category] -= 1
        held_item = category
        message = "You take one %s item. Bring it back to the register." % category
    message_time = 4.0

func _ask_question() -> void:
    if not customer_active:
        message = "There is nobody to ask."
    elif not REGISTER_RECT.grow(34.0).has_point(player_position):
        message = "Ask the customer at the register."
    elif question_used:
        message = "You already asked your one useful question."
    else:
        question_used = true
        trust += 1
        message = encounters[current_encounter]["question"] + "\nThey confirm they need something from the %s shelf." % encounters[current_encounter]["category"]
    message_time = 5.0

func _serve_customer() -> void:
    var encounter: Dictionary = encounters[current_encounter]
    if held_item == "":
        trust -= 1
        message = "You have nothing in your hands. The customer leaves disappointed."
    elif held_item == encounter["category"]:
        cash += 4
        trust += 1
        message = encounter["issue"] + "\nCorrect item served. They leave $4 and a clue behind."
    else:
        trust -= 1
        message = encounter["issue"] + "\nWrong item served. The customer leaves unconvinced."
    held_item = ""
    customer_active = false
    served_customers += 1
    var next_incident: Dictionary = incident_plan.get(served_customers - 1, {})
    if not next_incident.is_empty():
        incident_active = true
        active_incident = next_incident
        var stock_category: String = active_incident["stock_category"]
        var stock_loss: int = active_incident["stock_loss"]
        if stock_category != "" and stock_loss > 0:
            shelf_stock[stock_category] = max(0, int(shelf_stock[stock_category]) - stock_loss)
        message = active_incident["title"] + " " + active_incident["detail"]
        message_time = 6.0
    else:
        message_time = 6.0

func _incident_location_rect() -> Rect2:
    if active_incident.is_empty():
        return Rect2()
    match active_incident["location"]:
        "bathroom":
            return BATHROOM_RECT
        "odd_shelf":
            return SHELF_RECTS["odd"]
        "warm_shelf":
            return SHELF_RECTS["warm"]
        "register":
            return REGISTER_RECT
    return Rect2()

func _resolve_active_incident() -> void:
    incident_active = false
    safety_score += active_incident["safety_gain"]
    handoff_notes += active_incident["handoff_gain"]
    message = active_incident["resolution"]
    message_time = 6.0
    active_incident = {}

func _load_local_texture(resource_path: String) -> Texture2D:
    var image := Image.new()
    var local_path := ProjectSettings.globalize_path(resource_path)
    if image.load(local_path) != OK:
        return null
    return ImageTexture.create_from_image(image)

func _draw() -> void:
    draw_rect(Rect2(0.0, 0.0, 960.0, 540.0), Color("101622"))
    draw_rect(Rect2(20.0, 14.0, 920.0, 42.0), Color("182130"), true)
    draw_rect(SHOP_RECT, Color("2b3545"), true)
    draw_rect(SHOP_RECT, Color("91a4bd"), false, 4.0)
    draw_rect(SHELF_RECTS["cold"], Color("4a5c68"), true)
    draw_rect(SHELF_RECTS["cold"], Color("78909c"), false, 3.0)
    draw_rect(SHELF_RECTS["warm"], Color("566451"), true)
    draw_rect(SHELF_RECTS["warm"], Color("91a87b"), false, 3.0)
    draw_rect(SHELF_RECTS["odd"], Color("66524b"), true)
    draw_rect(SHELF_RECTS["odd"], Color("b88c75"), false, 3.0)
    if fridge_sheet != null:
        draw_texture_rect_region(fridge_sheet, Rect2(150.0, 165.0, 100.0, 180.0), Rect2(0.0, 0.0, 32.0, 32.0))
    if checkout_sheet != null:
        draw_texture_rect_region(checkout_sheet, Rect2(702.0, 176.0, 96.0, 64.0), Rect2(0.0, 0.0, 32.0, 32.0))
    draw_string(ThemeDB.fallback_font, Vector2(126.0, 126.0), "COLD  %02d" % shelf_stock["cold"], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("dbe9ef"))
    draw_string(ThemeDB.fallback_font, Vector2(346.0, 126.0), "WARM  %02d" % shelf_stock["warm"], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("e7f0cf"))
    draw_string(ThemeDB.fallback_font, Vector2(566.0, 126.0), "ODD  %02d" % shelf_stock["odd"], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("f3d5c7"))
    draw_rect(REGISTER_RECT, Color("b8815a"), true)
    draw_rect(REGISTER_RECT, Color("e8c18d"), false, 3.0)
    draw_string(ThemeDB.fallback_font, Vector2(708.0, 212.0), "REGISTER", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("fff1d6"))
    draw_rect(BATHROOM_RECT, Color("4d4659"), true)
    draw_rect(BATHROOM_RECT, Color("aa9ac2"), false, 3.0)
    draw_string(ThemeDB.fallback_font, Vector2(700.0, 402.0), "BATHROOM", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("eee3ff"))
    draw_circle(player_position, 18.0, Color("e6b875"))
    draw_circle(player_position, 18.0, Color("fff1d6"), false, 3.0)
    draw_string(ThemeDB.fallback_font, Vector2(30.0, 42.0), "CLOSING TIME  •  OVERNIGHT SHIFT", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("f5d7a1"))
    draw_rect(Rect2(20.0, 478.0, 920.0, 44.0), Color("182130"), true)
    draw_string(ThemeDB.fallback_font, Vector2(36.0, 502.0), "CUSTOMERS: %02d/03    TRUST: %02d    SAFETY: %02d" % [served_customers, trust, safety_score], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("dce8f4"))
    draw_string(ThemeDB.fallback_font, Vector2(430.0, 502.0), "WASD: move   E: interact   Q: ask", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("c4cfdd"))
    draw_rect(Rect2(650.0, 72.0, 210.0, 40.0), Color("182130"), true)
    draw_string(ThemeDB.fallback_font, Vector2(668.0, 98.0), "CASH: $%02d    HANDS: %s" % [cash, held_item if held_item != "" else "empty"], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("dce8f4"))
    if incident_active:
        var incident_panel: Dictionary = active_incident
        draw_rect(Rect2(150.0, 300.0, 660.0, 150.0), Color("241d2a"), true)
        draw_rect(Rect2(150.0, 300.0, 660.0, 150.0), Color("d59cbd"), false, 2.0)
        draw_string(ThemeDB.fallback_font, Vector2(175.0, 330.0), "NIGHT-SHIFT INCIDENT", HORIZONTAL_ALIGNMENT_LEFT, 600, 20, Color("ffd5e7"))
        draw_string(ThemeDB.fallback_font, Vector2(175.0, 358.0), incident_panel["title"], HORIZONTAL_ALIGNMENT_LEFT, 600, 16, Color("f4e8f0"))
        draw_string(ThemeDB.fallback_font, Vector2(175.0, 386.0), incident_panel["instruction"], HORIZONTAL_ALIGNMENT_LEFT, 600, 15, Color("e7c9da"))
        draw_string(ThemeDB.fallback_font, Vector2(175.0, 418.0), incident_panel["joke"], HORIZONTAL_ALIGNMENT_LEFT, 600, 14, Color("d8b4ca"))
    elif customer_active:
        var encounter: Dictionary = encounters[current_encounter]
        draw_rect(Rect2(210.0, 316.0, 540.0, 148.0), Color("101622"), true)
        draw_rect(Rect2(210.0, 316.0, 540.0, 148.0), Color("e8c18d"), false, 2.0)
        draw_string(ThemeDB.fallback_font, Vector2(230.0, 340.0), encounter["name"], HORIZONTAL_ALIGNMENT_LEFT, 500, 18, Color("fff1d6"))
        draw_string(ThemeDB.fallback_font, Vector2(230.0, 364.0), encounter["need"], HORIZONTAL_ALIGNMENT_LEFT, 500, 15, Color("dce8f4"))
        draw_string(ThemeDB.fallback_font, Vector2(230.0, 388.0), encounter["issue"], HORIZONTAL_ALIGNMENT_LEFT, 500, 15, Color("f5d7a1"))
        draw_string(ThemeDB.fallback_font, Vector2(230.0, 414.0), "Q: " + encounter["question"], HORIZONTAL_ALIGNMENT_LEFT, 500, 14, Color("c4cfdd"))
        draw_string(ThemeDB.fallback_font, Vector2(230.0, 442.0), "Find the %s shelf, take an item, then return to the register." % encounter["category"], HORIZONTAL_ALIGNMENT_LEFT, 500, 15, Color("fff1d6"))
    elif message_time > 0.0 or served_customers == 0 or dawn_reached:
        draw_rect(Rect2(250.0, 400.0, 460.0, 62.0), Color("101622"), true)
        draw_rect(Rect2(250.0, 400.0, 460.0, 62.0), Color("e8c18d"), false, 2.0)
        var message_lines := message.split("\n")
        for line_index in range(min(message_lines.size(), 2)):
            draw_string(ThemeDB.fallback_font, Vector2(270.0, 422.0 + line_index * 20.0), message_lines[line_index], HORIZONTAL_ALIGNMENT_LEFT, 420, 16, Color("fff1d6"))
