extends "res://scripts/level_01.gd"

## Вариант базовой трассы для ветвей карты.
## Переиспользует правила забега и добавляет верхние маршруты с предметами.

@export_enum("old_quarter", "neon_bypass") var route_style := "old_quarter"

const ELEVATED_ROUTES := {
	"old_quarter": [Rect2(260, 444, 260, 24), Rect2(1320, 412, 300, 24), Rect2(2380, 444, 260, 24)],
	"neon_bypass": [Rect2(430, 428, 300, 24), Rect2(1470, 444, 250, 24), Rect2(2440, 402, 300, 24)],
}
const BRANCH_ROUTE_ART_SCRIPT := preload("res://scripts/branch_route_art.gd")


func _ready() -> void:
	_configure_route()
	super._ready()


func _configure_route() -> void:
	$CentralCityArt.hide()
	$RoofStart/Visual.hide()
	$RoofMiddle/Visual.hide()
	$RoofEnd/Visual.hide()
	$Obstacle/Visual.hide()
	$FinishZone/Visual.hide()

	for vent: Area2D in [$DamageVent, $DamageVent02, $DamageVent03]:
		vent.get_node("Visual").hide()

	if route_style == "old_quarter":
		$DamageVent.position.x = 900
		$DamageVent02.position.x = 1850
		$DamageVent03.position.x = 2790
		$Obstacle.position = Vector2(1090, 480)
		_set_collectible_positions([
			Vector2(390, 410), Vector2(690, 470), Vector2(1450, 375),
			Vector2(1710, 470), Vector2(2490, 410), Vector2(2780, 470),
		], [Vector2(1520, 362), Vector2(2570, 394)])
	else:
		$DamageVent.position.x = 1040
		$DamageVent02.position.x = 2180
		$DamageVent03.position.x = 2880
		$Obstacle.position = Vector2(810, 480)
		_set_collectible_positions([
			Vector2(500, 360), Vector2(760, 470), Vector2(1520, 410),
			Vector2(1800, 470), Vector2(2520, 350), Vector2(2850, 470),
		], [Vector2(640, 345), Vector2(2650, 320)])

	for route: Rect2 in ELEVATED_ROUTES[route_style]:
		_add_elevated_platform(route)

	var art := BRANCH_ROUTE_ART_SCRIPT.new()
	art.call(
		"configure",
		route_style,
		ELEVATED_ROUTES[route_style],
		[$DamageVent.position, $DamageVent02.position, $DamageVent03.position],
		$Obstacle.position
	)
	add_child(art)
	# Фон ветви должен быть под игроком, предметами и интерфейсом.
	move_child(art, 0)


func _set_collectible_positions(letter_positions: Array[Vector2], fish_positions: Array[Vector2]) -> void:
	var letters: Array[Area2D] = [$Letter01, $Letter02, $Letter03, $Letter04, $Letter05, $Letter06]
	for index: int in letters.size():
		letters[index].position = letter_positions[index]

	$Fish01.position = fish_positions[0]
	$Fish02.position = fish_positions[1]


func _add_elevated_platform(route: Rect2) -> void:
	var platform := StaticBody2D.new()
	platform.position = route.get_center()
	add_child(platform)

	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = route.size
	collider.shape = shape
	platform.add_child(collider)
