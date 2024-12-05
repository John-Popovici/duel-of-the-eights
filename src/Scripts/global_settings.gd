extends Node

@onready var normalDiceTex = load("res://Materials/DiceTextures/Red.tres")
@onready var selectedDiceTex = load("res://Materials/DiceTextures/Purple.tres")
@onready var dicebaseTex = load("res://Materials/DiceTextures/White.tres")

@onready var dice_tex_folder = "res://Materials/DiceTextures"
@onready var allDiceTextures : Dictionary = {}

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

@onready var normalCustomDiceTex : Dictionary
@onready var selectedCustomDiceTex : Dictionary
@onready var custom_dice_tex_folder_paths : Dictionary = {
	"Red" : "res://Materials/CustomDiceTextures/Red",
	"Purple" : "res://Materials/CustomDiceTextures/Purple"
} 
@onready var allCustomDiceTextures : Dictionary = {}

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
	
	for pathName in custom_dice_tex_folder_paths.keys():
		var customdir = DirAccess.open(custom_dice_tex_folder_paths[pathName])
		if customdir:
			customdir.list_dir_begin()
			var file_name = customdir.get_next()
			var tempDict = {}
			while file_name != "":
				if file_name.ends_with(".tres"):
					var texture_name = file_name.replace(".tres", "").capitalize()
					var texture_path = custom_dice_tex_folder_paths[pathName] + "/" + file_name
					tempDict[texture_name] = load(texture_path)
				file_name = customdir.get_next()
			customdir.list_dir_end()
			allCustomDiceTextures[pathName] = tempDict
	normalCustomDiceTex = allCustomDiceTextures["Red"]
	selectedCustomDiceTex = allCustomDiceTextures["Purple"]
	print(allCustomDiceTextures["Red"])
