extends MeshInstance3D

func _ready():
	pass

func create_tracer(start_position: Vector3, end_position: Vector3):
	var draw_mesh = ImmediateMesh.new()
	mesh = draw_mesh
	draw_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material_override)
	
	print(start_position, " ", end_position)
	
	draw_mesh.surface_add_vertex(start_position)
	draw_mesh.surface_add_vertex(end_position)
	draw_mesh.surface_end()

func _process(delta: float):
	pass
