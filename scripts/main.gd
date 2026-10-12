extends Node2D
## First playable operations slice for Closing Time.
## Move with WASD/arrows. E interacts with shelves/register. Q asks a customer a question.

const PLAYER_SPEED: float = 220.0
const SHOP_RECT := Rect2(80.0, 70.0, 800.0, 400.0)
const REGISTER_RECT := Rect2(690.0, 165.0, 120.0, 90.0)
const BATHROOM_RECT := Rect2(690.0, 355.0, 120.0, 90.0)
const MOP_RECT := Rect2(90.0, 392.0, 96.0, 62.0)
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
var customer_visible: bool = false
var customer_position: Vector2 = Vector2.ZERO
var customer_phase: String = ""
var customer_target: Vector2 = Vector2.ZERO
var customer_secondary_target: Vector2 = Vector2.ZERO
var customer_browse_time: float = 0.0
var customer_has_wandered: bool = false
var held_item: String = ""
var shelf_stock: Dictionary = {"cold": 2, "warm": 2, "odd": 2}
var dawn_reached: bool = false
@export var shift_seed: int = 0
var incident_active: bool = false
var active_incident: Dictionary = {}
var incident_stage: String = ""
var holding_mop: bool = false
var aftermath: Array[String] = []
var draw_count: int = 0
var safety_score: int = 0
var handoff_notes: int = 0
var message: String = "The night shift begins. Stock the shelves, then check the register."
var message_time: float = 0.0
var encounters: Array[Dictionary] = []
var randomizer := RandomNumberGenerator.new()
var shift_generator: ShiftGenerator
var shift_data: Dictionary = {}
var incident_plan: Dictionary = {}
var opening_tasks: Array[Dictionary] = []
var completed_opening_tasks: int = 0
var fridge_sheet: Texture2D
var checkout_sheet: Texture2D

func _read_seed_override() -> int:
    for argument in OS.get_cmdline_user_args():
        if argument.begins_with("--shift-seed="):
            var value := argument.trim_prefix("--shift-seed=")
            if value.is_valid_int():
                return int(value)
    return 0

func _ready() -> void:
    fridge_sheet = _load_local_texture(FRIDGE_PATH)
    checkout_sheet = _load_local_texture(CHECKOUT_PATH)
    var seed_value := shift_seed
    if seed_value == 0:
        seed_value = _read_seed_override()
    if seed_value == 0:
        seed_value = int(Time.get_unix_time_from_system())
    shift_seed = seed_value
    randomizer.seed = seed_value
    shift_generator = ShiftGenerator.new(seed_value)
    shift_data = shift_generator.generate_shift(3)
    encounters = shift_data["encounters"]
    shelf_stock = shift_data["starting_stock"]
    incident_plan = shift_data["incidents"]
    opening_tasks = shift_data["opening_tasks"]
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
    _update_customer(delta)
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
    elif event.keycode == KEY_N or event.physical_keycode == KEY_N:
        _start_new_shift()

func _interact() -> void:
    if incident_active:
        if _incident_location_rect().grow(28.0).has_point(player_position):
            _handle_incident_step()
            return
        if MOP_RECT.grow(20.0).has_point(player_position):
            _take_mop()
            return
        else:
            message = "The active incident needs attention first. Do not chase trouble across the whole store."
            message_time = 4.0
        return
    if customer_active and REGISTER_RECT.grow(28.0).has_point(player_position):
        if customer_phase == "waiting":
            _serve_customer()
        else:
            message = "The customer is still browsing. Give them a moment to reach the register."
            message_time = 3.0
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
    if completed_opening_tasks < opening_tasks.size():
        message = "Finish the highlighted opening task before calling a customer."
        message_time = 4.0
        return
    current_encounter = served_customers
    customer_active = true
    customer_visible = true
    customer_phase = "entering"
    customer_position = Vector2(850.0, 430.0)
    customer_target = SHELF_RECTS[encounters[current_encounter]["category"]].get_center()
    customer_secondary_target = customer_target + encounters[current_encounter]["browse_offset"]
    customer_browse_time = encounters[current_encounter]["browse_pause"]
    customer_has_wandered = false
    question_used = false
    message = encounters[current_encounter]["name"] + " comes in and starts browsing."
    message_time = 6.0

func _update_customer(delta: float) -> void:
    if not customer_visible:
        return
    if customer_phase == "entering":
        customer_position = customer_position.move_toward(customer_target, 150.0 * delta)
        if customer_position.distance_to(customer_target) < 4.0:
            customer_phase = "browsing"
    elif customer_phase == "browsing":
        customer_browse_time -= delta
        if customer_browse_time <= 0.0:
            customer_phase = "wandering"
            customer_target = customer_secondary_target
    elif customer_phase == "wandering":
        customer_position = customer_position.move_toward(customer_target, 110.0 * delta)
        if customer_position.distance_to(customer_target) < 4.0:
            customer_has_wandered = true
            customer_phase = "walking_to_register"
            customer_target = REGISTER_RECT.get_center() + Vector2(0.0, 62.0)
    elif customer_phase == "walking_to_register":
        customer_position = customer_position.move_toward(customer_target, 180.0 * delta)
        if customer_position.distance_to(customer_target) < 4.0:
            customer_position = customer_target
            customer_phase = "waiting"

func _take_item(category: String) -> void:
    if customer_active == false:
        _complete_opening_task(category)
    elif held_item != "":
        message = "You are already carrying the %s item." % held_item
    elif int(shelf_stock[category]) <= 0:
        message = "The %s shelf is empty. The customer will have to wait." % category
    else:
        shelf_stock[category] -= 1
        held_item = category
        message = "You take one %s item. Bring it back to the register." % category
    message_time = 4.0

func _complete_opening_task(category: String) -> void:
    for task in opening_tasks:
        if not task["completed"]:
            if task["category"] == category:
                task["completed"] = true
                completed_opening_tasks += 1
                message = task["text"] + " Opening task complete."
            else:
                message = "That is not the highlighted opening task."
            return
    message = "The opening tasks are complete. Call the next customer."

func _handle_incident_step() -> void:
    if incident_stage == "observed":
        incident_stage = "inspected"
        message = active_incident["detail"] + "\n" + active_incident["instruction"]
        message_time = 6.0
        return
    if _incident_needs_mop() and not holding_mop:
        message = "You need the mop from the utility corner before you can clean this up."
        message_time = 4.0
        return
    _resolve_active_incident()

func _incident_needs_mop() -> bool:
    return not active_incident.is_empty() and active_incident["kind"] == "spill"

func _take_mop() -> void:
    if not incident_active or not _incident_needs_mop():
        message = "The mop can wait until something actually needs cleaning."
        message_time = 4.0
        return
    if holding_mop:
        message = "You are already carrying the mop."
        message_time = 3.0
        return
    holding_mop = true
    message = "You take the mop. Bring it back to the spill."
    message_time = 4.0

func _incident_location_label() -> String:
    if active_incident.is_empty():
        return "the shop floor"
    match active_incident["location"]:
        "bathroom":
            return "the bathroom"
        "odd_shelf":
            return "the odd shelf"
        "warm_shelf":
            return "the warm station"
        "register":
            return "the register"
    return "the shop floor"

func _start_new_shift() -> void:
    var seed_value := int(Time.get_unix_time_from_system())
    shift_seed = seed_value
    randomizer.seed = seed_value
    shift_generator = ShiftGenerator.new(seed_value)
    shift_data = shift_generator.generate_shift(3)
    encounters = shift_data["encounters"]
    shelf_stock = shift_data["starting_stock"]
    incident_plan = shift_data["incidents"]
    opening_tasks = shift_data["opening_tasks"]
    completed_opening_tasks = 0
    served_customers = 0
    current_encounter = -1
    customer_active = false
    customer_visible = false
    customer_phase = ""
    held_item = ""
    holding_mop = false
    incident_active = false
    active_incident = {}
    incident_stage = ""
    aftermath.clear()
    dawn_reached = false
    cash = 24
    trust = 0
    safety_score = 0
    handoff_notes = 0
    question_used = false
    player_position = Vector2(460.0, 360.0)
    message = "A new shift begins. %s" % shift_data["condition"]
    message_time = 6.0

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
    customer_visible = false
    customer_phase = ""
    served_customers += 1
    var next_incident: Dictionary = incident_plan.get(served_customers - 1, {})
    if not next_incident.is_empty():
        incident_active = true
        active_incident = next_incident
        incident_stage = "observed"
        var stock_category: String = active_incident["stock_category"]
        var stock_loss: int = active_incident["stock_loss"]
        if stock_category != "" and stock_loss > 0:
            shelf_stock[stock_category] = max(0, int(shelf_stock[stock_category]) - stock_loss)
        message = active_incident["title"] + "\nSomething is wrong at " + _incident_location_label() + "."
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
    aftermath.append(active_incident["kind"])
    holding_mop = false
    incident_stage = ""
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
    draw_count += 1
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
    if completed_opening_tasks < opening_tasks.size():
        var opening_category: String = opening_tasks[completed_opening_tasks]["category"]
        draw_rect(SHELF_RECTS[opening_category].grow(8.0), Color("f5d27d"), false, 4.0)
        draw_string(ThemeDB.fallback_font, SHELF_RECTS[opening_category].position + Vector2(0.0, -12.0), "OPENING TASK", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("f5d27d"))
    draw_rect(REGISTER_RECT, Color("b8815a"), true)
    draw_rect(REGISTER_RECT, Color("e8c18d"), false, 3.0)
    draw_string(ThemeDB.fallback_font, Vector2(708.0, 212.0), "REGISTER", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("fff1d6"))
    draw_rect(BATHROOM_RECT, Color("4d4659"), true)
    draw_rect(BATHROOM_RECT, Color("aa9ac2"), false, 3.0)
    draw_string(ThemeDB.fallback_font, Vector2(700.0, 402.0), "BATHROOM", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("eee3ff"))
    draw_rect(MOP_RECT, Color("3a4a3c"), true)
    draw_rect(MOP_RECT, Color("8fae86"), false, 2.0)
    draw_string(ThemeDB.fallback_font, MOP_RECT.position + Vector2(6.0, 18.0), "MOPS", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("d7ecd2"))
    draw_line(MOP_RECT.position + Vector2(30.0, 30.0), MOP_RECT.position + Vector2(58.0, 54.0), Color("c6b58a"), 3.0)
    draw_rect(Rect2(MOP_RECT.position.x + 52.0, MOP_RECT.position.y + 46.0, 16.0, 12.0), Color("e3dcc7"), true)
    _draw_incident_highlight()
    _draw_aftermath()
    _draw_incident_clue_visuals()
    draw_circle(player_position, 18.0, Color("e6b875"))
    draw_circle(player_position, 18.0, Color("fff1d6"), false, 3.0)
    if holding_mop:
        draw_line(player_position + Vector2(10.0, -14.0), player_position + Vector2(24.0, 18.0), Color("c6b58a"), 3.0)
        draw_rect(Rect2(player_position.x + 18.0, player_position.y + 10.0, 14.0, 10.0), Color("e3dcc7"), true)
    if customer_visible:
        var customer_category: String = encounters[current_encounter]["category"]
        var customer_color := Color("8aa7c7")
        if customer_category == "warm":
            customer_color = Color("c98f6f")
        elif customer_category == "odd":
            customer_color = Color("ad8cc4")
        draw_circle(customer_position, 16.0, customer_color)
        draw_circle(customer_position, 16.0, Color("fff1d6"), false, 2.0)
        draw_rect(Rect2(customer_position.x - 11.0, customer_position.y + 10.0, 22.0, 12.0), customer_color, true)
        if customer_phase == "browsing" or customer_phase == "wandering":
            draw_rect(Rect2(customer_position.x + 12.0, customer_position.y + 5.0, 9.0, 10.0), Color("e5c68c"), true)
            draw_line(customer_position + Vector2(14.0, 5.0), customer_position + Vector2(18.0, 1.0), Color("e5c68c"), 2.0)
        var customer_label: String = encounters[current_encounter]["name"]
        draw_string(ThemeDB.fallback_font, customer_position + Vector2(-55.0, -24.0), customer_label, HORIZONTAL_ALIGNMENT_LEFT, 120, 11, Color("fff1d6"))
    draw_string(ThemeDB.fallback_font, Vector2(30.0, 42.0), "CLOSING TIME  •  OVERNIGHT SHIFT", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("f5d7a1"))
    draw_rect(Rect2(20.0, 478.0, 920.0, 44.0), Color("182130"), true)
    draw_string(ThemeDB.fallback_font, Vector2(36.0, 502.0), "OPENING: %02d/%02d    CUSTOMERS: %02d/03    TRUST: %02d    SAFETY: %02d" % [completed_opening_tasks, opening_tasks.size(), served_customers, trust, safety_score], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("dce8f4"))
    draw_string(ThemeDB.fallback_font, Vector2(600.0, 502.0), "WASD: move  E: interact  Q: ask  N: new shift", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("c4cfdd"))
    draw_rect(Rect2(650.0, 72.0, 210.0, 40.0), Color("182130"), true)
    var hands_label := "empty"
    if holding_mop:
        hands_label = "mop"
    elif held_item != "":
        hands_label = held_item + " item"
    draw_string(ThemeDB.fallback_font, Vector2(668.0, 98.0), "CASH: $%02d  HANDS: %s  SHIFT #%d" % [cash, hands_label, shift_seed], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("dce8f4"))
    if incident_active:
        var incident_panel: Dictionary = active_incident
        draw_rect(Rect2(150.0, 300.0, 660.0, 150.0), Color("241d2a"), true)
        draw_rect(Rect2(150.0, 300.0, 660.0, 150.0), Color("d59cbd"), false, 2.0)
        draw_string(ThemeDB.fallback_font, Vector2(175.0, 330.0), "NIGHT-SHIFT INCIDENT", HORIZONTAL_ALIGNMENT_LEFT, 600, 20, Color("ffd5e7"))
        draw_string(ThemeDB.fallback_font, Vector2(175.0, 358.0), incident_panel["title"], HORIZONTAL_ALIGNMENT_LEFT, 600, 16, Color("f4e8f0"))
        var incident_hint: String = incident_panel["instruction"]
        if incident_stage == "observed":
            incident_hint = "Look at " + _incident_location_label() + " and press E to see what it is."
        draw_string(ThemeDB.fallback_font, Vector2(175.0, 386.0), incident_hint, HORIZONTAL_ALIGNMENT_LEFT, 600, 15, Color("e7c9da"))
        draw_string(ThemeDB.fallback_font, Vector2(175.0, 412.0), incident_panel["joke"], HORIZONTAL_ALIGNMENT_LEFT, 600, 14, Color("d8b4ca"))
        if incident_stage == "inspected" and _incident_needs_mop() and not holding_mop:
            draw_string(ThemeDB.fallback_font, Vector2(175.0, 436.0), "You need the mop from the utility corner.", HORIZONTAL_ALIGNMENT_LEFT, 600, 14, Color("f5d27d"))
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

func _draw_incident_highlight() -> void:
    if not incident_active or active_incident.is_empty():
        return
    var rect: Rect2 = _incident_location_rect()
    var ring_color := Color("e58ab0") if incident_stage == "observed" else Color("8fd3a8")
    draw_rect(rect.grow(10.0), ring_color, false, 3.0)
    draw_arc(rect.get_center(), maxf(rect.size.x, rect.size.y) * 0.62, 0.0, TAU, 40, ring_color, 2.0)

func _draw_aftermath() -> void:
    for kind in aftermath:
        match kind:
            "spill":
                var sign_base := SHELF_RECTS["warm"].get_center() + Vector2(0.0, 116.0)
                draw_colored_polygon(PackedVector2Array([
                    sign_base + Vector2(0.0, -18.0),
                    sign_base + Vector2(15.0, 12.0),
                    sign_base + Vector2(-15.0, 12.0)
                ]), Color("f2d16b"))
                draw_line(sign_base + Vector2(0.0, -8.0), sign_base + Vector2(0.0, 2.0), Color("4a3c12"), 2.0)
                draw_circle(sign_base + Vector2(0.0, 7.0), 1.8, Color("4a3c12"))
            "shoplifting":
                var gap_slot := Rect2(SHELF_RECTS["odd"].position + Vector2(25.0, 105.0), Vector2(50.0, 38.0))
                draw_rect(gap_slot, Color("1d1926"), true)
                draw_rect(gap_slot, Color("b0654e"), false, 2.0)
            "bathroom":
                draw_circle(BATHROOM_RECT.get_center() + Vector2(38.0, -22.0), 9.0, Color("8fd3a8"))
                draw_line(BATHROOM_RECT.get_center() + Vector2(34.0, -22.0), BATHROOM_RECT.get_center() + Vector2(37.0, -18.0), Color("1d2b21"), 2.0)
                draw_line(BATHROOM_RECT.get_center() + Vector2(37.0, -18.0), BATHROOM_RECT.get_center() + Vector2(43.0, -27.0), Color("1d2b21"), 2.0)
            "coupon":
                var left_coupon := Rect2(704.0, 240.0, 40.0, 18.0)
                draw_rect(left_coupon, Color("cdd894"), true)
                draw_rect(left_coupon, Color("27301d"), false, 2.0)
            "parking_lot":
                draw_rect(Rect2(806.0, 96.0, 54.0, 26.0), Color("46566b"), true)
                draw_rect(Rect2(816.0, 90.0, 30.0, 12.0), Color("46566b"), true)
                draw_circle(Vector2(818.0, 124.0), 6.0, Color("1b2028"))
                draw_circle(Vector2(848.0, 124.0), 6.0, Color("1b2028"))

func _draw_incident_clue_visuals() -> void:
    if not incident_active or active_incident.is_empty():
        return
    match active_incident["kind"]:
        "bathroom":
            draw_circle(BATHROOM_RECT.get_center() + Vector2(0.0, 12.0), 13.0, Color("1b1724"))
            draw_circle(BATHROOM_RECT.get_center() + Vector2(0.0, -5.0), 7.0, Color("d7b7cb"))
            draw_arc(BATHROOM_RECT.get_center(), 32.0, 0.0, TAU, 32, Color("e08ab4"), 3.0)
        "shoplifting":
            var shelf_slot := Rect2(SHELF_RECTS["odd"].position + Vector2(25.0, 105.0), Vector2(50.0, 38.0))
            draw_rect(shelf_slot, Color("25202c"), true)
            draw_line(shelf_slot.position, shelf_slot.end, Color("f0b26e"), 3.0)
            draw_line(Vector2(shelf_slot.end.x, shelf_slot.position.y), Vector2(shelf_slot.position.x, shelf_slot.end.y), Color("f0b26e"), 3.0)
            draw_circle(SHELF_RECTS["odd"].get_center() + Vector2(0.0, 105.0), 7.0, Color("d18d6e"))
        "coupon":
            var coupon_rect := Rect2(736.0, 226.0, 56.0, 24.0)
            draw_rect(coupon_rect, Color("d7e39a"), true)
            draw_rect(coupon_rect, Color("27301d"), false, 2.0)
            draw_line(Vector2(744.0, 234.0), Vector2(784.0, 234.0), Color("657647"), 2.0)
            draw_line(Vector2(744.0, 241.0), Vector2(774.0, 241.0), Color("657647"), 2.0)
        "spill":
            _draw_ellipse(SHELF_RECTS["warm"].get_center() + Vector2(0.0, 122.0), Vector2(58.0, 14.0), Color("b9a16e"))
            draw_circle(SHELF_RECTS["warm"].get_center() + Vector2(-45.0, 112.0), 7.0, Color("d9bf82"))
        "parking_lot":
            draw_rect(Rect2(820.0, 92.0, 54.0, 26.0), Color("53657e"), true)
            draw_rect(Rect2(830.0, 86.0, 30.0, 12.0), Color("53657e"), true)
            draw_circle(Vector2(832.0, 120.0), 6.0, Color("1b2028"))
            draw_circle(Vector2(862.0, 120.0), 6.0, Color("1b2028"))

func _draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
    draw_set_transform(center, 0.0, Vector2(1.0, radius.y / radius.x))
    draw_circle(Vector2.ZERO, radius.x, color)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
