extends CharacterBody3D

const RESPAWN_TIME = 5
const walk_speed = 1
const run_speed = 2
var turn_sensitivity = 0.02
var look_vertical: float = 0.0  # For clamping vertical look

var walking = false
var running = false

var dead = false

var grounded = false
const JUMP_POWER = 2.5
var gravity = 0.1

var spawn_point = Vector3(0,0,0)
var DEATH_PLANE = -30.0

var player_id = -1
var updated_network_id = false

enum {WEST,NORTH,EAST,SOUTH}
var face_dir = SOUTH

var controlled = false

func _ready() -> void:
	if player_id == multiplayer.get_unique_id():
		set_controlled(true)
	else:
		set_controlled(false)

func set_controlled(b:bool) -> void:
	$Face/Camera3D.current = b
	controlled = b
	$Face/SelfLight.visible = b
	$Model.visible = !b
	$AudioListener3D.make_current()

func _process(_delta: float) -> void:
	if !dead:
		if !grounded:
			$Model/AnimationPlayer.play("jump")
		elif walking:
			$Model/AnimationPlayer.play("walk")
		else:
			$Model/AnimationPlayer.play("idle")

func _physics_process(_delta: float) -> void:
	if controlled:
		var y_momentum = velocity.y
		var face_basis = $Face.global_transform.basis
		var input_dir = Vector3.ZERO
		if Input.is_action_pressed("move_up"):
			input_dir -= face_basis.z
		if Input.is_action_pressed("move_down"):
			input_dir += face_basis.z
		if Input.is_action_pressed("move_left"):
			input_dir -= face_basis.x
		if Input.is_action_pressed("move_right"):
			input_dir += face_basis.x
		
		var move_speed
		if Input.is_action_pressed("run"):
			move_speed = run_speed
		else:
			move_speed = walk_speed
		input_dir = input_dir.normalized()
		velocity = Vector3(input_dir.x, 0.0, input_dir.z) * move_speed
		if velocity:
			walking = true
		else:
			walking = false
		velocity.y = y_momentum - gravity
		move_and_slide()
		grounded = is_on_floor()
		if global_position.y < DEATH_PLANE:
			velocity.y = 0
			global_position = spawn_point

func _input(event):
	if controlled and event is InputEventMouseMotion:
		rotate_y(-event.relative.x * turn_sensitivity)  # Yaw (rotate body)
		look_vertical = clamp(look_vertical - event.relative.y * turn_sensitivity, -1.5, 1.5)  # Pitch
		$Face.rotation.x = look_vertical
	if controlled and grounded and event.is_action_pressed("jump"):
		velocity.y += JUMP_POWER

@rpc("any_peer","call_remote","unreliable")
func declare_position(id, pos):
	MP.id_to_character[id].position = pos

@rpc("any_peer","call_local","reliable")
func die():
	$DieSound.play()
	$Model/AnimationPlayer.play('die')
	dead = true
	$CollisionShape3D.set_deferred("disabled",true)
	controlled = false
	var camera_tween = create_tween()
	camera_tween.tween_property($Face/Camera3D,"rotation:x",PI/2,1.0)
	await get_tree().create_timer(RESPAWN_TIME).timeout
	respawn()


func _on_hurt_area_area_entered(_area: Area3D) -> void:
	if controlled:
		die.rpc()


func _on_collection_area_area_entered(area: Area3D) -> void:
	var collectible = area.get_parent()
	collectible.collect(self)

func respawn():
	global_position = spawn_point
	if player_id == multiplayer.get_unique_id():
		set_controlled(true)
	dead = false
	$Face/Camera3D.rotation.x = 0
	velocity = Vector3.ZERO
	$CollisionShape3D.set_deferred("disabled",false)
	
