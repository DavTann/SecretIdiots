extends Node3D

var target_camera
var target
var facing_angle = 0

func _ready() -> void:
	target = get_parent()

func _process(_delta: float) -> void:
	if target.visible:
		if !target_camera:
			target_camera = get_viewport().get_camera_3d()
		else:
			var camera_pos = Vector2(target_camera.global_position.x, target_camera.global_position.z)
			var my_pos = Vector2(target.global_position.x, target.global_position.z)
			var ang = camera_pos.angle_to_point(my_pos)
			facing_angle = PI/2 - ang
			target.rotation.y = PI/2 - ang
