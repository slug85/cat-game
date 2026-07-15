extends Control

## Карта маршрутов прототипа. Все три узла открыты для быстрого тестирования ветвей.

@onready var level_01_button: Button = %Level01Button
@onready var old_quarter_button: Button = %OldQuarterButton
@onready var neon_bypass_button: Button = %NeonBypassButton
@onready var menu_button: Button = %MenuButton


func _ready() -> void:
	level_01_button.pressed.connect(func() -> void: _open_level("res://scenes/level_01.tscn", "01"))
	old_quarter_button.pressed.connect(func() -> void: _open_level("res://scenes/level_02_old_quarter.tscn", "02A"))
	neon_bypass_button.pressed.connect(func() -> void: _open_level("res://scenes/level_03_neon_bypass.tscn", "02B"))
	menu_button.pressed.connect(_return_to_menu)
	level_01_button.grab_focus()
	DebugLog.event("MAP", "opened")


func _open_level(scene_path: String, level_id: String) -> void:
	DebugLog.event("MAP", "start_level=%s" % level_id)
	get_tree().change_scene_to_file(scene_path)


func _return_to_menu() -> void:
	DebugLog.event("MAP", "return_to_main_menu")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
