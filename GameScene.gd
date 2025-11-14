extends Node

const SAVE_PATH = "user://uiy_topia.save"

@onready var cutscene = $CutscenePlayer
@onready var pet = $PetSprite              # Sprite2D
@onready var anim_player = $AnimPlayer   # AnimationPlayer

@onready var hunger_bar = $UI/HungerBar
@onready var sleep_bar = $UI/SleepBar
@onready var fade_rect = $FadeRect

var hunger: float = 100.0
var sleepiness: float = 100.0


func _ready():
	var is_first_time = not FileAccess.file_exists(SAVE_PATH)
	
	if is_first_time:
		pet.visible = false
		play_hatching_cutscene()
	else:
		cutscene.visible = false
		load_pet_state()


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
	hunger -= delta * 0.5
	sleepiness -= delta * 0.3

	hunger = clamp(hunger, 0, 100)
	sleepiness = clamp(sleepiness, 0, 100)

	hunger_bar.value = hunger
	sleep_bar.value = sleepiness

	# Auto animations depending on status
	if hunger < 20:
		anim_player.play("Sad")
		pet.play()
	elif sleepiness < 20:
		anim_player.play("Sleep")
		pet.play()
	else:
		# only play idle if not currently eating or no
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
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_line("%s,%s" % [hunger, sleepiness])
	file.close()


# -------------------------------
# FOOD BUTTON
# -------------------------------
func _on_texture_button_pressed() -> void:
	if hunger >= 90:
		# play "No"
		anim_player.play("No")
		pet.play()
		await anim_player.animation_finished
		anim_player.play("Idle")
		pet.play()
	else:
		# play eating
		anim_player.play("Eating")
		pet.play()
		await anim_player.animation_finished

		hunger = min(hunger + 20, 100)
		hunger_bar.value = hunger

		anim_player.play("Idle")
		pet.play()
