@tool
extends GraphNodeData
class_name ChangeCharacterNodeData

#
#	Public Variables
#

var character_definition: CharacterDefinition = null:
	get:
		if not "cdef" in _internal_data:
			_internal_data["cdef"] = null
		return _internal_data["cdef"]
	set(new_character_definition):
		_internal_data["cdef"] = new_character_definition
