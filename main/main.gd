extends Node

onready var world_container = $"%WorldContainer"
onready var canvas_layer = $"%CanvasLayer"
onready var click_blocker = $"%ClickBlocker"
onready var video_player = $"%VideoPlayer"
onready var music_player = $"%MusicPlayer"
onready var collect_sfx = $"%CollectSFX"

var selected_ui := "GameHUD" setget set_selected_ui

var animation_period := 0.15

var level_videos := [
	"res://assets/video/AfterLevel1.ogv",
	"res://assets/video/AfterLevel2.ogv"
]

var music_index := 0
var musics := [
	preload("res://assets/audio/KRASHWORLD_FX_SONG3.ogg"),
	preload("res://assets/audio/KRASHWORLD_FX_SONG2.ogg"),
	preload("res://assets/audio/KRASHWORLD_FX_SONG1.ogg")
]


func _ready():
	canvas_layer.visible = false
	
	yield(get_tree(), "idle_frame")
	
	LevelManager.load_level_index(0)
	
	EventBus.connect("menu_requested", self, "_on_menu_requested")
	LevelManager.connect("level_reloaded", self, "_on_level_reloaded")
	EventBus.connect("resume_game_requested", self, "_on_resume_game_requested")
	EventBus.connect("game_started", self, "_on_game_started")
	EventBus.connect("options_requested", self, "_on_options_requested")
	EventBus.connect("end_game_requested", self, "_on_end_game_requested")
	EventBus.connect("next_level_requested", self, "_on_next_level_requested")
	EventBus.connect("time_ran_out", self, "_on_time_ran_out")
	yield(get_tree(), "idle_frame")
	LevelManager.connect("fully_collected", self, "_on_fully_collected")
	LevelManager.connect("collected", self, "_on_collected")
	
	start_music()

func _input(event):
	
	if not MouseHandler.showing_ui and (not OS.has_touchscreen_ui_hint() or not (OS.get_name() in ["Android", "HTML5"])) and event is InputEventMouseButton and not MouseHandler.is_mouse_captured() and event.button_index == BUTTON_RIGHT and event.is_pressed():
		MouseHandler.capture_mouse()
	
	elif MouseHandler.is_mouse_captured() and event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.is_pressed():
		MouseHandler.free_mouse()


func _process(delta: float) -> void:
	_process_ui(delta)


func _process_ui(delta: float) -> void:
#	print_debug(selected_ui)
	var transition_delta := delta/animation_period
	var visible_counter := 0
	var page_found := false
	
	InputManager.input_locked = selected_ui in ["Video", "GameEnd", "Failed"]
	
	if Input.is_action_just_pressed("ui_cancel"):
		if MouseHandler.is_mouse_captured():
			call_deferred("_on_menu_requested")
	
	for control in canvas_layer.get_children():
		if control == click_blocker:
			continue
		
		if control.name == selected_ui:
			page_found = true
			control.modulate.a = move_toward(control.modulate.a, 1.0, transition_delta)
			control.visible = true
			if control.get_index() < canvas_layer.get_child_count() - 1:
				canvas_layer.move_child(control, canvas_layer.get_child_count() - 1)
			visible_counter += 1
			continue
		
		control.modulate.a = move_toward(control.modulate.a, 0.0, transition_delta)
		control.visible = control.modulate.a > 0.01
		if control.visible:
			visible_counter += 1
			
	if not page_found:
		push_error("Page not found")
	
	if visible_counter > 1 and page_found:
		# we are transitioning so we have to block clicks:
		click_blocker.visible = true
		if click_blocker.get_index() != canvas_layer.get_child_count() - 2:
			canvas_layer.move_child(click_blocker, canvas_layer.get_child_count() - 2)
	else:
		click_blocker.visible = false


func _on_menu_requested() -> void:
	set_selected_ui("MainMenu")
	MouseHandler.free_mouse()


func _on_resume_game_requested() -> void:
	set_selected_ui("GameHUD")
	MouseHandler.capture_mouse()


func _on_level_reloaded() -> void:
	return


func _on_game_started() -> void:
	canvas_layer.visible = true
	MouseHandler.capture_mouse()


func _on_options_requested() -> void:
	set_selected_ui("Options")


func _on_VideoPlayer_finished():
	if LevelManager.current_level == LevelManager.level_scene_paths.size() - 1:
		set_selected_ui("GameEnd")
	else:
		LevelManager.go_to_next_level()
		set_selected_ui("GameHUD")
	start_music()


func play_video(path: String) -> void:
	yield(get_tree(), "idle_frame")
	set_selected_ui("Video")
	print_debug("Loading video ", path)
	video_player.stream = load(path)
	MouseHandler.free_mouse()
	video_player.play()
	stop_music()


func stop_video() -> void:
	video_player.stop()


func stop_music():
	music_player.stop()


func start_music() -> void:
	music_index = 0
	var cmusic = musics[music_index]
	music_player.stream = cmusic
	music_player.play()


func _on_fully_collected(_itid) -> void:
	return
#	if LevelManager.is_loading_level:
#		set_selected_ui("GameEnd")
#	elif LevelManager.current_level == LevelManager.level_scene_paths.size() - 1:
#		play_video(level_videos[LevelManager.current_level])


func _on_MenuButton_pressed():
	stop_video()
	start_music()
	EventBus.emit_signal("resume_game_requested")


func _on_MusicPlayer_finished():
	music_index = posmod(music_index + 1, musics.size())
	var cmusic = musics[music_index]
	music_player.stream = cmusic
	music_player.play()


func _on_GameEndButton_pressed():
	LevelManager.collectibles.clear()
	ClientSettings.game_save = [{}]
	ClientSettings.save()
	LevelManager._on_reset_save_requested()
	start_music()
	MouseHandler.free_mouse()
	selected_ui = "MainMenu"
#	EventBus.emit_signal("resume_game_requested")


func set_selected_ui(value: String) -> void:
	if selected_ui != value:
		selected_ui = value
#		assert(value != "GameEnd")
		print_debug(value, ", ", get_stack())


func _on_end_game_requested() -> void:
	play_video(level_videos.back())


func _on_ResetLevelButton_pressed():
	EventBus.emit_signal("reset_save_requested")
	EventBus.emit_signal("resume_game_requested")


func _on_time_ran_out() -> void:
	MouseHandler.free_mouse()
	selected_ui = "Failed"


func _on_collected(_1,_2) -> void:
	if not LevelManager.is_loading_level:
		collect_sfx.play()


func _on_SkipVideo_pressed():
	stop_video()
	_on_VideoPlayer_finished()


func _on_next_level_requested() -> void:
	play_video(level_videos[LevelManager.current_level])
