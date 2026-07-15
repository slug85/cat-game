extends Node

## Хранит небольшое состояние, которое переживает смену сцен.
## В прототипе сохраняется только лучшее время фиксированной трассы.

const SAVE_PATH := "user://runner_save.cfg"

var best_time_seconds := -1.0


func _ready() -> void:
	_load_best_time()
	DebugLog.event("STATE", "best_time=%s" % format_time(best_time_seconds) if best_time_seconds >= 0.0 else "best_time=none")


func register_finish_time(time_seconds: float) -> bool:
	if best_time_seconds >= 0.0 and time_seconds >= best_time_seconds:
		return false

	best_time_seconds = time_seconds
	_save_best_time()
	DebugLog.event("RECORD", "new_best=%s" % format_time(best_time_seconds))
	return true


func format_time(time_seconds: float) -> String:
	var total_centiseconds := roundi(time_seconds * 100.0)
	var minutes := total_centiseconds / 6000
	var seconds := (total_centiseconds % 6000) / 100
	var centiseconds := total_centiseconds % 100
	return "%02d:%02d.%02d" % [minutes, seconds, centiseconds]


func _load_best_time() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		best_time_seconds = float(config.get_value("records", "best_time_seconds", -1.0))


func _save_best_time() -> void:
	var config := ConfigFile.new()
	config.set_value("records", "best_time_seconds", best_time_seconds)
	config.save(SAVE_PATH)
	DebugLog.event("STATE", "save_path=%s" % SAVE_PATH)
