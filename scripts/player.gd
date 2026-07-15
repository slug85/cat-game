extends CharacterBody2D
class_name RunnerPlayer

## Автоматически бегущий герой серого прототипа.
## Позже визуальный Polygon2D будет заменён на анимированный спрайт кота.

signal health_changed(current_health: int, max_health: int)
signal defeated

@export var run_speed := 280.0
@export var jump_velocity := -470.0
@export var gravity := 1250.0
@export var fast_fall_multiplier := 1.9
@export var max_health := 3
@export var invulnerability_duration := 1.0

@onready var visual: Polygon2D = $Visual

var current_health := 3
var invulnerability_remaining := 0.0


func _ready() -> void:
	current_health = max_health


func _physics_process(delta: float) -> void:
	_update_invulnerability(delta)
	var was_on_floor := is_on_floor()
	velocity.x = run_speed

	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y < 0.0 and not _is_jump_held():
			velocity.y += gravity * 0.65 * delta
		if Input.is_action_pressed("ui_down"):
			velocity.y += gravity * (fast_fall_multiplier - 1.0) * delta
	elif _is_jump_pressed():
		velocity.y = jump_velocity

	move_and_slide()

	if is_on_floor() and not was_on_floor:
		DebugLog.event("LAND", "x=%.0f" % global_position.x)


func _is_jump_pressed() -> bool:
	var jump_pressed := Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")
	if jump_pressed:
		DebugLog.event("JUMP_INPUT", "x=%.0f" % global_position.x)
	return jump_pressed


func _is_jump_held() -> bool:
	return Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_up")


func take_damage(amount: int = 1) -> bool:
	if invulnerability_remaining > 0.0 or current_health <= 0:
		return false

	current_health = max(0, current_health - amount)
	invulnerability_remaining = invulnerability_duration
	health_changed.emit(current_health, max_health)
	if current_health == 0:
		defeated.emit()
	return true


func heal(amount: int = 1) -> int:
	var health_before := current_health
	current_health = min(max_health, current_health + amount)
	var restored := current_health - health_before
	if restored > 0:
		health_changed.emit(current_health, max_health)
	return restored


func _update_invulnerability(delta: float) -> void:
	if invulnerability_remaining <= 0.0:
		visual.visible = true
		return

	invulnerability_remaining = max(0.0, invulnerability_remaining - delta)
	visual.visible = int(invulnerability_remaining * 14.0) % 2 == 0
	if invulnerability_remaining == 0.0:
		visual.visible = true
