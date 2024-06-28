extends KinematicBody

var move_vector: Vector2
var move_speed: float = 10.0
var velocity: Vector3 = Vector3()
var snap_vector := Vector3.DOWN*0.3
var move_accel := 50.0
var gravity := Vector3.DOWN*9.8*2.0
var single_jump_impulse := 10.0
const JUMP_TIME_MARGIN := 0.1
var jump_queued_timer := 0.0
const SNAP_VECTOR_TIME_MARGIN := 0.07
var snap_vector_timer := 0.0

var look_sensitivity := 0.007
var custom_pan_sensitivity := 0.01
const base_run_speed := 8.0

onready var camera = $"%Camera"
onready var camera_pivot = $"%CameraPivot"
onready var model = $"%Model"
onready var animation_tree: AnimationTree = $Model/AnimationTree
onready var character_audio_stream_player = $"%CharacterAudioStreamPlayer"

const jump_audio := preload("res://assets/audio/KRASHWORLD_FX_JUMP.ogg")
const run_audio := preload("res://assets/audio/KRASHWORLDFX_RUN1.ogg")

func _ready():
	assert(InputManager.connect("move_vector_changed", self, "refresh_move_vector") == OK)
	assert(InputManager.connect("pan_detected", self, "_on_pan_detected") == OK)


func reset_camera() -> void:
	global_rotation.y = model.global_rotation.y + PI
	model.global_transform.basis = last_model_gbasis


func _process(_delta):
#	if not EventBus.game_started:
#		return
	
	if PhantomCameraGroups.get_current() != camera:
		var ccam = get_viewport().get_camera()
		if ccam:
			global_rotation.y = ccam.global_rotation.y
		model.global_transform.basis = last_model_gbasis
	refresh_animation()


func _exit_tree():
	InputManager.disconnect("move_vector_changed", self, "refresh_move_vector")
	InputManager.disconnect("pan_detected", self, "_on_pan_detected")




func _unhandled_input(event):
	if not EventBus.game_started:
		return
	
	if event.is_action_type():
		if event.is_action("character_forward")\
			or event.is_action("character_backward")\
			or event.is_action("character_left")\
			or event.is_action("character_right"):
				call_deferred("refresh_move_vector")
				get_viewport().set_input_as_handled()
		elif event.is_action_pressed("character_jump"):
			jump()
			get_viewport().set_input_as_handled()

func _input(event):
	if not EventBus.game_started:
		return
	
	if event is InputEventMouseMotion and MouseHandler.is_ui_captured():
		pan(-event.relative*look_sensitivity)
		get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	if InputManager.input_locked:
		stop_audio()
		return
	
	var gbasis := global_transform.basis.orthonormalized()
	if is_on_floor():
		var real_move_dir := gbasis*(Vector3.FORWARD*move_vector.y + Vector3.LEFT*move_vector.x) if EventBus.game_started else Vector3()
		var target_velocity = Vector3(real_move_dir.x*move_speed, velocity.y, real_move_dir.z*move_speed)
		velocity = velocity.move_toward(target_velocity, delta*move_accel)
	if snap_vector_timer > 0.0:
		snap_vector_timer = max(snap_vector_timer - delta, 0.0)
		if snap_vector_timer == 0.0:
			snap_vector = Vector3.DOWN*0.1
	
	if not is_on_floor():
		velocity += gravity*delta
		jump_queued_timer = max(jump_queued_timer - delta, 0.0)
	else:
		if move_vector.length() == 0.0:
			velocity.y = 0.0
		
		if jump_queued_timer > 0.0:
			jump_queued_timer = 0.0
			snap_vector_timer = SNAP_VECTOR_TIME_MARGIN
			play_jump_audio()
			snap_vector = Vector3()
			velocity.y = single_jump_impulse
		elif move_vector.length() > 0.7:
			play_run_audio()
		else:
			stop_audio()
	
	$CanvasLayer/Label3D.text = "%s" % [str(velocity)]
	if velocity.length() < 0.05:
		velocity = Vector3()
	else:
		velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP)
		velocity -= get_floor_normal()*get_floor_normal().dot(velocity)


func jump() -> void:
	jump_queued_timer = JUMP_TIME_MARGIN
		


func refresh_move_vector() -> void:
	if not EventBus.game_started:
		return
	move_vector = InputManager.get_move_vector()


func pan(relative_vec: Vector2) -> void:
	rotate_y(relative_vec.x)
	camera_pivot.rotation.x = clamp(camera_pivot.rotation.x + relative_vec.y, -PI*0.5, PI*0.3)
	


func _on_pan_detected(amount: Vector2) -> void:
	pan(amount*custom_pan_sensitivity)


var last_model_gbasis: Basis
func refresh_animation() -> void:
	var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
	var mbasis = Basis.IDENTITY.rotated(Vector3.UP, PI)
	if is_on_floor():
		if move_vector.length() > 0.01:
			playback.travel("run")
			animation_tree["parameters/run/speed/scale"] = (velocity*Vector3(1,0,1)).length()/base_run_speed
			var xrot = move_vector.angle()
			mbasis = mbasis.rotated(Vector3.UP, -xrot + PI*0.5)
		else:
			playback.travel("idle")
		
		if move_vector.length() > 0.0:
			model.transform.basis = mbasis
			
			last_model_gbasis = model.global_transform.basis
		else:
			model.global_transform.basis = last_model_gbasis
	else:
		model.global_transform.basis = last_model_gbasis
		playback.travel("jumping")


func _on_CollectionArea_area_entered(area):
	if area is Collectible:
		area.is_collected = true


func _on_InteractionArea_body_entered(area):
	if area is LevelFinishNPC:
		add_interaction(area)


func _on_InteractionArea_body_exited(area):
	if area is LevelFinishNPC:
		remove_interaction(area)


func _on_InteractionArea_area_exited(area):
	if area is LevelFinishNPC:
		remove_interaction(area)


func _on_InteractionArea_area_entered(area):
	if area is LevelFinishNPC:
		add_interaction(area)


func add_interaction(node: Node) -> void:
	EventBus.emit_signal("add_interaction", node)


func remove_interaction(node: Node) -> void:
	EventBus.emit_signal("remove_interaction", node)


func play_jump_audio() -> void:
	if not character_audio_stream_player.playing\
		or character_audio_stream_player.stream != jump_audio:
			character_audio_stream_player.stream = jump_audio
			character_audio_stream_player.play()


func play_run_audio() -> void:
	if not character_audio_stream_player.playing\
		or character_audio_stream_player.stream != run_audio:
			character_audio_stream_player.stream = run_audio
			character_audio_stream_player.play()


func stop_audio() -> void:
	character_audio_stream_player.stop()
