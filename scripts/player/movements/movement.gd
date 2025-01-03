extends Node

var active : bool = false

# Player nodes
@onready var body = $"../body"
@onready var neck = $"../body/neck"
@onready var head = $"../body/neck/head"
@onready var eyes = $"../body/neck/head/eyes"
@export var arms:Node3D

@onready var animation_player = $"../body/neck/head/eyes/AnimationPlayer"
@onready var standing_collision_shape = $"../standing_collision_shape"
@onready var crouch_collision_shape = $"../crouch_collision_shape"
@onready var camera_3d = $"../body/neck/head/eyes/Camera3D"
@onready var head_collision = $"../head_collision"

@onready var player = $".."

# Can only be doing one of these at a time
@onready var movements = {
	"walk" : $Walk,
	"sprint" : $Sprint,
	"crouch" : $Crouch,
	"slide" : $Slide,
	"dash" : $Dash,
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
var weight = 1.1

# Update the head and player body rotation
func rotate_player(relative_x, relative_y):
		if freelooking:
			neck.rotate_y(deg_to_rad(-1 * relative_x * mouse_sensitivity)) # handle the left/right rotation of player head
			neck.rotation.y = clamp(neck.rotation.y, deg_to_rad(-120), deg_to_rad(120)) # prevent player from looking too far back
		else:
			player.rotate_y(deg_to_rad(-1 * relative_x * mouse_sensitivity)) # handle the left/right rotation of player head
		head.rotate_x(deg_to_rad(-1 * relative_y * mouse_sensitivity)) # handle the up/down rotation of player head
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(80)) # prevent player from looking too far down
		# need to rotate arms as well
		if not arms.weapon_out:
			arms.rotation.x = -head.rotation.x
		else:
			arms.rotation.x = 0

# Captures Inputs
func _input(event): 
	if event is InputEventMouseMotion and active:
		rotate_player(event.relative.x, event.relative.y)
	
func process(delta:float, input:InputPackage):
	# TODO: let player walk up stairs
	
	# Getting movement input
	var input_dir:Vector2 = Vector2(input.input_dir.x, input.input_dir.z)
	
	# ==== MOVEMENT STATE MACHINE ====
	if (input.movement_actions.has("dash") and curr_mvmt == "sprint") and input_dir != Vector2.ZERO and dash_cd_curr <= 0:
		# Sprint -> Dash
		next_mvmt = "dash"
		
	elif input.movement_actions.has("crouch") and player.is_on_floor():
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
		
		# Move head position back up
		body.position.y = lerp(body.position.y,0.0,delta*LERP_SPEED)
		
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
	if input.movement_actions.has("jump") and player.is_on_floor() and curr_mvmt != "slide" and curr_mvmt != "crouch":
		player.velocity.y = JUMP_VELOCITY
		animation_player.play("jump")
	# Handle double jump
	elif input.movement_actions.has("jump") and !player.is_on_floor():
		if !dj_used:
			player.velocity.y = JUMP_VELOCITY
			animation_player.play("jump")
			dj_used = true
	
	prev_mvmt = curr_mvmt
	curr_mvmt = next_mvmt
	
	# Update state variables
	if curr_mvmt != prev_mvmt:
		#print("Player moved from state %s to %s" % [curr_mvmt, next_mvmt])
		movements[prev_mvmt].end()
		movements[curr_mvmt].begin()
		
		# Set cooldowns
		if curr_mvmt == "dash":
			dash_cd_curr = DASH_CD_MAX
		elif curr_mvmt == "slide":
			slide_cd_curr = SLIDE_CD_MAX
	
	movements[curr_mvmt].process(delta)
	
	# Handle freelooking
	if curr_mvmt == "slide":
		freelooking = true
		camera_3d.rotation.z = lerp(camera_3d.rotation.z,-deg_to_rad(4.0),delta*LERP_SPEED)
	else:
		freelooking = false
		neck.rotation.y = lerp(neck.rotation.y,0.0,delta*LERP_SPEED)
		camera_3d.rotation.z = lerp(camera_3d.rotation.y, 0.0, delta*LERP_SPEED)
		eyes.rotation.z = lerp(eyes.rotation.z, 0.0, delta*LERP_SPEED)
	
	# Handle headbobbing
	head_bobbing_current_intensity = movements[curr_mvmt].get_head_bob(delta)[0]
	head_bobbing_index += movements[curr_mvmt].get_head_bob(delta)[1]
	
	# See if headbobbing is needed
	if player.is_on_floor() && input_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index/2) + 0.5
		
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y * (head_bobbing_current_intensity/2.0), delta*LERP_SPEED)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x * head_bobbing_current_intensity, delta*LERP_SPEED)
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0, delta*LERP_SPEED)
		eyes.position.x = lerp(eyes.position.x, 0.0, delta*LERP_SPEED)
	
	# Add the gravity.
	if not player.is_on_floor():
		player.velocity.y -= gravity * weight * delta
	
	# Reset double jump CD
	if player.is_on_floor():
		dj_used = false
		
	# Handle landing
	if player.is_on_floor():
		if last_velocity.y < -4.0:
			animation_player.play("landing")
	
	# Get the input direction and handle the movement/deceleration.
	if player.is_on_floor():
		direction = lerp(direction,(player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*LERP_SPEED)
	else:
		# Less control in air
		if input_dir != Vector2.ZERO:
			direction = lerp(direction,(player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*AIR_LERP_SPEED)
	
	# Get direction and speed relative to current state
	direction = movements[curr_mvmt].get_direction(direction)
	current_speed = movements[curr_mvmt].get_speed(current_speed, delta)
	
	# If player is entering input
	if direction:
		player.velocity.x = direction.x * current_speed
		player.velocity.z = direction.z * current_speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, current_speed)
		player.velocity.z = move_toward(player.velocity.z, 0, current_speed)
	
	if curr_mvmt == "slide":
		player.velocity = Plane(player.get_floor_normal()).project(player.velocity)

	last_velocity = player.velocity
	
	player.move_and_slide()
	arms.process(delta)
	
	# Update cooldowns
	dash_cd_curr = max(dash_cd_curr - delta, 0)
	slide_cd_curr = max(slide_cd_curr - delta, 0)
