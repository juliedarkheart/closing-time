extends Node2D
class_name ClosingTimeShift
## First playable operations slice for Closing Time.
##
## Layout follows a real convenience-store plan: parking and glass frontage at the
## top, checkout just inside the door on the right, coffee and hot food as a front
## island visible from the entrance, dry-goods gondola runs down the middle, and the
## cold vault along the back wall as the destination. Back room and restroom sit
## along the back. Move with WASD/arrows. E interacts. Q asks. N starts a new shift.

const PLAYER_SPEED: float = 210.0
const NOTICE_PANEL_WIDTH: float = 540.0
const NOTICE_INNER_WIDTH: float = 500.0
const NOTICE_LINE_HEIGHT: float = 21.0
const NOTICE_FONT_SIZE: int = 15

# --- Interface frame -------------------------------------------------------
const HEADER_RECT := Rect2(20.0, 14.0, 920.0, 42.0)
const SIDEBAR_RECT := Rect2(20.0, 62.0, 260.0, 396.0)
const STORE_BLOCK := Rect2(292.0, 62.0, 648.0, 396.0)
const FOOTER_RECT := Rect2(20.0, 478.0, 920.0, 44.0)

# --- Store plan ------------------------------------------------------------
const EXTERIOR_RECT := Rect2(300.0, 66.0, 632.0, 38.0)   # parking / forecourt
const FLOOR_RECT := Rect2(300.0, 114.0, 632.0, 344.0)    # sales floor
const ENTRY_RECT := Rect2(618.0, 114.0, 84.0, 40.0)      # decompression zone
const DOOR_RECT := Rect2(630.0, 102.0, 60.0, 12.0)
const REGISTER_RECT := Rect2(790.0, 128.0, 128.0, 56.0)  # front counter, faces the glass
const COFFEE_RECT := Rect2(470.0, 126.0, 150.0, 64.0)    # coffee island + hot case
const GONDOLA_A_RECT := Rect2(360.0, 230.0, 88.0, 114.0) # dry goods / odd
const GONDOLA_B_RECT := Rect2(492.0, 230.0, 88.0, 114.0) # snacks
const COLD_VAULT_RECT := Rect2(604.0, 360.0, 296.0, 90.0) # reach-in coolers, back wall
const RESTROOM_RECT := Rect2(470.0, 360.0, 110.0, 90.0)
const BACK_ROOM_RECT := Rect2(316.0, 356.0, 130.0, 94.0)
const MOP_RECT := Rect2(330.0, 392.0, 74.0, 44.0)
const COUNTER_RECT := Rect2(788.0, 186.0, 132.0, 16.0)  # customer-facing counter edge
const CAMERA_POS := Vector2(318.0, 130.0)

const SHELF_RECTS := {
    "cold": COLD_VAULT_RECT,
    "warm": COFFEE_RECT,
    "odd": GONDOLA_A_RECT,
}

# Approach points sit in the aisle in front of each fixture, not on top of it.
const APPROACH_POINTS := {
    "cold": Vector2(752.0, 352.0),
    "warm": Vector2(545.0, 200.0),
    "odd": Vector2(462.0, 287.0),
}
## Browsing travel runs along the shelf face, so shoppers stay in the aisle.
const BROWSE_AXES := {
    "cold": Vector2(1.0, 0.0),
    "warm": Vector2(1.0, 0.0),
    "odd": Vector2(0.0, 1.0),
}
const FRONT_AISLE_Y: float = 208.0
const DOOR_POINT := Vector2(660.0, 118.0)
const REGISTER_QUEUE_POINT := Vector2(852.0, 202.0)
const WALK_BOUNDS := Rect2(306.0, 120.0, 620.0, 332.0)

const FRIDGE_PATH := "res://licensed_assets/limezu/modern_interiors/extracted/moderninteriors-win/3_Animated_objects/32x32/spritesheets/animated_fridge_white_32x32.png"
const CHECKOUT_PATH := "res://licensed_assets/limezu/modern_interiors/extracted/moderninteriors-win/3_Animated_objects/32x32/spritesheets/animated_grocery_store_checkout_roller_32x32.png"

# --- State -----------------------------------------------------------------
var player_position: Vector2 = Vector2(630.0, 300.0)
var cash: int = 24
var trust: int = 0
var served_customers: int = 0
var current_encounter: int = -1
var customer_active: bool = false
var question_used: bool = false
var customer_visible: bool = false
var customer_position: Vector2 = Vector2.ZERO
var customer_phase: String = ""
var customer_browse_time: float = 0.0
var customer_route: Array[Vector2] = []
var customer_route_index: int = 0
var leaving_customers: Array[Dictionary] = []
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
var message: String = "The night shift begins. Work the clipboard, then open the register."
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
        if direction != Vector2.ZERO:
            player_position += direction.normalized() * PLAYER_SPEED * delta
        player_position.x = clampf(player_position.x, WALK_BOUNDS.position.x, WALK_BOUNDS.end.x)
        player_position.y = clampf(player_position.y, WALK_BOUNDS.position.y, WALK_BOUNDS.end.y)
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

# --- Interaction -----------------------------------------------------------
func _interact() -> void:
    if incident_active:
        if _incident_location_rect().grow(28.0).has_point(player_position):
            _handle_incident_step()
            return
        if MOP_RECT.grow(20.0).has_point(player_position):
            _take_mop()
            return
        message = "The active incident needs attention first. Do not chase trouble across the whole store."
        message_time = 4.0
        return
    if customer_active and REGISTER_RECT.grow(28.0).has_point(player_position):
        if customer_phase == "waiting":
            _serve_customer()
        else:
            message = "%s is still shopping. Give them a moment to reach the counter." % encounters[current_encounter]["name"]
            message_time = 3.0
        return
    if not customer_active and REGISTER_RECT.grow(28.0).has_point(player_position):
        _start_next_encounter()
        return
    for category in SHELF_RECTS:
        if SHELF_RECTS[category].grow(14.0).has_point(player_position):
            _take_item(category)
            return
    message = "Nothing here to work with. Check the clipboard."
    message_time = 3.0

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
    customer_position = DOOR_POINT
    var entry_approach: Vector2 = APPROACH_POINTS[encounters[current_encounter]["category"]]
    _set_customer_route([
        Vector2(DOOR_POINT.x, FRONT_AISLE_Y),
        Vector2(entry_approach.x, FRONT_AISLE_Y),
        entry_approach,
    ])
    customer_browse_time = encounters[current_encounter]["browse_pause"]
    question_used = false
    message = encounters[current_encounter]["name"] + " comes in off the lot and starts shopping."
    message_time = 6.0

func _set_customer_route(points: Array[Vector2]) -> void:
    customer_route = points
    customer_route_index = 0

func _advance_route(delta: float, speed: float) -> bool:
    while customer_route_index < customer_route.size():
        var target: Vector2 = customer_route[customer_route_index]
        customer_position = customer_position.move_toward(target, speed * delta)
        if customer_position.distance_to(target) < 3.0:
            customer_position = target
            customer_route_index += 1
            continue
        return false
    return true

func _update_customer(delta: float) -> void:
    _update_leaving_customers(delta)
    if not customer_visible:
        return
    var category: String = encounters[current_encounter]["category"]
    var approach: Vector2 = APPROACH_POINTS[category]
    match customer_phase:
        "entering":
            if _advance_route(delta, 150.0):
                customer_phase = "browsing"
        "browsing":
            customer_browse_time -= delta
            if customer_browse_time <= 0.0:
                customer_phase = "wandering"
                var offset: Vector2 = encounters[current_encounter]["browse_offset"]
                var axis: Vector2 = BROWSE_AXES[category]
                _set_customer_route([approach + Vector2(offset.x * axis.x, offset.y * axis.y)])
        "wandering":
            if _advance_route(delta, 110.0):
                customer_phase = "walking_to_register"
                _set_customer_route([Vector2(approach.x, FRONT_AISLE_Y), REGISTER_QUEUE_POINT])
        "walking_to_register":
            if _advance_route(delta, 175.0):
                customer_position = REGISTER_QUEUE_POINT
                customer_phase = "waiting"

func _update_leaving_customers(delta: float) -> void:
    var still_leaving: Array[Dictionary] = []
    for shopper in leaving_customers:
        var index: int = int(shopper["index"])
        var route: Array = shopper["route"]
        var position: Vector2 = shopper["position"]
        while index < route.size():
            var target: Vector2 = route[index]
            position = position.move_toward(target, 175.0 * delta)
            if position.distance_to(target) < 3.0:
                position = target
                index += 1
                continue
            break
        if index < route.size():
            shopper["position"] = position
            shopper["index"] = index
            still_leaving.append(shopper)
    leaving_customers = still_leaving

func _customer_color(category: String) -> Color:
    if category == "warm":
        return Color("c98f6f")
    if category == "odd":
        return Color("ad8cc4")
    return Color("8aa7c7")

func _take_item(category: String) -> void:
    if customer_active == false:
        _complete_opening_task(category)
    elif held_item != "":
        message = "You are already carrying the %s item." % held_item
    elif int(shelf_stock[category]) <= 0:
        message = "The %s shelf is empty. You will have to tell the customer." % category
    else:
        shelf_stock[category] -= 1
        held_item = category
        message = "You take one %s item. Bring it to the counter." % category
    message_time = 4.0

func _complete_opening_task(category: String) -> void:
    for task in opening_tasks:
        if not task["completed"]:
            if task["category"] == category:
                task["completed"] = true
                completed_opening_tasks += 1
                if completed_opening_tasks >= opening_tasks.size():
                    message = "Clipboard clear. Open the register and call the first customer."
                else:
                    message = task["text"] + " Done. Next item is on the clipboard."
            else:
                message = "Wrong fixture. The clipboard points at the highlighted one."
            return
    message = "The opening tasks are done. Call the next customer at the register."
    message_time = 5.0

func _handle_incident_step() -> void:
    if incident_stage == "observed":
        incident_stage = "inspected"
        message = active_incident["detail"] + "\n" + active_incident["instruction"]
        message_time = 6.0
        return
    if _incident_needs_mop() and not holding_mop:
        message = "You need the mop from the back room before you can clean this up."
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
    message = "You take the mop out of the back room. Bring it to the spill."
    message_time = 4.0

func _incident_location_label() -> String:
    if active_incident.is_empty():
        return "the floor"
    match active_incident["location"]:
        "bathroom":
            return "restroom"
        "odd_shelf":
            return "dry goods gondola"
        "warm_shelf":
            return "coffee island"
        "register":
            return "front counter"
    return "the floor"

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
    leaving_customers.clear()
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
    player_position = Vector2(630.0, 300.0)
    message = "A new shift begins. %s" % shift_data["condition"]
    message_time = 6.0

func _ask_question() -> void:
    if not customer_active:
        message = "There is nobody at the counter to ask."
    elif not REGISTER_RECT.grow(34.0).has_point(player_position):
        message = "Ask the customer once they reach the counter."
    elif question_used:
        message = "You already asked your one useful question."
    else:
        question_used = true
        trust += 1
        message = encounters[current_encounter]["question"] + "\nThey confirm they need something from the %s." % _category_label(encounters[current_encounter]["category"])
    message_time = 5.0

func _category_label(category: String) -> String:
    match category:
        "cold":
            return "cold vault at the back"
        "warm":
            return "coffee and hot food island"
        "odd":
            return "dry goods gondola"
    return category

func _serve_customer() -> void:
    var encounter: Dictionary = encounters[current_encounter]
    if held_item == "":
        trust -= 1
        message = "You have nothing in your hands. The customer leaves without buying."
    elif held_item == encounter["category"]:
        cash += 4
        trust += 1
        message = encounter["issue"] + "\nCorrect item served. They leave $4 and a clue behind."
    else:
        trust -= 1
        message = encounter["issue"] + "\nWrong item served. The customer leaves unconvinced."
    held_item = ""
    leaving_customers.append({
        "position": customer_position,
        "route": [Vector2(customer_position.x, FRONT_AISLE_Y), Vector2(DOOR_POINT.x, DOOR_POINT.y)],
        "index": 0,
        "color": _customer_color(encounter["category"]),
        "name": encounter["name"],
    })
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
        message = active_incident["title"] + "\nSomething is wrong near the " + _incident_location_label() + "."
        message_time = 6.0
    else:
        message_time = 6.0

func _incident_location_rect() -> Rect2:
    if active_incident.is_empty():
        return Rect2()
    match active_incident["location"]:
        "bathroom":
            return RESTROOM_RECT
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

# --- Text rendering --------------------------------------------------------
## draw_string() clips when given a width, which is what cut off the dialogue.
## Everything here wraps first, then draws with no width limit.
func _wrap_text(text: String, max_width: float, font_size: int) -> PackedStringArray:
    var font := ThemeDB.fallback_font
    var lines := PackedStringArray()
    for paragraph in text.split("\n"):
        var current := ""
        for word in paragraph.split(" ", false):
            var candidate := word if current == "" else current + " " + word
            var measured := font.get_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
            if measured <= max_width or current == "":
                current = candidate
            else:
                lines.append(current)
                current = word
        lines.append(current)
    return lines

func _draw_wrapped(text: String, position: Vector2, max_width: float, font_size: int, color: Color, line_height: float) -> int:
    var lines := _wrap_text(text, max_width, font_size)
    for index in range(lines.size()):
        draw_string(ThemeDB.fallback_font, position + Vector2(0.0, float(index) * line_height), lines[index], HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
    return lines.size()

# --- Drawing ---------------------------------------------------------------
func _draw() -> void:
    draw_count += 1
    draw_rect(Rect2(0.0, 0.0, 960.0, 540.0), Color("0d1320"))
    _draw_header()
    _draw_sidebar()
    _draw_store()
    _draw_incident_highlight()
    _draw_aftermath()
    _draw_incident_clue_visuals()
    _draw_people()
    _draw_proximity_prompt()
    _draw_footer()
    _draw_overlay_panels()

func _draw_header() -> void:
    draw_rect(HEADER_RECT, Color("182130"), true)
    draw_rect(HEADER_RECT, Color("2d3a4e"), false, 2.0)
    draw_string(ThemeDB.fallback_font, Vector2(38.0, 42.0), "CLOSING TIME  ·  OVERNIGHT SHIFT", HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("f5d7a1"))
    draw_string(ThemeDB.fallback_font, Vector2(640.0, 41.0), "SHIFT #%d   ·   N: new shift" % shift_seed, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("c4cfdd"))

func _draw_sidebar() -> void:
    draw_rect(SIDEBAR_RECT, Color("161d2a"), true)
    draw_rect(SIDEBAR_RECT, Color("3a4a60"), false, 2.0)
    var x := SIDEBAR_RECT.position.x + 14.0
    var width := SIDEBAR_RECT.size.x - 28.0
    var y := SIDEBAR_RECT.position.y + 24.0
    draw_string(ThemeDB.fallback_font, Vector2(x, y), "SHIFT CLIPBOARD", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("f5d7a1"))
    y += 22.0
    draw_line(Vector2(x, y - 8.0), Vector2(x + width, y - 8.0), Color("2d3a4e"), 1.0)

    draw_string(ThemeDB.fallback_font, Vector2(x, y + 6.0), "OPENING TASKS", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("9fb3c8"))
    y += 24.0
    for task in opening_tasks:
        var mark := "[x]" if task["completed"] else "[ ]"
        var color := Color("7f9a7a") if task["completed"] else Color("e8eef5")
        y += float(_draw_wrapped(mark + " " + task["text"], Vector2(x, y + 5.0), width, 13, color, 17.0)) * 17.0
        y += 6.0

    y += 12.0
    draw_line(Vector2(x, y - 10.0), Vector2(x + width, y - 10.0), Color("2d3a4e"), 1.0)
    draw_string(ThemeDB.fallback_font, Vector2(x, y + 4.0), "CUSTOMERS SERVED   %d / %d" % [served_customers, encounters.size()], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("e8eef5"))
    y += 24.0
    draw_string(ThemeDB.fallback_font, Vector2(x, y), "NIGHT NOTES   %d" % handoff_notes, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("e8eef5"))
    y += 22.0
    draw_string(ThemeDB.fallback_font, Vector2(x, y), "SAFETY   %d" % safety_score, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("e8eef5"))
    y += 22.0
    draw_string(ThemeDB.fallback_font, Vector2(x, y), "CASH   $%d" % cash, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("e8eef5"))
    y += 22.0
    draw_string(ThemeDB.fallback_font, Vector2(x, y), "TRUST   %d" % trust, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("e8eef5"))

    var legend_y := SIDEBAR_RECT.end.y - 78.0
    draw_line(Vector2(x, legend_y - 14.0), Vector2(x + width, legend_y - 14.0), Color("2d3a4e"), 1.0)
    for line in [
        "WASD / arrows  move",
        "E  interact      Q  ask",
        "N  new shift",
    ]:
        draw_string(ThemeDB.fallback_font, Vector2(x, legend_y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("9fb3c8"))
        legend_y += 17.0

    var hands := "empty"
    if holding_mop:
        hands = "mop"
    elif held_item != "":
        hands = held_item + " item"
    draw_string(ThemeDB.fallback_font, Vector2(x, SIDEBAR_RECT.end.y - 18.0), "HANDS   %s" % hands, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("f5d7a1"))

func _draw_store() -> void:
    # Forecourt behind the glass.
    draw_rect(EXTERIOR_RECT, Color("141b28"), true)
    for stripe in range(6):
        var stripe_x := EXTERIOR_RECT.position.x + 24.0 + float(stripe) * 104.0
        draw_line(Vector2(stripe_x, EXTERIOR_RECT.end.y - 4.0), Vector2(stripe_x + 30.0, EXTERIOR_RECT.end.y - 4.0), Color("2b3444"), 2.0)
    draw_string(ThemeDB.fallback_font, Vector2(EXTERIOR_RECT.position.x + 8.0, EXTERIOR_RECT.position.y + 18.0), "PARKING LOT", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("5d6b80"))

    # Sales floor.
    draw_rect(FLOOR_RECT, Color("39434f"), true)
    draw_rect(FLOOR_RECT, Color("5c6b7d"), false, 3.0)
    # Tile grid so movement reads.
    for column in range(1, 13):
        var grid_x := FLOOR_RECT.position.x + float(column) * 48.0
        draw_line(Vector2(grid_x, FLOOR_RECT.position.y), Vector2(grid_x, FLOOR_RECT.end.y), Color("414c59"), 1.0)
    for row in range(1, 8):
        var grid_y := FLOOR_RECT.position.y + float(row) * 44.0
        draw_line(Vector2(FLOOR_RECT.position.x, grid_y), Vector2(FLOOR_RECT.end.x, grid_y), Color("414c59"), 1.0)

    # Glass storefront with the entrance gap.
    draw_rect(Rect2(FLOOR_RECT.position.x, FLOOR_RECT.position.y - 12.0, FLOOR_RECT.size.x, 12.0), Color("8fb6d6"), true)
    draw_rect(DOOR_RECT, Color("1b2430"), true)
    draw_rect(DOOR_RECT, Color("e8c18d"), false, 2.0)
    draw_string(ThemeDB.fallback_font, Vector2(DOOR_RECT.position.x + 6.0, DOOR_RECT.position.y - 4.0), "ENTRANCE", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("e8c18d"))
    draw_rect(ENTRY_RECT, Color("6f7d8f"), false, 1.0)

    # Fixtures.
    draw_rect(BACK_ROOM_RECT, Color("3d3630"), true)
    draw_rect(BACK_ROOM_RECT, Color("7a6a58"), false, 2.0)
    draw_rect(RESTROOM_RECT, Color("3f3a4c"), true)
    draw_rect(RESTROOM_RECT, Color("9b8fb8"), false, 2.0)
    draw_rect(COLD_VAULT_RECT, Color("3f5560"), true)
    draw_rect(COLD_VAULT_RECT, Color("87b6c8"), false, 3.0)
    draw_rect(COFFEE_RECT, Color("4a5a45"), true)
    draw_rect(COFFEE_RECT, Color("9dc088"), false, 3.0)
    draw_rect(GONDOLA_A_RECT, Color("5b4a41"), true)
    draw_rect(GONDOLA_A_RECT, Color("c19a7d"), false, 3.0)
    draw_rect(GONDOLA_B_RECT, Color("5b4a41"), true)
    draw_rect(GONDOLA_B_RECT, Color("a8825f"), false, 2.0)
    draw_rect(REGISTER_RECT, Color("7c5a42"), true)
    draw_rect(REGISTER_RECT, Color("e8c18d"), false, 3.0)
    draw_rect(COUNTER_RECT, Color("a97f57"), true)

    if fridge_sheet != null:
        draw_texture_rect_region(fridge_sheet, Rect2(COLD_VAULT_RECT.position.x + 12.0, COLD_VAULT_RECT.position.y + 10.0, 56.0, 66.0), Rect2(0.0, 0.0, 32.0, 32.0))
    if checkout_sheet != null:
        draw_texture_rect_region(checkout_sheet, Rect2(REGISTER_RECT.position.x + 16.0, REGISTER_RECT.position.y + 8.0, 72.0, 40.0), Rect2(0.0, 0.0, 32.0, 32.0))

    # Identification signage, the way a real store labels its zones.
    draw_string(ThemeDB.fallback_font, Vector2(COLD_VAULT_RECT.position.x + 78.0, COLD_VAULT_RECT.position.y + 30.0), "COLD DRINKS", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("dff2f8"))
    draw_string(ThemeDB.fallback_font, Vector2(COLD_VAULT_RECT.position.x + 78.0, COLD_VAULT_RECT.position.y + 50.0), "reach-in coolers  ·  back wall", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("a9c7d2"))
    draw_string(ThemeDB.fallback_font, Vector2(COFFEE_RECT.position.x + 10.0, COFFEE_RECT.position.y + 24.0), "COFFEE · HOT FOOD", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("e2f5d3"))
    draw_string(ThemeDB.fallback_font, Vector2(COFFEE_RECT.position.x + 10.0, COFFEE_RECT.position.y + 44.0), "self-serve island", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("b6d3a6"))
    draw_string(ThemeDB.fallback_font, Vector2(REGISTER_RECT.position.x + 8.0, REGISTER_RECT.position.y + 50.0), "FRONT COUNTER", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("ffeccd"))
    draw_string(ThemeDB.fallback_font, Vector2(GONDOLA_A_RECT.position.x + 4.0, GONDOLA_A_RECT.position.y + 22.0), "DRY", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("f2dcc8"))
    draw_string(ThemeDB.fallback_font, Vector2(GONDOLA_A_RECT.position.x + 4.0, GONDOLA_A_RECT.position.y + 38.0), "GOODS", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("f2dcc8"))
    draw_string(ThemeDB.fallback_font, Vector2(GONDOLA_B_RECT.position.x + 4.0, GONDOLA_B_RECT.position.y + 22.0), "SNACKS", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("e6c9a8"))
    draw_string(ThemeDB.fallback_font, Vector2(BACK_ROOM_RECT.position.x + 10.0, BACK_ROOM_RECT.position.y + 20.0), "BACK ROOM", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("e0d2bf"))
    draw_string(ThemeDB.fallback_font, Vector2(RESTROOM_RECT.position.x + 12.0, RESTROOM_RECT.position.y + 22.0), "RESTROOM", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("e6dcff"))

    # Mop and bucket in the back room.
    if not holding_mop:
        draw_line(MOP_RECT.position + Vector2(12.0, 34.0), MOP_RECT.position + Vector2(44.0, 4.0), Color("c6b58a"), 3.0)
        draw_rect(Rect2(MOP_RECT.position.x + 4.0, MOP_RECT.position.y + 30.0, 22.0, 12.0), Color("8fa8c0"), true)

    # Ceiling camera, pointed wherever it feels like it.
    draw_rect(Rect2(CAMERA_POS.x, CAMERA_POS.y, 20.0, 12.0), Color("2a3340"), true)
    draw_circle(Vector2(CAMERA_POS.x + 10.0, CAMERA_POS.y + 16.0), 5.0, Color("5d6b80"))
    draw_circle(Vector2(CAMERA_POS.x + 10.0, CAMERA_POS.y + 16.0), 2.0, Color("cfd8e3"))

func _draw_people() -> void:
    for shopper in leaving_customers:
        var position: Vector2 = shopper["position"]
        var color: Color = shopper["color"]
        draw_circle(position, 13.0, color)
        draw_circle(position, 13.0, Color("fff1d6"), false, 2.0)
        draw_rect(Rect2(position.x - 9.0, position.y + 8.0, 18.0, 10.0), color, true)

    if customer_visible:
        var category: String = encounters[current_encounter]["category"]
        var color := _customer_color(category)
        draw_circle(customer_position, 14.0, color)
        draw_circle(customer_position, 14.0, Color("fff1d6"), false, 2.0)
        draw_rect(Rect2(customer_position.x - 9.0, customer_position.y + 8.0, 18.0, 11.0), color, true)
        if customer_phase == "browsing" or customer_phase == "wandering":
            draw_rect(Rect2(customer_position.x + 10.0, customer_position.y + 4.0, 9.0, 10.0), Color("e5c68c"), true)
            draw_line(customer_position + Vector2(12.0, 4.0), customer_position + Vector2(16.0, 0.0), Color("e5c68c"), 2.0)
        var name: String = encounters[current_encounter]["name"]
        var name_width := ThemeDB.fallback_font.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x
        draw_string(ThemeDB.fallback_font, customer_position + Vector2(-name_width * 0.5, -22.0), name, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("fff1d6"))

    draw_circle(player_position, 15.0, Color("e6b875"))
    draw_circle(player_position, 15.0, Color("fff1d6"), false, 3.0)
    if holding_mop:
        draw_line(player_position + Vector2(9.0, -12.0), player_position + Vector2(22.0, 16.0), Color("c6b58a"), 3.0)
        draw_rect(Rect2(player_position.x + 16.0, player_position.y + 8.0, 13.0, 10.0), Color("8fa8c0"), true)
    elif held_item != "":
        draw_rect(Rect2(player_position.x + 12.0, player_position.y - 6.0, 12.0, 12.0), Color("dce8f4"), true)

func _proximity_prompt() -> String:
    return _proximity_prompt_at(player_position)

## Proximity prompt: name the thing and the action, the way a real interactive object does.
func _proximity_prompt_at(point: Vector2) -> String:
    if incident_active:
        if _incident_location_rect().grow(28.0).has_point(point):
            if incident_stage == "observed":
                return "[E]  Look at the " + _incident_location_label()
            return "[E]  Handle it"
        if MOP_RECT.grow(20.0).has_point(point):
            return "[E]  Take the mop"
        return ""
    if REGISTER_RECT.grow(28.0).has_point(point):
        if customer_active:
            if customer_phase == "waiting":
                return "[E]  Serve %s" % encounters[current_encounter]["name"]
            return "Waiting for %s to reach the counter" % encounters[current_encounter]["name"]
        if completed_opening_tasks < opening_tasks.size():
            return "Opening tasks first"
        if served_customers >= encounters.size():
            return "[E]  Close out the shift"
        return "[E]  Call the next customer"
    for category in SHELF_RECTS:
        if SHELF_RECTS[category].grow(14.0).has_point(point):
            if not customer_active:
                for task in opening_tasks:
                    if not task["completed"] and task["category"] == category:
                        return "[E]  " + task["text"]
                return "Nothing to do here right now"
            if held_item == "":
                return "[E]  Take a %s item" % category
            return "Hands full"
    return ""

func _draw_proximity_prompt() -> void:
    var prompt := _proximity_prompt()
    if prompt == "":
        return
    var font := ThemeDB.fallback_font
    var text_width := font.get_string_size(prompt, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
    var box := Rect2(player_position.x - text_width * 0.5 - 10.0, player_position.y - 50.0, text_width + 20.0, 22.0)
    box.position.x = clampf(box.position.x, FLOOR_RECT.position.x + 4.0, FLOOR_RECT.end.x - box.size.x - 4.0)
    draw_rect(box, Color("0d1320"), true)
    draw_rect(box, Color("e8c18d"), false, 1.0)
    draw_string(font, Vector2(box.position.x + 10.0, box.position.y + 16.0), prompt, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("fff1d6"))

func _draw_footer() -> void:
    draw_rect(FOOTER_RECT, Color("182130"), true)
    draw_rect(FOOTER_RECT, Color("2d3a4e"), false, 2.0)
    var summary := "OPENING %d/%d   ·   CUSTOMERS %d/%d   ·   SAFETY %d   ·   NOTES %d   ·   CASH $%d   ·   TRUST %d" % [
        completed_opening_tasks, opening_tasks.size(), served_customers, encounters.size(), safety_score, handoff_notes, cash, trust
    ]
    draw_string(ThemeDB.fallback_font, Vector2(38.0, 506.0), summary, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("dce8f4"))

func _draw_overlay_panels() -> void:
    if incident_active:
        var entries: Array[String] = [active_incident["title"]]
        if incident_stage == "observed":
            entries.append("Look at the " + _incident_location_label() + " and press E to see what it is.")
        else:
            entries.append(active_incident["instruction"])
        entries.append(active_incident["joke"])
        if incident_stage == "inspected" and _incident_needs_mop() and not holding_mop:
            entries.append("You need the mop from the back room.")
        _draw_notice_panel("NIGHT-SHIFT INCIDENT", entries, Color("241d2a"), Color("d59cbd"), Color("ffd5e7"))
        return
    if customer_active:
        var encounter: Dictionary = encounters[current_encounter]
        var entries: Array[String] = [encounter["name"], encounter["need"], encounter["issue"]]
        entries.append("Q: " + encounter["question"])
        if customer_phase == "waiting":
            entries.append("At the counter. Take a %s item and press E." % encounter["category"])
        else:
            entries.append("Still shopping near the %s." % _category_label(encounter["category"]))
        _draw_notice_panel("CUSTOMER", entries, Color("101622"), Color("e8c18d"), Color("fff1d6"))
        return
    if message_time > 0.0 or served_customers == 0 or dawn_reached:
        _draw_notice_panel("", [message], Color("101622"), Color("e8c18d"), Color("fff1d6"))

## Single source of truth for the overlay panel box, so tests can verify the
## worst-case incident text still fits on screen instead of guessing.
func _notice_panel_rect(title: String, entries: Array[String]) -> Rect2:
    var body_lines := 0
    for entry in entries:
        body_lines += _wrap_text(entry, NOTICE_INNER_WIDTH, NOTICE_FONT_SIZE).size()
    var title_lines := 0
    if title != "":
        title_lines = 1
    var panel_height := 22.0 + float(title_lines) * 26.0 + float(body_lines) * NOTICE_LINE_HEIGHT + 14.0
    return Rect2(FLOOR_RECT.position.x + 24.0, FLOOR_RECT.end.y - panel_height - 14.0, NOTICE_PANEL_WIDTH, panel_height)

func _draw_notice_panel(title: String, entries: Array[String], fill: Color, border: Color, text_color: Color) -> void:
    var font := ThemeDB.fallback_font
    var panel := _notice_panel_rect(title, entries)
    draw_rect(panel, fill, true)
    draw_rect(panel, border, false, 2.0)
    var y := panel.position.y + 28.0
    if title != "":
        draw_string(font, Vector2(panel.position.x + 20.0, y), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, text_color)
        y += 26.0
    for entry in entries:
        for line in _wrap_text(entry, NOTICE_INNER_WIDTH, NOTICE_FONT_SIZE):
            draw_string(font, Vector2(panel.position.x + 20.0, y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, NOTICE_FONT_SIZE, text_color)
            y += NOTICE_LINE_HEIGHT

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
                var sign_base := Vector2(COFFEE_RECT.get_center().x, COFFEE_RECT.end.y + 16.0)
                draw_colored_polygon(PackedVector2Array([
                    sign_base + Vector2(0.0, -18.0),
                    sign_base + Vector2(15.0, 12.0),
                    sign_base + Vector2(-15.0, 12.0)
                ]), Color("f2d16b"))
                draw_line(sign_base + Vector2(0.0, -8.0), sign_base + Vector2(0.0, 2.0), Color("4a3c12"), 2.0)
                draw_circle(sign_base + Vector2(0.0, 7.0), 1.8, Color("4a3c12"))
            "shoplifting":
                var gap_slot := Rect2(GONDOLA_A_RECT.position + Vector2(18.0, 52.0), Vector2(52.0, 34.0))
                draw_rect(gap_slot, Color("241c18"), true)
                draw_rect(gap_slot, Color("b0654e"), false, 2.0)
            "bathroom":
                draw_circle(RESTROOM_RECT.get_center() + Vector2(36.0, -22.0), 9.0, Color("8fd3a8"))
                draw_line(RESTROOM_RECT.get_center() + Vector2(32.0, -22.0), RESTROOM_RECT.get_center() + Vector2(35.0, -18.0), Color("1d2b21"), 2.0)
                draw_line(RESTROOM_RECT.get_center() + Vector2(35.0, -18.0), RESTROOM_RECT.get_center() + Vector2(41.0, -27.0), Color("1d2b21"), 2.0)
            "coupon":
                var left_coupon := Rect2(REGISTER_RECT.position.x + 8.0, REGISTER_RECT.end.y - 22.0, 44.0, 16.0)
                draw_rect(left_coupon, Color("cdd894"), true)
                draw_rect(left_coupon, Color("27301d"), false, 2.0)
            "parking_lot":
                draw_rect(Rect2(EXTERIOR_RECT.position.x + 40.0, EXTERIOR_RECT.position.y + 6.0, 60.0, 22.0), Color("46566b"), true)
                draw_rect(Rect2(EXTERIOR_RECT.position.x + 50.0, EXTERIOR_RECT.position.y, 34.0, 10.0), Color("46566b"), true)
                draw_circle(Vector2(EXTERIOR_RECT.position.x + 52.0, EXTERIOR_RECT.position.y + 30.0), 6.0, Color("1b2028"))
                draw_circle(Vector2(EXTERIOR_RECT.position.x + 88.0, EXTERIOR_RECT.position.y + 30.0), 6.0, Color("1b2028"))

func _draw_incident_clue_visuals() -> void:
    if not incident_active or active_incident.is_empty():
        return
    match active_incident["kind"]:
        "bathroom":
            draw_circle(RESTROOM_RECT.get_center() + Vector2(0.0, 12.0), 13.0, Color("1b1724"))
            draw_circle(RESTROOM_RECT.get_center() + Vector2(0.0, -5.0), 7.0, Color("d7b7cb"))
            draw_arc(RESTROOM_RECT.get_center(), 32.0, 0.0, TAU, 32, Color("e08ab4"), 3.0)
        "shoplifting":
            var shelf_slot := Rect2(GONDOLA_A_RECT.position + Vector2(18.0, 52.0), Vector2(52.0, 34.0))
            draw_rect(shelf_slot, Color("241c18"), true)
            draw_line(shelf_slot.position, shelf_slot.end, Color("f0b26e"), 3.0)
            draw_line(Vector2(shelf_slot.end.x, shelf_slot.position.y), Vector2(shelf_slot.position.x, shelf_slot.end.y), Color("f0b26e"), 3.0)
            draw_circle(Vector2(GONDOLA_A_RECT.end.x + 26.0, GONDOLA_A_RECT.get_center().y + 30.0), 7.0, Color("d18d6e"))
        "coupon":
            var coupon_rect := Rect2(REGISTER_RECT.position.x + 20.0, REGISTER_RECT.end.y - 34.0, 56.0, 22.0)
            draw_rect(coupon_rect, Color("d7e39a"), true)
            draw_rect(coupon_rect, Color("27301d"), false, 2.0)
            draw_line(Vector2(coupon_rect.position.x + 8.0, coupon_rect.position.y + 8.0), Vector2(coupon_rect.end.x - 8.0, coupon_rect.position.y + 8.0), Color("657647"), 2.0)
            draw_line(Vector2(coupon_rect.position.x + 8.0, coupon_rect.position.y + 15.0), Vector2(coupon_rect.end.x - 16.0, coupon_rect.position.y + 15.0), Color("657647"), 2.0)
        "spill":
            _draw_ellipse(Vector2(COFFEE_RECT.get_center().x, COFFEE_RECT.end.y + 10.0), Vector2(58.0, 14.0), Color("b9a16e"))
            draw_circle(Vector2(COFFEE_RECT.get_center().x - 45.0, COFFEE_RECT.end.y + 2.0), 7.0, Color("d9bf82"))
        "parking_lot":
            draw_rect(Rect2(EXTERIOR_RECT.position.x + 60.0, EXTERIOR_RECT.position.y + 6.0, 60.0, 24.0), Color("53657e"), true)
            draw_rect(Rect2(EXTERIOR_RECT.position.x + 70.0, EXTERIOR_RECT.position.y, 34.0, 12.0), Color("53657e"), true)
            draw_circle(Vector2(EXTERIOR_RECT.position.x + 72.0, EXTERIOR_RECT.position.y + 32.0), 6.0, Color("1b2028"))
            draw_circle(Vector2(EXTERIOR_RECT.position.x + 108.0, EXTERIOR_RECT.position.y + 32.0), 6.0, Color("1b2028"))

func _draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
    draw_set_transform(center, 0.0, Vector2(1.0, radius.y / radius.x))
    draw_circle(Vector2.ZERO, radius.x, color)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
