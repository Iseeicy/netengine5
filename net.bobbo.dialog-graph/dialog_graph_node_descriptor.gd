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
#	Private Variables
#

var _spawned_graph_nodes: Array[DialogGraphNode] = []
var _spawned_handlers: Array[DialogRunnerActiveHandlerState] = []

#
#	Functions
#

func instantiate_graph_node() -> DialogGraphNode:
	var graph_node: DialogGraphNode = graph_node_scene.instantiate()
	graph_node.descriptor = self
	
	# Create a new instance of the data script and assign it
	var new_data = GraphNodeData.new()
	new_data.set_script(data_script)
	graph_node.set_node_data(new_data)
	
	# Add this to the list of spawned nodes, and make it
	# remove itself when it's freed
	_spawned_graph_nodes.push_back(graph_node)
	graph_node.tree_exited.connect(func(): _spawned_graph_nodes.erase(graph_node))
	
	return graph_node
	
func instantiate_handler() -> DialogRunnerActiveHandlerState:
	var handler = DialogRunnerActiveHandlerState.new()
	handler.set_script(handler_script)
	handler.name = node_name
	
	# Add this to the list of spawned handlers, and make it
	# remove itself when it's freed
	_spawned_handlers.push_back(handler)
	handler.tree_exited.connect(func(): _spawned_handlers.erase(handler))
	
	return handler
