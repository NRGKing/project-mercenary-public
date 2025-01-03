extends Node3D

const SPEED = 300.0

@onready var mesh = $MeshInstance3D
@onready var ray_cast = $RayCast3D
@onready var bullet_particles = $GPUParticles3D



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += transform.basis * Vector3(0,0,-SPEED) * delta
	if ray_cast.is_colliding():
		mesh.visible = false
		bullet_particles.emitting = true
		await get_tree().create_timer(1.0).timeout
		queue_free()

func _on_timer_timeout():
	queue_free()
