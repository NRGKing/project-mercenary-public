extends WeaponType

@export var attack_handler : Node
@export var bullet_particles : Node3D
@onready var player : CharacterBody3D = attack_handler.player
@onready var camera : Camera3D = attack_handler.camera_3d

func attack(weapon:Weapon):
	var hit_data := HitData.blank()
	hit_data.dmg.pierce = weapon.health_damage
	hit_data.dmg.shield = weapon.shield_damage
	hit_data.is_parryable = true
	hit_data.weapon = weapon
	
	var start_position = attack_handler.curr_weapon_scene.global_transform.origin
		
	if attack_handler.curr_weapon_scene.get_node("Muzzle"):
		start_position = attack_handler.curr_weapon_scene.get_node("Muzzle").global_transform.origin
		
	var hit_positions:PackedVector3Array = []
	
	# Send out one raycast per shot
	# Deal damage where raycast hits
	# Visual where raycast hits
	for n in weapon.shot_amount:
		var result = camera.get_camera_collision_angle(weapon.attack_dist, weapon.spread)
		var intersection = result[0]
		hit_positions.append(result[1])
		if intersection and intersection.collider and intersection.collider != player:
			if intersection.collider.has_method("send_attack"):
				intersection.collider.send_attack(hit_data)
		
		var box: MeshInstance3D
		# Create a MeshInstance3D dynamically
		box = MeshInstance3D.new()
		var box_mesh = BoxMesh.new()
		box_mesh.size = Vector3(0.5,0.5,0.5)
		box.mesh = box_mesh
		add_child(box)  # Add the box to the current node
		box.global_position = result[1]  # Initial position
		
		
		# Visual
		#bullet_tracer.create_tracer(start_position, result[1])
		bullet_particles.fire_trail(start_position, result[1])
	
	return hit_positions
