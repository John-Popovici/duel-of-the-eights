extends Node3D

@onready var join: Button = $VBoxContainer/Join
@onready var username: LineEdit = $VBoxContainer/Username
@onready var send: Button = $VBoxContainer/Send
@onready var message: LineEdit = $VBoxContainer/Message
@onready var messages: TextEdit = $VBoxContainer/Messages

var usrnm: String
const SERVER_IP = "54.174.171.0"  
const PORT = 9999

func _ready():
	join.pressed.connect(_on_join_pressed)
	send.pressed.connect(_on_send_pressed)

func _on_join_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	var multiplayer_api = SceneMultiplayer.new()
	
	if peer.create_client(SERVER_IP, PORT) != OK:
		print("Failed to connect to server")
		return
	
	multiplayer_api.multiplayer_peer = peer
	get_tree().set_multiplayer(multiplayer_api)
	
	usrnm = username.text.strip_edges()
	if usrnm.is_empty():
		usrnm = "Guest_" + str(randi() % 1000)

	join.hide()
	username.hide()
	send.show()
	message.show()



func _on_send_pressed() -> void:
	if usrnm.is_empty() or message.text.is_empty():
		return
	
	# Display the message immediately in the messages TextEdit (right-aligned)
	messages.text += str(usrnm, ": ", message.text, "\n")
	messages.scroll_vertical = messages.get_line_count()

	rpc_id(1, "msg_rpc", usrnm, message.text)  # Send message to server
	message.text = ""

@rpc("any_peer", "call_local")
func msg_rpc(usrnm: String, data: String):
	messages.text += str(usrnm, ": ", data, "\n")
	messages.scroll_vertical = messages.get_line_count()
