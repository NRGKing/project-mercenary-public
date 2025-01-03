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

@onready var player = $"../.."

# Project-wide Constants
const LERP_SPEED = 3.5

# Define crouching constants
const CROUCH_FOV = 70
const CROUCH_SPEED = 2.0
const head_bobbing_crouching_speed = 6
const head_bobbing_crouching_intensity = 0.025
const CROUCHING_DEPTH = -0.5

func begin():
	active = true

func end():
	active = false

# Input of an index in sinusoidal, returns intensity then index
func get_head_bob(delta):
	return [head_bobbing_crouching_intensity, head_bobbing_crouching_speed*delta]

func get_speed(curr_speed, delta):
	return lerp(curr_speed, CROUCH_SPEED, delta*LERP_SPEED)

func get_direction(direction : Vector3) -> Vector3:
	return direction

func process(delta):
	camera_3d.fov = lerp(camera_3d.fov,float(CROUCH_FOV),delta*LERP_SPEED)
	
	# Move head and hitbox down
	body.position.y = lerp(body.position.y,CROUCHING_DEPTH,delta*LERP_SPEED)
	standing_collision_shape.disabled = true
	crouch_collision_shape.disabled = false
