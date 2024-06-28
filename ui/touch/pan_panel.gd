tool
extends Control

onready var collision_shape_2d = $"%CollisionShape2D"

var ongoing_drag: int = -1
var relative_drag_ignore := 100.0

func _process(_delta):
	if Engine.editor_hint:
		return
	collision_shape_2d.transform.origin = rect_size*0.5
	collision_shape_2d.shape.extents = rect_size*0.5


func _input(event):
	if not is_visible_in_tree():
		ongoing_drag = -1
		return
	
#	if event is InputEventScreenDrag:
	if event is InputEventScreenTouch:
		if event.index == ongoing_drag and not event.is_pressed():
			ongoing_drag = -1
	elif event is InputEventScreenDrag and event.index == ongoing_drag:
		if event.relative.length() > relative_drag_ignore:
			return
		InputManager.emit_signal("pan_detected", -event.relative)


func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if not is_visible_in_tree():
		ongoing_drag = -1
		return
	
	if event is InputEventScreenTouch and event.is_pressed():
		if ongoing_drag <= 0:
			ongoing_drag = event.index
