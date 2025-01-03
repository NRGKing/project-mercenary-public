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

@onready var sprint = $"../Sprint"
@onready var movement = $".."

# Project-wide Constants
const LERP_SPEED = 3.5

# Define dash constants
var dash_timer = 0
var dash_vector = Vector2.ZERO
const DASH_FOV = 85
const MAX_DASH_POWER = 30.0
const DJ_DASH_POWER = 24.0
const DASH_TIMER_MAX = 1.0

func begin():
	active = true
	dash_vector = Input.get_vector("left", "right", "forward", "backward")
	dash_timer = DASH_TIMER_MAX
	camera_3d.fov = DASH_FOV

func end():
	active = false
	dash_vector = Vector2.ZERO

# Input of an index in sinusoidal, returns intensity then index
func get_head_bob(_delta):
	return [0,0]

func get_speed(_curr_speed, _delta) -> float:
	return (dash_timer + 0.1) * MAX_DASH_POWER

func get_direction(_direction) -> Vector3:
	return (player.transform.basis * Vector3(dash_vector.x, 0.0, dash_vector.y)).normalized()

func process(delta):
	# Update FOV to dash FOV
	camera_3d.fov = lerp(camera_3d.fov,float(DASH_FOV),delta*LERP_SPEED)
	
	dash_timer -= delta
	if dash_timer <= 0:
		end()
		sprint.begin()
		movement.next_mvmt = "sprint"
