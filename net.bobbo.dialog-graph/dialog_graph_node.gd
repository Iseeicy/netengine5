@tool
class_name DialogGraphNode
extends GraphNode

#
#	Exports
#

## Emitted when this node's data has been changed in some way
signal data_updated(data: GraphNodeData)

## Emitted when this node is requesting that all connections be removed from a
## specific slot. `side` is which side of the slot to remove from (-1 for left,
## 1 for right). `slot` is the actual slot index to remove connections from.
signal remove_connections_request(side: int, slot: int)

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
