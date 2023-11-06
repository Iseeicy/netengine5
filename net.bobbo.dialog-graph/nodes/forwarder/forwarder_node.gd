@tool
extends DialogGraphNode

#
#	Public Functions
#

func set_node_data(data: GraphNodeData) -> GraphNodeData:
	var casted_data = data as ForwarderNodeData
	if casted_data == null:
		return null
	
	return super(casted_data)
