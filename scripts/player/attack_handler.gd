extends Node

@onready var player := $".."
@onready var camera_3d := $"../body/neck/head/eyes/Camera3D"
@onready var crosshair := $"../body/neck/head/eyes/Camera3D/UI/CenterContainer"

var iframe := false

@onready var weapon_types := {
	"katana" : $"../WeaponTypes/Katana",
	"longsword" : $"../WeaponTypes/Longsword",
	"pistol" : $"../WeaponTypes/Pistol",
	#"rifle" : $"../WeaponTypes/Rifle",
	#"shotgun" : $"../WeaponTypes/Shotgun",
}

@onready var equipped_weapons := {
	"primary_weapon" : load("res://scripts/common/weapons/base_sword.tres"),
	#"secondary_weapon" : load("res://scripts/common/weapons/energy_pistol.tres"),
	"secondary_weapon" : load("res://scripts/common/weapons/energy_pistol.tres"),
	"last_equip" : load("res://scripts/common/weapons/base_sword.tres")
}

@onready var curr_weapon:Weapon = null
@onready var next_weapon:Weapon = equipped_weapons["primary_weapon"]
var curr_weapon_scene:Node3D

@onready var attack_states := {
	"attack" : $Attack,
	"reload" : null,
	"quick_action" : null,
	"none" : $None,
	"parry" : $Parry,
	"execute" : null,
	"switch" : $Switch
}

var curr_state := "none"
var next_state := "none"
var prev_state := "none"

var weapon_drawn:bool = false

var combo:int = 0

func process(delta:float, input:InputPackage):
	# Idle -> Parry
	if input.combat_actions.has("parry") and curr_state == "none" and weapon_drawn:
		next_state = "parry"
	# Idle -> Shoot
	elif input.combat_actions.has("attack") and weapon_drawn and (curr_state == "attack" or curr_state == "none"):
		next_state = "attack"
	# Idle -> Switch/Draw
	elif input.combat_actions.has("toggle_weapon") or input.combat_actions.has("primary_weapon") or input.combat_actions.has("secondary_weapon"):
		#print("transition, curr state: %s" % curr_state)
		if Time.get_ticks_msec() - attack_states["attack"].last_shot > 500: 
			next_state = "switch"
		
	if attack_states[next_state].check_valid():
		prev_state = curr_state
		curr_state = next_state
		# Update state variables
		if curr_state != prev_state:
			#print("Player moved from state %s to %s" % [curr_state, prev_state])
			attack_states[prev_state].end()
			attack_states[curr_state].begin()
		
		curr_weapon = next_weapon
		
		attack_states[curr_state].process(delta)
