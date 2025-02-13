extends Control

@onready var chat_popup = $ChatPopup
@onready var scroll_contatiner = $ChatPopup/VSplitContainer/ScrollContainer
@onready var chat_messages = $ChatPopup/VSplitContainer/ScrollContainer/ChatMessages
@onready var chat_input = $ChatPopup/VSplitContainer/InputUI/ChatInput
@onready var send_button = $ChatPopup/VSplitContainer/InputUI/SendButton
@onready var chat_button = $ChatButton  # The toggle button
@onready var networkManagers = get_tree().get_nodes_in_group("NetworkHandlingNodes")
@onready var network_manager = networkManagers[0]

var unread_messages = 0  # Tracks unread messages
var last_chat = null

func _ready():
	chat_popup.hide()  # Hide chat initially
	send_button.connect("pressed", _on_send_pressed)
	chat_input.connect("text_submitted", _on_text_submitted)
	chat_button.connect("pressed", toggle_chat)
	network_manager.connect("chat_received", self.receive_chat_message)
	
func toggle_chat():
	chat_popup.visible = !chat_popup.visible  # Toggle visibility
	if chat_popup.visible:
		unread_messages = 0  # Reset unread count when chat opens
		chat_button.texture_normal = preload("res://Assets/2D Assets/OtherImages/message_read.svg")  # Reset texture
		if last_chat != null:
			await get_tree().process_frame
			scroll_contatiner.ensure_control_visible(last_chat)

func _on_send_pressed():
	send_chat_message(chat_input.text)

func _on_text_submitted(new_text):
	send_chat_message(new_text)

func send_chat_message(message: String):
	if message.strip_edges() == "":
		return  # Ignore empty messages
	chat_input.clear()
	_add_message_to_chat("You: " + message)
	network_manager.send_chat_rpc(message)  # Send message over the network

func _add_message_to_chat(message: String):
	var label = Label.new()
	label.set_autowrap_mode(3)
	if message.substr(0,3) == "You":
		label.set_horizontal_alignment(2)
	else:
		label.set_horizontal_alignment(0)
	label.text = message
	chat_messages.add_child(label)
	last_chat = label
	await get_tree().process_frame
	scroll_contatiner.ensure_control_visible(last_chat)

func receive_chat_message(message: String):
	_add_message_to_chat("Opponent: " + message)
	
	if not chat_popup.visible:
		unread_messages += 1  # Increment unread count
		chat_button.texture_normal = preload("res://Assets/2D Assets/OtherImages/message_unread.svg")  # Change button texture

func _input(event):
	return
	if event is InputEventKey and event.pressed and event.keycode == KEY_C:
		toggle_chat()
