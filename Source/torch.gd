extends Node3D

func _ready() -> void:
	$blockbench_export/AnimationPlayer.play("flicker")
	$blockbench_export/AnimationPlayer.get_animation("flicker").loop_mode = Animation.LOOP_LINEAR
	$blockbench_export/Node/Torch/flame3/torus.set_layer_mask_value(1,false)
	$blockbench_export/Node/Torch/flame3/torus.set_layer_mask_value(2,true)
	$blockbench_export/Node/Torch/flame2/torus2.set_layer_mask_value(1,false)
	$blockbench_export/Node/Torch/flame2/torus2.set_layer_mask_value(2,true)
	$blockbench_export/Node/Torch/flame1/torus3.set_layer_mask_value(1,false)
	$blockbench_export/Node/Torch/flame1/torus3.set_layer_mask_value(2,true)
