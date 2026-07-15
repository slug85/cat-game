extends Sprite2D

## Переключает спрайтовые листы кота в зависимости от состояния RunnerPlayer.
## Все листы используют кадры 80x64; импортированные PNG не изменяются.

const ANIMATIONS := {
	"run": {
		"texture": preload("res://assets/characters/cat/free_cat_2d_pixel_art/Sprites/RUN.png"),
		"frames": 8,
		"fps": 10.0,
	},
	"jump": {
		"texture": preload("res://assets/characters/cat/free_cat_2d_pixel_art/Sprites/RUNNING JUMP.png"),
		"frames": 3,
		"fps": 8.0,
	},
	"hurt": {
		"texture": preload("res://assets/characters/cat/free_cat_2d_pixel_art/Sprites/HURT.png"),
		"frames": 4,
		"fps": 10.0,
	},
}

@onready var player: RunnerPlayer = get_parent() as RunnerPlayer

var current_animation := ""
var frame_elapsed := 0.0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_play_animation("run")


func _process(delta: float) -> void:
	var target_animation := _get_target_animation()
	if target_animation != current_animation:
		_play_animation(target_animation)
	if current_animation == "jump":
		frame = _get_jump_phase_frame()
		return

	frame_elapsed += delta
	var animation: Dictionary = ANIMATIONS[current_animation]
	var frame_duration := 1.0 / float(animation["fps"])
	if frame_elapsed >= frame_duration:
		frame_elapsed = fmod(frame_elapsed, frame_duration)
		frame = (frame + 1) % int(animation["frames"])


func _get_target_animation() -> String:
	if player.invulnerability_remaining > 0.0:
		return "hurt"
	if not player.is_on_floor():
		return "jump"
	return "run"


func _get_jump_phase_frame() -> int:
	if player.velocity.y < -90.0:
		return 0
	if player.velocity.y < 90.0:
		return 1
	return 2


func _play_animation(animation_name: String) -> void:
	current_animation = animation_name
	frame_elapsed = 0.0
	var animation: Dictionary = ANIMATIONS[current_animation]
	texture = animation["texture"] as Texture2D
	hframes = int(animation["frames"])
	vframes = 1
	frame = 0
