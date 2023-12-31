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
	preload("../nodes/knowledge_junction/knowledge_junction_desc.tres"),
]

#
#	Public Funcitons
#

## Given the name of a dialog node type, create a new instance of it's data
## object. Returns null if there is no node by `node_name` found.
func create_data(node_name: String) -> GraphNodeData:
	var desc = find_descriptor_by_name(node_name)
	if desc == null:
		return null
	return desc.instantiate_data()

## Given the name of a dialog node type, find the `DialogGraphNodeDescriptor`
## that it belongs to. Returns null if there is no node by `node_name` found.
func find_descriptor_by_name(node_name: String) -> DialogGraphNodeDescriptor:
	for desc in descriptors:
		if desc.node_name == node_name:
			return desc
	return null

## Given some data script, find the descriptor that it belongs to.
func find_descriptor_for_data_script(data_script: Script) -> DialogGraphNodeDescriptor:
	for desc in descriptors:
		if desc.data_script == data_script:
			return desc
	return null

## Given some node data, find the descriptor that it belongs to.
func find_descriptor_for_data(data: GraphNodeData) -> DialogGraphNodeDescriptor:
	return find_descriptor_for_data_script(data.get_script())
