# This Class Managers the Players Resource
# Player Resource:
#	Money	  (0 
#	Health	  (0 -> 100)
# 	Inventory (Guns, Stuff)
class_name PlayerResource
extends ResourceManager


@export var player_inventory: Inventory
func player_buy_weapon() -> bool:
	return true

func player_buy_upgrade() -> bool:
	return true

func player_buy_bmarket() -> bool:
	return true
