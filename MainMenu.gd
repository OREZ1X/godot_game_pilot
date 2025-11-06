# MainMenu.gd
extends Control

func _ready():
	# Check if a save file exists to enable/disable 'Continue'
	$VBoxContainer/ContinueButton.disabled = not FileAccess.file_exists(SaveManager.SAVE_PATH)

func _on_new_game_button_pressed():
	# Delete old save file to ensure a fresh start
	if FileAccess.file_exists(SaveManager.SAVE_PATH):
		DirAccess.remove_absolute(SaveManager.SAVE_PATH)
	
	# Change scene to the game
	get_tree().change_scene_to_file("res://game_scene.tscn")

func _on_continue_button_pressed():
	# Change scene to the game
	get_tree().change_scene_to_file("res://game_scene.tscn")

func _on_exit_button_pressed():
	get_tree().quit()
