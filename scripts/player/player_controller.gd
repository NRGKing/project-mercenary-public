extends CharacterBody3D

@onready var char_handler = $CharacterHandler
@onready var input_handler:InputHandler = InputHandler.new()
@onready var attack_handler = $AttackHandler


# States enum
@onready var states = {
	"normal" : $Movement,
	"menu" : null,
	"cutscene" : null,
	"dead" : null,
	"space" : $SpaceMvmt,
}

# States
var curr_state = "normal"
var next_state = "normal"
var prev_state = "normal"

# Run once at start of program
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Captures unhandled input
func _unhandled_input(event):
	if event.is_action_pressed("exit"):
		get_tree().quit()

func _input(InputEvent):
	if Input.is_action_just_pressed("interact"):
		next_state = "space"

func gather_input() -> InputPackage:
	return input_handler.get_input()

func send_attack(hit_data:HitData):
	char_handler.send_attack(hit_data)

# Run when physics is updated
func _physics_process(delta):
	
	var input:InputPackage = gather_input()
	
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
		
		## Update health bar
		char_handler.update_gui()
		
		## Attack Handling
		attack_handler.process(delta, input)
