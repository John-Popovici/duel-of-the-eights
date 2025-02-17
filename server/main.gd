extends Node

const PORT = 9999
var peer = ENetMultiplayerPeer.new()

func _ready():
	var multiplayer_api = SceneMultiplayer.new()
	if peer.create_server(PORT) == OK:
		multiplayer_api.multiplayer_peer = peer
		get_tree().set_multiplayer(multiplayer_api)
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
		print("Server started on port ", PORT)
	else:
		print("Failed to start server")

var chat_history = []  # Stores messages for new users

@rpc("any_peer")
func msg_rpc(usrnm: String, data: String):
	print(usrnm, ": ", data)  # Server logs message
	chat_history.append(usrnm + ": " + data)  # Store message
	if chat_history.size() > 50:  # Limit message history
		chat_history.pop_front()

	# Broadcast to all **other** clients (not the sender)
	for peer_id in multiplayer.get_peers():
		if peer_id != multiplayer.get_remote_sender_id():  # Avoid echoing back to sender
			rpc_id(peer_id, "msg_rpc", usrnm, data)

func _on_peer_connected(peer_id):
	print("New user connected: ", peer_id)
	for msg in chat_history:
		rpc_id(peer_id, "msg_rpc", "SERVER", msg)  # Send chat history

func _on_peer_disconnected(peer_id):
	print("User disconnected: ", peer_id)
