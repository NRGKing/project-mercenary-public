extends CenterContainer

@onready var ui = $body/neck/head/eyes/Camera3D/UI

func signum(num:float):
	if num == 0:
		return 0
	else:
		return num/abs(num)

@onready var lines := {
	"top" : $Top,
	"right" : $Right,
	"bottom" : $Bottom,
	"left" : $Left
}

@export var dot_radius:float = 1.0
@export var dot_color:Color = Color(Color.DIM_GRAY, 0.25)
@export var line_dist:float = 5.0
@export var line_length:float = 5.0
@export var line_width:float = 2.0

var target_dot_radius:float = 1.0
var target_line_dist:float = 5.0
var target_line_length:float = 5.0

const LERP_SPEED = 10

func change_crosshair(rad,dist,length,color:Color):
	target_dot_radius = rad
	target_line_dist = dist
	target_line_length = length
	dot_color = color

func change_crosshair_instant(rad,dist,length,color:Color):
	dot_radius = rad
	line_dist = dist
	line_length = length
	dot_color = color

# Called when the node enters the scene tree for the first time.
func _ready():
	queue_redraw()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	dot_radius = lerp(dot_radius,target_dot_radius,LERP_SPEED*delta)
	line_dist = lerp(line_dist,target_line_dist,LERP_SPEED*delta)
	line_length = lerp(line_length,target_line_length,LERP_SPEED*delta)
	queue_redraw()

var signums = {
	"top" : [Vector2(0, -1), Vector2(0, -1)],
	"right" : [Vector2(1, 0), Vector2(1, 0)],
	"bottom" :[Vector2(0, 1), Vector2(0, 1)],
	"left" : [Vector2(-1, 0), Vector2(-1, 0)]
}

func _draw():
	#draw_circle(Vector2(0,0), dot_radius, dot_color)
	draw_rect(Rect2(Vector2(-dot_radius + size.x/2, -dot_radius + size.y/2), Vector2(dot_radius*2,dot_radius*2)), dot_color, true)
	#ui.crosshair_position = Vector2(-dot_radius + size.x/2, -dot_radius + size.y/2)
	for key in lines:
		var pts = signums[key]
		lines[key].set_points([
			Vector2(signum(pts[0].x) * line_dist + size.x/2, signum(pts[0].y) * line_dist + size.y/2),
			Vector2(signum(pts[1].x) * (line_dist + line_length) + size.x/2, signum(pts[1].y) * (line_dist + line_length) + size.y/2)
		])
		lines[key].set_default_color(dot_color)
		lines[key].set_width(line_width)
	
