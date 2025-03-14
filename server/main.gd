extends Node

const PORT = 9999
var peer = ENetMultiplayerPeer.new()
var lobbies = {}  # Dictionary to store lobbies (lobby_id -> [players])

func _ready():
	var multiplayer_api = SceneMultiplayer.new()
	if peer.create_server(PORT) == OK:
		multiplayer_api.multiplayer_peer = peer
		get_tree().set_multiplayer(multiplayer_api)
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
		print("✅ Server started on port ", PORT)
	else:
		print("❌ Failed to start server")

var chat_history = []  # Stores messages for new users



# 🟢 When a new player joins, add them to a lobby
func _on_peer_connected(peer_id):
	print("👤 New user connected: ", peer_id)

	# 🔹 Add player to the first available lobby (or create one)
	var lobby_id = "MainLobby"  # You can modify this for multiple lobbies
	if not lobbies.has(lobby_id):
		lobbies[lobby_id] = []

	lobbies[lobby_id].append(peer_id)

	# 🔹 Print lobby status
	_print_lobby_status()


# 🟢 Handle player disconnects
func _on_peer_disconnected(peer_id):
	print("👤 User disconnected: ", peer_id)

	# 🔹 Remove player from lobbies
	for lobby_id in lobbies.keys():
		if peer_id in lobbies[lobby_id]:
			lobbies[lobby_id].erase(peer_id)
			break  # Stop searching once found

	# 🔹 Print updated lobby status
	_print_lobby_status()

#@rpc("any_peer")
#func receive_disconnect():
	#var peer_id = multiplayer.get_remote_sender_id()  # Get the ID of the disconnecting client
	#print("❌ Client", peer_id, "disconnected via RPC.")
	
	# Remove the player from lobbies
	#for lobby_id in lobbies.keys():
		#if peer_id in lobbies[lobby_id]:
			#lobbies[lobby_id].erase(peer_id)
			#break  # Stop searching once found
	
	# Print updated lobby status
	#_print_lobby_status()

# 🟢 Print lobby details
func _print_lobby_status():
	print("\n📜 Current Lobbies:")
	for lobby_id in lobbies.keys():
		print("🛖 Lobby:", lobby_id, " | Players:", lobbies[lobby_id])
	print("")

@rpc("any_peer")
func receive_game_state(state: String, data: Dictionary):
	for peer_id in multiplayer.get_peers():
		rpc_id(peer_id, "receive_game_state", state, data)



@rpc("any_peer")
func receive_game_settings(_game_settings: Dictionary, _hand_settings: Dictionary):
	var game_settings = _game_settings
	var hand_settings = _hand_settings
	# Broadcast to all clients
	for peer_id in multiplayer.get_peers():
		rpc_id(peer_id, "receive_game_settings", game_settings, hand_settings)



@rpc("any_peer", "call_local")
func ping():
	print("Received ping from peer:", multiplayer.get_remote_sender_id())
