extends Node

var active : bool = false

# Player nodes
@export_category("Character Objects")
@export var standing_collision_shape:CollisionShape3D
@export var crouch_collision_shape:CollisionShape3D
@export var head_collision:RayCast3D
@export var character:CharacterController
@export var head:Node3D

@export_category("Movement Constants")
@export var turn_speed:float

# Can only be doing one of these at a time
@onready var movements = {
	"walk" : $Walk,
	#"sprint" : $Sprint,
	#"crouch" : $Crouch,
	"idle" : $Idle,
}

var curr_mvmt = "idle"
var prev_mvmt = "idle"
var next_mvmt = "idle"

# Define tuning values
var mouse_sensitivity : float = 0.25
const LERP_SPEED = 10.0
const AIR_LERP_SPEED = 3.0
const CROUCHING_DEPTH = -0.6

# Double jump vars
var dj_used = false

# Cooldowns
var slide_cd_curr = 0.0
var dash_cd_curr = 0.0
const SLIDE_CD_MAX = 3.0
const DASH_CD_MAX = 1.0

# Freelooking
var freelooking : bool = false

# Head bobbing vars
var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0
var head_bobbing_current_intensity = 0.0

# Movement vars
var direction = Vector3.ZERO
var current_speed = 6.0
var last_velocity = Vector3.ZERO
const JUMP_VELOCITY = 5.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func process(delta:float, input:InputPackage):
	# TODO: let character walk up stairs
	
	# Getting movement input
	var input_dir:Vector2 = Vector2(input.input_dir.x, input.input_dir.z)
	
	# ==== MOVEMENT STATE MACHINE ====
	if (input.movement_actions.has("dash") and curr_mvmt == "sprint") and input_dir != Vector2.ZERO and dash_cd_curr <= 0:
		# Sprint -> Dash
		next_mvmt = "dash"
		
	elif input.movement_actions.has("crouch") and character.is_on_floor():
		# Sprint -> Slide
		if curr_mvmt == "sprint" and input_dir != Vector2.ZERO and slide_cd_curr <= 0:
			next_mvmt = "slide"
		
		# Walk -> Crouch
		if curr_mvmt == "walk" or curr_mvmt == "idle":
			next_mvmt = "crouch"
	
	elif !head_collision.is_colliding() and curr_mvmt != "slide": # make sure there is room to stand
		# Use standing hitbox
		standing_collision_shape.disabled = false
		crouch_collision_shape.disabled = true
		
		# Crouch -> Sprint/Walk
		if input_dir != Vector2.ZERO:
			if input.movement_actions.has("sprint"):
				next_mvmt = "sprint"
			else:
				next_mvmt = "walk"
		# Anything -> Idle
		else:
			next_mvmt = "idle"
			
	# ==== END STATE MACHINE ====
	
	# Handle jump
	if input.movement_actions.has("jump") and character.is_on_floor() and curr_mvmt != "slide" and curr_mvmt != "crouch":
		character.velocity.y = JUMP_VELOCITY
	
	# Update state variables
	if curr_mvmt != next_mvmt:
		#print("Player moved from state %s to %s" % [curr_mvmt, next_mvmt])
		movements[curr_mvmt].end()
		movements[next_mvmt].begin()
		
		# Set cooldowns
		if next_mvmt == "dash":
			dash_cd_curr = DASH_CD_MAX
		elif next_mvmt == "slide":
			slide_cd_curr = SLIDE_CD_MAX
	
	prev_mvmt = curr_mvmt
	curr_mvmt = next_mvmt
	
	movements[curr_mvmt].process(delta)
	
	# Add the gravity.
	if not character.is_on_floor():
		character.velocity.y -= gravity * delta
	
	# Get the input direction and handle the movement/deceleration.
	if character.is_on_floor():
		direction = lerp(direction,Vector3(input_dir.x, 0, input_dir.y).normalized(),delta*LERP_SPEED)
	else:
		# Less control in air
		if input_dir != Vector2.ZERO:
			direction = lerp(direction,Vector3(input_dir.x, 0, input_dir.y).normalized(),delta*AIR_LERP_SPEED)
	
	# Get direction and speed relative to current state
	direction = movements[curr_mvmt].get_direction(direction)
	current_speed = movements[curr_mvmt].get_speed(current_speed, delta)
	
	# If character is entering input
	if direction:
		character.velocity.x = direction.x * current_speed
		character.velocity.z = direction.z * current_speed
	else:
		character.velocity.x = move_toward(character.velocity.x, 0, current_speed)
		character.velocity.z = move_toward(character.velocity.z, 0, current_speed)
	
	last_velocity = character.velocity

	head.look_at(input.target_object.position + Vector3(0, 1.5, 0) + (-0.125*input.target_object.velocity), Vector3.UP)
	head.rotation.x = clamp(head.rotation.x, deg_to_rad(-70), deg_to_rad(70))
	character.rotate_y(deg_to_rad(head.rotation.y*turn_speed))
	
	character.move_and_slide()
