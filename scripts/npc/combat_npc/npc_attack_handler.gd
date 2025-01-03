extends Node
class_name AttackHandler

@export var player : CharacterController
@export var camera_3d : Camera3D

@export var weapon_type:WeaponType
@export var equipped_weapon:Weapon

@onready var crosshair = null

@onready var weapon_types := {
	"katana" : $"../WeaponTypes/Katana",
	"longsword" : $"../WeaponTypes/Longsword",
	"pistol" : $"../WeaponTypes/Pistol",
	"rifle" : $"../WeaponTypes/Rifle",
	"shotgun" : $"../WeaponTypes/Shotgun",
}

@onready var attack_states := {
	"attack" : $Attack,
	"reload" : null,
	"quick_action" : null,
	"none" : $None,
	"parry" : $Parry
}

@onready var equipped_weapons := {
	"primary" : load("res://scripts/common/weapons/energy_pistol.tres"),
	"secondary" : null
}

@onready var last_equipped:String = "primary"
@onready var curr_weapon:Weapon = equipped_weapons[last_equipped]
@onready var next_weapon:Weapon = equipped_weapons[last_equipped]
@export var curr_weapon_scene:Node3D

var curr_state := "none"
var next_state := "none"
var prev_state := "none"

var weapon_drawn:bool = true # false

var combo:int = 2

func process(delta:float, input:InputPackage):
	# Idle -> Parry
	if input.combat_actions.has("parry") and curr_state == "none":
		next_state = "parry"
	# Idle -> Shoot
	elif input.combat_actions.has("attack") and weapon_drawn and (curr_state == "attack" or curr_state == "none"):
		next_state = "attack"
	# Idle -> Switch/Draw
	elif input.combat_actions.has("toggle_weapon"):
		#print("transition, curr state: %s" % curr_state)
		next_state = "switch"
	
	if attack_states[next_state] == null:
		return
	
	if attack_states[next_state].check_valid():
		# Update state variables
		if curr_state != next_state:
			#print("Player moved from state %s to %s" % [curr_state, next_state])
			attack_states[curr_state].end()
			attack_states[next_state].begin()
		
		attack_states[next_state].process(delta)
		
		prev_state = curr_state
		curr_state = next_state
