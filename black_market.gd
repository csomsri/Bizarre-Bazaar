class_name Shop
extends Area3D

#we could add sound for purchases
signal purchase_made(item_name: String)

const upgrade_ids:= ["security_camera", "security_mirror"]
const weapon_scene_folder := "res://scenes/Weapons"

@export_group("Data_files")
@export_file("*.json") var weapon_file := "res://json/player_weapons.json"
@export_file("*json") var upgrade_file := "res://json/store_upgrade.json"


@export_group("Weapons")
@export_group("Upgrades")

@export var drop_distance := 2.0
@export var mirrors: Array[Node3D] = []
@export var cams_for_sale : Array[Camera3D] = []
@export var moniter: Cam_moniter


var _player: Node3D = null
var _open := false

var _items: Array[Dictionary] = []
var _stock: Dictionary = {}

var _mirrors_bought := 0
var _cams_bought := 0

var _ui: CanvasLayer
var _money_label: Label
var _message_label:Label
var _buttons: Dictionary = {}



func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player") as Node3D
	_add_items(_read_json(weapon_file, "weapons"), "weapon")
	_add_items(_read_json(upgrade_file, "store_upgrades"), "upgrade")
	_build_ui()
	
	_lock_world_items.call_deferred()
	
	

func _read_json(path: String, key: String)-> Array:
	if not FileAccess.file_exists(path):
		print("wrong path")
		push_error("check paths")
		return[]
	
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed[key]
	

func _add_items(list: Array, kind: String)-> void:
	
	for entry in list:
		if not entry.has("id") or not entry.has("name") or not entry.has("price"):
			print("incomplete json, check and fix")
			continue
		
		var item: Dictionary = entry.duplicate()
		item["kind"]= kind
		_items.append(item)
		
		if kind == "upgrade":
			_stock[item["id"]] = int(item.get("quantity",0))
		
#all cams/mirrors are invisible until bought
func _lock_world_items() -> void:
	for m in mirrors:
		_set_mirror_active(m, false)
	
	for c in cams_for_sale:
		c.visible = false
	
	
func _unhandled_input(event: InputEvent) -> void:
	
	if _open:
		if event.is_action_pressed("interact"):
			_close_shop()
			print(_player.money)
			get_viewport().set_input_as_handled()
		return
	
	if event.is_action_pressed("interact") and _player != null and overlaps_body(_player):
		_open_shop()
		get_viewport().set_input_as_handled()
		

func _open_shop()-> void:
	_open = true
	_player.set_controls_enabled(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_message_label.text = ""
	_refresh_ui()
	_ui.visible = true


func _close_shop() -> void:
	_open = false
	_ui.visible = false
	_restore_player.call_deferred()

func _restore_player() ->void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_player.set_controls_enabled(true)
	

func _in_stock(item: Dictionary) -> bool:
	return item["kind"] == "weapon" or _stock[item["id"]] >0

func _buy(item: Dictionary) -> void:
	var id: String = item["id"]

	if not _in_stock(item):
		return

	if _player.money < (int(item["price"])):
		_message_label.text = "Not enough money!"
		return

	match id:
		"security_camera":
			var cam := cams_for_sale[_cams_bought]
			cam.visible = true
			moniter.add_camera(cam)
			_cams_bought += 1

		"security_mirror":
			_set_mirror_active(mirrors[_mirrors_bought], true)
			_mirrors_bought += 1

		_:
			_spawn_weapon(item)

	if item["kind"] == "upgrade":
		_stock[id] -= 1

	_message_label.text = "Bought %s" % item["name"]
	purchase_made.emit(item["name"])
	_refresh_ui()

func _spawn_weapon(item: Dictionary) -> void:
	var path: String = item.get("scene" , "%s/%s.tscn" % [weapon_scene_folder, item["id"]])
	var gun := (load(path) as PackedScene).instantiate() as Gun
	
	gun.damage = float(item["damage"]) / maxi(gun.bullets,1)
	gun.mag_size = int(item.get("magazine_size", gun.mag_size))
	
	get_tree().current_scene.add_child(gun)
	var forward := -_player.global_transform.basis.z
	gun.global_position = _player.global_position + forward *drop_distance + Vector3.UP* 1.0
	gun.global_rotation.y = _player.global_rotation.y


func _set_mirror_active(m: Node3D, on: bool) -> void:
	m.visible = on
	

func _build_ui()-> void:
	_ui = CanvasLayer.new()
	_ui.visible = false
	add_child(_ui)
	
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ui.add_child(center)
	
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(380,0)
	center.add_child(panel)
	
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	
	var title := Label.new()
	title.text = "Shop"
	title. horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	
	_money_label = Label.new()
	box.add_child(_money_label)
	
	var last_category = ""
	
	for i in _items:
		var category: String = i["category"]
		if category != last_category:
			last_category = category
			var heading = Label.new()
			heading.text = category
			box.add_child(heading)
		
		var button := Button.new()
		button.tooltip_text = _tooltip_for(i)
		button.pressed.connect(_buy.bind(i))
		box.add_child(button)
		_buttons[i["id"]] = button
		
	_message_label = Label.new()
	box.add_child(_message_label)
	
	var close := Button.new()
	close.text = "Close"
	close.pressed.connect(_close_shop)
	box.add_child(close)
	

func _tooltip_for(item: Dictionary)-> String:
	if item.has("description"):
		return item["description"]
		
	var text := "Damage: %d" % int(item["damage"])
	if item.has("magazine_size"):
		text += "\nMagazine: %d" %int(item["magazine_size"])
		
	#text += "%d" %int(_player.money)
	return text
	

func _refresh_ui() -> void:
	_money_label.text = "Money $%d" %_player.money
	for item in _items:
		var button: Button = _buttons[item["id"]]
		if item["kind"] == "weapon":
			# No stock shown for weapons
			button.text = "%s - $%d" % [item["name"], int(item["price"])]
		else:
			button.text = "%s - $%d (%d left)" % [item["name"], int(item["price"]), _stock[item["id"]]]
		button.disabled = not _in_stock(item)
		
