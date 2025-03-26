extends Control

var first_scene = preload("res://Source/test_world.tscn")


var game

func _ready() -> void:
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	$HostContent/PortLabel.text = "Port: %d"%MP.port

func peer_connected(id):
	Global.messages.message("Player %d connected to %d"%[id,multiplayer.get_unique_id()])
	if MP.i_am_server:
		assign_player_number.rpc_id(id,MP.num_players)
		MP.num_players += 1
	MP.players[id] = {}

func peer_disconnected(id):
	#TODO clean up that peer
	Global.messages.message("Player disconnected %d"%id)

func connected_to_server():
	Global.messages.message("Connected to server")

func connection_failed():
	Global.messages.message("Connect failed")

@rpc("any_peer","call_local","reliable")
func assign_player_number(n):
	MP.player_num = n

@rpc("any_peer","call_local","reliable")
func send_player_information(id,data):
	if !(id in MP.players):
		Global.messages.message("I didn't know about player %d!!!"%id)
		MP.players[id] = {}
	for d in data:
		MP.players[id][d] = data[d]

func _on_host_button_pressed() -> void:
	get_ip()
	#MP.peer = ENetMultiplayerPeer.new()
	MP.peer = WebSocketMultiplayerPeer.new()
	var error = MP.peer.create_server(MP.port)
	if error != OK:
		Global.messages.message("Hosting failed: "+str(error)+" "+error_string(error))
		return
	#Put compression here
	
	multiplayer.multiplayer_peer = MP.peer
	Global.messages.message("Waiting for players")
	MP.i_am_server = true
	MP.num_players = 1
	assign_player_number(0)
	MP.id = multiplayer.get_unique_id()
	MP.players[MP.id] = {}
	$HostButton.hide()
	$JoinButton.hide()
	$HostContent.show()

func _on_join_button_pressed() -> void:
	initial_join()

func initial_join():
	$HostButton.hide()
	$JoinButton.hide()
	$ClientContent.show()
	

func _on_mp_join_button_pressed() -> void:
	MP.address = $ClientContent/IPEntryField.text
	MP.port = int($ClientContent/PortEntryField.text)
	var connection_address = MP.address+":"+str(MP.port)
	#MP.peer = ENetMultiplayerPeer.new()
	MP.peer = WebSocketMultiplayerPeer.new()
	MP.peer.create_client("ws://"+connection_address)
	Global.messages.message("Client connecting to " + str(connection_address))
	#Put compression here
	multiplayer.multiplayer_peer = MP.peer
	$ClientContent.hide()
	$WaitMessage.show()

func _on_start_game_button_pressed() -> void:
	start_game.rpc()

@rpc("any_peer","call_local","reliable")
func start_game():
	MP.id = multiplayer.get_unique_id()
	var game_scene = first_scene.instantiate()
	game.add_child(game_scene)
	hide()

func get_ip():
	$HostContent/IPLabel.show()
	$HostContent/IPLabel.text = "Fetching IP..."
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(print_ip)
	http.request("https://api.ipify.org")
	
func print_ip(_result, _response_code, _headers, body):
	var ip = body.get_string_from_utf8()
	$HostContent/IPLabel.text = "IP: %s"%str(ip)
