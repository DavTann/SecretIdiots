extends CharacterBody3D

const GRAVITY = 1

@export var roll_direction = Vector2(0.0,-1.0)
@export var roll_speed = 2

func _ready() -> void:
	roll_direction = Vector2(0.0,-1.0).rotated(rotation.y)
	face_vector(roll_direction)
	$blockbench_export/AnimationPlayer.play("roll")
	$blockbench_export/AnimationPlayer.get_animation("roll").set_loop_mode(Animation.LOOP_LINEAR)

func _physics_process(_delta: float) -> void:
	velocity.y -= GRAVITY
	velocity = Vector3(roll_direction.x * roll_speed,velocity.y,roll_direction.y * roll_speed)
	move_and_slide()
	
	for collision_i in range(get_slide_collision_count()):
		var collision = get_slide_collision(collision_i)
		var normal = collision.get_normal()
		if normal:
			var wall_collision = Vector2(normal.x,normal.z)
			if wall_collision.length_squared() > 0.01:
				roll_direction = wall_collision.normalized()
				face_vector(roll_direction)

func face_vector(v:Vector2):
	rotation.y = -v.angle() - PI/2
