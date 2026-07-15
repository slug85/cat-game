extends Node2D

## Управляет забегом первой тестовой трассы: таймером, финишем и падением.

const FALL_Y := 760.0

@onready var player: CharacterBody2D = $Player
@onready var finish_zone: Area2D = $FinishZone
@onready var timer_label: Label = %TimerLabel
@onready var result_panel: PanelContainer = %ResultPanel
@onready var result_title: Label = %ResultTitle
@onready var result_details: Label = %ResultDetails
@onready var retry_button: Button = %RetryButton
@onready var menu_button: Button = %MenuButton

var elapsed_seconds := 0.0
var is_run_active := true


func _ready() -> void:
	finish_zone.body_entered.connect(_on_finish_zone_body_entered)
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	result_panel.hide()
	_update_timer_label()


func _process(delta: float) -> void:
	if not is_run_active:
		return

	elapsed_seconds += delta
	_update_timer_label()
	if player.global_position.y > FALL_Y:
		_end_run(false)


func _on_finish_zone_body_entered(body: Node2D) -> void:
	if is_run_active and body == player:
		_end_run(true)


func _end_run(is_victory: bool) -> void:
	is_run_active = false
	player.set_physics_process(false)
	result_panel.show()

	if is_victory:
		var is_new_record := GameState.register_finish_time(elapsed_seconds)
		result_title.text = "Доставка завершена!"
		result_details.text = "Время: %s\n%s" % [
			GameState.format_time(elapsed_seconds),
			"Новый рекорд!" if is_new_record else "Лучшее время: %s" % GameState.format_time(GameState.best_time_seconds),
		]
	else:
		result_title.text = "Курьер упал с крыши"
		result_details.text = "Время забега: %s" % GameState.format_time(elapsed_seconds)

	retry_button.grab_focus()


func _update_timer_label() -> void:
	timer_label.text = "Время  %s" % GameState.format_time(elapsed_seconds)


func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
