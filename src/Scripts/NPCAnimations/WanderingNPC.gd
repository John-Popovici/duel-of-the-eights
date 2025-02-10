extends PathFollow3D

@onready var animation_player = $Rogue/AnimationPlayer  # Adjust path if needed
@onready var Paths = {
	0: preload("res://Scripts/NPCAnimations/Curve_P1.tres"),
	1: preload("res://Scripts/NPCAnimations/Curve_P2.tres"),
	2: preload("res://Scripts/NPCAnimations/Curve_P3.tres")
	}

var is_moving = true  # Controls when the NPC is moving
var active_path = 0

func _ready():
	start_path()

func start_path():
	is_moving = true
	get_parent().curve = Paths[active_path]
	create_tween().tween_property(self, "progress_ratio",0.99,10)
	animation_player.play("Walking_A")  # Resume walking animation

func _process(delta):
	if is_moving:
		# If the NPC reaches the end of the path, loop back
		if progress_ratio >= 0.99:
			progress_ratio = 0.0
			idle_before_moving()

func idle_before_moving():
	is_moving = false  # Stop movement temporarily
	animation_player.play("Use_Item") #Drink
	AudioManager.play_ambience("drink_sip")
	await get_tree().create_timer(2).timeout  # Random idle time
	animation_player.play("Idle")  # Play idle animation
	await get_tree().create_timer(randf_range(2, 5)).timeout  # Random idle time
	active_path = (active_path + 1) % 3
	start_path()
