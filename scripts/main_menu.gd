extends Control

## Управляет минимальным главным меню прототипа.

@onready var play_button: Button = %PlayButton
@onready var exit_button: Button = %ExitButton


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	play_button.grab_focus()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_01.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
