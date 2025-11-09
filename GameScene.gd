extends Node

const SAVE_PATH = "user://uiy_topia.save"

@onready var cutscene = $Hatching
@onready var pet = $PetSprite

func _ready():
	var is_first_time = not FileAccess.file_exists(SAVE_PATH)
	_on_cutscene_finished()
	#if is_first_time:
		#print("🐣 First time playing — show hatching cutscene!")
		#pet.visible = false
		#play_hatching_cutscene()
	#else:
		#print("➡️ Save found — loading game directly.")
		#load_pet_state()

func play_hatching_cutscene():
	# Example: if Cutscene is an AnimationPlayer
	cutscene.play("hatch")

	# Wait for the animation to finish, then call _on_cutscene_finished
	await cutscene.animation_finished
	_on_cutscene_finished()

func _on_cutscene_finished():
	# After the egg hatches
	pet.visible = true
	pet.play("idle")
	save_game()

func load_pet_state():
	# Here you’d read from your save file and update the pet
	pet.visible = true
	pet.texture = load("res://assets/pet_level1.png") # placeholder

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_line("pet_level=1")
	file.close()
