extends Node

const SAVE_PATH = "user://uiy_topia.save"

@onready var cutscene = $CutscenePlayer
@onready var pet = $PetSprite              # Sprite2D
@onready var anim_player = $AnimPlayer   # AnimationPlayer

@onready var hunger_bar = $UI/HungerBar
@onready var sleep_bar = $UI/SleepBar
@onready var fade_rect = $FadeRect

@onready var food_button = $UI/TextureButton

var hunger: float = 100.0
var sleepiness: float = 100.0

var is_sleeping = false


func _ready():
	# First time? No save file → play egg hatching
	var save_data = SaveManager.load_game()

	if save_data.is_empty():
		pet.visible = false
		play_hatching_cutscene()
	else:
		apply_loaded_state(save_data)
		
	#food_button.pressed.connect(_on_texture_button_pressed)


# -------------------------------
# CUTSCENE
# -------------------------------
func play_hatching_cutscene():
	cutscene.connect("finished", Callable(self, "_on_cutscene_finished"), CONNECT_ONE_SHOT)
	cutscene.play()


func _on_cutscene_finished():
	var tween = get_tree().create_tween()

	# Fade to black
	tween.tween_property(fade_rect, "modulate:a", 1.0, 1.0)

	# After fade → show pet → fade back
	tween.tween_callback(Callable(self, "_show_pet_after_fade"))

	# Fade from black to visible
	tween.tween_property(fade_rect, "modulate:a", 0.0, 1.0)


func _show_pet_after_fade():
	cutscene.visible = false
	pet.visible = true
	anim_player.play("Idle")
	pet.play()
	save_game()


# -------------------------------
# PET STATUS LOGIC
# -------------------------------
func _process(delta):
	update_pet_status(delta)

func update_pet_status(delta):

	# ------------------------------------
	# AUTO SLEEP MODE
	# ------------------------------------
	if is_sleeping:
		# Regenerate sleepiness (e.g. +5 per second)
		sleepiness += delta * 5
		sleepiness = clamp(sleepiness, 0, 100)
		sleep_bar.value = sleepiness

		# Play sleep animation (if not already)
		if anim_player.current_animation != "Sleep":
			anim_player.play("Sleep")
			pet.play()

		# When fully rested → wake up
		if sleepiness >= 100:
			is_sleeping = false
			anim_player.play("Idle")
			pet.play()
		return   # VERY IMPORTANT → stop other logic!


	# ------------------------------------
	# NORMAL MODE (only when not sleeping)
	# ------------------------------------
	hunger -= delta * 0.5
	sleepiness -= delta * 0.3

	hunger = clamp(hunger, 0, 100)
	sleepiness = clamp(sleepiness, 0, 100)

	hunger_bar.value = hunger
	sleep_bar.value = sleepiness

	# Enter auto sleep
	if sleepiness <= 20:
		is_sleeping = true
		return

	# Normal animation logic
	if hunger < 20:
		anim_player.play("Sad")
		pet.play()
	else:
		# if not currently eating or special anim, use idle
		if not anim_player.is_playing() or anim_player.current_animation in ["Sad","Sleep"]:
			anim_player.play("Idle")
			pet.play()


# -------------------------------
# SAVE / LOAD
# -------------------------------
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
	
	# show pet immediately when load game
	pet.visible = true
	anim_player.play("Idle")
	pet.play()


func save_game():
	var data = {
		"hunger": hunger,
		"sleepiness": sleepiness,
	}

	SaveManager.save_game(data)
	
func apply_loaded_state(data: Dictionary):
	hunger = data.get("hunger", 100.0)
	sleepiness = data.get("sleepiness", 100.0)

	hunger_bar.value = hunger
	sleep_bar.value = sleepiness

	cutscene.visible = false
	pet.visible = true
	
	_on_cutscene_finished();

	anim_player.play("Idle")
	pet.play()

# -------------------------------
# FOOD BUTTON
# -------------------------------
func _on_texture_button_pressed() -> void:
	if hunger >= 90:
		anim_player.play("No")
		pet.play()
		await anim_player.animation_finished
		anim_player.play("Idle")
		pet.play()
	else:
		anim_player.play("Eating")
		pet.play()
		await anim_player.animation_finished
		hunger += 20
		hunger = clamp(hunger, 0, 100)
		hunger_bar.value = hunger
		
		anim_player.play("Idle")
		pet.play()

	save_game()
