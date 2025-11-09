# MainMenu.gd
extends Control

@onready var start_button = $CanvasLayer/VBoxContainer/StartButton

func _ready():
	# Use for Test First Time Flow
	var path = "user://uiy_topia.save"
	if FileAccess.file_exists(path):
		var dir = DirAccess.open("user://")
		if dir:
			dir.remove("uiy_topia.save")
			print("✅ Save file removed:", path)
	else:
		print("ℹ️ No save file found to remove.")
	# ####################################################################
	
	start_button.pressed.connect(_on_start_button_pressed)
	
func _on_start_button_pressed():
	var has_save = FileAccess.file_exists(SaveManager.SAVE_PATH)

	if has_save:
		# Continue game
		get_tree().change_scene_to_file("res://GameScene.tscn")
	else:
		# Start new game: delete old save (if any, just in case)
		if FileAccess.file_exists(SaveManager.SAVE_PATH):
			DirAccess.remove_absolute(SaveManager.SAVE_PATH)
		
		get_tree().change_scene_to_file("res://GameScene.tscn")

func _on_exit_button_pressed():
	get_tree().quit()
