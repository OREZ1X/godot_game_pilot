# Pet.gd
extends Area2D

# --- STATS ---
# Use @export_group for organization in the Inspector
@export_group("Pet Stats")
var hungry: float = 100.0 # 0 (starving) to 100 (full)
var happiness: float = 100.0 # 0 (sad) to 100 (joyful)
var energy: float = 100.0 # 0 (asleep) to 100 (awake)
var experience: int = 0
var level: int = 1

# --- EVOLUTION TRACKING ---
@export_group("Evolution Trackers")
var food_type_a_count: int = 0
var food_type_b_count: int = 0
var food_type_c_count: int = 0

# --- CONSTANTS ---
const LEVEL_2_XP: int = 100
const LEVEL_3_XP: int = 200
const DECAY_RATE_HUNGER: float = 0.5 # Per second
const DECAY_RATE_HAPPINESS: float = 0.3
const DECAY_RATE_ENERGY: float = 0.4

func _process(delta: float) -> void:
	# Decrease stats over time
	hungry = max(0, hungry - DECAY_RATE_HUNGER * delta)
	happiness = max(0, happiness - DECAY_RATE_HAPPINESS * delta)
	energy = max(0, energy - DECAY_RATE_ENERGY * delta)
	
	# You may want to emit a signal here to tell the UI to update
	# emit_signal("stats_updated")
	
	check_death()

func check_death():
	# Example: If pet is fully hungry and unhappy, it passes away
	if hungry <= 0 and happiness <= 10:
		print("Pet has passed away.")
		get_tree().quit() # For now, just exit the game
		
func feed(food_type: String) -> void:
	# 1. Increase Stats
	hungry = min(100, hungry + 30)
	experience += 10 
	
	# 2. Track Food Type for Evolution
	match food_type:
		"A":
			food_type_a_count += 1
		"B":
			food_type_b_count += 1
		"C":
			food_type_c_count += 1
			
	# 3. Check for Level Up/Evolution
	check_evolution()

func check_evolution() -> void:
	if level == 1 and experience >= LEVEL_2_XP:
		level = 2
		print("Pet has leveled up to Level 2!")
		# TODO: Change pet's sprite/animation here

	elif level == 2 and experience >= LEVEL_3_XP:
		level = 3
		
		# Determine final evolution based on most-fed food type
		var counts = {
			"A": food_type_a_count,
			"B": food_type_b_count,
			"C": food_type_c_count
		}
		
		var max_count = -1
		var final_evolution_type = "C" # Default to C if all are 0 or tied
		
		# Simple check for the maximum count
		if counts.A > max_count:
			max_count = counts.A
			final_evolution_type = "A"
		if counts.B > max_count:
			max_count = counts.B
			final_evolution_type = "B"
		if counts.C > max_count:
			max_count = counts.C
			final_evolution_type = "C"
			
		print("Pet has achieved Level 3! Final Evolution Type: ", final_evolution_type)
		# TODO: Change pet's sprite/animation to the final form
		
# Pet.gd (Add this function)

func get_save_data() -> Dictionary:
	return {
		"hungry": hungry,
		"happiness": happiness,
		"energy": energy,
		"experience": experience,
		"level": level,
		"food_a": food_type_a_count,
		"food_b": food_type_b_count,
		"food_c": food_type_c_count
		# Add any other variables you want to save
	}

func apply_load_data(data: Dictionary) -> void:
	hungry = data.get("hungry", 100.0) # 100.0 is the default if the key is missing
	happiness = data.get("happiness", 100.0)
	energy = data.get("energy", 100.0)
	experience = data.get("experience", 0)
	level = data.get("level", 1)
	food_type_a_count = data.get("food_a", 0)
	food_type_b_count = data.get("food_b", 0)
	food_type_c_count = data.get("food_c", 0)
	
	# After loading, immediately check evolution status
	check_evolution()
