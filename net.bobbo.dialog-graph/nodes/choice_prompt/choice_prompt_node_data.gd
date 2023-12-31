@tool
extends GraphNodeData
class_name ChoicePromptNodeData

const OPTIONS_KEY: String = "o"
const OPTIONS_TEXT_KEY: String = "t"
const OPTIONS_VIS_COND_KEY: String = "vc"

## A list of options to present the user
var options: Array[Dictionary] = []:
	get:
		return _get_internal_data(OPTIONS_KEY, [] as Array[Dictionary])
	set(new_options):
		_set_internal_data(OPTIONS_KEY, new_options)
