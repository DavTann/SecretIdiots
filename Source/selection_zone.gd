extends Area2D

signal selected

var selectable = false
var ids_in_area = []


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if selectable and event is InputEventMouseButton and event.is_pressed():
		selected.emit()

func set_selection(b):
	selectable = b
	$Sprite2D.visible = b

func _on_area_entered(area: Area2D) -> void:
	var id = area.get_multiplayer_authority()
	ids_in_area.append(id)
	#print("Id:", id, " entered, Mine:", MP.id)
	if id == MP.id:
		set_selection(true)

func _on_area_exited(area: Area2D) -> void:
	var id = area.get_multiplayer_authority()
	ids_in_area.erase(id)
	#print("Id:", id, " exited")
	if id == MP.id:
		set_selection(false)
