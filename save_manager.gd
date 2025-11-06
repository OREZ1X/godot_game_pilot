# SaveManager.gd (The Autoload script)
extends Node

const SAVE_PATH: String = "user://uiy_topia.save"

const DECAY_RATE_HUNGER: float = 0.5 # Per second
const DECAY_RATE_HAPPINESS: float = 0.3
const DECAY_RATE_ENERGY: float = 0.4

# --- 1. SAVE FUNCTION ---
func save_game(pet_data: Dictionary) -> void:
	# Add the current time to the dictionary for offline decay calculation
	pet_data["last_save_time"] = Time.get_unix_time_from_system()
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(pet_data)
		print("Game Saved!")
	else:
		printerr("Failed to open file for saving: ", SAVE_PATH)

# --- 2. LOAD FUNCTION ---
func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {} 

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var pet_data: Dictionary = file.get_var()
		
		# CORE TAMAGOTCHI LOGIC: OFFLINE DECAY
		var last_time: int = pet_data.get("last_save_time", Time.get_unix_time_from_system())
		var current_time: int = Time.get_unix_time_from_system()
		var time_elapsed: float = float(current_time - last_time)

		# Apply decay using constants from SaveManager
		pet_data["hungry"] = max(0.0, pet_data.hungry - DECAY_RATE_HUNGER * time_elapsed)
		pet_data["happiness"] = max(0.0, pet_data.happiness - DECAY_RATE_HAPPINESS * time_elapsed)
		pet_data["energy"] = max(0.0, pet_data.energy - DECAY_RATE_ENERGY * time_elapsed)
		
		print("Game Loaded! Time elapsed: %s seconds" % time_elapsed)
		return pet_data
	else:
		printerr("Failed to open file for loading: ", SAVE_PATH)
		return {}
