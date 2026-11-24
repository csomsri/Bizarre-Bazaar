class_name Aggressive_thief
extends Customer


#need annimation for npc fighting player
signal punch_start
signal punch_land
signal surrendered


signal drop_loot(items: Dictionary, at_position: Vector3)

@export var punch_dmg := 11.0
@export var punch_range := 2.0
@export var punch_windup:= 0.5
@export var punch_cooldown := 1.0
@export var chase_speed_mult = 1.25		#increase in base speed during fight 
@export var surrender_chance = 0.15		#each time they are hurt this chance is added to them surrendering

#needed for shotguns so each pellet doesnt count as 1 hit 
@export var group_hit = 0.1

var _player : Node3D = null
var _hits_taken := 0
var _surrendered := false
var _winding_up := false
var _wind_up_left := 0.0
var _cooldown := 0.0
var _next_hit := 0.0

#skips chekout goes right to the exit
func finish_shopping() -> void:
	go_to(exit_position.global_position, State.LEAVING)
	

#add fight logic to inherited class
func _physics_process(delta: float) -> void:
	if state == State.CONFRONTED:
		_fight(delta)
		move_and_slide()
		return
	super._physics_process(delta)
	
#surrender overrides confrontation
func confront() -> void:
	if _surrendered:
		return
	super.confront()

#if confronted always start fight
func confrontation() ->void:
	_begin_fight()
	
func on_hurt() -> void:
	if _surrendered:
		return
	
	var now := Time.get_ticks_msec() / 1000.0
	if now < _next_hit:
		return
	_next_hit = now + group_hit
	
	_hits_taken += 1
	var chance := clampf( _hits_taken * surrender_chance, 0.0, 1.0)
	if randf() < chance:
		surrender()
	elif state != State.CONFRONTED:	#shot with no confrontation
		_begin_fight()

#give up, drop inventory, leave
func surrender() -> void:
	_surrendered = true
	_winding_up = false
	drop_everything()
	surrendered.emit()
	go_to(exit_position.global_position, State.LEAVING)
	

func drop_everything() -> void:
	var inv: Dictionary = {}
	for item in resources.inventory.items:
		inv[item] = resources.inventory.items[item]
	resources.inventory.items.clear()
	
	if not inv.is_empty():
		drop_loot.emit(inv, global_position)

#sets player as enemy
func _begin_fight() -> void:
	state = State.CONFRONTED
	velocity = Vector3.ZERO
	_winding_up = false
	_cooldown = 0.0
	_player = get_tree().get_first_node_in_group("player") as Node3D

#face player, hit if close enough else chase them down
func _fight(delta: float)-> void:
	velocity = Vector3.ZERO
	
	if _player == null or not is_instance_valid(_player):
		go_to(exit_position.global_position, State.LEAVING)
		return
	
	_cooldown = maxf(_cooldown - delta, 0.0)
	
	#distacne in straight line
	var dis_to_player := _player.global_position - global_position
	dis_to_player.y = 0.0
	var distance := dis_to_player.length()
	
	#look at player
	if distance > 0.1:
		look_at(Vector3(_player.global_position.x, global_position.y,_player.global_position.z))
		
	if _winding_up:
		_wind_up_left -= delta
		if _wind_up_left <= 0.0:
			_throw_punch(distance)
		return
	
	#beging punch
	if distance <= punch_range:
		if _cooldown <= 0.0:
			_winding_up = true
			_wind_up_left = punch_windup
			punch_start.emit() #for aninmaiton/sound
		
		return
	
	#iff to far from the player
	navigation.target_position = _player.global_position
	update_movement()
	velocity *= chase_speed_mult
	

func _throw_punch(d: float)-> void:
	_winding_up = false
	_cooldown = punch_cooldown
	
	if d <= punch_range*1.25:
		_player.take_damage(punch_dmg)
		punch_land.emit()
	
	

	
