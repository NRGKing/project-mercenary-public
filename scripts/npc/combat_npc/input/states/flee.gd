extends AIInputState

@onready var zone_folder:Node = get_node('/root/world/safe_zones')

func generate_input() -> InputPackage:
	var input_package = InputPackage.new()
	
	## Target Selection
	for zone in zone_folder.get_children():
			handler.prev_target = handler.target
			handler.target_object = zone
			handler.target = zone.position
	
	## Get direction
	input_package.input_dir = handler.nav_agent.get_next_path_position() - handler.char_controller.position
	
	if handler.target.distance_to(handler.prev_target) > handler.MAX_ERROR:
		handler.nav_agent.target_position = handler.target
	
	# Stop jitter and make it a bit more lifelike
	input_package.input_dir = input_package.input_dir.normalized()
	input_package.input_dir = Vector3(snapped(input_package.input_dir.x, 0.1), snapped(input_package.input_dir.y, 0.1),
		snapped(input_package.input_dir.z, 0.1))
	
	input_package.target_object = handler.target_object
	
	return input_package
