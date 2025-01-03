extends Node3D

@onready var gpu_particles_3d = $GPUParticles3D

func fire_trail(start_position: Vector3, target_position: Vector3):
	#print(global_transform.origin)
	global_transform.origin = start_position
	#print(global_transform.origin)
	
	#print(target_position)
	
	#look_at(target_position)
	
	gpu_particles_3d.global_transform.origin = global_transform.origin
	
	gpu_particles_3d.process_material.direction = gpu_particles_3d.to_local(target_position - global_transform.origin.normalized()).normalized()

	#print(gpu_particles_3d.process_material.direction)

	#var direction = (target_position - global_transform.origin).normalized()
	#gpu_particles_3d.process_material.direction = gpu_particles_3d.to_local(direction).normalized()
	
	#print(gpu_particles_3d.process_material.direction)

	gpu_particles_3d.restart()
