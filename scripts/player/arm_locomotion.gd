extends Node3D

@onready var arm_player := $AnimationPlayer
@onready var left_arm_player = $LeftArm
@onready var weapon_attachment := $weapon_attachment

@export var weapon_out := false

# ==== Prio Chart for Arms ====
# lower = higher priority
# 0 - Combat Active Actions
#	(parry, block, shoot, reload, etc)
# 1 - Combat Passive Actions
#	(holding out gun)
# 2 - Movement Active Actions
#	(Slide, Dash)
# 3 - Movement Passive Actions
#	(Idle, Walk, Sprint)
# ==== End ====

var idles = ["out_idle_pistol", "idle"]

var left_arm = ["parry"]

var curr_idle := "idle"
var curr_idle_prio := 3

var curr_anim := "none"
var next_anim := "idle"
var prev_anim := curr_anim

var curr_prio := 10
var next_prio := 3

var anim_changed := false

func has_animation(anim_name:String):
	return arm_player.has_animation(anim_name)

func queue_animation(anim_name, prio):
	#print("has anim: ", has_animation(anim_name))
	if has_animation(anim_name) and prio <= curr_prio:
		next_anim = anim_name
		next_prio = prio
		#print("queue anim")
		anim_changed = true

func change_idle(idle_name, idle_prio):
	#if has_animation(idle_name) and idle_prio <= curr_idle_prio:
	curr_idle = idle_name
	#print(curr_idle)
	curr_idle_prio = idle_prio

func anim_length(anim_name):
	if arm_player.has_animation(anim_name):
		return arm_player.get_animation(anim_name).get_length()
	else:
		return 0

func process(delta):
	if next_prio <= curr_prio and (next_anim != curr_anim or anim_changed)and arm_player.has_animation(next_anim):
		if next_anim in left_arm:
			left_arm_player.stop(0)
			left_arm_player.play(next_anim)
		else:
			arm_player.stop()
			arm_player.play(next_anim)
		
		prev_anim = curr_anim
		
		curr_anim = next_anim
		curr_prio = next_prio
		
		anim_changed = false
	
	if curr_anim in idles and curr_anim != curr_idle:
		next_anim = curr_idle
	
	if not arm_player.is_playing():
		next_anim = curr_idle
		next_prio = curr_idle_prio
		curr_prio = curr_idle_prio
