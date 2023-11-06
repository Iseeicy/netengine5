## The menu that appears in the DialogGraphEditor when you right-click, or you
## attempt to make a new connection.
## Allows you to choose from a list of DialogGraph nodes to spawn.
## References GraphNodeDB to determine what kind of nodes to use.
@tool
extends PopupMenu

enum ReqType {
	Normal,
	From,
	To
}

#
#	Exports
#

## Emitted when a node is chosen from the popup menu.
signal spawn_node(desc: DialogGraphNodeDescriptor, position: Vector2)
## Emitted when a node is chosen, and should connect to a specific
## existing node.
signal spawn_node_from(desc: DialogGraphNodeDescriptor, position: Vector2, to_node: String, to_port: int)
## Emitted when a node is chosen, and should have a connection from a specific
## existing node.
signal spawn_node_to(desc: DialogGraphNodeDescriptor, position: Vector2, from_node: String, from_port: int)

## The GraphEdit that is interacting with us. Required!
@export var graph_edit: GraphEdit

#
#	Private Variables
#

## The last node spawning request that the GraphEdit made
var _last_req_type: ReqType
## The node name provided when the GraphEdit last made a node spawn request
var _last_node_name: String
## The node port provided when the GraphEdit last made a node spawn request
var _last_node_port: int
## The position provided when the GraphEdit last made a node spawn request
var _last_req_position: Vector2

#
#	Godot Functions
#

func _ready():
	# Hook up the pressed signal from PopupMenu
	id_pressed.connect(_on_id_pressed.bind())
	
	# Use the GraphNodeDB to determine what kind of Dialog Graph Nodes
	# we can represent in this menu
	clear()
	for x in range(0, GraphNodeDB.descriptors.size()):
		if GraphNodeDB.descriptors[x].is_spawnable:
			# Only add a node if it's marked as spawnable
			add_item(GraphNodeDB.descriptors[x].node_name, x)

#
#	Private Functions
#

## Given a position on-screen, return a position relative to the GraphEdit.
func _screen_pos_to_graph_pos(screen_pos: Vector2) -> Vector2:
	return (screen_pos + graph_edit.scroll_offset) / graph_edit.zoom


#
#	Signals
#

## Called when an option in this PopupMenu is clicked on.
## This calls one of the spawn_node events, depending on the previous
## context in which this menu was shown.
func _on_id_pressed(id: int) -> void:
	match(_last_req_type):
		ReqType.Normal:
			# If we are just spawning a node, tell other classes about it with 
			# the `spawn_node` event.
			spawn_node.emit(
				GraphNodeDB.descriptors[id], 
				_screen_pos_to_graph_pos(_last_req_position)
			)
		
		ReqType.To:
			# If we are spawning a node and connecting its input to some 
			# previous node, tell other classes about it with the 
			# `spawn_node_to` event.
			spawn_node_to.emit(
				GraphNodeDB.descriptors[id],
				_screen_pos_to_graph_pos(_last_req_position),
				_last_node_name,
				_last_node_port
			)
		
		ReqType.From:
			# If we are spawning a node and connecting its output to some 
			# existing node, tell other classes about it with the 
			# `spawn_node_from` event.
			spawn_node_from.emit(
				GraphNodeDB.descriptors[id],
				_screen_pos_to_graph_pos(_last_req_position),
				_last_node_name,
				_last_node_port
			)

## Called when the GraphEdit wants a popup to appear at a given position.
## Usually this happens bc the user right-clicked on the GraphEdit.
func _on_graph_edit_popup_request(req_pos):
	_last_req_position = req_pos
	_last_req_type = ReqType.Normal
	position = req_pos + graph_edit.get_screen_position() 
	self.popup()

## Called when the GraphEdit wants to connect a node's output port to a new, 
## non-existing node. Usually this happens bc the user dragged an output noodle
## to an empty space on the GraphEdit.
func _on_graph_edit_connection_to_empty(_from_node, _from_port, release_position):
	_last_req_position = release_position
	_last_req_type = ReqType.To
	_last_node_name = _from_node
	_last_node_port = _from_port
	position = release_position + graph_edit.get_screen_position() 
	self.popup()

## Called when the GraphEdit wants to connect a node's input port to a new, 
## non-existing node. Usually this happens bc the user dragged an input noodle
## to an empty space on the GraphEdit.
func _on_graph_edit_connection_from_empty(_to_node, _to_port, release_position):
	_last_req_position = release_position
	_last_req_type = ReqType.From
	_last_node_name = _to_node
	_last_node_port = _to_port
	position = release_position + graph_edit.get_screen_position() 
	self.popup()
