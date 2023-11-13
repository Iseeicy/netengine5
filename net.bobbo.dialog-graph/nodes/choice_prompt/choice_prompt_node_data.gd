@tool
extends GraphNodeData
class_name ChoicePromptNodeData

## The text to show when displaying this prompt
var text: String = "":
	get:
		if not "t" in _internal_data:
			_internal_data["t"] = ""
		return _internal_data["t"]
	set(new_text):
		_internal_data["t"] = new_text

## A list of options to present the user
var options: Array[Dictionary] = []:
	get:
		if not "o" in _internal_data:
			_internal_data["o"] = [] as Array[Dictionary]
		return _internal_data["o"]
	set(new_options):
		_internal_data["o"] = new_options
