class_name NPCSpawner
extends Node3D

# AI USAGE

@export var npc_scene: PackedScene
@export var npc_container: Node3D


@onready var spawn_point: Marker3D = $SpawnPoint
@onready var npc_manager: NPCManager = $NPCManager

var has_spawned: bool = false


func spawn_npc() -> Node3D:
	if has_spawned:
		return null

	if not npc_manager.can_spawn():
		return null

	if npc_scene == null or not is_instance_valid(npc_container):
		push_error("NPCSpawner: Assign npc_scene and npc_container.")
		return null

	var instance := npc_scene.instantiate()

	if not instance is Node3D:
		push_error("NPCSpawner: NPC scene root must be Node3D.")
		instance.free()
		return null

	var npc := instance as Node3D

	# Place the NPC at the marker before its _ready() runs
	npc.transform = (
		npc_container.global_transform.affine_inverse()
		* spawn_point.global_transform
	)

	has_spawned = true
	npc_manager.register_npc(npc)
	npc_container.add_child(npc)

	return npc
