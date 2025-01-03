extends Node

@export var attack_handler:Node
@export var hand_attachment:BoneAttachment3D
@export var arms:Node3D
@export var body:Node3D
@export var head:Node3D
@export var movement:Node

var last_switch:float = Time.get_ticks_msec() # in ms
const SWITCH_CD = 500 # in ms

func begin():
	var to_equip = ""
	if Input.is_action_just_pressed("primary_weapon"):
		to_equip = "primary_weapon"
	elif Input.is_action_just_pressed("secondary_weapon"):
		to_equip = "secondary_weapon"
	else:
		to_equip = "last_equip"
	
	last_switch = Time.get_ticks_msec() 
	if attack_handler.curr_weapon_scene == null:
		#print("null -> equip")
		attack_handler.next_weapon = attack_handler.equipped_weapons[to_equip]
		attack_handler.curr_weapon = attack_handler.next_weapon
		attack_handler.weapon_drawn = true
		render(attack_handler.curr_weapon)
		# Crosshair handling
		attack_handler.crosshair.change_crosshair(
			1,
			clamp(tan(deg_to_rad(attack_handler.curr_weapon.spread)) * attack_handler.curr_weapon.attack_dist,8,30),
			8, Color.WHITE
		)
	elif attack_handler.curr_weapon != attack_handler.equipped_weapons[to_equip] and to_equip != "last_equip":
		#print("switch between two wpn")
		unrender()
		attack_handler.next_weapon = attack_handler.equipped_weapons[to_equip]
		attack_handler.curr_weapon = attack_handler.next_weapon
		attack_handler.weapon_drawn = true
		render(attack_handler.curr_weapon)
		# Crosshair handling
		attack_handler.crosshair.change_crosshair(
			1,
			clamp(tan(deg_to_rad(attack_handler.curr_weapon.spread)) * attack_handler.curr_weapon.attack_dist,8,30),
			8, Color.WHITE
		)
	else:
		#print("unequip any")
		unrender()
		attack_handler.equipped_weapons["last_equip"] = attack_handler.curr_weapon
		attack_handler.next_weapon = null
		attack_handler.curr_weapon = attack_handler.next_weapon
		attack_handler.weapon_drawn = false
		# Crosshair handling
		attack_handler.crosshair.change_crosshair(1, 5, 5, Color(Color.DIM_GRAY, 0.25))

func end():
	pass

func process(_delta:float):
	if (arms and (arms.curr_anim != "draw" or arms.curr_anim != "sheathe")) or attack_handler.curr_weapon_scene == null:
		attack_handler.next_state = "none"

func check_valid() -> bool:
	if Time.get_ticks_msec() - last_switch > SWITCH_CD:
		return true
	else:
		return false

func render(weapon:Weapon):
	if arms:
		arms.weapon_out = true
		arms.queue_animation("draw", 0)
		arms.change_idle("out_idle_" + str(attack_handler.curr_weapon.type), 1)
		movement.rotate_player(0,0)
	attack_handler.curr_weapon_scene = weapon.scene.instantiate()
	## New - Just weapon attaching to hand attachment
	hand_attachment.add_child(attack_handler.curr_weapon_scene, true)
	attack_handler.curr_weapon_scene.position = weapon.camera_position
	attack_handler.curr_weapon_scene.rotation = Vector3(deg_to_rad(weapon.camera_rotation.x), 
	deg_to_rad(weapon.camera_rotation.y), deg_to_rad(weapon.camera_rotation.z))
	attack_handler.curr_weapon_scene.scale = weapon.camera_scale

func unrender():
	## New - wpn attachment
	#print("unrender")
	if arms:
		arms.weapon_out = false
		arms.queue_animation("sheathe", 0)
		arms.change_idle("idle", 3)
	#await get_tree().create_timer(min(arms.anim_length("sheathe"), 0.5)).timeout
	if arms:
		movement.rotate_player(0,0)
	attack_handler.curr_weapon_scene.free()
	attack_handler.curr_weapon_scene = null
