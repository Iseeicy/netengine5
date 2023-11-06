## An autoload class that acts as reference for what kinds of dialog nodes
## exist, and how to work with them.
@tool
extends Node

#
#	Exports
#

## A list of descriptors that represent what kind of dialog nodes exist.
@export var descriptors: Array[DialogGraphNodeDescriptor] = [
	preload("../nodes/entry/entry_desc.tres"),
	preload("../nodes/dialog_text/dialog_text_desc.tres"),
	preload("../nodes/choice_prompt/choice_prompt_desc.tres"),
	preload("../nodes/forwarder/forwarder_desc.tres"),
]

#
#	Public Funcitons
#

## Given some node data, find the descriptor that it belongs to.
func find_descriptor_for_data(data: GraphNodeData) -> DialogGraphNodeDescriptor:
	for desc in descriptors:
		if desc.data_script == data.get_script():
			return desc
	return null
