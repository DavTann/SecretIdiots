extends Node2D

signal trigger
@export var trigger_targets: Array[Node]

@export var state = false

func _ready() -> void:
	for target in trigger_targets:
		trigger.connect(target.trigger)

func _on_selection_zone_selected() -> void:
	change_state.rpc(!state)

@rpc("any_peer","call_local","reliable")
func change_state(new_state):
	state = new_state
	if state:
		$AnimatedSprite2D.play("on")
		trigger.emit(true)
	else:
		$AnimatedSprite2D.play("off")
		trigger.emit(false)
