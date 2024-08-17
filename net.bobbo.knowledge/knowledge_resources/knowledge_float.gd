@tool
class_name KnowledgeFloat
extends Knowledge

#
#	Exports
#

## The default value of this knowledge, as a float
@export var default_value: float:
	get:
		if _default_value == null:
			return 0
		return _default_value
	set(new_value):
		_default_value = new_value

#
#	Public Functions
#


func get_default_value() -> float:
	return default_value
