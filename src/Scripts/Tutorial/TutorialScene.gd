extends Control

@onready var image_display = get_node("Panel/Container/ImageDisplay")
@onready var caption_label = get_node("Panel/Container/CaptionBox/CaptionLabel")
@onready var prev_button = get_node("Panel/Container/NavigationButtons/PreviousButton")
@onready var next_button = get_node("Panel/Container/NavigationButtons/NextButton")
@onready var skip_button = get_node("Panel/Container/NavigationButtons/SkipButton")

# List of tutorial images and captions
var tutorial_slides = [
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard1.png"), "caption": "Welcome to Dice Duels! Let's learn the basics."},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard2.png"), "caption": "Click 'Play Standard Game' to start a classic match of Dice Duels!"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard3.png"), "caption": "If you are hosting the game, check the 'Host?' box to set up the connection."},
	#{"image": preload("res://Assets/2D Assets/TutorialImages/Standard4.png"), "caption": "Choose a scoring category to record your roll."},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard5.png"), "caption": "Click 'Start Hosting' to create a game lobby and your opponent can join."},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard6.png"), "caption": "Click 'Copy Connect Code' and share it with your opponent so they can join your game."},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard7.png"), "caption": "Select the type of dice you want to use for this game. Click '8-Sided' to play with eight-sided dice."},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard8.png"), "caption": "Enter the connect code provided by the host into the text box to join the game."},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard9.png"), "caption": "After entering the connect code, click 'Connect' to join the host's game."},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard10.png"), "caption": "Waiting for the host to start the game. Sit tight while the game is set up!"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard11.png"), "caption": "Once your opponent has connected, click 'Start Game' to begin the match!"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard12.png"), "caption": "This is the game screen. Here’s what each section of the UI does: \nDice Area: Shows your rolled dice. \nScoreboard: Tracks your available scoring options, and is used to select a scoring option. \nOpponent Panel: Displays your opponent's dice and score. \nGame Info Panel: Shows the current round, rolls left, and turn status. \nAction Buttons: Allows you to reroll dice or pass on rolling."},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard13.png"), "caption": "Select dice for re-rolling by clicking on either the 3D dice models or their corresponding 2D images in the panel."},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard14.png"), "caption": "Click 'Roll Selected' to reroll the dice you have chosen and try to get the combination you need!"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard15.png"), "caption": "Decide your next move: Click 'Roll Selected' to reroll your chosen dice, or 'Pass' if you're satisfied with your roll."},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard16.png"), "caption": "To aim for a Straight, select the three highlighted dice and click 'Roll Selected' to try and complete the sequence!"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard17.png"), "caption": "You’ve reached the end of your rolls! Click on a scoring option, like 'Chance,' to record your points based on your final dice combination."},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard18.png"), "caption": "You’ve scored your hand! Your points have been added, and the chosen category is now unavailable for future rounds. Wait for your opponent to score their hand."},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard19.png"), "caption": "Your opponent has scored their hand. Now it's your turn! Click on a highlighted scoring option to record your points based on your final dice combination."},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard20.png"), "caption": "Both players have scored their hands! The game continues with the next round—roll your dice and aim for the best scoring combination."},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Bluff1.png"), "caption": "Welcome to Bluff Mode! In this variant, the player with the lower-scoring hand loses 1 HP each round—the last one standing wins!\n'Raise the Stakes' lets you double the damage for this round, unless your opponent folds.\nIf they fold, they immediately lose 1 HP.\nUse this strategically to pressure your opponent and take control of the game!"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Bluff2.png"), "caption": "You’ve raised the stakes! The potential damage this round has doubled—now continue playing by rolling your selected dice."},
	#{"image": preload("res://Assets/2D Assets/TutorialImages/Bluff3.png"), "caption": ""},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Bluff4.png"), "caption": "Your opponent has raised the stakes! You can continue playing, or click 'Fold' if you think your hand won’t win—folding immediately costs you 1 HP, but prevents extra damage."},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Bluff5.png"), "caption": "You folded! You take 1 HP damage, and the game moves to the next round. Stay in the game and plan your next move carefully!"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Bluff6.png"), "caption": "Your opponent folded! They took 1 HP damage, and the next round begins. Keep up the pressure and outlast them to win!"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Bluff7.png"), "caption": "You’ve raised the stakes! The potential damage this round is doubled—now play through to scoring and see how the results unfold!"},
	#{"image": preload("res://Assets/2D Assets/TutorialImages/Bluff8.png"), "caption": ""},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Bluff9.png"), "caption": "Your opponent has raised the stakes! You can choose to keep playing and try to win the round, or fold and take 1 HP damage immediately."},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Bluff10.png"), "caption": "Both players have played through the round—folding is no longer an option. Choose a scoring category to see who wins this round!"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Bluff11.png"), "caption": "Scoring is complete! Since you scored higher, you avoided damage—but your opponent lost 2 HP because of the raised stakes. The game continues until one player runs out of health!"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Bluff12.png"), "caption": "Your opponent scored higher this round! Since the stakes were raised, you lose 2 HP. The game continues until one player runs out of health—fight back next round!"}
]

var current_slide_index = 0  # Track the current slide

func _ready():
	update_slide()  # Load the first slide
	prev_button.connect("pressed", _on_prev_pressed)
	next_button.connect("pressed", _on_next_pressed)
	skip_button.connect("pressed", _on_skip_pressed)
	AudioManager.connect_buttons()

func update_slide():
	image_display.texture = tutorial_slides[current_slide_index]["image"]
	caption_label.text = tutorial_slides[current_slide_index]["caption"]
	
	# Disable/Enable navigation buttons based on slide index
	prev_button.disabled = (current_slide_index == 0)
	next_button.text = "Finish" if current_slide_index == tutorial_slides.size() - 1 else "Next"

func _on_prev_pressed():
	if current_slide_index > 0:
		current_slide_index -= 1
		update_slide()

func _on_next_pressed():
	if current_slide_index < tutorial_slides.size() - 1:
		current_slide_index += 1
		update_slide()
	else:
		_on_skip_pressed()  # Finish the tutorial when reaching the last slide

func _on_skip_pressed():
	SceneSwitcher.returnToIntro()  # Replace with the actual scene to load
