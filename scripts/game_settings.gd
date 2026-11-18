extends Node

const PATH := "res://json/cutscene_settings.json"

var data:Dictionary ={}

# load settings from json file(s)
# available as a global value
func _ready() -> void:
	var file := FileAccess.open(PATH, FileAccess.READ)
	if file == null:
		push_error("[GameSettings] cannot open settings file")
		return
		
	#print("[GameSettings] file opened")
		
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		data = parsed
	else:
		push_error("[GameSettings] settings data not parsed")
	
	#print("[GameSettings] settingss loaded")
	
# simple getter for section and key within settings data from json file
func get_value(section:String, key:String):
	#print("[GameSettings] data = ", data)
	#print("[GameSettings] sections %s   key: %s"%[section,key])
	if not data.has(section) or not data[section].has(key):
		push_warning("[GameSettings] missings args: %s,%s"%[section,key])
		return null
	return data[section][key] 
