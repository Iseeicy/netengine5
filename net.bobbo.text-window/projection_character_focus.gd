extends Node
class_name ProjectionCharacterFocus

@onready var _projection = get_parent() as ControlProjection
var current_character: CharacterSpeaker = null

#
#	Godot Functions
#

func _process(delta):
	if !current_character:
		return
		
	_projection.set_focus_position(current_character.get_position())

#
#	Private Functions
#

func _set_target_character(character: CharacterSpeaker) -> void:
	if character and character.is_physical():
		current_character = character
	else:
		current_character = null
		_projection.reset_focus()

#
#	Signals
#

func _on_text_window_dialog_shown(dialog: TextWindowDialog):
	_set_target_character(dialog.character)
