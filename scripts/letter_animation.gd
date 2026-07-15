extends Sprite2D

## Небольшая трёхкадровая пульсация письма-подборки.
## Предмет остаётся на месте: меняется только визуальный масштаб.

const FRAME_DURATION := 0.18
const PULSE_SCALES := [Vector2(1.0, 1.0), Vector2(1.08, 1.06), Vector2(1.0, 1.0)]

var elapsed := 0.0


func _process(delta: float) -> void:
	elapsed += delta
	var frame_index := int(elapsed / FRAME_DURATION) % PULSE_SCALES.size()
	scale = PULSE_SCALES[frame_index]
