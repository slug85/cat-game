extends Node2D

## Управляет забегом первой тестовой трассы: таймером, финишем и падением.

const FALL_Y := 760.0

@onready var player: RunnerPlayer = $Player
@onready var finish_zone: Area2D = $FinishZone
@onready var damage_puddles: Array[Area2D] = [$DamagePuddle, $DamagePuddle02, $DamagePuddle03]
@onready var timer_label: Label = %TimerLabel
@onready var hearts_label: Label = %HeartsLabel
@onready var letters_label: Label = %LettersLabel
@onready var damage_label: Label = %DamageLabel
@onready var hint_label: Label = %HintLabel
@onready var pause_panel: PanelContainer = %PausePanel
@onready var pause_details: Label = %PauseDetails
@onready var resume_button: Button = %ResumeButton
@onready var pause_menu_button: Button = %PauseMenuButton
@onready var result_panel: PanelContainer = %ResultPanel
@onready var result_title: Label = %ResultTitle
@onready var result_details: Label = %ResultDetails
@onready var retry_button: Button = %RetryButton
@onready var menu_button: Button = %MenuButton

var elapsed_seconds := 0.0
var is_run_active := true
var letters_collected := 0
var total_letters := 0
var fish_collected := 0
var total_fish := 0
var damage_feedback_remaining := 0.0


func _ready() -> void:
	finish_zone.body_entered.connect(_on_finish_zone_body_entered)
	for puddle: Area2D in damage_puddles:
		puddle.body_entered.connect(_on_damage_puddle_body_entered.bind(puddle))
	player.health_changed.connect(_on_player_health_changed)
	player.defeated.connect(_on_player_defeated)
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	resume_button.pressed.connect(_on_resume_pressed)
	pause_menu_button.pressed.connect(_on_pause_menu_pressed)
	_connect_collectibles()
	result_panel.hide()
	pause_panel.hide()
	_update_timer_label()
	_update_health_label(player.current_health, player.max_health)
	_update_letters_label()
	DebugLog.event("RUN", "start level=01")


func _process(delta: float) -> void:
	if get_tree().paused:
		return

	_update_damage_feedback(delta)
	if not is_run_active:
		return

	elapsed_seconds += delta
	_update_timer_label()
	if player.global_position.x > 650.0:
		hint_label.hide()
	if player.global_position.y > FALL_Y:
		_end_run(false, "fall")


func _unhandled_input(event: InputEvent) -> void:
	if not is_run_active or not event.is_action_pressed("ui_cancel"):
		return

	_set_paused(not get_tree().paused)
	get_viewport().set_input_as_handled()


func _on_finish_zone_body_entered(body: Node2D) -> void:
	if is_run_active and body == player:
		DebugLog.event("FINISH_ZONE", "x=%.0f time=%s" % [player.global_position.x, GameState.format_time(elapsed_seconds)])
		_end_run(true)


func _on_damage_puddle_body_entered(body: Node2D, puddle: Area2D) -> void:
	if not is_run_active or body != player:
		return

	if player.take_damage():
		DebugLog.event("DAMAGE", "source=%s hearts=%d/%d x=%.0f" % [puddle.name, player.current_health, player.max_health, player.global_position.x])
		_show_damage_feedback()


func _on_player_health_changed(current_health: int, max_health: int) -> void:
	_update_health_label(current_health, max_health)


func _on_player_defeated() -> void:
	if is_run_active:
		_end_run(false, "health")


func _connect_collectibles() -> void:
	for collectible: RunnerCollectible in get_tree().get_nodes_in_group("collectibles"):
		collectible.collected.connect(_on_collectible_collected)
		if collectible.collectible_type == "letter":
			total_letters += collectible.amount
		elif collectible.collectible_type == "fish":
			total_fish += collectible.amount


func _on_collectible_collected(collectible: RunnerCollectible) -> void:
	if collectible.collectible_type == "letter":
		letters_collected += collectible.amount
		_update_letters_label()
		DebugLog.event("COLLECT", "type=letter total=%d/%d x=%.0f" % [letters_collected, total_letters, collectible.global_position.x])
	elif collectible.collectible_type == "fish":
		fish_collected += collectible.amount
		var restored: int = player.heal(collectible.amount)
		DebugLog.event("HEAL", "type=fish restored=%d hearts=%d/%d x=%.0f" % [restored, player.current_health, player.max_health, collectible.global_position.x])


func _end_run(is_victory: bool, failure_reason: String = "") -> void:
	is_run_active = false
	player.set_physics_process(false)
	result_panel.show()

	if is_victory:
		var is_new_record := GameState.register_finish_time(elapsed_seconds)
		DebugLog.event("RUN", "finish time=%s new_record=%s" % [GameState.format_time(elapsed_seconds), is_new_record])
		result_title.text = "Доставка завершена!"
		result_details.text = "Время: %s\nПисьма: %d / %d\n%s" % [
			GameState.format_time(elapsed_seconds),
			letters_collected,
			total_letters,
			"Новый рекорд!" if is_new_record else "Лучшее время: %s" % GameState.format_time(GameState.best_time_seconds),
		]
	else:
		DebugLog.event("RUN", "failed reason=%s time=%s x=%.0f letters=%d/%d" % [failure_reason, GameState.format_time(elapsed_seconds), player.global_position.x, letters_collected, total_letters])
		result_title.text = "У кота закончились сердца" if failure_reason == "health" else "Курьер упал с крыши"
		result_details.text = "Время забега: %s\nПисьма: %d / %d" % [GameState.format_time(elapsed_seconds), letters_collected, total_letters]

	retry_button.grab_focus()


func _update_timer_label() -> void:
	timer_label.text = "Время  %s" % GameState.format_time(elapsed_seconds)


func _update_health_label(current_health: int, max_health: int) -> void:
	hearts_label.text = "Сердца  %s  %d/%d" % ["♥".repeat(current_health) + "♡".repeat(max_health - current_health), current_health, max_health]


func _update_letters_label() -> void:
	letters_label.text = "Письма  %d / %d" % [letters_collected, total_letters]


func _set_paused(should_pause: bool) -> void:
	get_tree().paused = should_pause
	player.set_physics_process(not should_pause)
	player.visual.set_process(not should_pause)
	if should_pause:
		_update_pause_details()
		pause_panel.show()
		resume_button.grab_focus()
		DebugLog.event("PAUSE", "opened time=%s" % GameState.format_time(elapsed_seconds))
	else:
		pause_panel.hide()
		DebugLog.event("PAUSE", "resumed")


func _update_pause_details() -> void:
	pause_details.text = "Время: %s\nСердца: %d / %d\nПисьма: %d / %d\nРыбки: %d / %d\nВсего предметов: %d / %d" % [
		GameState.format_time(elapsed_seconds),
		player.current_health,
		player.max_health,
		letters_collected,
		total_letters,
		fish_collected,
		total_fish,
		letters_collected + fish_collected,
		total_letters + total_fish,
	]


func _show_damage_feedback() -> void:
	damage_feedback_remaining = 0.8
	damage_label.modulate.a = 1.0
	damage_label.show()


func _update_damage_feedback(delta: float) -> void:
	if damage_feedback_remaining <= 0.0:
		return

	damage_feedback_remaining = max(0.0, damage_feedback_remaining - delta)
	damage_label.modulate.a = damage_feedback_remaining / 0.8
	if damage_feedback_remaining == 0.0:
		damage_label.hide()


func _on_retry_pressed() -> void:
	DebugLog.event("MENU", "retry_level_01")
	get_tree().reload_current_scene()


func _on_menu_pressed() -> void:
	DebugLog.event("MENU", "return_to_main_menu")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_resume_pressed() -> void:
	_set_paused(false)


func _on_pause_menu_pressed() -> void:
	get_tree().paused = false
	DebugLog.event("MENU", "pause_return_to_main_menu")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
