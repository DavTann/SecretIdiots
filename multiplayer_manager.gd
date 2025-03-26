extends Node

var player_num = -1
var num_players = 0

var i_am_server = false
var id = -1
var players = {}
var id_to_character = {}

@export var address = "127.0.0.1"
@export var port = 8910

var peer
