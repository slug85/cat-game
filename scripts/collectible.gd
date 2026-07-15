extends Area2D
class_name RunnerCollectible

## Универсальный подбираемый предмет трассы.
## Тип "letter" увеличивает счёт, тип "fish" восстанавливает здоровье.

signal collected(collectible: Area2D)

@export_enum("letter", "fish") var collectible_type := "letter"
@export var amount := 1

var is_collected := false


func _ready() -> void:
	add_to_group("collectibles")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if is_collected or not body is CharacterBody2D:
		return

	is_collected = true
	collected.emit(self)
	queue_free()
