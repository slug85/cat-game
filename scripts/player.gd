extends CharacterBody2D

## Автоматически бегущий герой серого прототипа.
## Позже визуальный Polygon2D будет заменён на анимированный спрайт кота.

@export var run_speed := 280.0
@export var jump_velocity := -470.0
@export var gravity := 1250.0
@export var fast_fall_multiplier := 1.9


func _physics_process(delta: float) -> void:
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


func _is_jump_pressed() -> bool:
	return Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")


func _is_jump_held() -> bool:
	return Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_up")
