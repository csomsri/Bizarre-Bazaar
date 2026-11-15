class_name ResourceManager
extends Node

var money: float = 0
var health: int = 0
var is_dead: bool = false

@export var max_health: int = 100
@export var start_money: float = 99.99

@onready var inventory: Inventory = $Inventory

func _ready() -> void:
	money = start_money
	health = max_health

func _take_damage(damage: int) -> void:
	if is_dead or damage <= 0:
		return

	health = maxi(health - damage, 0)
	is_dead = health == 0


func _take_money(cost: float) -> bool:
	if cost < 0 or money < cost:
		return false

	money -= cost
	return true
	

	
