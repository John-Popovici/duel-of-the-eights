extends ScrollContainer

@export var scroll_speed: float = 50  # Pixels per second
@export var idle_resume_delay: float = 8.0  # Seconds before resuming after user interaction
@export var pause_between_cycles: float = 0.5  # seconds between directions

var tween: Tween


func _start_auto_scroll():
	if tween:
		tween.kill()

	var scroll_bar = get_v_scroll_bar()
	var max_scroll = scroll_bar.max_value - scroll_bar.page
	var duration = max_scroll / scroll_speed

	#Loop our tweens
	tween = create_tween().set_loops().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "scroll_vertical", max_scroll, duration).set_delay(pause_between_cycles)
	tween.tween_property(self, "scroll_vertical", 0.0, duration).set_delay(pause_between_cycles)

func _on_scrolling():
	if tween.is_running():
		tween.pause()
		await get_tree().create_timer(idle_resume_delay).timeout
		tween.play()

func _ready() -> void:
	# Wait for layout calculations
	await get_tree().process_frame
	
	# Connect to scroll event
	var scroll_bar = get_v_scroll_bar()
	scroll_bar.scrolling.connect(_on_scrolling)
	
	# Initialize tween
	_start_auto_scroll()

func _input(event):
	if event is InputEventKey:
		if event.is_pressed() and event.keycode == KEY_ESCAPE :
			SceneSwitcher.returnToIntro()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
