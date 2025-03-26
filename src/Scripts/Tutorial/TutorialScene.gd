extends Control

@onready var image_display = get_node("Panel/Container/ImageDisplay")
@onready var caption_label = get_node("Panel/Container/CaptionBox/CaptionLabel")
@onready var title_label = get_node("Panel/Container/TutTitle/TitleLabel")
@onready var prev_button = get_node("Panel/Container/NavigationButtons/PreviousButton")
@onready var next_button = get_node("Panel/Container/NavigationButtons/NextButton")
@onready var skip_button = get_node("Panel/Container/NavigationButtons/SkipButton")

# List of tutorial images and captions
var tutorial_slides = [
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard1.png"), "caption": "Welcome to Dice Duels! Let's learn the basics.", "title": "1: Introduction"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard2.png"), "caption": "Click 'Play Standard Game' to start a classic match of Dice Duels! Note that Online mode connects to our servers and allows two players to play togeather on anyplace with wifi, while Local mode use a LAN connection and requires players to be in the same wifi network.", "title": "2: Begining a game"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard3.png"), "caption": "If you are hosting the game, check the 'Host?' box to set up the connection.", "title": "2a: Begining a game as Host"},
	#{"image": preload("res://Assets/2D Assets/TutorialImages/Standard4.png"), "caption": "Choose a scoring category to record your roll."},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard5.png"), "caption": "Click 'Start Hosting' to create a game lobby and your opponent can join.", "title": "2a: Begining a game as Host"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard6.png"), "caption": "Click 'Copy Connect Code' and share it with your opponent so they can join your game.", "title": "2a: Begining a game as Host"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard7.png"), "caption": "Select the type of dice you want to use for this game. Click '8-Sided' to play with eight-sided dice.", "title": "2a: Begining a game as Host"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard11.png"), "caption": "Once your opponent has connected, click 'Start Game' to begin the match!", "title": "2a: Begining a game as Host"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard8.png"), "caption": "Once the host sends you the game code, enter it into the text box to join the game.", "title": "2b: Begining a game as a non-Host"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard9.png"), "caption": "After entering the connect code, click 'Connect' to join the host's game.", "title": "2b: Begining a game as a non-Host"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard10.png"), "caption": "Waiting for the host to start the game. Sit tight while the game is set up!", "title": "2b: Begining a game as a non-Host"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard22.png"), "caption": "This is the game screen. Here’s what each section of the UI does: \nDice Area: Shows your rolled dice. \nScoreboard: Tracks your available scoring options, and is used to select a scoring option. \nOpponent Stats: Displays the score and stats of the Opponent  \nPlayer Stats: Displays your total score and stats \nGame progress tracker: Shows the current round, rolls left, and turn status. \nRolling Options: Allows you to reroll dice or pass on rolling. \n Scoring guide: Shows you how to score each type of hand. ", "title": "3: Standard Gameplay"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard23.png"), "caption": "\nOpponent Panel: Displays your opponent's dice rolls  \nPlayer Panel: Displays your dice roll's \nCamera Controls: Use to control the camera angle of the game  \nChat button: opens a chat panel you can use to send messages to your opponent  \n Dice sorting: sorts the dice for you inyour dice roll panel \n Timer: counts down how much time is left for you to make your turn.  ", "title": "3: Standard Gameplay"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard31.png"), "caption": "Now, in a Standard Game, the goal is to score as high as possible, and you do this by rolling hands on dice. \n Note that at the begining of each round, both players roll their dice automatically.", "title": "3: Standard Gameplay"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard24.png"), "caption": "After each roll is completed, Select dice for re-rolling by clicking on either the 3D dice models or their corresponding 2D images in the panel.", "title": "3: Standard Gameplay"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard25.png"), "caption": "Click 'Roll Selected' to reroll the dice you have chosen and try to get the combination you need, or pass if you're satisfied with your result", "title": "3: Standard Gameplay"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard26.png"), "caption": "Remember to try to aim for a hand type if you wish to score big! In this case, I'll aim for a full house by rerolling the four selected dice, and hope that they all land on the same value.", "title": "3: Standard Gameplay"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard27.png"), "caption": "You’ve reached the end of your rolls! Click on a scoring option, like 'Chance,' to record your points based on your final dice combination.", "title": "3: Standard Gameplay"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard28.png"), "caption": "You’ve scored your hand! Your points have been added, and the chosen category is now unavailable for future rounds. Wait for your opponent to score their hand.", "title": "3: Standard Gameplay"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard29.png"), "caption": "Both players have scored their hands! The game continues with the next round—roll your dice and aim for the best scoring combination.", "title": "3: Standard Gameplay"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard30.png"), "caption": "By the way, if You're ever not sure how to score you can always select and read the scoring guide to find out how to get the hand combinations that allow you to score in each category.", "title": "3: Standard Gameplay"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard32.png"), "caption": "Now, lets discuss the second main gamemode: Bluff mode!", "title": "4: Bluff Gameplay"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Bluff1.png"), "caption": "Welcome to Bluff Mode! In this variant, the player with the lower-scoring hand loses 1 HP each round—the last one standing wins!\n'Raise the Stakes' lets you double the damage for this round, unless your opponent folds.\nIf they fold, they immediately lose 1 HP.\nUse this strategically to pressure your opponent and take control of the game!", "title": "4: Bluff Gameplay"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Bluff2.png"), "caption": "You’ve raised the stakes! The potential damage this round has doubled—now continue playing by rolling your selected dice.", "title": "4: Bluff Gameplay"},
	#{"image": preload("res://Assets/2D Assets/TutorialImages/Bluff3.png"), "caption": ""},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Bluff4.png"), "caption": "Switching to the opponent's pov, the opponient now has to make a choice! continue playing, or click 'Fold' if the opponent thinks they can't win - folding immediately costs them 1 HP, but prevents extra damage.", "title": "4: Bluff Gameplay"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Bluff5.png"), "caption": "As the opponent has chosen to fold, take the Oppoennt takes 1 HP damage, and the game moves to the next round. The Opponent needs to plan their next move carefully!", "title": "4: Bluff Gameplay"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Bluff6.png"), "caption": "Your opponent folded! They took 1 HP damage, and the next round begins. Keep up the pressure and outlast them to win!", "title": "4: Bluff Gameplay"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Bluff7.png"), "caption": "You’ve raised the stakes again! The potential damage this round is doubled—now play through to scoring and see how the results unfold!", "title": "4: Bluff Gameplay"},
	#{"image": preload("res://Assets/2D Assets/TutorialImages/Bluff8.png"), "caption": ""},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Bluff9.png"), "caption": "the Opponent, seeing you raise the stakes again, is forced to choose between continuing playing for double damage or folding and taking 1 damage. \n This time, the opponent choses to play to the end.", "title": "4: Bluff Gameplay"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Bluff10.png"), "caption": "Both players have played through the round—folding is no longer an option. Choose a scoring category to see who wins this round!", "title": "4: Bluff Gameplay"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Bluff11.png"), "caption": "Scoring is complete! Since you scored Lower, you lost 2 HP because of the raised stakes. The game continues until one player runs out of health!", "title": "4: Bluff Gameplay"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Bluff12.png"), "caption": "Your opponent meanwhile scored higher this round. Since the stakes were raised, the player lost 2 HP. The game continues until one player runs out of health.", "title": "4: Bluff Gameplay"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Blitz.png"), "caption": "The Blitz game mode is essentially the same as the Bluff game mode, the key difference being the shorter, unadjustible timer for a more quicker and faster paced game. \n To Play in Blitz mode, refer to the previous chapter, the Bluff Gameplay guide", "title": "5: Blitz gameplay"},
	{"image": preload("res://Assets/2D Assets/TutorialImages/Standard1.png"), "caption": "Placeholder", "title": "6: Gameplay Customization options"}
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
	title_label.text = tutorial_slides[current_slide_index]["title"]
	
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
