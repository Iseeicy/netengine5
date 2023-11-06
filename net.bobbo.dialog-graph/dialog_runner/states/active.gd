## The 'Active' state of the DialogRunner. All DialogRunnerActiveHandlerState
## nodes will be spawned underneath this node.
@tool
extends DialogRunnerState

#
#	Private Variables
#

## The ID of the node we are handling, if given. -1 if not given.
var _node_id: int = -1
## The data of the node we are handling, if given. null if not given.
var _data: GraphNodeData = null

#
#	State Functions
#

func state_enter(_message: Dictionary = {}) -> void:
	# Try to get the node ID and node data to handle
	_node_id = _message.get("id", -1)
	_data = _message.get("data", null)
	
func state_exit() -> void:
	# Clean our cached variables to prevent weirdness
	_node_id = -1
	_data = null

#
#	Public Functions
#

## Get the ID of the node that this state is handling. 
## Returns -1 if we don't know the ID for some reason.
func get_node_id() -> int:
	return _node_id

## Get the data from the node that this state is handling.
## Returns null if we don't have any data for some reason.
func get_node_data() -> GraphNodeData:
	return _data
