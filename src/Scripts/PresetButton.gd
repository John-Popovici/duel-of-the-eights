extends Button

var toCall: Callable
var settings: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.connect("pressed",self.usePreset)
	pass # Replace with function body.

func usePreset() -> void:
	toCall.call(settings)

func setSettings(_settings: String) -> void:
	settings = _settings

func setCallable(_call: Callable) -> void:
	toCall = _call

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
