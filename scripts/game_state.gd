extends Node

## Хранит небольшое состояние, которое переживает смену сцен.
## В прототипе сохраняет лучшее время отдельно для каждой трассы.

const SAVE_PATH := "user://runner_save.cfg"

var best_time_seconds := -1.0
var best_times: Dictionary[String, float] = {}


func _ready() -> void:
	_load_best_time()
	DebugLog.event("STATE", "best_time=%s" % format_time(best_time_seconds) if best_time_seconds >= 0.0 else "best_time=none")


func register_finish_time(time_seconds: float, level_id: String = "01") -> bool:
	var previous_best := get_best_time(level_id)
	if previous_best >= 0.0 and time_seconds >= previous_best:
		return false

	best_times[level_id] = time_seconds
	best_time_seconds = get_best_time("01")
	_save_best_time()
	DebugLog.event("RECORD", "level=%s new_best=%s" % [level_id, format_time(time_seconds)])
	return true


func get_best_time(level_id: String) -> float:
	return best_times.get(level_id, -1.0)


func format_time(time_seconds: float) -> String:
	var total_centiseconds := roundi(time_seconds * 100.0)
	var minutes := total_centiseconds / 6000
	var seconds := (total_centiseconds % 6000) / 100
	var centiseconds := total_centiseconds % 100
	return "%02d:%02d.%02d" % [minutes, seconds, centiseconds]


func _load_best_time() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		for key: String in config.get_section_keys("records"):
			if key.begins_with("level_"):
				best_times[key.trim_prefix("level_")] = float(config.get_value("records", key, -1.0))

		# Мягкая миграция сохранения ранней версии прототипа, где был один рекорд.
		if best_times.is_empty():
			var legacy_best := float(config.get_value("records", "best_time_seconds", -1.0))
			if legacy_best >= 0.0:
				best_times["01"] = legacy_best

	best_time_seconds = get_best_time("01")


func _save_best_time() -> void:
	var config := ConfigFile.new()
	for level_id: String in best_times:
		config.set_value("records", "level_%s" % level_id, best_times[level_id])
	config.save(SAVE_PATH)
	DebugLog.event("STATE", "save_path=%s" % SAVE_PATH)
