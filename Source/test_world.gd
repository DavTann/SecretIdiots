extends Node3D

var spawn_points = []

var player_resource = preload("res://Source/player_3d.tscn")

@rpc("any_peer","call_local","reliable")
func spawn_player(n,player_id):
	var spawn_pos = spawn_points[n].position
	var new_player = player_resource.instantiate()
	new_player.spawn_point = spawn_pos
	new_player.rotation = spawn_points[n].rotation
	new_player.position = spawn_pos
	new_player.player_id = player_id
	MP.id_to_character[player_id] = new_player
	new_player.player_id = player_id
	new_player.set_multiplayer_authority(player_id,true)
	add_child(new_player,true)

func _ready() -> void:
	var floor_num = 0
	for layer in $Map.get_children():
		LoadMapFromTiles(layer,floor_num)
		floor_num += 1
	if MP.i_am_server:
		var spawn_count = 0
		for id in MP.players:
			spawn_player.rpc(spawn_count,id)
			spawn_count += 1

func LoadMapFromTiles(layer,floor_num):
	var tiles = layer.get_used_cells()
	
	var tile_map = {}
	tile_map[0] = preload("res://Source/stairs.tscn")
	tile_map[1] = preload("res://Source/floor.tscn")
	tile_map[2] = preload("res://Source/wall.tscn")
	tile_map[3] = preload("res://Source/spawn_point.tscn")
	tile_map[4] = preload("res://Source/roof.tscn")
	tile_map[5] = preload("res://Source/torch.tscn")
	tile_map[6] = preload("res://Source/boulder.tscn")
	tile_map[7] = preload("res://Source/treasure.tscn")
	
	var room_height = 1.0
	for coords in tiles:
		var id = layer.get_cell_source_id(coords)
		var rot_amt = layer.get_cell_alternative_tile(coords) * PI/2.0
		var new_tile = tile_map[id].instantiate()
		new_tile.rotation.y = -rot_amt
		new_tile.position = Vector3(coords.x,room_height*floor_num,coords.y)
		$Level.add_child(new_tile)

	spawn_points = get_tree().get_nodes_in_group("SpawnPoints")
	layer.hide()
