extends Node

signal add_interaction()
signal remove_interaction()
signal menu_requested()
signal resume_game_requested()
signal reset_save_requested()
signal reset_level_requested()
signal game_started()
signal options_requested()
signal end_game_requested()
signal reset_level_timer()
signal level_timer_progress(delta)
signal time_ran_out()
signal next_level_requested()

var game_started := false


func _ready():
	connect("game_started", self, "_on_game_started")


func _on_game_started() -> void:
	game_started = true
