extends Node2D
## First graybox slice for Closing Time.
## Move with WASD or arrow keys. Press E at the register.

const PLAYER_SPEED: float = 220.0
const SHOP_RECT := Rect2(80.0, 70.0, 800.0, 400.0)
const REGISTER_RECT := Rect2(690.0, 165.0, 120.0, 90.0)

var player_position: Vector2 = Vector2(460.0, 360.0)
var cash: int = 24
var stock: int = 6
var served_customers: int = 0
var message: String = "The night shift begins. Check the register."
var message_time: float = 0.0

func _ready() -> void:
    queue_redraw()

func _process(delta: float) -> void:
    var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    player_position += direction * PLAYER_SPEED * delta
    player_position.x = clamp(player_position.x, SHOP_RECT.position.x + 24.0, SHOP_RECT.end.x - 24.0)
    player_position.y = clamp(player_position.y, SHOP_RECT.position.y + 24.0, SHOP_RECT.end.y - 24.0)
    if message_time > 0.0:
        message_time -= delta
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("interact") and REGISTER_RECT.grow(28.0).has_point(player_position):
        if stock > 0:
            stock -= 1
            cash += 4
            served_customers += 1
            message = "Customer served. Something about them felt off."
        else:
            message = "The shelves are empty. Restock before dawn."
        message_time = 4.0
        queue_redraw()

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
    draw_string(ThemeDB.fallback_font, Vector2(30.0, 510.0), "WASD / ARROWS: move     E: serve at register", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("c4cfdd"))
    draw_string(ThemeDB.fallback_font, Vector2(690.0, 110.0), "CASH: $%02d    STOCK: %02d" % [cash, stock], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("dce8f4"))
    draw_string(ThemeDB.fallback_font, Vector2(30.0, 495.0), "CUSTOMERS SERVED: %02d" % served_customers, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("dce8f4"))
    if message_time > 0.0 or served_customers == 0:
        draw_rect(Rect2(280.0, 420.0, 400.0, 42.0), Color("182130"), true)
        draw_string(ThemeDB.fallback_font, Vector2(300.0, 447.0), message, HORIZONTAL_ALIGNMENT_LEFT, 360, 16, Color("fff1d6"))
