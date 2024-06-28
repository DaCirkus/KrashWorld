extends Control

onready var collectibles = $"%Collectibles"
onready var next_level_ui = $"%NextLevelUI"
onready var touch_hud = $"%TouchHUD"
onready var prev_level_button = $"%PrevLevelButton"
onready var next_level_button = $"%NextLevelButton"
onready var game_end_button = $"%GameEndButton"
onready var collection_explanation = $"%CollectionExplanation"
onready var timer_label = $"%TimerLabel"

func _ready():
	EventBus.connect("add_interaction", self, "_on_add_interaction")
	EventBus.connect("remove_interaction", self, "_on_remove_interaction")
	LevelManager.connect("level_reloaded", self, "_on_level_reloaded")
	LevelManager.connect("fully_collected", self, "_on_fully_collected")
	LevelManager.connect("collectibles_reloaded", self, "_on_collectibles_reloaded")


func _process(delta):
	if modulate.a == 1.0 and is_visible_in_tree() and not next_level_ui.is_visible_in_tree():
		if not LevelManager.is_fully_collected():
			EventBus.emit_signal("level_timer_progress", delta)
		timer_label.text = "TIME LEFT : %d s" % int(ClientSettings.game_timer)


func _on_add_interaction(node: Node) -> void:
	MouseHandler.free_mouse()
	MouseHandler.showing_ui = true
	next_level_ui.visible = true
	refresh_status()


func _on_remove_interaction(node: Node) -> void:
	MouseHandler.capture_mouse()
	MouseHandler.showing_ui = false
	next_level_ui.visible = false


func _on_level_reloaded() -> void:
	next_level_ui.visible = false
	MouseHandler.showing_ui = false
	yield(get_tree(), "idle_frame")
	collection_explanation.text = LevelManager.get_npc_text()


func _on_fully_collected(_id) -> void:
	yield(get_tree(), "idle_frame")
	collection_explanation.text = LevelManager.get_npc_text()


func refresh_status() -> void:
	if LevelManager.previous_level >= 0:
		prev_level_button.visible = true
	else:
		prev_level_button.visible = false
	
	if LevelManager.is_fully_collected():
		if LevelManager.next_level >= 0:
			next_level_button.visible = true
			game_end_button.visible = false
		else:
			next_level_button.visible = false
			game_end_button.visible = true
	else:
		game_end_button.visible = false
		next_level_button.visible = false


func _on_MenuButton_pressed():
	EventBus.emit_signal("menu_requested")


func _on_NextLevelButton_pressed():
	EventBus.emit_signal("next_level_requested")


func _on_PrevLevelButton_pressed():
	LevelManager.go_to_previous_level()


func _on_collectibles_reloaded() -> void:
	yield(get_tree(), "idle_frame")
	collection_explanation.text = LevelManager.get_npc_text()


func _on_GameEndButton_pressed():
	EventBus.emit_signal("end_game_requested")
