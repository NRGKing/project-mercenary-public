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
const WALK_FOV = 75
const WALK_SPEED = 6.0
const head_bobbing_walking_speed = 10
const head_bobbing_walking_intensity  = 0.05

func begin():
	arms.queue_animation("walk", 3)
	active = true

func end():
	active = false

# Input of an index in sinusoidal, returns intensity then index
func get_head_bob(delta):
	return [head_bobbing_walking_intensity, head_bobbing_walking_speed*delta]

func get_speed(curr_speed, delta):
	return lerp(curr_speed, WALK_SPEED, delta*LERP_SPEED)

func get_direction(direction : Vector3) -> Vector3:
	return direction

func process(delta):
	camera_3d.fov = lerp(camera_3d.fov,float(WALK_FOV),delta*LERP_SPEED)
	
	# Use standing hitbox
	standing_collision_shape.disabled = false
	crouch_collision_shape.disabled = true
		
	# Move head position back up
	body.position.y = lerp(body.position.y,0.0,delta*LERP_SPEED)
