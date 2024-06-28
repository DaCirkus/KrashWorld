tool
extends Control

export var joy_stick_ratio := 0.4


onready var collision_shape_2d = $Area2D/CollisionShape2D
onready var joy_stick = $"%JoyStick"

export var joystick_vector: Vector2
export var extra_margin := 0.3
onready var area_2d = $"%Area2D"

var relative_drag_ignore := 100.0
var real_radius := 1.0

var ongoing_drag := -1

func _process(_delta):
	if is_visible_in_tree():
		collision_shape_2d.transform.origin = rect_size*0.5
		real_radius = min(rect_size.x, rect_size.y)*0.5
		collision_shape_2d.shape.radius = real_radius * (1.0 + extra_margin)
		
		joy_stick.rect_size = Vector2(real_radius, real_radius)*joy_stick_ratio*2.0
		joy_stick.rect_position = rect_size*0.5 + joystick_vector*Vector2(real_radius, real_radius) - joy_stick.rect_size*0.5


func _input(event):
	if not is_visible_in_tree():
		ongoing_drag = -1
		return
	
	if ongoing_drag < 0:
		return
	
	if event is InputEventScreenTouch:
		if event.index == ongoing_drag:
			if not event.is_pressed():
				ongoing_drag = -1
				joystick_vector = Vector2()
				# set input as handled?
	elif event is InputEventScreenDrag:
		if event.relative.length() > relative_drag_ignore:
			return
		if event.index == ongoing_drag:
			event.position -= rect_global_position
			_process_drag(event)


func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if not is_visible_in_tree():
		ongoing_drag = -1
		return
		
	if event is InputEventScreenTouch:
		if event.is_pressed():
			ongoing_drag = event.index


func _process_drag(event):
	ongoing_drag = event.index
	joystick_vector = (event.position + event.relative - rect_size*0.5)/max(real_radius, real_radius)
	if abs(joystick_vector.x) > 1.0 or abs(joystick_vector.y) > 1.0:
		joystick_vector = joystick_vector.normalized()
