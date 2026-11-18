class_name DialogueManager
extends Node

var dialogue_json: JSON
@onready var voice_player: AudioStreamPlayer = $VoicePlayer


func _ready() -> void:
	return

# Example code I found online
# In JSOn, we should specicy audio paths and stuff
#func show_node(node: Dictionary) -> void:
	#voice_player.stop()
#
	#dialogue_label.text = node.get("text", "")
#
	#var audio_path: String = node.get("audio", "")
	#if not audio_path.is_empty():
		#voice_player.stream = load(audio_path) as AudioStream
		#voice_player.play()
