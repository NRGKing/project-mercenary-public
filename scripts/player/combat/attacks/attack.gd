extends Node

@export var attack_handler:Node
@export var arms:Node3D

@onready var curr_anim_player:AnimationPlayer = null

var last_shot:float = Time.get_ticks_msec()

func begin():
	#print("atk start")
	# Make sure allowed to shoot
	last_shot = Time.get_ticks_msec()
	# Pass handling to weapon class
	var hit_positions = attack_handler.weapon_types[attack_handler.curr_weapon.type].attack(attack_handler.curr_weapon)
	# Play animation
	if attack_handler.curr_weapon_scene:
		if arms:
			if attack_handler.weapon_types[attack_handler.curr_weapon.type].uses_combo == true:
				arms.queue_animation("shoot" + str(attack_handler.combo) + str(attack_handler.curr_weapon.type), 0)
				#print("shoot" + str(attack_handler.combo) + str(attack_handler.curr_weapon.type))
			else:
				arms.queue_animation("shoot" + str(attack_handler.curr_weapon.type), 0)
				#print("shoot" + str(attack_handler.curr_weapon.type))
		# BUG: sound ends when switch wpn
		# Commented for now just to focus on refactor
		#if attack_handler.curr_weapon_scene.get_node("Root_Node").has_node("FxPlayer"):
			#var fx_player = attack_handler.curr_weapon_scene.get_node("Root_Node").get_node("FxPlayer")
			#fx_player.stop(true)
			#fx_player.play("shoot")
		#if attack_handler.curr_weapon_scene.get_node("Root_Node").has_node("BulletParticle"):
			#var bullet_particle:GPUParticles3D = attack_handler.curr_weapon_scene.get_node("Root_Node").get_node("BulletParticle")
			## BUG: Not working
			#for position:Vector3 in hit_positions:
				#bullet_particle.emit_particle(
					#bullet_particle.transform, 
					#bullet_particle.global_position.direction_to(position) * 1000,
					#attack_handler.curr_weapon.particle_color,
					#attack_handler.curr_weapon.particle_color,
					#4
				#)
	# Crosshair displacement
	if attack_handler.crosshair:
		attack_handler.crosshair.change_crosshair_instant(
			attack_handler.crosshair.dot_radius,
			4*clamp(tan(deg_to_rad(attack_handler.curr_weapon.spread)) * attack_handler.curr_weapon.attack_dist,8,30),
			attack_handler.crosshair.line_dist,
			attack_handler.crosshair.dot_color
		)
	if attack_handler.weapon_types[attack_handler.curr_weapon.type].uses_combo == false or Time.get_ticks_msec() - last_shot > 3*1000/attack_handler.curr_weapon.attack_speed:
		attack_handler.combo = 0
	else:
		attack_handler.combo += 1
		if attack_handler.combo > 2:
			attack_handler.combo = 0

func end():
	pass

func check_valid() -> bool:
	if Time.get_ticks_msec() - last_shot > 1000/attack_handler.curr_weapon.attack_speed:
		#print("valid")
		return true
	else:
		#print("invalid")
		return false

func process(_delta:float):
	if ((arms and not "shoot" in arms.curr_anim or attack_handler.curr_weapon_scene == null 
	or Time.get_ticks_msec() - last_shot > 1000/attack_handler.curr_weapon.attack_speed)):
		attack_handler.next_state = "none"
