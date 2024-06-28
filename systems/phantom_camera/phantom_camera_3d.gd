extends Camera
class_name PhantomCamera3D

export var priority := 0 setget set_priority


func _ready():
	current = false
	PhantomCameraGroups.add_camera(self)


func refresh():
	PhantomCameraGroups.refresh()


func set_priority(value: int) -> void:
	if priority != value:
		priority = value
		refresh()

