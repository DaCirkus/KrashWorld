extends Node

signal fully_collected(item_id)
signal collected(item_id, amount)
signal level_reloaded()
signal collectibles_reloaded()

var collectibles := {}

var level_container: Spatial

const level_scene_paths := [
	"res://assets/scenes/exports/forest_scene_01/forest_scene_01.tscn",
	"res://assets/scenes/island/island.tscn"
]

const level_collectible_icons := [
	preload("res://assets/textures/cd_icon.png"),
	preload("res://assets/textures/ruby_gem.png")
]

const level_collectible_models := [
	preload("res://assets/scenes/collectibles/cd_collectible_model.tscn"),
	preload("res://assets/scenes/ruby/ruby.tscn")
]

const level_npc_message := [
	{
		"request": "GRL I lost all my CD's can you help me collect them?\nI don't know what I would do without you!",
		"completed": "\nHere take this ticket to the island as a thank you."
	},
	{
		"request": "I need help! I opened the chest and all of the gems came flying out. \nCan you help me collect them?",
		"completed": "I need help! I opened the chest and all of the gems came flying out. \nCan you help me collect them?"
	}
]

var next_level: int
var current_level: int
var previous_level: int

var is_loading_level := false
var ill_counter := 0

func _ready():
	EventBus.connect("reset_level_requested", self, "_on_reset_level_requested")
	EventBus.connect("reset_save_requested", self, "_on_reset_save_requested")


func _process(delta):
	if Input.is_action_just_pressed("cheat_button"):
		cheat_collect()


func load_level_index(value: int) -> void:
	if not ClientSettings.opened_levels.has(value):
		ClientSettings.opened_levels.append(value)
		ClientSettings.game_timer += 100
	
	if value >= level_scene_paths.size():
		value = level_scene_paths.size() - 1
	
	previous_level = -1 if value == 0 else value - 1
	current_level = value
	next_level = value + 1 if value < level_scene_paths.size() - 1 else -1
	_load_level(load(level_scene_paths[current_level]))


func _load_level(scene: PackedScene = null) -> void:
	ill_counter += 1
	var cc = ill_counter
	is_loading_level = true
	save()
	
	collectibles = {}
	
	var level_containers := get_tree().get_nodes_in_group("level_container")
	if level_containers.size() > 0:
		level_container = level_containers[0]
		for child in level_container.get_children():
			child.free()
		
		var new_node = scene.instance()
		
		level_container.add_child(new_node)
	else:
		level_container = null
	
	reload_collectibles()
	emit_signal("level_reloaded")
	yield(get_tree(), "idle_frame")
	if ill_counter == cc:
		is_loading_level = false


func reload_collectibles() -> void:
	collectibles.clear()
	
	var collectible_nodes = get_tree().get_nodes_in_group("collectible")
	
	for node in collectible_nodes:
		var item_id: String = node.item_id
		var collected: bool = node.is_collected
		var amount: int = node.amount
		
		var curr_dict = collectibles.get(item_id)
		if not curr_dict:
			collectibles[item_id] = {
				"collected": amount if collected else 0,
				"total": amount
			}
		else:
			if collected:
				curr_dict["collected"] += amount
			
			curr_dict["total"] += amount
	
	emit_signal("collectibles_reloaded")


func _on_collected(node: Node) -> void:
	var new_collected = collectibles[node.item_id]["collected"] + node.amount
	var total = collectibles[node.item_id]["total"]
	collectibles[node.item_id]["collected"] = new_collected
	if node.amount > 0:
		emit_signal("collected", node.item_id, node.amount)
	if node.amount > 0 and new_collected == total:
		_on_fully_collected(node.item_id)
	
	save()


func _on_fully_collected(item_id: String) -> void:
	emit_signal("fully_collected", item_id)


func is_fully_collected(item_id: String = "default") -> bool:
	if not collectibles.has(item_id):
		return true
	
	var total = collectibles[item_id]["total"]
	var amount = collectibles[item_id]["collected"]
	return amount >= total


func go_to_next_level() -> void:
	if next_level >= 0:
		load_level_index(next_level)


func go_to_previous_level() -> void:
	if previous_level >= 0:
		load_level_index(previous_level)


func save():
	var save_nodes := get_tree().get_nodes_in_group("has_save")
	
	for node in save_nodes:
		node.save()


func _on_reset_save_requested() -> void:
	var level_containers := get_tree().get_nodes_in_group("level_container")
	if level_containers.size() > 0:
		level_container = level_containers[0]
		for child in level_container.get_children():
			child.free()
	
	ClientSettings.game_timer = 0.0
	ClientSettings.opened_levels = []
	ClientSettings.game_save = [{}]
	collectibles = {}
	ClientSettings.save()
	
	load_level_index(0)


func _on_reset_level_requested() -> void:
	for node in get_tree().get_nodes_in_group("collectible"):
		node.set("is_collected", false)
	reload_collectibles()


func cheat_collect() -> void:
	for node in get_tree().get_nodes_in_group("collectible"):
		node.set("is_collected", true)


func get_current_collectible_icon() -> Texture:
	if current_level < level_collectible_icons.size():
		return level_collectible_icons[current_level]
	else:
		return level_collectible_icons[0]


func get_current_collectible_model() -> PackedScene:
	if current_level < level_collectible_models.size():
		return level_collectible_models[current_level]
	else:
		return level_collectible_models[0]


func get_npc_text() -> String:
	var retdict: Dictionary
	if current_level < level_npc_message.size():
		retdict = level_npc_message[current_level]
	else:
		retdict = level_npc_message[0]
	
	if is_fully_collected():
		return retdict.completed
	else:
		return retdict.request
