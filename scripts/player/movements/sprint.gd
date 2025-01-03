extends Node

# Is this state active?
var active : bool = false

# Player nodes
@onready var body = $"../../body"
@onready var neck = $"../../body/neck"
@onready var head = $"../../body/neck/head"
@onready var eyes = $"../../body/neck/head/eyes"

@onready var animation_player = $"../../body/neck/head/eyes/AnimationPlayer"
@onready var standing_collision_shape = $"../../standing_collision_shape"
@onready var crouch_collision_shape = $"../../crouch_collision_shape"
@onready var camera_3d = $"../../body/neck/head/eyes/Camera3D"
@onready var head_collision = $"../../head_collision"
@onready var arms = $"../../body/neck/head/arms"

@onready var player = $"../.."

# Project-wide Constants
const LERP_SPEED = 3.5

# Define walking constants
const SPRINT_FOV = 80
const SPRINT_SPEED = 8.0
const head_bobbing_sprinting_speed = 16
const head_bobbing_sprinting_intensity = 0.1

func begin():
	arms.queue_animation("sprint", 3)
	active = true

func end():
	active = false

# Input of an index in sinusoidal, returns intensity then index
func get_head_bob(delta):
	return [head_bobbing_sprinting_intensity, head_bobbing_sprinting_speed*delta]

func get_speed(curr_speed, delta):
	return lerp(curr_speed, SPRINT_SPEED, delta*LERP_SPEED)

func get_direction(direction : Vector3) -> Vector3:
	return direction

func process(delta):
	camera_3d.fov = lerp(camera_3d.fov,float(SPRINT_FOV),delta*LERP_SPEED)
	
	# Use standing hitbox
	standing_collision_shape.disabled = false
	crouch_collision_shape.disabled = true
		
	# Move head position back up
	body.position.y = lerp(body.position.y,0.0,delta*LERP_SPEED)
