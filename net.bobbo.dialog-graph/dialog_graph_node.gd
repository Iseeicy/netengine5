@tool
extends GraphNode
class_name DialogGraphNode

#
#	Exports
#

## Emitted when this node's data has been changed in some way
signal data_updated(data: GraphNodeData)

#
#	Public Variables
#

var descriptor: DialogGraphNodeDescriptor = null

#
#	Private Variables
#

var _data: GraphNodeData = null

#
#	Virtual Functions
#

func get_node_data() -> GraphNodeData:
	return _data

func set_node_data(data: GraphNodeData) -> GraphNodeData:
	_data = data
	data_updated.emit(data)
	return _data
