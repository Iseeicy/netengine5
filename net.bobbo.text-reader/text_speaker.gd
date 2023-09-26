extends Node
class_name TextSpeaker

#
#	Exported
#

# The origin of our audio, and also where audio players will be created.
# If this is null, a child node without spatialization will be made.
@export var audio_origin_node: Node

# The sounds to use when writing text, by default
@export var default_sounds: TextSounds = preload("sounds/console/console.tres")

#
#	Variables
#

var char_counter: int = 0
var previous_char: String = ''
var _sounds: TextSounds
var _players: Dictionary = {}

#
#	Godot Functions
#

func _ready():
	if default_sounds != null:
		_set_sounds(default_sounds)
	
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
	if force_play and speak_type == TextSounds.SoundType.None:
		speak_type = TextSounds.SoundType.Default
		
	# If we shouldn't play a sound, EXIT EARLY
	if speak_type == TextSounds.SoundType.None:
		return
		
	# Play a sound for this character
	_play_sound_type(speak_type)
	char_counter = 0

# Depending on the state of this, get the speak type for the given char
func char_to_speak_type(char: String) -> TextSounds.SoundType:
	match char:
		'\n', ' ':
			return TextSounds.SoundType.Default
		'.':
			if previous_char == '.':
				return TextSounds.SoundType.None
			else:
				return TextSounds.SoundType.Period
		',', '-', ':', ';':
			return TextSounds.SoundType.Comma
		'?':
			return TextSounds.SoundType.Question
		'!':
			return TextSounds.SoundType.Exclam
	
	if char_counter > 3:
		return TextSounds.SoundType.Default
	else:
		return TextSounds.SoundType.None

#
#	Private Functions
#

func _set_sounds(new_sounds: TextSounds) -> void:
	# If we're already using these sounds, EXIT EARLY
	if _sounds == new_sounds:
		return
	
	# Use defaults if we're given no sounds
	if new_sounds == null:
		new_sounds = default_sounds
	
	# Remove all existing sound players
	for player in _players.values():
		player.queue_free()
	_players.clear()

	# Save our new sounds, and if we truly ave none then exit	
	_sounds = new_sounds
	if new_sounds == null:
		return
		
	# OTHERWISE, let's spawn players for each type
	for type in TextSounds.SoundType.values():
		var stream = new_sounds.get_stream(type)
		if stream == null:
			continue
	
		# Spawn a player for this stream
		var new_player = _create_sound_player(type, stream)
		if new_player == null:
			continue
			
		# Store the new player by type
		_players[type] = new_player
	
func _create_sound_player(type: TextSounds.SoundType, stream: AudioStream):
	# If we're not given an audio origin, then just make our own
	# and assume no spatialization
	if audio_origin_node == null:
		var new_origin = Node.new()
		add_child(new_origin)
		audio_origin_node = new_origin
	
	# Create the audio stream player depending on the type that
	# the audio origin is. This lets us have spatialization
	var new_player
	if audio_origin_node is Node3D:
		new_player = AudioStreamPlayer3D.new()
	elif audio_origin_node is Node2D:
		new_player = AudioStreamPlayer2D.new()
	else:
		new_player = AudioStreamPlayer.new()
		
	new_player.stream = stream
	
	audio_origin_node.add_child(new_player)
	return new_player

func _play_sound_type(type: TextSounds.SoundType) -> void:
	# If we specifically don't want to play anything, EXIT
	if type == TextSounds.SoundType.None:
		return
	
	# If we don't have this type or the default type, then just EXIT
	var real_type = type if _players.has(type) else TextSounds.SoundType.Default
	if not _players.has(real_type):
		return
	
	# OTHERWISE we have a real sound type, so get the player
	var our_player = _players[real_type]
	
	# Loop through all known players...
	for player in _players.values():
		# ...and if this player is OUR player, PLAY IT!
		if player == our_player:
			player.play()
		# ...but if it ISN'T our player, STOP IT.
		# (we do this to enforce monophonic playback)
		else:
			player.stop()
	
# When text starts, force a noise
func _on_text_reader_reading_started(raw_text, stripped_text, settings):
	reset_speak_state()
	_set_sounds(settings.sounds)
	handle_character(' ', true)

# When a new character is shown, eat it and maybe play a noise
func _on_text_reader_visible_chars_changed(visible_count, char):
	handle_character(char)
