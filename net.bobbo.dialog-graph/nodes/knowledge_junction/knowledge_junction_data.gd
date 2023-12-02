@tool
extends GraphNodeData
class_name KnowledgeJunctionNodeData 

const TEXT_KEY: String = "t"
const CONDITIONS_KEY: String = "c"
const CONDITIONS_TEXT_KEY: String = "t"
const CONDITIONS_VIS_COND_KEY: String = "vc"

## The text to show when displaying this prompt
var text: String = "":
	get:
		return _get_internal_data(TEXT_KEY, "")
	set(new_text):
		_set_internal_data(TEXT_KEY, new_text)

## A list of conditions to present the user
var options: Array[Dictionary] = []:
	get:
		return _get_internal_data(CONDITIONS_KEY, [] as Array[Dictionary])
	set(new_conditions):
		_set_internal_data(CONDITIONS_KEY, new_conditions)
