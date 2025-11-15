# SaveManager.gd (Autoload)
extends Node

const SAVE_PATH := "user://uiy_topia.save"

# Decay per second (adjust as needed)
const DECAY_HUNGER := 0.5        # lose 0.5 per second
const DECAY_SLEEPINESS := 0.3    # lose 0.3 per second


# -------------------------------------
# SAVE
# -------------------------------------
func save_game(pet_data: Dictionary) -> void:
	pet_data["last_save_time"] = Time.get_unix_time_from_system()

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(pet_data)
		print("💾 Game Saved!")
	else:
		printerr("❌ Failed to save:", SAVE_PATH)


# -------------------------------------
# LOAD
# -------------------------------------
func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		print("⚠ No save file found — first time playing.")
		return get_default_data()

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		printerr("❌ Save file exists but cannot be opened.")
		return get_default_data()

	var pet_data = file.get_var()

	# If corrupted or empty → return defaults
	if typeof(pet_data) != TYPE_DICTIONARY:
		printerr("❌ Save corrupted — using defaults.")
		return get_default_data()

	# Guarantee required keys exist
	if not pet_data.has("hunger"): pet_data["hunger"] = 100.0
	if not pet_data.has("sleepiness"): pet_data["sleepiness"] = 100.0
	if not pet_data.has("last_save_time"):
		pet_data["last_save_time"] = Time.get_unix_time_from_system()
		return pet_data   # first load → no decay yet

	# -------------------------------------
	# OFFLINE DECAY
	# -------------------------------------
	var last_time: int = pet_data["last_save_time"]
	var now := Time.get_unix_time_from_system()
	var offline_seconds := float(now - last_time)

	# Reduce values (offline Tamagotchi effect)
	pet_data["hunger"] = max(0.0, pet_data["hunger"] - DECAY_HUNGER * offline_seconds)
	pet_data["sleepiness"] = max(0.0, pet_data["sleepiness"] - DECAY_SLEEPINESS * offline_seconds)

	print("⏱ Loaded save. Offline:", offline_seconds, "seconds")

	return pet_data


# -------------------------------------
# Default dictionary
# -------------------------------------
func get_default_data() -> Dictionary:
	return {
		"hunger": 100.0,
		"sleepiness": 100.0,
		"last_save_time": Time.get_unix_time_from_system()
	}
