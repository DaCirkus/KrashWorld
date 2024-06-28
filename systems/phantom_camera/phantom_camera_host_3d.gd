extends Node
class_name PhantomCameraHost3D

onready var p = get_parent()

var transition_period := 0.5

var temp_camera: Camera

const copy_props := [
	"global_transform"
]

var current_camera: Camera
var next_camera: Camera
var remaining_lerp := 0.0


func _ready():
	if not (p is Camera):
		queue_free()
	
	_phantom_camera_updated(PhantomCameraGroups.get_current())
	assert(PhantomCameraGroups.connect("phantom_camera_updated", self, "_phantom_camera_updated") == OK)


func _phantom_camera_updated(_prev) -> void:
	var next = PhantomCameraGroups.get_current()
	if not next:
		return
	if is_instance_valid(temp_camera):
		temp_camera.queue_free()
		temp_camera = null
	var curr_cam = Camera.new()
	add_child(curr_cam)
	curr_cam.current = false
	for prop in copy_props:
		curr_cam.set(prop, p.get(prop))
	
	next_camera = next
	current_camera = curr_cam
	remaining_lerp = transition_period


func _process(delta):
	remaining_lerp = max(remaining_lerp - delta, 0.0)
	var t = (transition_period - remaining_lerp)/transition_period
	if not is_instance_valid(current_camera):
		return
	if not is_instance_valid(next_camera):
		return
	
	var in_val: Transform = current_camera.global_transform
	var fval: Transform = next_camera.global_transform
	
	var basis = in_val.basis.slerp(fval.basis, t)
	var pos = lerp(in_val.origin, fval.origin, t)
	
	
	p.global_transform.basis = basis
	p.global_transform.origin = pos
