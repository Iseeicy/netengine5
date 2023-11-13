## Represents the whole definition of a node that can be used in a
## DialogGraph. This acts as a reference for all details about a type
## of node, including it's name, it's visual representation in the graph,
## what kind of data it stores, and how to handle it when traversing
## the graph.
@tool
extends Resource
class_name DialogGraphNodeDescriptor

#
#	Exports
#

## The name that represents the node type we are describing.
@export var node_name: String = ""

## The scene containing the visual GraphNode for GraphEdit that represents this
## node type. 
@export var graph_node_scene: PackedScene = null

## The script that will handle performing actions as a result of 
## encountering this node type in the graph.
@export var handler_script: Script = null

## The script that defines how this node type's data will be organized
@export var data_script: Script = null

## Can you spawn this node in a graph editor?
@export var is_spawnable: bool = true

#
#	Functions
#

## Spawn a new instance of the GraphNodeData for this kind of DialogGraph node.
func instantiate_data() -> GraphNodeData:
	var new_data = GraphNodeData.new()
	new_data.set_script(data_script)
	new_data.descriptor = self
	
	return new_data

## Spawn a new instance of the Control that visually represents this
## kind of DialogGraph node.
func instantiate_graph_node() -> DialogGraphNode:
	# Spawn the GraphNode and make sure it can reference this def
	var graph_node: DialogGraphNode = graph_node_scene.instantiate()
	graph_node.descriptor = self
	
	# Create a new instance of the data script and assign it
	var new_data = instantiate_data()
	graph_node.set_node_data(new_data)
	
	return graph_node

## Spawn a new instance of the DialogRunnerState that can handle
## tis kind of DialogGraph node.
func instantiate_handler() -> DialogRunnerActiveHandlerState:
	var handler = DialogRunnerActiveHandlerState.new()
	handler.set_script(handler_script)
	handler.name = node_name
	
	return handler
