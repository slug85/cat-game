extends Sprite2D

## Проигрывает шесть кадров CC0-рыбы и добавляет лёгкое покачивание подборке.

const FRAMES: Array[Texture2D] = [
	preload("res://assets/collectibles/animated_fish/fish_01.png"),
	preload("res://assets/collectibles/animated_fish/fish_02.png"),
	preload("res://assets/collectibles/animated_fish/fish_03.png"),
	preload("res://assets/collectibles/animated_fish/fish_04.png"),
	preload("res://assets/collectibles/animated_fish/fish_05.png"),
	preload("res://assets/collectibles/animated_fish/fish_06.png"),
]

const FRAME_DURATION := 0.12
const BOB_SPEED := 3.0
const BOB_HEIGHT := 3.0

var elapsed := 0.0
var base_position := Vector2.ZERO


func _ready() -> void:
	base_position = position
	texture = FRAMES.front()


func _process(delta: float) -> void:
	elapsed += delta
	texture = FRAMES[int(elapsed / FRAME_DURATION) % FRAMES.size()]
	position.y = base_position.y + sin(elapsed * BOB_SPEED) * BOB_HEIGHT
