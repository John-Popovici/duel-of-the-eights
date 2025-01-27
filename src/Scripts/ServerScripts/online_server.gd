extends Control


var multiplayer_peer = ENetMultiplayerPeer.new()

var port:int = 9999

func _ready():
	var args = OS.get_cmdline_user_args()
	for arg in args:
		var key_value = arg.rsplit("=")
		match key_value[0]:
			"port":
				port = key_value[1].to_int()
	multiplayer_peer.create_server(port)
	multiplayer.multiplayer_peer = multiplayer_peer
	multiplayer_peer.peer_connected.connect(func(id): print("Peer Connected. ID: ",id))
	multiplayer_peer.peer_disconnected.connect(func(id): print("Peer disonnected. ID: ",id))
	print("Server running on port ",port)
