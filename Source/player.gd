extends CharacterBody2D

const move_speed = 120
var turn_sensitivity = 0.002

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

func _process(_delta: float) -> void:
	$AuthorityLabel.text = str(get_multiplayer_authority())

func set_controlled(b:bool) -> void:
	controlled = b
	if !b:
		modulate = Color("ff0000")
	$SelfLight.visible = b
	$Camera2D.enabled = b

func _physics_process(_delta: float) -> void:
	if controlled:
		var move_dir = Input.get_vector("move_left","move_right","move_up","move_down")
		velocity = Vector2(move_dir.x, move_dir.y) * move_speed
		if move_dir:
			var angle = move_dir.angle()
			if angle < -3*PI/4:
				face_dir = WEST
				$Sprite2D.play("WalkW")
			elif angle < -PI/4:
				face_dir = NORTH
				$Sprite2D.play("WalkN")
			elif angle < PI/4:
				face_dir = EAST
				$Sprite2D.play("WalkE")
			elif angle < 3*PI/4:
				face_dir = SOUTH
				$Sprite2D.play("WalkS")
			else:
				face_dir = WEST
				$Sprite2D.play("WalkW")
		else:
			if face_dir == WEST:
				$Sprite2D.play("IdleW")
			elif face_dir == NORTH:
				$Sprite2D.play("IdleN")
			elif face_dir == EAST:
				$Sprite2D.play("IdleE")
			elif face_dir == SOUTH:
				$Sprite2D.play("IdleS")
			
		move_and_slide()

@rpc("any_peer","call_remote","unreliable")
func declare_position(id, pos):
	MP.id_to_character[id].position = pos
