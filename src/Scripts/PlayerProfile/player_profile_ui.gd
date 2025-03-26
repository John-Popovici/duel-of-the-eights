extends CanvasLayer

signal profile_settings_ready(profile_settings)
@onready var fileDialog = get_node("FileDialog")
@onready var listingsContainer = get_node("MainBackground/MainContainer/MarginContainer/HListingsContainer")
@onready var userDetailsContainer = listingsContainer.get_node("UserDetailsContainer")
@onready var profile_pic_button = userDetailsContainer.get_node("ProfileBackground/ProfilePicButton")
@onready var username_box = userDetailsContainer.get_node("UsernameFrame/UsernameBox")
@onready var invert_select_method = listingsContainer.get_node("InvertSelectMethodContainer/CheckButton")
@onready var align_dice = listingsContainer.get_node("AlignDiceContainer/CheckButton")
@onready var chat_enabled = listingsContainer.get_node("ChatEnabledContainer/CheckButton")
@onready var sfxContainer = listingsContainer.get_node("SFXVolumeContainer/SliderContainer")
@onready var sfx_slider = sfxContainer.get_node("Slider")
@onready var sfx_slider_value = sfxContainer.get_node("Value")
@onready var musicContainer = listingsContainer.get_node("MusicVolumeContainer/SliderContainer")
@onready var music_slider = musicContainer.get_node("Slider")
@onready var music_slider_value = musicContainer.get_node("Value")
@onready var ambienceContainer = listingsContainer.get_node("AmbientVolumeContainer/SliderContainer")
@onready var ambience_slider = ambienceContainer.get_node("Slider")
@onready var ambience_slider_value = ambienceContainer.get_node("Value")
@onready var back_to_home_button = listingsContainer.get_node("BackToHomeButton")

@export var presets_folder = "user://Presets"
@export var player_settings_path = (presets_folder + "/profile_settings.json")

@export var profile_settings: Dictionary = {}
@export var username: String
@export var invertedSelection: bool
@export var alignDice: bool
@export var chatEnabled: bool
@export var sfxVolume: int
@export var musicVolume: int
@export var ambienceVolume: int

func _on_profile_pic_button_pressed():
	fileDialog.popup_centered()
	
func _on_username_box_modified(new_username):
	Debugger.log(str("username changed to: ", new_username))
	self.username = new_username
	# save new username
	self.save_profile_settings()
	
func _on_invert_select_method_toggled(button_pressed: bool):
	Debugger.log(str("invert selection method is now set to: ", button_pressed))
	self.invertedSelection = button_pressed
	# ACTUAL LOGIC STILL TO BE IMPLEMENTED
	# save new selection method
	self.save_profile_settings()
	
func _on_align_dice_toggled(button_pressed: bool):
	Debugger.log(str("align dice is now set to: ", button_pressed))
	self.alignDice = button_pressed
	# save new dice alignment decision
	self.save_profile_settings()

func _on_chat_enabled_toggled(button_pressed: bool):
	Debugger.log(str("chat enabled is now set to: ", button_pressed))
	self.chatEnabled = button_pressed
	# save new chat preference
	self.save_profile_settings()
	
func _on_sfx_slider_drag_ended(value):
	Debugger.log(str("sfx volume set to: ", value))
	set_sfx_volume(value, true, false)
	# save modified sfx volume preferences
	self.save_profile_settings()
	
func _on_music_slider_drag_ended(value):
	Debugger.log(str("music volume set to: ", value))
	set_music_volume(value, true, false)
	# save modified music volume preferences
	self.save_profile_settings()
	
func _on_ambience_slider_drag_ended(value):
	Debugger.log(str("ambience volume set to: ", value))
	set_ambience_volume(value, true, false)
	# save modified music volume preferences
	self.save_profile_settings()
	
func _on_image_file_selected(path: String):
	# Create a new Image instance
	var image = Image.new()
	
	# Load the image from the selected file path
	var err = image.load(path)
	if err != OK:
		Debugger.log_error(str("Failed to load image at: " + path))
		return

	var save_path = presets_folder + "/Images/profile_pic.png"
	var error = image.save_png(save_path)
	if error != OK:
		Debugger.log_error(str("Failed to save the image: " + str(error)))
	else:
		Debugger.log(str("Image saved successfully at ", save_path))
	
	# Create an ImageTexture, assign the loaded image to it, and give to profile pic
	var texture = ImageTexture.new()
	texture.set_image(image)
	texture.set_size_override(Vector2(200,200))
	# share profile pic to global settings
	GlobalSettings.profile_pic = texture
	profile_pic_button.texture_normal = texture
	profile_pic_button.texture_hover = null
	
func set_sfx_volume(volume: float, setAudioManager: bool, setSlider: bool):
	if volume == null:
		return
	self.sfxVolume = volume
	sfx_slider_value.text = str(volume) + "%"
	if setAudioManager:
		AudioManager.set_sfx_volume(float(volume)/100)
	if setSlider:
		sfx_slider.value = volume

func set_music_volume(volume: float, setAudioManager: bool, setSlider: bool):
	if volume == null:
		return
	self.musicVolume = volume
	music_slider_value.text = str(volume) + "%"
	if setAudioManager:
		AudioManager.set_music_volume(float(volume)/100)
	if setSlider:
		music_slider.value = volume
		
func set_ambience_volume(volume: float, setAudioManager: bool, setSlider: bool):
	if volume == null:
		return
	self.ambienceVolume = volume
	ambience_slider_value.text = str(volume) + "%"
	if setAudioManager:
		AudioManager.set_ambience_volume(float(volume)/100)
	if setSlider:
		ambience_slider.value = volume

func save_profile_settings():
	self.profile_settings = {
		"player_name": self.username,
		"invert_selection_method": self.invertedSelection,
		"align_rolled_dice": self.alignDice,
		"chat_enabled": self.chatEnabled,
		"sfx_volume": self.sfxVolume,
		"music_volume": self.musicVolume,
		"ambience_volume": self.ambienceVolume
	}
	# share changes to global settings
	GlobalSettings.profile_settings = self.profile_settings

	Debugger.log(str("Writing to: ", player_settings_path))
	var file = FileAccess.open(player_settings_path, FileAccess.WRITE)
	var json = JSON.new()
	var json_string = json.stringify(profile_settings)
	file.store_string(json_string)
	file.close()
	Debugger.log("profile settings saved.")

# Load existing profile settings
func load_profile_settings():
	# load username
	self.username = GlobalSettings.profile_settings["player_name"]
	self.username_box.text = self.username
	# load selection method
	self.invertedSelection = GlobalSettings.profile_settings["invert_selection_method"]
	invert_select_method.button_pressed = self.invertedSelection
	# load align decisions
	self.alignDice = GlobalSettings.profile_settings["align_rolled_dice"]
	align_dice.button_pressed = self.alignDice
	# load chat decisions
	self.chatEnabled = GlobalSettings.profile_settings["chat_enabled"]
	chat_enabled.button_pressed = self.chatEnabled
	# load sfx_volume
	self.set_sfx_volume(GlobalSettings.profile_settings["sfx_volume"], true, true)
	# load music_volume
	self.set_music_volume(GlobalSettings.profile_settings["music_volume"], true, true)
	# load ambience_volume
	self.set_ambience_volume(GlobalSettings.profile_settings["ambience_volume"], true, true)
	
	# load profile pic
	if GlobalSettings.profile_pic != null:
		profile_pic_button.texture_normal = GlobalSettings.profile_pic
		profile_pic_button.texture_hover = null

# Load default settings
func load_default_settings():
	set_sfx_volume(int(AudioManager.get_sfx_volume()*100), false, true)
	set_music_volume(int(AudioManager.get_music_volume()*100), false, true)
	set_ambience_volume(int(AudioManager.get_ambience_volume()*100), false, true)

func _ready() -> void:
	self.load_default_settings()
	self.load_profile_settings()
	
	fileDialog.filters = ["*.png ; PNG Images", "*.jpg ; JPEG Images"]
	fileDialog.file_selected.connect(self._on_image_file_selected)
	profile_pic_button.connect("pressed",self._on_profile_pic_button_pressed)
	username_box.connect("text_changed", self._on_username_box_modified)
	invert_select_method.connect("toggled", self._on_invert_select_method_toggled)
	align_dice.connect("toggled", self._on_align_dice_toggled)
	chat_enabled.connect("toggled", self._on_chat_enabled_toggled)
	sfx_slider.connect("value_changed", self._on_sfx_slider_drag_ended)
	music_slider.connect("value_changed", self._on_music_slider_drag_ended)
	ambience_slider.connect("value_changed", self._on_ambience_slider_drag_ended)
	back_to_home_button.connect("pressed",self.returnToIntro)
	
	AudioManager.connect_buttons()

func returnToIntro() -> void:
	SceneSwitcher.returnToIntro()

func _process(delta: float) -> void:
	pass
