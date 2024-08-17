@tool
class_name ChangeCharacterNodeData
extends GraphNodeData

const CHARACTER_DEFINITION_KEY: String = "cdef"

#
#	Public Variables
#

var character_definition: CharacterDefinition = null:
	get:
		return _get_internal_data(CHARACTER_DEFINITION_KEY, null)
	set(new_character_definition):
		_set_internal_data(CHARACTER_DEFINITION_KEY, new_character_definition)
