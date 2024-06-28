extends Node

signal move_vector_changed()
signal pan_detected(amount)

var forward_press_override := false setget set_forward_press_override
var backward_press_override := false setget set_backward_press_override
var left_press_override := false setget set_left_press_override
var right_press_override := false setget set_right_press_override
var input_locked := false

var move_vector_override

func get_move_vector() -> Vector2:
	if move_vector_override:
		return move_vector_override
	
	var left_str = Input.get_action_strength("character_left") if not left_press_override else 1.0
	var right_str := Input.get_action_strength("character_right") if not right_press_override else 1.0
	var forward_str := Input.get_action_strength("character_forward") if not forward_press_override else 1.0
	var backward_str := Input.get_action_strength("character_backward") if not backward_press_override else 1.0
	var move_vector = Vector2(
		left_str - right_str,
		forward_str - backward_str
	)
	
	return move_vector.normalized()


func set_forward_press_override(value: bool) -> void:
	if forward_press_override != value:
		forward_press_override = value
		emit_signal("move_vector_changed")


func set_backward_press_override(value: bool) -> void:
	if backward_press_override != value:
		backward_press_override = value
		emit_signal("move_vector_changed")


func set_left_press_override(value: bool) -> void:
	if left_press_override != value:
		left_press_override = value
		emit_signal("move_vector_changed")


func set_right_press_override(value: bool) -> void:
	if right_press_override != value:
		right_press_override = value
		emit_signal("move_vector_changed")
