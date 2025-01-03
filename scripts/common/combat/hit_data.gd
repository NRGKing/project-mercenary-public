extends Node
class_name HitData

# TEMP, DELETE LATER
var ignore_list:Array

var is_parryable:bool
var dmg := {
	"pierce" : 0.0,
	"shield" : 0.0,
	"environmental" : 0.0
}
var weapon:Weapon

static func blank() -> HitData:
	return HitData.new()
