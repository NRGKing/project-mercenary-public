extends Resource
class_name Weapon

@export_group("Basic Properties")
@export var name:String
@export var desc:String
@export_enum("longsword", "katana", "pistol", "rifle", "shotgun", 
	"hand_cannon", "heavy") var type:String

@export_group("Visuals")
@export var scene:PackedScene
@export var camera_position:Vector3
@export var camera_scale:Vector3
## Degrees
@export var camera_rotation:Vector3

@export_group("Shot Visuals")
@export_color_no_alpha var particle_color:Color

@export_group("Combat Properties")
## Attacks per second
@export_range(1,30) var attack_speed:float = 1 # atks per second
## Maximum angular displacement of shots
@export_range(0,10) var spread:float = 0.0
## Damage dealt to health
@export var health_damage:float = 0.0
## Damage dealth to shields
@export var shield_damage:float = 0.0
## Amount of shots to fire per attack
@export_range(1,20) var shot_amount:int = 1
## Max distance a bullet can travel
@export var attack_dist:float
