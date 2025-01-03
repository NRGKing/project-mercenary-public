extends Node
class_name CharacterModel

# Player variables
@onready var health := 20.0
@onready var shield := 100.0

@onready var is_parrying:bool = false
@onready var is_vulnerable:bool = true

@export var MAX_HEALTH := 20.0
@export var MAX_SHIELD := 100.0

# Regen rates per second
@export var HEALTH_REGEN_RATE := 0.0
@export var SHIELD_REGEN_RATE := 0.6

@onready var incoming_dmg = {
	"shield" : 0.0,
	"pierce" : 0.0,
	"environmental" : 0.0,
}

func start_parry():
	is_parrying = true

func end_parry():
	is_parrying = false

func set_vulnerable(val:bool):
	is_vulnerable = val

# Update regen rates
func regen(delta:float):
	health += HEALTH_REGEN_RATE * delta
	shield += SHIELD_REGEN_RATE * delta
	health = clamp(health, 0, MAX_HEALTH)
	shield = clamp(shield, 0, MAX_SHIELD)
	
func send_attack(hit_data:HitData):
	#print(is_parrying)
	if (!is_parrying or !hit_data.is_parryable) and is_vulnerable:
		for dmg_type in hit_data.dmg:
			if incoming_dmg[dmg_type] or incoming_dmg[dmg_type] == 0.0:
				incoming_dmg[dmg_type] += hit_data.dmg[dmg_type]
			#print(dmg_type, " ", incoming_dmg[dmg_type])
		# TODO: Slash Visuals
	else:
		if is_parrying:
			# TODO: Parry visuals
			# TODO: Send back parry for reaction
			print("attack parried")
			pass
		else:
			pass

# Register damage with an incoming damage dictionary
func register_dmg(dmg:Dictionary):
	# Subtract shield damage from shield
	shield -= dmg.shield

	# Add overflow to pierce damage
	dmg.pierce += abs(min(shield, 0))
	shield = max(shield,0)
	
	if shield == 0:
		# Apply health damage
		health -= max(dmg.pierce,0)

func process(delta:float):
	register_dmg(incoming_dmg)
	for key in incoming_dmg:
		incoming_dmg[key] = 0.0
	regen(delta)
