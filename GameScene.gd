# GameScene.gd
extends Node2D

@onready var pet = $Pet
@onready var hunger_bar = $GameUI/VBoxContainer/HungerHBox/HungerBar
@onready var happiness_bar = $GameUI/VBoxContainer/HappinessHBox/HappinessBar
@onready var energy_bar = $GameUI/VBoxContainer/EnergyHBox/EnergyBar

@onready var level_bar = $GameUI/VBoxContainer2/Experience/ExpBar

func _process(delta: float) -> void:
	# Update UI based on pet's stats every frame
	update_ui()

func update_ui():
	hunger_bar.value = pet.hungry
	happiness_bar.value = pet.happiness
	energy_bar.value = pet.energy
	
	level_bar.value = pet.experience


func _on_feed_a_button_pressed() -> void:
	pet.feed("A")


func _on_feed_b_button_pressed() -> void:
	pet.feed("B")


func _on_feed_c_button_pressed() -> void:
	pet.feed("C")


var game_data: Dictionary = {}

func _ready():
	# Load game data on startup
	game_data = SaveManager.load_game()
	
	if game_data.size() > 0:
		# If data exists (Continue was pressed)
		pet.apply_load_data(game_data)
		print("Game Data Applied.")
	# Else: (New Game) Pet starts with default values (100)
	
	# Ensure UI is updated
	update_ui()


# Save when the game is about to close
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		var data_to_save = pet.get_save_data()
		SaveManager.save_game(data_to_save)
		get_tree().quit()
