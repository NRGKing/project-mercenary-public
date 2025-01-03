extends Node

@export var char_model:CharacterModel
@export var attack_handler:Node
@export var arms:Node3D

const MAX_PARRY_TIME = 0.2
var curr_parry_time := 0.0

var last_parry:float = Time.get_ticks_msec() # in ms
const PARRY_CD = 500 # in ms

func begin():
	char_model.start_parry()
	arms.queue_animation("parry", 0)
	curr_parry_time = MAX_PARRY_TIME

func end():
	char_model.end_parry()

func process(delta:float):
	#print(curr_parry_time, " parry")
	curr_parry_time -= delta
	if curr_parry_time <= 0 or char_model.is_parrying == false:
		curr_parry_time = 0
		attack_handler.next_state = "none"

func check_valid() -> bool:
	if Time.get_ticks_msec() - last_parry > PARRY_CD:
		return true
	else:
		return false
