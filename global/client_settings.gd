extends Node


const USER_CFG_PATH := "user://data/user_data.cfg"


var settings_categories := {
	"game_save": {
		"game_save": "game_save",
		"game_timer": "game_timer",
		"opened_levels": "opened_levels",
	},
	
	"audio": {
		"msater_volume": "master_volume",
		"music_volume": "music_volume"
	}
}

var game_save := [{}]

var master_volume := 1.0 setget set_master_volume
var music_volume := 1.0 setget set_music_volume

var is_ready := false

var game_timer := 0.0
var opened_levels := []

func _ready():
	var dir = Directory.new()
	
	dir.make_dir_recursive("user://data")
	
	var _errt = try_load()
	is_ready = true
	save()
	
	EventBus.connect("level_timer_progress", self, "_on_level_timer_progress")


func _process(delta):
	if Input.is_action_pressed("debug_1"):
		game_timer = 0
		EventBus.emit_signal("time_ran_out")
		return


func try_load() -> int:
	var loaded_cfg = ConfigFile.new()
	var err = loaded_cfg.load(USER_CFG_PATH)
	
	if err:
		return err
	
	for category in settings_categories:
		var category_dict = settings_categories[category]
		for key in category_dict:
			if loaded_cfg.has_section_key(category, key):
				var value = loaded_cfg.get_value(category, key)
				var value_name = category_dict[key]
				set(value_name, value)
	
	return OK


func save() -> void:
	if not is_ready:
		return
	
	var cfg = ConfigFile.new()
	for category in settings_categories:
		var category_dict = settings_categories[category]
		for key in category_dict:
			var value_name = category_dict[key]
			var value = get(value_name)
			cfg.set_value(category, value_name, value)
	
	cfg.save(USER_CFG_PATH)


func get_current_save() -> Dictionary:
	if game_save.size() == 0:
		game_save.append({})
	
	return game_save[0]


func get_level_save(level_tag: String) -> Dictionary:
	var currsave = get_current_save()
	if not currsave.has(level_tag):
		currsave[level_tag] = {}
	return currsave.get(level_tag, {})


func set_master_volume(value: float) -> void:
	if master_volume != value:
		master_volume = value
		
		AudioServer.lock()
		
		var bus = AudioServer.get_bus_index("Master")
		var db = linear2db(master_volume)
		AudioServer.set_bus_volume_db(bus, db)
		
		AudioServer.unlock()
		
		save()


func set_music_volume(value: float) -> void:
	if music_volume != value:
		music_volume = value
		
		AudioServer.lock()
		
		var bus = AudioServer.get_bus_index("Music")
		var db = linear2db(music_volume)
		AudioServer.set_bus_volume_db(bus, db)
		
		AudioServer.unlock()
		
		save()


func _on_level_timer_progress(delta) -> void:
	if game_timer > 0:
		game_timer -= delta
		game_timer = max(game_timer, 0)
		if game_timer == 0:
			EventBus.emit_signal("time_ran_out")
