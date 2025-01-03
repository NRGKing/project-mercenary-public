extends CharacterModel

@onready var health_bar = $"../body/neck/head/eyes/Camera3D/UI/PanelContainer/MarginContainer/Stats/Health/Bar"
@onready var shield_bar = $"../body/neck/head/eyes/Camera3D/UI/PanelContainer/MarginContainer/Stats/Shield/Bar"

# Update the bar GUIS
func update_gui():
	health_bar.value = health/MAX_HEALTH * 100
	shield_bar.value = shield/MAX_SHIELD * 100
