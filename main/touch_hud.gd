extends Control

onready var analog = $"%Analog"

func _ready():
	if not OS.has_touchscreen_ui_hint() or not (OS.get_name() in ["HTML5", "Android"]):
		visible = false


func _process(_delta):
	if is_visible_in_tree():
		InputManager.move_vector_override = Vector2(-1,-1)*analog.joystick_vector#analog.get_force()*Vector2(-1,1)
		InputManager.emit_signal("move_vector_changed") 

#
#func _on_LeftButton_button_up():
#	InputManager.left_press_override = false
#
#
#func _on_LeftButton_button_down():
#	InputManager.left_press_override = true
#
#
#func _on_RightButton_button_up():
#	InputManager.right_press_override = false
#
#
#func _on_RightButton_button_down():
#	InputManager.right_press_override = true
#
#
#func _on_BackwardButton_button_up():
#	InputManager.backward_press_override = false
#
#
#func _on_BackwardButton_button_down():
#	InputManager.backward_press_override = true
#
#
#func _on_ForwardButton_pressed():
#	InputManager.forward_press_override = false
#
#
#func _on_ForwardButton_released():
#	pass # Replace with function body.


func _on_VirtualJoystick_analogic_chage(_move):
	pass # Replace with function body.


func _on_VirtualJoystick_analogic_released():
	pass # Replace with function body.
