@tool
class_name KnowledgeString
extends Knowledge

#
#	Exports
#

## The default value of this knowledge, as a String
@export var default_value: String:
	get:
		if _default_value == null:
			return ""
		return _default_value
	set(new_value):
		_default_value = new_value

#
#	Public Functions
#


func get_default_value() -> String:
	return default_value
