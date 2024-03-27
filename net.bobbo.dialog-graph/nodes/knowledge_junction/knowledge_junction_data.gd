@tool
extends GraphNodeData

class_name KnowledgeJunctionNodeData

const CONDITIONS_KEY: String = "c"
const STATES_KEY: String = "s"
const RESOURCES_KEY: String = "r"
const BUTTON_STATES_KEY: String = "b"
const CONSTANT_KEY: String = "k"

## A list of all specified conditions by the user
var conditions: Array[Dictionary] = []:
	get:
		return _get_internal_data(CONDITIONS_KEY, [] as Array[Dictionary])
	set(new_conditions):
		_set_internal_data(CONDITIONS_KEY, new_conditions)
