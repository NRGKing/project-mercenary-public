extends Node
class_name NpcInputHandler

@onready var target:Vector3
@onready var target_object:Node3D
@onready var prev_target:Vector3

@export_category("Object Pointers")
@export var char_controller:CharacterController
@export var nav_agent:NavigationAgent3D

@export_category("Simple Control")
@export var target_distance:float = 1.0
@export var detection_distance:float = 30.0
@export_enum("chase", "flee", "hold_pos") var assigned_action:String
@export_enum("melee", "range", "none") var preferred_attack:String

@export_category("Available States")
@export var chase:bool = true
@export var flee:bool = true
@export var hold_pos:bool = true

@export_category("State Nodes")
@export var chase_node:Node
@export var flee_node:Node
@export var hold_position_node:Node

# TODO: link to states folder
@onready var states = {
	"chase" = chase_node,
	"flee" = flee_node,
	"hold_pos" = hold_position_node,
}

@onready var curr_action = assigned_action
@onready var next_action = assigned_action

const MAX_ERROR = 0.05

func _process(delta):
	curr_action = next_action

func generate_input() -> InputPackage:
	#print(curr_action, assigned_action)
	return states[curr_action].generate_input()
