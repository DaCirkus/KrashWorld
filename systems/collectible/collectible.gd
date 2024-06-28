tool
extends Area
class_name Collectible

signal collected

export var item_id: String = "default"
export var amount: int = 1
export var collect_vfx: PackedScene
export var model_override: PackedScene
var is_collected: bool = false setget set_is_collected
onready var mesh_container = $"%MeshContainer"


func _init():
	add_to_group("collectible")
	add_to_group("persistent")


func _ready() -> void:
	if Engine.editor_hint:
		$AnimationPlayer.play("rotate")
	else:
		yield(get_tree(), "idle_frame")
		reload_model_to(LevelManager.get_current_collectible_model())
		refresh()


func reload_model_to(scene: PackedScene) -> void:
	for child in mesh_container.get_children():
		child.queue_free()
	
	mesh_container.add_child(scene.instance())


func refresh() -> void:
	if not is_inside_tree():
		return
	
	visible = not is_collected
	monitorable = not is_collected


func set_is_collected(value: bool) -> void:
	if is_collected != value:
		is_collected = value
		emit_signal("collected")
		if is_inside_tree():
			if is_collected and collect_vfx:
				get_parent().add_child(collect_vfx.instance())
			refresh()
			LevelManager._on_collected(self)


func generate_save() -> Dictionary:
	return {
		"is_collected": is_collected
	}
