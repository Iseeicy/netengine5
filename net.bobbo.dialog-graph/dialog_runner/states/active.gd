## The 'Active' state of the DialogRunner. All DialogRunnerActiveHandlerState
## nodes will be spawned underneath this node.
@tool
extends DialogRunnerState
class_name DialogRunnerStateActive

#
#	Private Variables
#

## The data of the node we are handling, if given. null if not given.
var _data: GraphNodeData = null

#
#	State Functions
#

func state_enter(_message: Dictionary = {}) -> void:
	# Try to get the node ID and node data to handle
	_data = _message.get("node_data", null)
	
func state_exit() -> void:
	# Clean our cached variables to prevent weirdness
	_data = null

#
#	Public Functions
#

## Get the data from the node that this state is handling.
## Returns null if we don't have any data for some reason.
func get_node_data() -> GraphNodeData:
	return _data
