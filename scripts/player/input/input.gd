extends Node
class_name InputHandler

func get_input() -> InputPackage:
	var input_package = InputPackage.new()
	
	# Get direction
	var input_dir_2d := Input.get_vector("left", "right", "forward", "backward")
	input_package.input_dir = Vector3(input_dir_2d.x, Input.get_axis("crouch", "jump"), input_dir_2d.y)
	
	# Get movement actions
	# sprint, jump, crouch, dash
	if Input.is_action_just_pressed("dash"):
		input_package.movement_actions.append("dash")
	if Input.is_action_pressed("crouch"):
		input_package.movement_actions.append("crouch")
	if Input.is_action_pressed("sprint"):
		input_package.movement_actions.append("sprint")
	if Input.is_action_just_pressed("jump"):
		input_package.movement_actions.append("jump")
	
	# Get combat actions
	# attack, parry, special, "reload+guard", draw weapon
	# Only can be doing one, ordered in prio order
	if Input.is_action_just_pressed("parry"):
		input_package.combat_actions.append("parry")
	elif Input.is_action_just_pressed("attack"):
		input_package.combat_actions.append("attack")
	elif Input.is_action_just_pressed("special"):
		input_package.combat_actions.append("special_attack")
	elif Input.is_action_just_pressed("reload+guard"):
		input_package.combat_actions.append("reload+guard")
	elif Input.is_action_just_pressed("toggle_weapon"):
		input_package.combat_actions.append("toggle_weapon")
	elif Input.is_action_just_pressed("primary_weapon"):
		input_package.combat_actions.append("primary_weapon")
	elif Input.is_action_just_pressed("secondary_weapon"):
		input_package.combat_actions.append("secondary_weapon")
	
	# Get world actions
	# interact
	if Input.is_action_just_pressed("interact"):
		input_package.world_actions.append("interact_start")
	elif Input.is_action_pressed("interact"):
		input_package.world_actions.append("interact_continue")
	
	return input_package
