tool
extends TextureButton

onready var texture_rect = $Scaler/TextureRect
onready var scaler = $Scaler

const animation_period := 0.075
const HOVER_SCALE := 1.05

var hover_value := 0.0
var button_down_value := 0.0

var is_button_down := false

func _ready():
	if not is_connected("resized", self, "_on_resized"):
		connect("resized", self, "_on_resized")
	
	if not is_connected("button_down", self, "_on_button_down"):
		connect("button_down", self, "_on_button_down")
	
	if not is_connected("button_up", self, "_on_button_up"):
		connect("button_up", self, "_on_button_up")
	
	_on_resized()


func _process(delta):
	var tdelta: float = delta/animation_period
	
	var hv_target := 1.0 if is_hovered() else 0.0
	var bt_target := 1.0 if is_button_down else 0.0
	
	hover_value = move_toward(hover_value, hv_target, tdelta)
	button_down_value = move_toward(button_down_value, bt_target, tdelta)
	
	var fscale: float = lerp(lerp(1.0, HOVER_SCALE, hover_value), 1.0, button_down_value)
	
	scaler.rect_scale = Vector2(fscale, fscale)


func _on_resized() -> void:
	if texture_rect:
		texture_rect.rect_min_size = rect_size


func _on_button_down() -> void:
	is_button_down = true


func _on_button_up() -> void:
	is_button_down = false
