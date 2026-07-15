extends Control

## Управляет минимальным главным меню прототипа.

@onready var play_button: Button = %PlayButton
@onready var exit_button: Button = %ExitButton


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	play_button.grab_focus()
	DebugLog.event("MENU", "opened")


func _on_play_pressed() -> void:
	DebugLog.event("MENU", "open_route_map")
	get_tree().change_scene_to_file("res://scenes/world_map.tscn")


func _on_exit_pressed() -> void:
	DebugLog.event("MENU", "exit_requested")
	get_tree().quit()
