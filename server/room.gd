extends Node

var host_id: int
var client_id: int
var room_code: String
var players: Array  # List of players in the room
@onready var playerInfo = {} # {id: "Name"}
@onready var check_ping = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func initialize_room(host: int, code: String):
	host_id = host
	room_code = code
	players.append(host)
	check_ping = true
	print("Room initialized with host:", host_id, ", Room Code:", room_code)

func add_client(_client_id: int):
	if _client_id not in players and players.size() < 2:
		client_id = _client_id
		players.append(_client_id)
		print("Client", _client_id, " added to room:", room_code)
		get_parent().rpc_id(_client_id, "room_joined", room_code, host_id)
		get_parent().rpc_id(host_id, "room_joined", room_code, _client_id)
	else:
		get_parent().rpc_id(_client_id, "room_join_failed")

func remove_player(player_id: int):
	#Change to affect on both game and server side
	if player_id in players:
		players.erase(player_id)
		print("Player", player_id, "removed from room:", room_code)

func is_full() -> bool:
	return players.size() >= 2

func is_empty() -> bool:
	return players.size() == 0

func returnids():
	if is_empty():
		return []
	else:
		return players

func clear():
	for id in players:
		get_parent().rpc_id(id,"receive_disconnect")
	print("Room: ", room_code, " Cleared")
	queue_free()

func otherPlayerid(id: int):
	print("Players in room: ",room_code," are ",players)
	if players.size() <2:
		return
	elif players.has(id):
		if players[0] == id:
			return players[1]
		else:
			return players[0]
	else:
		print("ID Missing")
		return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !check_ping:
		return
	if Time.get_ticks_msec() % 1000 < delta * 1000:
		for id in players:
			get_parent().rpc_id(id,"ping")
