extends Control

@onready var center_container = $CenterContainer

@onready var crosshair_position: Vector2 = Vector2(
	-center_container.dot_radius + center_container.size.x/2 + center_container.global_position.x,
 	-center_container.dot_radius + center_container.size.y/2 + center_container.global_position.y)
