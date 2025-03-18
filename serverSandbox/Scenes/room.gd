extends Node

@onready var roomId : int
@onready var roomType : String
@onready var roomName : String
@onready var peers = []
@onready var playerInfo
@onready var check_ping = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func initialize_room(_id,_Type):
	roomId = _id
	roomType = _Type

func add_peer(id):
	peers.append(id)
	check_ping = true

func remove_peer(id):
	peers.erase(id)
	if peers.size() == 0:
		check_ping = false

func get_other_peer(id) -> int:
	var idx = peers.find(id)
	if idx == 0:
		return peers[1]
	else:
		return peers[0]

func clear_room():
	peers.clear()
	check_ping = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !check_ping:
		return
	if Time.get_ticks_msec() % 1000 < delta * 1000:
		for id in peers:
			get_parent().get_parent().rpc_id(id,"ping")
			#rpc_id(peers.pick_random(),"ping")
			#print("Pinging")
