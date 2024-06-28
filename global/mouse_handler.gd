extends Node

var fake_capture := false
var showing_ui := false

var capture_location: Vector2
func free_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
#	Input.call_deferred("warp_mouse_position", capture_location)


func capture_mouse() -> void:
	if not is_mouse_captured():
		capture_location = get_viewport().get_mouse_position()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func is_mouse_captured() -> bool:
	return Input.mouse_mode == Input.MOUSE_MODE_CAPTURED


func is_ui_captured() -> bool:
	return is_mouse_captured() or fake_capture


#func _unhandled_input(event):
#	if event.is_action("capture_mouse"):
#		if is_mouse_captured() and event.is_action_released("capture_mouse"):
#			free_mouse()
#		elif
