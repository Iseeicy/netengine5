@tool
class_name KnowledgeInteger
extends Knowledge

#
#	Exports
#

## The default value of this knowledge, as an integer
@export var default_value: int:
	get:
		if _default_value == null:
			return 0
		return _default_value
	set(new_value):
		_default_value = new_value

#
#	Public Functions
#


func get_default_value() -> int:
	return default_value
