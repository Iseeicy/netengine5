extends Knowledge
class_name KnowledgeBool

#
#	Exports
#

## The default value of this knowledge, as a bool
@export var default_value: bool:
	get:
		if _default_value == null:
			return false
		else:
			return _default_value
	set(new_value):
		_default_value = new_value

#
#	Public Functions
#

func get_default_value() -> bool:
	return default_value
