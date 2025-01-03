extends CharacterBody3D
class_name CharacterController

@export var char_handler:CharacterModel
@export var input_handler:NpcInputHandler
@export var attack_handler:AttackHandler
@export var can_attack:bool = true

# States enum
@onready var states = {
	"normal" : $MovementHandler,
	"dead" : $DeadHandler,
	"space" : null,
}

# States
var curr_state = "normal"
var next_state = "normal"
var prev_state = "normal"

func gather_input() -> InputPackage:
	return input_handler.generate_input()

func send_attack(hit_data:HitData):
	char_handler.send_attack(hit_data)

func health():
	return char_handler.health
	
func shield():
	return char_handler.shield

func _ready():
	set_physics_process(false)
	await get_tree().physics_frame
	set_physics_process(true)

# Run when physics is updated
func _physics_process(delta):
	
	var input:InputPackage = gather_input()
	
	if health() <= 0:
		next_state = "dead"
	
	prev_state = curr_state
	
	if curr_state != next_state:
		states[curr_state].active = false
	
	curr_state = next_state
	
	if states[curr_state].active == false:
		states[curr_state].active = true
	
	states[curr_state].process(delta, input)
	
	if curr_state == "normal" or curr_state == "space":
		## Health Handling
		char_handler.process(delta)
		
		if can_attack:
			## Attack Handling
			attack_handler.process(delta, input)
