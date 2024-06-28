extends Control


var next_scene := "res://main/main.tscn"

func _ready():
	advance()

func advance() -> void:
	# TODO : make this a background loading
	var new_scene = load(next_scene)
	var _err = get_tree().change_scene_to(new_scene)
