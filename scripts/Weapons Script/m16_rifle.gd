class_name M16
extends Gun



func _init() -> void:
	damage = 23.0
	mag_size = 31
	reload_time = 2.5
	fire_rate = 0.07
	max_range = 150.0
	automatic = true
	bullets = 1
	spread_deg = 0
	
#func _ready() -> void:
	#super._ready()
	#world_parent = get_parent()
	#org_collision_layer = collision_layer
	#org_collision_mask = collision_mask
