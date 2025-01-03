extends Node

var active : bool = false

@export_category("Character Objects")
@export var character:CharacterController

func process(delta:float, input:InputPackage):
	character.rotation = Vector3(deg_to_rad(90), 0.0, 0.0)
