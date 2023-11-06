@tool
extends Node

#
#	Exports
#

@export var descriptors: Array[DialogGraphNodeDescriptor] = []

#
#	Public Funcitons
#

## Given some node data, find the descriptor that it belongs to
func find_descriptor_for_data(data: GraphNodeData) -> DialogGraphNodeDescriptor:
	for desc in descriptors:
		if desc.data_script == data.get_script():
			return desc
	return null
