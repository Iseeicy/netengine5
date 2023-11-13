@tool
extends GraphNodeData
class_name ChoicePromptNodeData

const TEXT_KEY: String = "t"
const OPTIONS_KEY: String = "o"

## The text to show when displaying this prompt
var text: String = "":
	get:
		return _get_internal_data(TEXT_KEY, "")
	set(new_text):
		_set_internal_data(TEXT_KEY, new_text)

## A list of options to present the user
var options: Array[Dictionary] = []:
	get:
		return _get_internal_data(OPTIONS_KEY, [] as Array[Dictionary])
	set(new_options):
		_set_internal_data(OPTIONS_KEY, new_options)
