extends Node

var active : bool = false

# Player nodes
@onready var body = $"../body"
@onready var neck = $"../body/neck"
@onready var head = $"../body/neck/head"
@onready var eyes = $"../body/neck/head/eyes"

@onready var animation_player = $"../body/neck/head/eyes/AnimationPlayer"
@onready var standing_collision_shape = $"../standing_collision_shape"
@onready var crouch_collision_shape = $"../crouch_collision_shape"
@onready var camera_3d = $"../body/neck/head/eyes/Camera3D"
@onready var head_collision = $"../head_collision"

@onready var player = $"../"

@onready var input_handler = InputHandler.new()


# Can only be doing one of these at a time
@onready var movements = {
	"fly" : $Fly,
	"idle" :$Idle,
}

var curr_mvmt = "idle"
var prev_mvmt = "idle"
var next_mvmt = "idle"

# Define tuning values
var mouse_sensitivity : float = 0.25
const LERP_SPEED = 10.0
const DIR_LERP_SPEED = 3.5
const INERTIA_LOSS = 0.005

# Movement vars
var direction:Vector3 = Vector3.ZERO
var current_speed:float = 5.0
var last_velocity:Vector3 = Vector3.ZERO

# Captures Inputs
func _input(event): 
	if event is InputEventMouseMotion and active:
		# Head first movement
		# BUG: Issue with r/l when upside down
		player.rotate_y(deg_to_rad(-1 * event.relative.x * mouse_sensitivity)) # handle the left/right rotation of player body
		head.rotate_x(deg_to_rad(-1 * event.relative.y * mouse_sensitivity)) # handle the up/down rotation of player body
	
func process(delta:float, input:InputPackage):
	# Getting movement input
	var input_dir:Vector3 = input.input_dir.normalized()
	
	# ==== MOVEMENT STATE MACHINE ====
	# TODO: add state transitions and stuff here
	if input_dir == Vector3.ZERO:
		next_mvmt = "idle"
	else:
		next_mvmt = "fly"
	# ==== END STATE MACHINE ====
	
	# Update state variables
	if curr_mvmt != next_mvmt:
		#print("Player moved from state %s to %s" % [curr_mvmt, next_mvmt])
		movements[curr_mvmt].end()
		movements[next_mvmt].begin()
	
	prev_mvmt = curr_mvmt
	curr_mvmt = next_mvmt
	
	movements[curr_mvmt].process(delta)
	
	# Apply character control to direction
	direction = lerp(direction,(camera_3d.get_global_transform().basis * input_dir).normalized(),delta*LERP_SPEED)
	
	# Get direction and speed relative to current state
	direction = movements[curr_mvmt].get_direction(direction)
	current_speed = movements[curr_mvmt].get_speed(current_speed, delta)
	
	# If player is entering input
	if input_dir != Vector3.ZERO:
		player.velocity.x = direction.x * current_speed
		player.velocity.y = direction.y * current_speed
		player.velocity.z = direction.z * current_speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, current_speed*INERTIA_LOSS)
		player.velocity.y = move_toward(player.velocity.y, 0, current_speed*INERTIA_LOSS)
		player.velocity.z = move_toward(player.velocity.z, 0, current_speed*INERTIA_LOSS)

	last_velocity = player.velocity
	
	# TODO: 3d mvmt is working, but little shake at the end
	
	player.move_and_slide()
