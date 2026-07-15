extends Node

## Единый журнал важных событий забега.
## По умолчанию включён. Во время игры его можно переключать клавишей F3.

var enabled := true


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F3:
		enabled = not enabled
		print("[DEBUG][LOGGER] %s" % ("enabled" if enabled else "disabled"))


func event(tag: String, details: String = "") -> void:
	if not enabled:
		return

	var suffix := "" if details.is_empty() else " | %s" % details
	print("[DEBUG][%s]%s" % [tag, suffix])
