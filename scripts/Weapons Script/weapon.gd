class_name Gun
extends RigidBody3D

#use for sound/animations
signal fired
signal reload_started
signal reload_finished

#use for hud changed if we dispaly ammo/mag size
signal current_ammo(current:int, mag_size: int)

@export var damage:= 10.0
@export var mag_size := 30
@export var reload_time := 3.0
@export var fire_rate := 0.1
@export var max_range := 100.0
@export var automatic: bool = true
@export var bullets := 1
@export var spread_deg := 0.0
@export var pickup_range := 5.0

var ammo:= 0
var reloading := false
var _next_shot_time := 0.0
var _reload_id := 0


var equipped := false
var nearby_player: CharacterBody3D = null
var holder : CharacterBody3D = null
var world_parent: Node = null
var org_collision_layer :=0
var org_collision_mask := 0

func _ready() -> void:
	ammo = mag_size
	current_ammo.emit(ammo, mag_size)
	world_parent = get_parent()
	org_collision_layer = collision_layer
	org_collision_mask = collision_mask
	
#handels shooting logic by checking the gun the gets player cam info to fire a ray
func shoot(camera: Camera3D, exclude: Array[RID] = []) -> bool:
	if reloading:
		return false
	
	var now:= Time.get_ticks_msec()/1000.0
	if now < _next_shot_time:
		return false
	
	if ammo <= 0:
		reload()
		return false
	
	_next_shot_time = now + fire_rate
	ammo -= 1
	#print("weapon fired")
	#print("ammo left:", ammo)
	for i in bullets:
		_cast_ray(camera, exclude)
	fired.emit()
	current_ammo.emit(ammo, mag_size)
	return true
	
#begins relaod if allowed
func reload() -> void:
	if reloading or ammo== mag_size:
		return
	
	reloading = true
	_reload_id += 1
	
	var id := _reload_id
	reload_started.emit()
	await get_tree().create_timer(reload_time).timeout
	
	#if player canceled the reload
	if id != _reload_id:
		return
	
	ammo = mag_size
	reloading = false
	reload_finished.emit()
	current_ammo.emit(ammo, mag_size)
	
	
	
func cancel_reload() -> void:
	_reload_id +=1
	reloading = false
	
#fire a ray per bullet/ multiple for shotguns
func _cast_ray(cam: Camera3D, exclude: Array[RID]) -> void:
	
	var origin := cam.global_position
	var direction := - cam.global_transform.basis.z
	
	#handles spread from center of cam
	if spread_deg > 0.0:
		var spread := deg_to_rad(spread_deg)
		#random x,y amount to spread out pellets
		var offset:= Basis.from_euler(Vector3(randf_range(-spread, spread), randf_range(-spread, spread), 0.0))
		direction = cam.global_transform.basis * offset * Vector3.FORWARD
	
	#build the ray
	var query := PhysicsRayQueryParameters3D.create(origin, origin+direction.normalized() * max_range) 
	
	#ignore the player and gun model so they dont eat the bullet/ray path
	var ignore: Array[RID] = exclude.duplicate()
	ignore.append(get_rid())
	query.exclude = ignore
	
	
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit:
		#print("got a hit")
		_on_hit(hit)
		
	
func _on_hit(hit: Dictionary)-> void:
	var target: Object = hit.collider
	if target and target.has_method("take_damage"):
		target.take_damage(damage)
		

func pickup() -> void:
	if equipped or nearby_player == null:
		return
	
	if global_position.distance_to(nearby_player.global_position) > pickup_range:
		return
	
	if nearby_player.equipped_gun != null:
		return
	
	var gun_holder := nearby_player.get_node_or_null("Camera3D/Gun")
	if gun_holder == null:
		push_warning("player not found")
		return
		
	#gun cant collide with surrousnings
	freeze = true
	collision_layer =0
	collision_mask=0
	
	#move to hand position
	reparent(gun_holder, false)
	position = Vector3.ZERO
	rotation = Vector3.ZERO
	
	#set players
	holder = nearby_player
	holder.equipped_gun = self
	equipped = true
	

func drop_gun() -> void:
	if not equipped:
		return
	
	cancel_reload()
	reparent(world_parent, true)
	collision_layer = org_collision_layer
	collision_mask = org_collision_mask
	freeze = false
	
	if holder:
		holder.equipped_gun = null
		holder = null
	
	equipped = false

func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("interact") && not equipped:
		pickup()
	elif event.is_action_pressed("drop") && equipped:
		drop_gun()
		
	
func _on_pickup_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		nearby_player = body
	
func _on_pickup_body_exit(body: Node3D) -> void:
	if body == nearby_player:
		nearby_player = null
