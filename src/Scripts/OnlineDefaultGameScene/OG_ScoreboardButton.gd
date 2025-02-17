extends Button

var toCall: Callable
var maxPlays: int
var settings: Dictionary
var disable: bool
@onready var plays: int = 0
var game_manager
var player
var scoreCalc

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.connect("pressed",self.playHand)
	var game_managers = get_tree().get_nodes_in_group("SingleGameManager")
	if game_managers.size() > 0:
		game_manager = game_managers[0]
		player = game_manager.myPlayer
		scoreCalc = game_manager.scoreCalc
		connect("mouse_entered", _on_focus_entered)
		connect("mouse_exited", _on_focus_exited)
	pass # Replace with function body.

func playHand() -> void:
	plays += 1
	_on_focus_exited()
	tempdisableText()
	if plays >= maxPlays:
		self.disabled = true
		disable = true
	toCall.call(settings, self)
	

var textChangeable = true

func tempdisableText():
	textChangeable = false
	prevState = ""
	await get_tree().create_timer(1.0).timeout
	textChangeable = true

func setText(_text: String):
	if textChangeable:
		self.text = _text

func getDisable() ->bool:
	return disable

func setMaxPlays(_max: int) -> void:
	maxPlays = _max

func setSettings(_settings: Dictionary) -> void:
	settings = _settings

func setCallable(_call: Callable) -> void:
	toCall = _call

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

var prevState = "Select"

func _on_focus_entered() -> void:
	Debugger.log("Hover started","Testing")
	if player == null or self.disabled:
		Debugger.log("Returned on Hover","Testing")
		return
	var rolls = player.getRolls()
	Debugger.log(str(rolls),"Testing")
	prevState = self.text
	Debugger.log("Prev State: " + prevState,"Testing")
	var handScore = scoreCalc.calculate_hand_score(settings,rolls)
	Debugger.log("HandScore: " + str(handScore),"Testing")
	if !(typeof(scoreCalc.calculate_hand_score(settings,rolls)) == typeof(0)):
		handScore = handScore[0]
	if prevState == "Select":
		setText(str(handScore))
	else:
		setText(str(int(prevState) + handScore))
	pass # Replace with function body.


func _on_focus_exited() -> void:
	Debugger.log("Hover Exited","Testing")
	if player == null or self.disabled or prevState == "":
		return
	setText(str(prevState))
	prevState = "Select"
	pass # Replace with function body.
