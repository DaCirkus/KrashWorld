extends Spatial
class_name Level

export var level_tag := "unnamed_level"

func _init():
	add_to_group("has_save")


func _ready():
	yield(get_tree(), "idle_frame")
	load_level_save(ClientSettings.get_level_save(level_tag))


func load_level_save(dict: Dictionary) -> void:
	for path in dict:
		var node = get_node_or_null(path)
		if not is_instance_valid(node):
			push_warning("could not load save for node in path %s" % path)
			continue
		
		var props = dict[path]
		if not node.has_method("load_save"):
			for prop in props:
				node.set(prop, props[prop])
		else:
			node.load_save(props)


func generate_save_data() -> Dictionary:
	var sdata := {}
	
	for node in get_tree().get_nodes_in_group("persistent"):
		if is_a_parent_of(node):
			var relpath := get_path_to(node)
			var data = node.generate_save() if node.has_method("generate_save") else {}
			sdata[relpath] = data
	
	return sdata


func save():
	var save_dict := ClientSettings.get_current_save()
	save_dict[level_tag] = generate_save_data()
	ClientSettings.save()

