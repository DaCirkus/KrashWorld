extends Node

signal phantom_camera_updated(prev)

var main_group := []

#func _process(delta):
#	clear_invalid_cams()


func sort_ascending(a, b):
	if a.priority > b.priority:
		return true
	return false


func get_current():
	return main_group.front() if main_group.size() > 0 else null


func refresh() -> void:
	for node in main_group:
		if not is_instance_valid(node):
			main_group.erase(node)
	
	var prev_first = get_current()
	main_group.sort_custom(self, "sort_ascending")
	
	var next_first = get_current()
	if prev_first != next_first:
		emit_signal("phantom_camera_updated", prev_first)


func clear_invalid_cams() -> void:
	var narr := []
	for node in main_group:
		if is_instance_valid(node):
			narr.append(node)
	
	var main_changed := is_instance_valid(get_current())
	main_group = narr
	if main_changed:
		emit_signal("phantom_camera_updated", null)


func add_camera(cam):
	clear_invalid_cams()
	
	var prev_first = get_current()
	
	
	main_group.append(cam)
	main_group.sort_custom(self, "sort_ascending")
	
	var next_first = get_current()
	if prev_first != next_first:
		emit_signal("phantom_camera_updated", prev_first)
