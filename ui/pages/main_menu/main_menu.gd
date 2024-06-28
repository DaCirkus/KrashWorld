extends Control


func _ready():
	pass


func _on_ResumeGame_pressed():
	EventBus.emit_signal("resume_game_requested")




func _on_ResetSave_pressed():
	EventBus.emit_signal("reset_save_requested")
	EventBus.emit_signal("resume_game_requested")


func _on_Cheat_pressed():
	LevelManager.cheat_collect()
	EventBus.emit_signal("resume_game_requested")


func _on_Options_pressed():
	EventBus.emit_signal("options_requested")


func _on_ResetLevel_pressed():
	EventBus.emit_signal("reset_level_requested")
	EventBus.emit_signal("resume_game_requested")
