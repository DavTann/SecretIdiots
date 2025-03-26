extends Node2D

var player_resource = preload("res://Source/player.tscn")

@rpc("any_peer","call_local","reliable")
func spawn_player(n,player_id):
	var spawn_pos = $SpawnPoints.get_child(n).position
	var new_player = player_resource.instantiate()
	new_player.position = spawn_pos
	new_player.player_id = player_id
	MP.id_to_character[player_id] = new_player
	new_player.player_id = player_id
	new_player.set_multiplayer_authority(player_id,true)
	add_child(new_player,true)

func _process(_delta: float) -> void:
	$NetworkID.text = "ID:"+str(multiplayer.get_unique_id())
	
func _ready() -> void:
	$CanvasModulate.show()
	if MP.i_am_server:
		var spawn_count = 0
		for id in MP.players:
			spawn_player.rpc(spawn_count,id)
			spawn_count += 1
