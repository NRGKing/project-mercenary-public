extends WeaponType

@export var attack_handler : Node
@export var hitbox : Node3D
@onready var player : CharacterBody3D = attack_handler.player
@onready var camera : Camera3D = attack_handler.camera_3d

# TODO: Add basic functions that will be needed here

func attack(weapon:Weapon):
	var hit_data = HitData.blank()
	hit_data.dmg.pierce = weapon.health_damage
	hit_data.dmg.shield = weapon.shield_damage
	hit_data.is_parryable = true
	hit_data.weapon = weapon
	hit_data.ignore_list.append(player)
	
	# Create hitbox in front of player
	# Read current states of objects inside hitbox
	# Pass damage data to handler
	
	# Temp solution for hitbox handling - obj on player
	for body in hitbox.get_overlapping_bodies():
		if hit_data.ignore_list.find(body): # edit back to no !
			if body.has_method("send_attack"):
				body.send_attack(hit_data)
			elif body.has_node("CharacterHandler") and body.get_node("CharacterHandler").has_method("send_attack"):
				body.get_node("CharacterHandler").send_attack(hit_data)
