extends RefCounted
class_name InputPackage

var movement_actions : Array[String]
var combat_actions : Array[String]
var world_actions : Array[String]

var input_dir := Vector3.ZERO

var target_object:Node3D
