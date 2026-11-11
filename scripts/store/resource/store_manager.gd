class_name StoreManager
extends Node3D

signal stock_changed(item_id: StringName, quantity: int)

var stock: Dictionary = {
    &"apple": 10,
    &"bread": 15,
    &"milk": 8
}


func take_item(item_id: StringName, amount: int = 1) -> bool:
    if amount <= 0 or not stock.has(item_id):
        return false

    if stock[item_id] < amount:
        return false

    stock[item_id] -= amount
    stock_changed.emit(item_id, stock[item_id])

    return true

