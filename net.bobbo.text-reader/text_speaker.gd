extends Node
class_name TextSpeaker

enum SpeakType {
	None,
	Default,
	Period,
	Comma,
	Question,
	Exclam
}

#
#	Exported
#

# The origin of our audio, and also where to find audio streams
@export var audio_origin_node: Node

#
#	Variables
#

var char_counter: int = 0
var previous_char: String = ''
var all_speakers: Array[AudioStreamPlayer] = []

#
#	Godot Functions
#

func _ready():
	# Assume that we have a default speak type
	assert(get_speak_player(SpeakType.Default) != null)
	
	for type in SpeakType.values():
		var speak_player = get_speak_player(type)
		if speak_player != null:
			all_speakers.append(speak_player)

#
#	Functions
#

func reset_speak_state() -> void:
	char_counter = 0
	previous_char = ''

func handle_character(char: String, force_play: bool = false) -> void:
	char_counter += 1
	var speak_type = char_to_speak_type(char)
	previous_char = char
	
	# If we should force playing a sound, mark the speak type appropraitely
	if force_play and speak_type == SpeakType.None:
		speak_type = SpeakType.Default
		
	# If we shouldn't play a sound, EXIT EARLY
	if speak_type == SpeakType.None:
		return
		
	# Get the speak player
	var speak_player = get_speak_player(speak_type)
	if speak_player == null:
		speak_player = get_speak_player(SpeakType.Default)
		if speak_player == null:	# In a worst case scenario,
			return					# exit if no speak player
		
	# ...and play!
	for other_player in all_speakers:
		other_player.stop()
	speak_player.play()
	char_counter = 0

# Depending on the state of this, get the speak type for the given char
func char_to_speak_type(char: String) -> SpeakType:
	match char:
		'\n', ' ':
			return SpeakType.Default
		'.':
			if previous_char == '.':
				return SpeakType.None
			else:
				return SpeakType.Period
		',', '-', ':', ';':
			return SpeakType.Comma
		'?':
			return SpeakType.Question
		'!':
			return SpeakType.Exclam
	
	if char_counter > 3:
		return SpeakType.Default
	else:
		return SpeakType.None

func get_speak_player(type: SpeakType) -> AudioStreamPlayer:
	# If we don't have an audio origin, EXIT EARLY
	if audio_origin_node == null:
		return null
	
	# Turn the type into a string we can use to find the right node
	# (NOTE: We don't store audio as children under this node becaues
	# it allows us to keep this behaviour 2D / 3D agnostic. By delegating
	# another node to hold audio streams, it can have 2D or 3D positioning
	# while this node can not)
	var type_string = SpeakType.keys()[type]
	var potential_node = audio_origin_node.get_node_or_null(type_string)
	
	if !(potential_node is AudioStreamPlayer):
		return null
	else:
		return potential_node
	


# When text starts, force a noise
func _on_text_reader_label_text_started(read_text: String):
	reset_speak_state()
	handle_character(' ', true)

# When a new character is shown, eat it and maybe play a noise
func _on_text_reader_label_new_character_shown(char):
	handle_character(char)

# When text starts, force a noise
func _on_text_reader_reading_started(raw_text, stripped_text, settings):
	reset_speak_state()
	handle_character(' ', true)

# When a new character is shown, eat it and maybe play a noise
func _on_text_reader_visible_chars_changed(visible_count, char):
	handle_character(char)
