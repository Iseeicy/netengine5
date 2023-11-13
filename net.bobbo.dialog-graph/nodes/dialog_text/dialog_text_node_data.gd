@tool
extends GraphNodeData
class_name DialogTextNodeData

const TEXT_KEY: String = "t"

## A list of dialog text to show the user, in order
var text: Array[String] = []:
	get:
		return _get_internal_data(TEXT_KEY, [] as Array[String])
	set(new_texts):
		_set_internal_data(TEXT_KEY, new_texts)

