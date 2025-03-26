extends Control

var message_time = 3.0

func _ready() -> void:
	Global.messages = self

func message(t:String):
	var new_label = Label.new()
	new_label.text = t
	add_child(new_label)
	await get_tree().create_timer(message_time).timeout
	new_label.queue_free()
