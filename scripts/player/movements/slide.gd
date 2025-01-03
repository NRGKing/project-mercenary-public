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

@onready var crouch = $"../Crouch"
@onready var movement = $".."

@onready var angle_label = $"../../body/neck/head/eyes/Camera3D/UI/Debug/Angle"

# Project-wide Constants
const LERP_SPEED = 3.5

# Slide vars
var slide_timer = 0.0
var slide_vector = Vector2.ZERO
const SLIDE_TIMER_MAX = 1.0
const SLIDE_SPEED = 15.0
const CROUCH_FOV = 70
const CROUCHING_DEPTH = -0.5
const SLOPE_SLIDE_ANGLE = PI/12

func begin():
	active = true
	slide_vector = Input.get_vector("left", "right", "forward", "backward")
	slide_timer = SLIDE_TIMER_MAX
	movement.freelooking = true

func end():
	active = false
	slide_vector = Vector2.ZERO

# Input of an index in sinusoidal, returns intensity then index
func get_head_bob(_delta):
	return [0,0]

func get_speed(_curr_speed, _delta) -> float:
	return (slide_timer + 0.1) * SLIDE_SPEED

func get_direction(direction) -> Vector3:
	direction = (player.transform.basis * Vector3(slide_vector.x, 0.0, slide_vector.y)).normalized()
	# BUG: Camera issue with below code
	if player.is_on_floor() and player.get_floor_angle() > SLOPE_SLIDE_ANGLE:
		direction = Plane(player.get_floor_normal()).project(direction)
	return direction

func process(delta):
	# Update FOV to slide FOV
	camera_3d.fov = lerp(camera_3d.fov,float(CROUCH_FOV),delta*LERP_SPEED)
	
	# Move head and hitbox down
	body.position.y = lerp(body.position.y,CROUCHING_DEPTH,delta*LERP_SPEED)
	standing_collision_shape.disabled = true
	crouch_collision_shape.disabled = false
	
	angle_label.text = "Angle: %s" % player.get_floor_angle()
	
	if player.get_floor_angle() < SLOPE_SLIDE_ANGLE || player.velocity.y > 0:
		slide_timer -= delta
	if slide_timer <= 0:
		end()
		crouch.begin()
		movement.next_mvmt = "crouch"
