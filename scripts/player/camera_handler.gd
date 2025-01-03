extends Camera3D

@onready var ui = $UI

func get_look_vector():
	# TODO: fix, not working in all dirs
	return get_global_transform().basis

func get_camera_collision(distance):
	var center = get_viewport().get_size()/2
	var ray_origin = project_ray_origin(center)
	var ray_end = ray_origin + project_ray_normal(center)*distance
	
	var new_intersection = PhysicsRayQueryParameters3D.create(ray_origin,ray_end)
	var intersection = get_world_3d().direct_space_state.intersect_ray(new_intersection)
	
	if not intersection.is_empty():
		# TODO: get the exact position that this collides with, it currently returns pos of object
		return [intersection, intersection.position]
	else:
		return [null, ray_end]

func get_camera_collision_angle(distance:float, angle:float): #angle in deg
	#var center = get_viewport().get_mouse_position()
	var center = ui.crosshair_position
	var ray_origin = project_ray_origin(center)
	var ray_end = ray_origin + project_ray_normal(center)*distance
	
	var max_displacement = tan(deg_to_rad(angle)) * distance
	
	ray_end.x += randf_range(-max_displacement,max_displacement)
	ray_end.y += randf_range(-max_displacement,max_displacement)
	
	var new_intersection = PhysicsRayQueryParameters3D.create(ray_origin,ray_end)
	var intersection = get_world_3d().direct_space_state.intersect_ray(new_intersection)
	
	if not intersection.is_empty():
		# TODO: get the exact position that this collides with, it currently returns pos of object
		return [intersection, ray_end]
	else:
		return [null, ray_end]
