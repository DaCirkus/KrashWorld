extends Spatial

onready var camera_list := [
	$PhantomCamera1,
	$PhantomCamera2,
	$PhantomCamera3,
	$PhantomCamera4,
]

var current_index := 0


func _ready():
	refresh()


func _process(delta):
	if Input.is_action_just_pressed("ui_left"):
		current_index = posmod(current_index + 1, camera_list.size())
		refresh()


func refresh() -> void:
	for i in camera_list.size():
		if i == current_index:
			camera_list[i].priority = 3
		else:
			camera_list[i].priority = 0


func _on_Button_pressed():
	current_index = posmod(current_index + 1, camera_list.size())
	refresh()
