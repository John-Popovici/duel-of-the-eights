extends Node

@onready var normalDiceTex = preload("res://Materials/DiceTextures/Red.tres")
@onready var selectedDiceTex = preload("res://Materials/DiceTextures/Purple.tres")
@onready var dicebaseTex = preload("res://Materials/DiceTextures/White.tres")

@onready var globalTheme = "Tavern"

@onready var dice_tex_folder = "res://Materials/DiceTextures"
@onready var allDiceTextures : Dictionary = {
	"Blue": preload("res://Materials/DiceTextures/Blue.tres"),
	"Red": preload("res://Materials/DiceTextures/Red.tres"),
	"Forest Green": preload("res://Materials/DiceTextures/ForestGreen.tres"),
	"Gold": preload("res://Materials/DiceTextures/Gold.tres"),
	"Green": preload("res://Materials/DiceTextures/Green.tres"),
	"Orange": preload("res://Materials/DiceTextures/Orange.tres"),
	"Pink": preload("res://Materials/DiceTextures/Pink.tres"),
	"Purple": preload("res://Materials/DiceTextures/Purple.tres"),
	"White": preload("res://Materials/DiceTextures/White.tres"),
	"Yellow": preload("res://Materials/DiceTextures/Yellow.tres"),
	"Black": preload("res://Materials/DiceTextures/Black.tres"),
}

@onready var presets_folder = "res://Presets"
@onready var player_settings_path = (presets_folder + "/profile_settings.json")
@onready var dice_settings_path = (presets_folder + "/dice_settings.json")

@onready var profile_settings : Dictionary = {
	"player_name": "New Player",
	"invert_selection_method": false,
	"align_rolled_dice": false,
	"chat_enabled": true,
	"sfx_volume": null,
	"music_volume": null,
	"ambience_volume": null
}
@onready var profile_pic : Texture

@onready var d4Settings : Dictionary = {
	"start_time" : 0,
	"impulse_range" : 15,
	"torque_range" : 25,
	"velocity_threshold" : 0.1,
	"roll_time_limit" : 5.0,
	"up_threshold" : 0.8
}
@onready var d6Settings : Dictionary = {
	"start_time" : 0,
	"impulse_range" : 5,
	"torque_range" : 5,
	"velocity_threshold" : 0.1,
	"roll_time_limit" : 3.0,
	"up_threshold" : 0.9
}
@onready var d8Settings : Dictionary = {
	"start_time" : 0,
	"impulse_range" : 15,
	"torque_range" : 25,
	"velocity_threshold" : 0.1,
	"roll_time_limit" : 5.0,
	"up_threshold" : 0.8
}
@onready var d12Settings : Dictionary = {
	"start_time" : 0,
	"impulse_range" : 15,
	"torque_range" : 25,
	"velocity_threshold" : 0.1,
	"roll_time_limit" : 10.0,
	"up_threshold" : 0.9
}

@onready var diceDefaultSettingsRefs : Dictionary = {
	4 : d4Settings,
	6 : d6Settings,
	8 : d8Settings,
	12 : d12Settings
}

@export var debug_mode: bool = true
	
# Load existing profile settings
func load_profile_settings():
	if FileAccess.file_exists(player_settings_path):
		var file = FileAccess.open(player_settings_path, FileAccess.READ)
		var content = file.get_as_text()
		var json_data = JSON.parse_string(content)
		
		if json_data == null:
			Debugger.log_error("Error parsing JSON")
			return
			
		for key in json_data:
			Debugger.log(str("loading ", key, ": ", json_data[key]))
			self.profile_settings[key] = json_data[key]
			
	else:
		Debugger.log_warning("no data to load")
		
	# load profile pic
	Debugger.log("checking for profile picture")
	var save_path = presets_folder + "/Images/profile_pic.png"
	if FileAccess.file_exists(save_path):
		Debugger.log("profile picture found")
		self.profile_pic = self.load_image_texture(save_path)
		
func load_dice_textures():
	var diceTexturesPath = presets_folder + "/DiceTextures"
	var dir = DirAccess.open(diceTexturesPath)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):  # Ignore subdirectories
				print("Loading file:", file_name)
				var full_path = diceTexturesPath + "/" + file_name
				set(file_name.get_basename(), load(full_path))
				
			file_name = dir.get_next()  # Move to the next file

		dir.list_dir_end()  # Clean up
	else:
		print("Error: Could not open directory.")
		
func save_dice_textures():
	var dice_settings = {
		"normalDiceTex": self.normalDiceTex,
		"selectedDiceTex": self.selectedDiceTex,
		"dicebaseTex": self.dicebaseTex
	}
	
	for dice_tex in dice_settings:
		var save_path = presets_folder + "/DiceTextures/"+dice_tex+".tres"
		print("saving to : ", save_path)
		ResourceSaver.save(dice_settings[dice_tex], save_path)
		
func load_image_texture(path: String) -> Texture:
	# Create a new Image instance
	var image = Image.new()
	
	# Load the image from the selected file path
	var err = image.load(path)
	if err != OK:
		push_error("Failed to load image at: " + path)
		return
	
	# Create an ImageTexture, assign the loaded image to it, and give to profile pic
	var texture = ImageTexture.new()
	texture.set_image(image)
	texture.set_size_override(Vector2(200,200))
	return texture

func setDiceTexture(text_to_set, new_tex) -> void:
	match text_to_set:
		"normal":
			self.normalDiceTex = new_tex
		"selected":
			self.selectedDiceTex = new_tex
		"base":
			self.dicebaseTex = new_tex
		_:
			return
	self.save_dice_textures()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dir = DirAccess.open(dice_tex_folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var texture_name = file_name.replace(".tres", "").capitalize()
				var texture_path = "res://Materials/DiceTextures/" + file_name
				allDiceTextures[texture_name] = load(texture_path)
			file_name = dir.get_next()
		dir.list_dir_end()
	#Debugger.log(str("Dice Tex: ",allDiceTextures))
	load_profile_settings()
	load_dice_textures()
	
	Debugger.debug_enabled = true
