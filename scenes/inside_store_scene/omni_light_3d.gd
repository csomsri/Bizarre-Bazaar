extends SpotLight3D

@export var min_energy: float = 0.5
@export var max_energy: float = 2.0
@export var use_lerp: bool = true
@export var lerp_speed: float = 15.0
@onready var sound = %ChristmasTreeBulb

var target_energy: float

func _ready() -> void:
	target_energy = light_energy
	sound.play()

func _process(delta: float) -> void:
	if use_lerp:
		light_energy = lerp(light_energy, target_energy, delta * lerp_speed)
		if abs(light_energy - target_energy) < 0.05:
			target_energy = randf_range(min_energy, max_energy)
	else:
		if randf() < 0.2: 
			light_energy = randf_range(min_energy, max_energy)
