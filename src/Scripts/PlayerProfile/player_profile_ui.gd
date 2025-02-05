extends CanvasLayer

signal profile_settings_ready(profile_settings)
@onready var fileDialog = get_node("FileDialog")
@onready var listingsContainer = get_node("MainBackground/MainContainer/MarginContainer/HListingsContainer")
@onready var userDetailsContainer = listingsContainer.get_node("UserDetailsContainer")
@onready var profile_pic_button = userDetailsContainer.get_node("ProfileBackground/ProfilePicButton")
@onready var username_box = userDetailsContainer.get_node("UsernameFrame/UsernameBox")
@onready var invert_select_method = listingsContainer.get_node("InvertSelectMethodContainer/CheckButton")
@onready var sfxContainer = listingsContainer.get_node("SFXVolumeContainer/SliderContainer")
@onready var sfx_slider = sfxContainer.get_node("Slider")
@onready var sfx_slider_value = sfxContainer.get_node("Value")
@onready var musicContainer = listingsContainer.get_node("MusicVolumeContainer/SliderContainer")
@onready var music_slider = musicContainer.get_node("Slider")
@onready var music_slider_value = musicContainer.get_node("Value")

@export var presets_folder = "res://Presets"

var profile_settings_saved = false
@export var profile_settings: Dictionary = {}


func _on_profile_pic_button_pressed():
	fileDialog.popup_centered()
	
func _on_image_file_selected(path):
	# Create a new Image instance
	var image = Image.new()
	
	# Load the image from the selected file path
	var err = image.load(path)
	if err != OK:
		push_error("Failed to load image at: " + path)
		return
	
	# Create an ImageTexture, assign the loaded image to it, and give to profile pic
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	profile_pic_button.texture = texture


func save_profile_settings():
	profile_settings = {
		"player_name": username_box.text,
		"invert_selection_method": invert_select_method,
		"sfx_volume": sfx_slider_value,
		"music_volume": music_slider_value
	}

	var file_path = presets_folder + "/profile_settings.json"
	print("Writing to: ", file_path)
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	var json = JSON.new()
	var json_string = json.stringify(profile_settings)
	file.store_string(json_string)
	file.close()
	print("profile settings saved.")

func _ready() -> void:
	self.visible = false
	profile_pic_button.connect("pressed",self._on_profile_pic_button_pressed)
	AudioManager.connect_buttons()

func returnToIntro() -> void:
	SceneSwitcher.returnToIntro()

func _process(delta: float) -> void:
	pass
