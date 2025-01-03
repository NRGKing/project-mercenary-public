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
const LERP_SPEED = 5 * 1e-1

# Define walking constants
const NORMAL_FOV = 80
const SPEED = 15.0

func begin():
	active = true

func end():
	active = false

func get_speed(curr_speed, delta):
	return lerp(curr_speed, SPEED, delta*LERP_SPEED)

func get_direction(direction : Vector3) -> Vector3:
	return direction

func process(delta):
	camera_3d.fov = lerp(camera_3d.fov,float(NORMAL_FOV),delta*LERP_SPEED)
		
	# Move head position back up
	head.position.y = lerp(head.position.y,0.0,delta*LERP_SPEED)
