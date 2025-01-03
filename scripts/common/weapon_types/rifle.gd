extends WeaponType

#RIFLE

@export var attack_handler : Node
@onready var player : CharacterBody3D = attack_handler.player
@onready var camera : Camera3D = attack_handler.camera_3d

# TODO: Add basic functions that will be needed here

func attack(weapon:Weapon):
	var hit_data = HitData.blank()
	hit_data.dmg.pierce = weapon.health_damage
	hit_data.dmg.shield = weapon.shield_damage
	hit_data.is_parryable = true
	hit_data.weapon = weapon
	
	# Send out one raycast per shot
	# Deal damage where raycast hits
	# Visual where raycast hits
	for n in weapon.shot_amount:
		var result = camera.get_camera_collision_angle(weapon.attack_dist, weapon.spread)
		var intersection = result[0]
		if intersection and intersection.collider and intersection.collider != player:
			if intersection.collider.has_method("send_attack"):
				intersection.collider.send_attack(hit_data)
			



