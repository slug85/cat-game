extends Node2D

## Визуальное оформление двух развилок: Старого квартала и Неонового обхода.

const FORT_TILES: Texture2D = preload("res://assets/environment/fort_of_illusion/tileset.png")
const FORT_WINDOW: Texture2D = preload("res://assets/environment/fort_of_illusion/window.png")
const FORT_BANNER: Texture2D = preload("res://assets/environment/fort_of_illusion/banner.png")
const FORT_GATE: Texture2D = preload("res://assets/environment/fort_of_illusion/door.png")
const CITY_TILES: Texture2D = preload("res://assets/environment/central_city/Tiles.png")
const CITY_BUILDINGS: Texture2D = preload("res://assets/environment/central_city/Buildings.png")

var route_style := "old_quarter"
var elevated_routes: Array = []
var vent_positions: Array = []
var obstacle_position := Vector2.ZERO
var animation_time := 0.0


func configure(style: String, routes: Array, vents: Array, obstacle: Vector2) -> void:
	route_style = style
	elevated_routes = routes
	vent_positions = vents
	obstacle_position = obstacle


func _ready() -> void:
	queue_redraw()


func _process(delta: float) -> void:
	animation_time += delta
	queue_redraw()


func _draw() -> void:
	if route_style == "old_quarter":
		_draw_old_quarter()
	else:
		_draw_neon_bypass()


func _draw_old_quarter() -> void:
	draw_rect(Rect2(-200, 0, 3600, 648), Color("15142b"))
	draw_rect(Rect2(-200, 320, 3600, 200), Color("24214c"))
	_draw_floor_roofs(Color("8f93bd"), Rect2(0, 32, 48, 64), FORT_TILES)
	for route: Rect2 in elevated_routes:
		_draw_stone_platform(route)
	_draw_obstacle(Color("796c9c"), Color("c5b6e7"))
	for vent: Vector2 in vent_positions:
		_draw_steam_vent(vent, Color("7c81af"), Color("c8d9ff"))
	draw_texture(FORT_WINDOW, Vector2(600, 460), Color("8db4f7"))
	draw_texture(FORT_WINDOW, Vector2(1940, 460), Color("8db4f7"))
	draw_set_transform(Vector2(1780, 455), sin(animation_time * 2.0) * 0.04)
	draw_texture(FORT_BANNER, Vector2(-24, 0), Color("d47dae"))
	draw_set_transform(Vector2.ZERO)
	draw_texture(FORT_GATE, Vector2(2952, 440), Color("aaa8d9"))
	draw_string(ThemeDB.fallback_font, Vector2(2969, 432), "СТАРАЯ ПОЧТА", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("ffe197"))


func _draw_neon_bypass() -> void:
	draw_rect(Rect2(-200, 0, 3600, 648), Color("07142c"))
	for x: int in range(0, 3300, 320):
		draw_texture_rect_region(CITY_BUILDINGS, Rect2(x, 280 + (x % 3) * 18, 320, 240), Rect2(0, 0, 320, 240), Color("5850ae"))
	_draw_floor_roofs(Color("6f79c9"), Rect2(32, 0, 16, 16), CITY_TILES)
	for route: Rect2 in elevated_routes:
		draw_rect(route.grow(3), Color("171b3a"))
		draw_rect(route, Color("28355d"))
		draw_line(Vector2(route.position.x, route.position.y), Vector2(route.end.x, route.position.y), Color("74f4ff"), 3.0)
		draw_line(Vector2(route.position.x, route.end.y - 4), Vector2(route.end.x, route.end.y - 4), Color("a158f4"), 2.0)
	_draw_obstacle(Color("334b83"), Color("70f4ff"))
	for vent: Vector2 in vent_positions:
		_draw_steam_vent(vent, Color("24365d"), Color("70f4ff"))
	draw_rect(Rect2(2948, 424, 104, 96), Color("20274e"))
	draw_line(Vector2(2952, 438), Vector2(3048, 438), Color("68f7d3"), 4.0)
	draw_string(ThemeDB.fallback_font, Vector2(2973, 430), "DEPOT", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("68f7d3"))


func _draw_floor_roofs(tint: Color, source: Rect2, texture: Texture2D) -> void:
	for roof: Rect2 in [Rect2(0, 520, 1000, 80), Rect2(1200, 520, 900, 80), Rect2(2240, 520, 920, 80)]:
		draw_rect(roof, Color("14152b"))
		for x: int in range(int(roof.position.x), int(roof.end.x), 48):
			draw_texture_rect_region(texture, Rect2(x, roof.position.y, minf(48.0, roof.end.x - x), roof.size.y), source, tint)
		draw_line(Vector2(roof.position.x, roof.position.y), Vector2(roof.end.x, roof.position.y), Color("c5d5ff"), 2.0)


func _draw_stone_platform(route: Rect2) -> void:
	draw_rect(route.grow(3), Color("17172e"))
	draw_texture_rect_region(FORT_TILES, route, Rect2(48, 16, 96, 48), Color("abb1cf"))
	draw_line(Vector2(route.position.x, route.position.y), Vector2(route.end.x, route.position.y), Color("d2d9ed"), 2.0)


func _draw_obstacle(fill_color: Color, edge_color: Color) -> void:
	# Повторяет размер коллайдера исходной стены (54x80).
	var obstacle_rect := Rect2(obstacle_position - Vector2(27, 40), Vector2(54, 80))
	draw_rect(obstacle_rect.grow(3), Color("101226"))
	draw_rect(obstacle_rect, fill_color)
	draw_line(obstacle_rect.position, Vector2(obstacle_rect.end.x, obstacle_rect.position.y), edge_color, 3.0)
	draw_line(Vector2(obstacle_rect.position.x + 8, obstacle_rect.end.y - 10), Vector2(obstacle_rect.end.x - 8, obstacle_rect.end.y - 10), edge_color.darkened(0.2), 2.0)


func _draw_steam_vent(vent_position: Vector2, grate_color: Color, glow_color: Color) -> void:
	# Решётка визуально совпадает с областью урона 112x24.
	var grate := Rect2(vent_position - Vector2(56, 12), Vector2(112, 24))
	draw_rect(grate.grow(2), Color("111426"))
	draw_rect(grate, grate_color)
	for x: float in range(grate.position.x + 8, grate.end.x - 4, 12):
		draw_line(Vector2(x, grate.position.y + 3), Vector2(x, grate.end.y - 3), glow_color, 2.0)

	var phase := animation_time * 2.6 + vent_position.x * 0.01
	for plume: int in range(2):
		for step: int in range(5):
			var progress := step / 4.0
			var radius := 7.0 + progress * 13.0
			var sway := sin(phase + step * 1.6 + plume) * (4.0 + progress * 7.0)
			var alpha := 0.28 - progress * 0.16
			draw_circle(Vector2(vent_position.x + sway, grate.position.y - 8 - step * 12 - plume * 5), radius, Color(0.8, 0.92, 1.0, alpha))
