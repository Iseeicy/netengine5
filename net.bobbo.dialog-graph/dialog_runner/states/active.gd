@tool
extends DialogRunnerState

#
#	Private Variables
#

var _node_id: int = -1
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

func get_node_id() -> int:
	return _node_id
	
func get_node_data() -> GraphNodeData:
	return _data
