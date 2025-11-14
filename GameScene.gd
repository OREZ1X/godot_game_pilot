extends Node

const SAVE_PATH = "user://uiy_topia.save"

@onready var cutscene = $CutscenePlayer
@onready var pet = $PetSprite
@onready var hunger_bar = $UI/HungerBar
@onready var sleep_bar = $UI/SleepBar
@onready var fade_rect = $FadeRect

var hunger: float = 100.0
var sleepiness: float = 100.0

func _ready():
	var is_first_time = not FileAccess.file_exists(SAVE_PATH)
	
	if is_first_time:
		print("🐣 First time playing — show hatching cutscene!")
		pet.visible = false
		play_hatching_cutscene()
	else:
		print("➡️ Save found — loading game directly.")
		cutscene.visible = false
		load_pet_state()

func play_hatching_cutscene():
	# Connect to finished signal before playing
	cutscene.connect("finished", Callable(self, "_on_cutscene_finished"), CONNECT_ONE_SHOT)
	cutscene.play()

func _on_cutscene_finished():
	print("🎬 Cutscene finished — fade out then show pet")
	
	var tween = get_tree().create_tween()
	
	# Step 1: fade to black
	tween.tween_property(fade_rect, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Step 2: after fade complete → hide cutscene, show pet, fade back in
	tween.tween_callback(Callable(self, "_show_pet_after_fade"))
	
	# Step 3: fade from black to transparent again
	tween.tween_property(fade_rect, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
func _show_pet_after_fade():
	cutscene.visible = false
	pet.visible = true
	pet.play("idle")
	save_game()

func _process(delta):
	update_pet_status(delta)
	
func update_pet_status(delta):
	# decrease hunger & sleep gradually over time
	hunger -= delta * 0.5     # about 0.5% per second
	sleepiness -= delta * 0.3 # slower decay for sleep

	hunger = clamp(hunger, 0, 100)
	sleepiness = clamp(sleepiness, 0, 100)

	hunger_bar.value = hunger
	sleep_bar.value = sleepiness

	# Optional: show pet reaction when very low
	if hunger < 20:
		pet.play('sad')
	elif sleepiness < 20:
		pet.play('sad')
	else:
		pet.play('idle')
	
func load_pet_state():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var line = file.get_line()
	file.close()
	var parts = line.split(",")
	if parts.size() == 2:
		hunger = float(parts[0])
		sleepiness = float(parts[1])
	hunger_bar.value = hunger
	sleep_bar.value = sleepiness
	_on_cutscene_finished()
	pet.visible = true

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_line("%s,%s" % [hunger, sleepiness])
	file.close()
