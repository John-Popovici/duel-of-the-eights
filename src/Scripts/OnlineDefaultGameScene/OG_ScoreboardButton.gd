extends Button

var toCall: Callable
var maxPlays: int
var settings: Dictionary
var disable: bool
@onready var plays: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.connect("pressed",self.playHand)
	pass # Replace with function body.

func playHand() -> void:
	plays += 1
	if plays >= maxPlays:
		self.disabled = true
		disable = true
	toCall.call(settings, self)

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
