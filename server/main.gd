extends Node

@export var default_port: int = 9999
var port
var is_host: bool = false
var ConnectionUI: CanvasLayer

var time_since_last_ping: float = 0.0

var rooms = {} # Dictionary to store active rooms { "room_code": Room }
var max_rooms = 3  # Maximum number of concurrent rooms
var room_code_length = 4  # Length of generated room codes

@onready var waitingPeers = [] # Peers not in  rooms { "id": TimeJoined }

func start_server(_port: int = default_port):
	var peer = ENetMultiplayerPeer.new()
	port = _port
	var error = peer.create_server(port, max_rooms*3)  # Set maximum peers to 2 (host + 1 client)
	if error != OK:
		print(str("Cannot Host: ", error))
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	is_host = true
	print(str("Started as server on port: ", port))
	multiplayer.multiplayer_peer.connect("peer_connected", self._on_peer_connected)
	multiplayer.multiplayer_peer.connect("peer_disconnected", self._on_peer_disconnected)

# Generate a unique room code
func generate_room_code() -> String:
	var code = ""
	var characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	for i in range(room_code_length):
		code += characters[randi() % characters.length()]
	if rooms.has(code):
		return generate_room_code()
	return code

func _on_peer_connected(id: int):
	print(str("Connected to peer with ID: ", id))
	waitingPeers.append(id)

func _on_peer_disconnected(id: int):
	print(str("Disconnected from peer with ID: ", id))
	waitingPeers.erase(id)
	removeIdFromRoom(id)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_server()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if waitingPeers.is_empty():
		return
	if Time.get_ticks_msec() % 1000 < delta * 1000:
		for id in waitingPeers:
			rpc_id(id,"ping")

func removeIdFromRoom(id):
	#To be completed
	for room in rooms.keys():
		if rooms[room].returnids().has(id):
			print("Found id: ", id, " in room: ", room)
			rooms[room].clear()
			rooms.erase(room)


func findReciever(id: int):
	for room in rooms.keys():
		if rooms[room].returnids().has(id):
			print("Found id: ", id, " in room: ", room)
			return rooms[room].otherPlayerid(id)

####################  RPCs ###########################
# Host creates a room
@rpc("any_peer", "reliable")
func create_room():
	if rooms.size() >= max_rooms:
		print("Server room limit reached.")
		return  # Reject new rooms if at max capacity
	
	var host_id = multiplayer.get_remote_sender_id()
	var room_code = generate_room_code()
	
	waitingPeers.erase(host_id)
	var new_room = preload("res://room.tscn").instantiate()
	new_room.name = room_code
	add_child(new_room)
	
	new_room.initialize_room(host_id, room_code)
	rooms[room_code] = new_room
	
	print("Room created:", room_code, "by Host:", host_id)
	rpc_id(host_id, "room_created", room_code)

@rpc("any_peer", "reliable")
func join_room(room_code):
	var client_id = multiplayer.get_remote_sender_id()

	if room_code in rooms and not rooms[room_code].is_full():
		rooms[room_code].add_client(client_id)
		#rpc_id(client_id, "room_joined", room_code) Already called by room
		print("Client ", client_id, " joined room: ", room_code)
	else:
		rpc_id(client_id, "room_join_failed")
		print("Client", client_id, "failed to join room:", room_code)

@rpc("reliable")
func room_created(code):
	pass

@rpc("reliable")
func room_joined(code, hostid):
	pass

@rpc("reliable")
func room_join_failed():
	pass

###############

# Reset the timer on each ping received
@rpc("any_peer")
func ping() -> void:
	time_since_last_ping = 0.0

# Broadcasts disconnect
func broadcast_disconnect(state: String = "", data: Dictionary = {}):
	print("Broadcasting Disconnect")
	rpc("receive_disconnect")
	remove_from_group("NetworkHandlingNodes")

@rpc("any_peer")
func receive_disconnect():
	var disconnectedId = multiplayer.get_remote_sender_id()
	print("Recieved Disconnect on server")
	removeIdFromRoom(disconnectedId)
	#Find id in rooms and clear and empty room




######################## Game specific transmissions ##########################

# Broadcasts the game state to keep both players in sync
func broadcast_game_state(senderid, state: String, data: Dictionary):
	print(str("Broadcasting state: ", state, "with data: ", data, "from Server"))
	var recieverid = findReciever(senderid)
	rpc_id(recieverid,"receive_game_state", state, data)

# Remote function to handle incoming game state updates
@rpc("any_peer")
func receive_game_state(state: String, data: Dictionary):
	print(str("Received state: ", state, " with data: ", data, " on Server"))
	var senderid = multiplayer.get_remote_sender_id()
	broadcast_game_state(senderid,state,data)

@rpc("any_peer","call_remote")
func receive_game_settings(_game_settings: Dictionary, _hand_settings: Dictionary) -> void:
	var game_settings = _game_settings
	var hand_settings = _hand_settings
	print("Server recieved settings")
	var senderid = multiplayer.get_remote_sender_id()
	send_game_settings(senderid, _game_settings, _hand_settings)

func send_game_settings(senderid, _game_settings: Dictionary,_hand_settings: Dictionary) -> void:
	var game_settings = _game_settings
	var hand_settings = _hand_settings
	print("Server sent settings")
	var recieverid = findReciever(senderid)
	rpc_id(recieverid,"receive_game_settings",_game_settings, _hand_settings)

func send_chat_rpc(senderid, message: String):
	var recieverid = findReciever(senderid)
	rpc_id(recieverid,"receive_chat_rpc", message)  # Broadcast to all clients


@rpc("any_peer","reliable","call_remote")
func receive_chat_rpc(message: String):
	print(message)
	var senderid = multiplayer.get_remote_sender_id()
	send_chat_rpc(senderid,message)
