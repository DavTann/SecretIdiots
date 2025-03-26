extends StaticBody2D

var open = false

func _on_selection_zone_selected() -> void:
	set_open.rpc(!open)
	
@rpc("any_peer","call_local","reliable")
func set_open(b):
	if b:
		open = b
		$AnimatedSprite2D.play("Open")
		$CollisionShape2D.disabled = true
	else:
		open = b
		$AnimatedSprite2D.play("Closed")
		$CollisionShape2D.disabled = false
