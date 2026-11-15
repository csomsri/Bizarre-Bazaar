class_name NPCManager
extends Node

@export var max_npcs: int = 20

var active_npcs: Array[Node3D] = []


func can_spawn() -> bool:
	return active_npcs.size() < max_npcs


func get_npc_count() -> int:
	return active_npcs.size()


func register_npc(npc: Node3D) -> void:
	if active_npcs.has(npc):
		return

	active_npcs.append(npc)
	npc.tree_exited.connect(
		_on_npc_removed.bind(npc),
		CONNECT_ONE_SHOT
	)


func _on_npc_removed(npc: Node3D) -> void:
	active_npcs.erase(npc)
