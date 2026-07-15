extends Node2D

## Рисует фасады крыш, вентиляционные люки и ворота доставки из листов Central City.
## Коллизии остаются на StaticBody2D и Area2D в сцене level_01.tscn.

const TILES: Texture2D = preload("res://assets/environment/central_city/Tiles.png")
const PROPS: Texture2D = preload("res://assets/environment/central_city/Props-01.png")
const BUILDINGS: Texture2D = preload("res://assets/environment/central_city/Buildings.png")
const TILE_SIZE := 16
const ROOFS := [
	Rect2(0, 520, 1000, 80),
	Rect2(1200, 520, 900, 80),
	Rect2(2240, 520, 920, 80),
]
const ROOF_TOP_SOURCE := Rect2(TILE_SIZE * 2, 0, TILE_SIZE, TILE_SIZE)
const ROOF_TRIM_SOURCE := Rect2(0, 0, TILE_SIZE, TILE_SIZE)
const FACADE_SOURCES := [
	Rect2(0, 0, 80, 64),
	Rect2(80, 0, 80, 64),
	Rect2(160, 0, 80, 64),
	Rect2(240, 0, 80, 64),
]
const WALL_SOURCE := Rect2(0, TILE_SIZE * 2, TILE_SIZE * 2, TILE_SIZE * 4)
const STEAM_VENTS := [
	Rect2(1768, 496, 144, 24),
	Rect2(2468, 496, 144, 24),
	Rect2(2818, 496, 144, 24),
]

var steam_elapsed := 0.0


func _ready() -> void:
	queue_redraw()


func _process(delta: float) -> void:
	steam_elapsed += delta
	queue_redraw()


func _draw() -> void:
	for roof: Rect2 in ROOFS:
		_draw_roof(roof)

	# Технический блок слегка заходит в покрытие, чтобы его основание не висело над крышей.
	draw_texture_rect_region(PROPS, Rect2(753, 462, 54, 80), WALL_SOURCE)

	for vent: Rect2 in STEAM_VENTS:
		_draw_steam_vent(vent)

	_draw_finish_gate()


func _draw_roof(roof: Rect2) -> void:
	# Поверхность, узкий карниз и фасад отделены, чтобы платформа читалась как крыша здания.
	draw_rect(roof, Color("14152b"))
	for x: int in range(int(roof.position.x), int(roof.end.x), TILE_SIZE):
		draw_texture_rect_region(TILES, Rect2(x, roof.position.y, TILE_SIZE, TILE_SIZE), ROOF_TOP_SOURCE)
		draw_texture_rect_region(TILES, Rect2(x, roof.position.y + TILE_SIZE, TILE_SIZE, TILE_SIZE), ROOF_TRIM_SOURCE)

	var segment_width := 80
	for x: int in range(int(roof.position.x), int(roof.end.x), segment_width):
		var source: Rect2 = FACADE_SOURCES[(x / segment_width as int) % FACADE_SOURCES.size()]
		var width := minf(segment_width, roof.end.x - x)
		draw_texture_rect_region(BUILDINGS, Rect2(x, roof.position.y + TILE_SIZE * 2, width, roof.size.y - TILE_SIZE * 2), source, Color("7370a4"))

	draw_rect(Rect2(roof.position.x, roof.end.y - 7, roof.size.x, 7), Color("0a0b19"))
	draw_line(Vector2(roof.position.x, roof.end.y - 8), Vector2(roof.end.x, roof.end.y - 8), Color("554d9f"), 2.0)


func _draw_steam_vent(vent: Rect2) -> void:
	# Вентиляционная решётка встроена в плоскость крыши, без выступающей трубы.
	var grate := Rect2(vent.get_center().x - 30, vent.end.y - 14, 60, 14)
	draw_rect(grate.grow(2), Color("111426"))
	draw_rect(grate, Color("252d49"))
	for x: float in range(grate.position.x + 6, grate.end.x - 2, 8):
		draw_line(Vector2(x, grate.position.y + 2), Vector2(x, grate.end.y - 2), Color("7891bb"), 2.0)
	draw_line(Vector2(grate.position.x, grate.position.y), Vector2(grate.end.x, grate.position.y), Color("9ef4ff"), 1.0)

	var phase := steam_elapsed * 2.7 + vent.position.x * 0.01
	for plume: int in range(2):
		for step: int in range(6):
			var progress := step / 5.0
			var radius := 8.0 + progress * 15.0 + sin(phase + step + plume) * 2.0
			var sway := sin(phase + step * 1.7 + plume * 2.5) * (5.0 + progress * 8.0)
			var y := grate.position.y - 6.0 - step * 11.0 - plume * 5.0
			var alpha := 0.28 - progress * 0.15 + sin(phase + step) * 0.04
			draw_circle(Vector2(vent.get_center().x + sway, y), radius, Color(0.78, 0.92, 1.0, alpha))


func _draw_finish_gate() -> void:
	# Портал «пункта передачи»: визуально это проход, а не стена, поэтому кот бежит сквозь него.
	var opening := Rect2(2974, 392, 52, 128)
	draw_rect(opening, Color("11243d"))
	draw_rect(Rect2(2962, 376, 14, 144), Color("38245e"))
	draw_rect(Rect2(3026, 376, 14, 144), Color("38245e"))
	draw_texture_rect_region(PROPS, Rect2(2958, 376, 22, 144), WALL_SOURCE, Color("5e55d7"))
	draw_texture_rect_region(PROPS, Rect2(3022, 376, 22, 144), WALL_SOURCE, Color("5e55d7"), true)
	draw_line(Vector2(2962, 380), Vector2(3040, 380), Color("69f5d0"), 5.0)
	draw_line(Vector2(2974, 398), Vector2(3026, 398), Color("c2fff2"), 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(2983, 390), "GO", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("69f5d0"))
