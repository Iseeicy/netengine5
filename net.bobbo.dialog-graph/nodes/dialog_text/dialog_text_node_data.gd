@tool
extends GraphNodeData
class_name DialogTextNodeData

## A list of dialog text to show the user, in order
var text: Array[String] = []:
	get:
		if not "t" in _internal_data:
			_internal_data["t"] = [] as Array[String]
		return _internal_data["t"]
	set(new_texts):
		_internal_data["t"] = new_texts

