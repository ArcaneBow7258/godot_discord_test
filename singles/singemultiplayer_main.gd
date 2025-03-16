extends Node

# Autoload named Lobby

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const PORT = 8181
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
@export var MAX_CONNECTIONS = 4
@export var  PLAYER_SPAWNER : MultiplayerSpawner
@export var PLAYER_HOLDER : Node
# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players = {}

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info = {}
var serv_info = {}
var players_loaded = 0


# Set up hooks for disconnect and connect
func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	#PLAYER_SPAWNER = %PlayerSpawner
	#PLAYER_HOLDER = $"../Players"
	PLAYER_SPAWNER.set_spawn_function(_spawn_player)
	if OS.has_feature("dedicated_server"):
		create_game()
func _spawn_player(data: Dictionary):
	if multiplayer.is_server():
		print("spawning for server")
	var character = preload("res://scenes/2_player.tscn").instantiate()
	character.set_multiplayer_authority(data['multiplayer_id'])
	character.name =  str(data['id'])
	#print(PLAYER_SPAWNER.spawn_path)
	character.reparent(PLAYER_HOLDER, true)
	return character
# Guess this is when it creates the local player
func _process_local_player():
	#print('local player')
	var t = (JoinUI.get_node("VBoxContainer/NameBox/name_edit") as TextEdit).text 
	var color = (JoinUI.get_node("VBoxContainer/NameBox/name_color") as ColorPicker).color 
	
	if t != '':
		player_info['name'] = t
	else:
		player_info['name'] = randi()
	player_info['color'] = color
	#print('local', player_info)

func join_game():
	#print("Attempt Join")
	var address = (JoinUI.get_node("VBoxContainer/lobby_edit") as TextEdit).text 
	if address.is_empty():
		
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		print("Error creating client")
		return error
	_process_local_player()
	multiplayer.multiplayer_peer = peer
	JoinUI.hide()
	


func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	serv_info['seed'] = 818
	TileMaps.make_map()
	# server has id of 1
	if not OS.has_feature("dedicated_server"):
		print("NOT DEDICATED")
		_process_local_player()
		players[1] = player_info
		player_connected.emit(1, player_info)
		PLAYER_SPAWNER.spawn({'id' = player_info['name'],
		'multiplayer_id' = 1})
		#print("woah", JoinUI)
		JoinUI.visible = false


func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null


# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
# Local is to all clients
@rpc("call_local", "reliable")
func load_game(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)


# Every peer will call this when they have loaded the game scene.
# Any pear will be allows anyone to call it
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	TileMaps.make_tiles.rpc_id(multiplayer.get_remote_sender_id(), TileMaps.map)
	players_loaded += 1
	#print("Srever player count: " + str(players_loaded))
	PLAYER_SPAWNER.spawn({"id" = player_info[multiplayer.get_remote_sender_id()],
						  "multiplayer_id" =multiplayer.get_remote_sender_id()
						})


# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
# Essentially, trading data.
func _on_player_connected(id):

	# Send data to specific user
	#print(str(multiplayer.get_unique_id()) + " _on_player_connected")
	#print(player_info)
	_register_player.rpc_id(id, player_info)

	
	
	
@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)
	#print(str(multiplayer.get_unique_id()) + " register player: " + str(new_player_id))
	if multiplayer.is_server():
		TileMaps.make_tiles.rpc_id(multiplayer.get_remote_sender_id(), TileMaps.map)
		var used = TileMaps.cropmap.get_used_cells()
		print("Sending ", len(used), " crop tiles")
		var used_atlas = []
		for cord in used:
			used_atlas.append(TileMaps.cropmap.get_cell_atlas_coords(cord))
		print(used_atlas)
		TileMaps.make_crops.rpc_id(multiplayer.get_remote_sender_id(), used, used_atlas)
		PLAYER_SPAWNER.spawn({"id" = new_player_info['name'],
							  "multiplayer_id" = new_player_id
							})
		
		#player_loaded.rpc_id(1)
	

func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)
	
# get data form conetced peer
func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)


func _on_connected_fail():
	multiplayer.multiplayer_peer = null


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()
func output_local(msg):
	print(str(multiplayer.get_unique_id()) + msg)
