extends CanvasLayer

const START_DISTANCE := 0.5
onready var character = $"%Character"
onready var title_camera = $"%TitleCamera"
onready var animation_player = $"%AnimationPlayer"

var activated := false
var game_started := false

#var spawn_position := Vector3()

func _ready():
	if EventBus.game_started:
		title_camera.priority = -1
		visible = false
		return
	
	animation_player.play("title")
	
	yield(get_tree(), "idle_frame")
#	spawn_position = character.global_transform.origin
	activated = true


#func _process(delta):
#	if not activated:
#		return
#
##	print_debug(game_started, ", ", spawn_position)
#	if game_started:
#		title_camera.priority = -1
#		PhantomCameraGroups.refresh()
##		character.reset_camera()
#		set_process(false)
#		return
#	if (character.global_transform.origin - spawn_position).length() > START_DISTANCE:
#		game_started = true
#		animation_player.play("game_start")




func _on_PlayButton_pressed():
	game_started = true
	title_camera.priority = -1
	PhantomCameraGroups.refresh()
	animation_player.play("game_start")
	EventBus.emit_signal("game_started")
	
