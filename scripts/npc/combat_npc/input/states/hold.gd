extends AIInputState

@onready var character_folder:Node = get_node('/root/world/characters')

@export var hold_point:Vector3

func generate_input() -> InputPackage:
	var input_package = InputPackage.new()
	
	## Target Selection
	for character in character_folder.get_children():
		if character.is_in_group("player"):
			handler.prev_target = handler.target
			handler.target_object = character
	
	handler.target = hold_point
	
	## Get direction
	input_package.input_dir = handler.nav_agent.get_next_path_position() - handler.char_controller.position
	
	if handler.target.distance_to(handler.prev_target) > handler.MAX_ERROR:
		handler.nav_agent.target_position = handler.target
	
	# Stop jitter and make it a bit more lifelike
	input_package.input_dir = input_package.input_dir.normalized()
	input_package.input_dir = Vector3(snapped(input_package.input_dir.x, 0.1), snapped(input_package.input_dir.y, 0.1),
		snapped(input_package.input_dir.z, 0.1))
	
	input_package.target_object = handler.target_object
	
	input_package.combat_actions.append("attack")
	
	return input_package
