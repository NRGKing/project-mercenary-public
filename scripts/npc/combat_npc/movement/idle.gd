extends Node

# Is this state active?
var active : bool = false

# Player nodes
@export var character:CharacterController

# Project-wide Constants
const LERP_SPEED = 3.5

# Define walking constants
const NORMAL_FOV = 75

func begin():
	active = true

func end():
	active = false

func get_speed(curr_speed, delta):
	return lerp(curr_speed, 0.0, delta*LERP_SPEED)

func get_direction(_direction: Vector3) -> Vector3:
	return Vector3.ZERO

func process(delta):
	## Use standing hitbox
	#standing_collision_shape.disabled = false
	#crouch_collision_shape.disabled = true

	## Move head position back up
	#head.position.y = lerp(head.position.y,0.0,delta*LERP_SPEED)
	pass

