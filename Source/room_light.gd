extends PointLight2D

@export var initial_state:bool = true

func _ready() -> void:
	trigger(initial_state)

func trigger(b):
	visible = b
