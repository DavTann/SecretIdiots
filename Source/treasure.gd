extends Node3D

var collected = false

func collect(collector):
	if collected:
		return
	collected = true

	hide()
	
	$CollectSound.play()
	await $CollectSound.finished
	queue_free()
