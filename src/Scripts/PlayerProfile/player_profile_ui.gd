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
@onready var back_to_home_button = listingsContainer.get_node("BackToHomeButton")

@export var presets_folder = "res://Presets"

var profile_settings_saved = false
@export var profile_settings: Dictionary = {}
@export var username: String
@export var invertedSelection: bool
@export var sfxVolume: int
@export var musicVolume: int

func _on_profile_pic_button_pressed():
	fileDialog.popup_centered()
	
func _on_username_box_modified(new_username):
	print("username changed to: ", new_username)
	self.username = new_username
	# save new username
	self.save_profile_settings()
	
func _on_invert_select_method_toggled(button_pressed: bool):
	print("invert selection method is now set to: ", button_pressed)
	self.invertedSelection = button_pressed
	# ACTUAL LOGIC STILL TO BE IMPLEMENTED
	# save new selection method
	self.save_profile_settings()
	
func _on_sfx_slider_drag_ended(value):
	print("sfx volume set to: ", value)
	set_sfx_volume(value, false)
	AudioManager.set_sfx_volume(float(self.sfxVolume)/100)
	# save modified sfx volume preferences
	self.save_profile_settings()
	
func _on_music_slider_drag_ended(value):
	print("music volume set to: ", value)
	set_music_volume(value, false)
	AudioManager.set_music_volume(float(self.musicVolume)/100)
	# save modified music volume preferences
	self.save_profile_settings()
	
func _on_image_file_selected(path: String):
	# Create a new Image instance
	var image = Image.new()
	
	# Load the image from the selected file path
	var err = image.load(path)
	if err != OK:
		push_error("Failed to load image at: " + path)
		return
		
	var save_path = presets_folder + "/images/profile_pic.png"  # 'user://' points to the application's data folder
	# Save the image as a PNG file
	var error = image.save_png(save_path)
	if error != OK:
		push_error("Failed to save the image: " + str(error))
	else:
		print("Image saved successfully at ", save_path)
	
	# Create an ImageTexture, assign the loaded image to it, and give to profile pic
	var texture = ImageTexture.new()
	texture.set_image(image)
	profile_pic_button.texture_normal = texture
	
func set_sfx_volume(volume: float, setSlider: bool):
	self.sfxVolume = volume
	sfx_slider_value.text = str(volume) + "%"
	if setSlider:
		sfx_slider.value = volume

func set_music_volume(volume: float, setSlider: bool):
	self.musicVolume = volume
	music_slider_value.text = str(volume) + "%"
	if setSlider:
		music_slider.value = volume

func save_profile_settings():
	profile_settings = {
		"player_name": self.username,
		"invert_selection_method": self.invertedSelection,
		"sfx_volume": self.sfxVolume,
		"music_volume": self.musicVolume
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
	set_sfx_volume(int(AudioManager.get_sfx_volume()*100), true)
	set_music_volume(int(AudioManager.get_music_volume()*100), true)
	
	fileDialog.filters = ["*.png ; PNG Images", "*.jpg ; JPEG Images"]
	fileDialog.file_selected.connect(self._on_image_file_selected)
	profile_pic_button.connect("pressed",self._on_profile_pic_button_pressed)
	username_box.connect("text_changed", self._on_username_box_modified)
	invert_select_method.connect("toggled", self._on_invert_select_method_toggled)
	sfx_slider.connect("value_changed", self._on_sfx_slider_drag_ended)
	music_slider.connect("value_changed", self._on_music_slider_drag_ended)
	back_to_home_button.connect("pressed",self.returnToIntro)
	AudioManager.connect_buttons()

func returnToIntro() -> void:
	SceneSwitcher.returnToIntro()

func _process(delta: float) -> void:
	pass
