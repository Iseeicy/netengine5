@tool
extends DialogRunnerActiveHandlerState

#
#	Variables
#

var condition_data: KnowledgeJunctionNodeData:
	get:
		return data as KnowledgeJunctionNodeData

## Translates between the index of a visible condition, and the condition's actual
## index in the data it's from. This is to account for potentially non-visible
## condition.
var _condition_index_translation: Dictionary = {}

#
#	State Functions
#

func state_enter(_message: Dictionary = {}) -> void:
	_get_parent_state().state_enter(_message)
	
func state_exit() -> void:
	_get_parent_state().state_exit()

#
#	Private Functions
#


#
#	Signals
#

