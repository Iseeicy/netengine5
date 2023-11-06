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

## Emitted when a node is chosen from the popup menu
signal spawn_node(desc: DialogGraphNodeDescriptor, position: Vector2)
signal spawn_node_from(desc: DialogGraphNodeDescriptor, position: Vector2, to_node: String, to_port: int)
signal spawn_node_to(desc: DialogGraphNodeDescriptor, position: Vector2, from_node: String, from_port: int)

@export var graph_edit: GraphEdit

#
#	Private Variables
#

var _last_req_type: ReqType
var _last_node_name: String
var _last_node_port: int
var _last_req_position: Vector2

#
#	Godot Functions
#

func _ready():
	await get_tree().root.ready
	id_pressed.connect(_on_id_pressed.bind())
	
	clear()
	for x in range(0, GraphNodeDB.descriptors.size()):
		if GraphNodeDB.descriptors[x].is_spawnable:
			add_item(GraphNodeDB.descriptors[x].node_name, x)

#
#	Signals
#

func _on_id_pressed(id: int) -> void:
	match(_last_req_type):
		ReqType.Normal:
			spawn_node.emit(
				GraphNodeDB.descriptors[id], 
				(_last_req_position + graph_edit.scroll_offset) / graph_edit.zoom
			)
		ReqType.To:
			spawn_node_to.emit(
				GraphNodeDB.descriptors[id],
				(_last_req_position + graph_edit.scroll_offset) / graph_edit.zoom,
				_last_node_name,
				_last_node_port
			)
		ReqType.From:
			spawn_node_from.emit(
				GraphNodeDB.descriptors[id],
				(_last_req_position + graph_edit.scroll_offset) / graph_edit.zoom,
				_last_node_name,
				_last_node_port
			)

func _on_graph_edit_popup_request(req_pos):
	_last_req_position = req_pos
	_last_req_type = ReqType.Normal
	position = req_pos + graph_edit.get_screen_position() 
	self.popup()

func _on_graph_edit_connection_to_empty(_from_node, _from_port, release_position):
	_last_req_position = release_position
	_last_req_type = ReqType.To
	_last_node_name = _from_node
	_last_node_port = _from_port
	position = release_position + graph_edit.get_screen_position() 
	self.popup()

func _on_graph_edit_connection_from_empty(_to_node, _to_port, release_position):
	_last_req_position = release_position
	_last_req_type = ReqType.From
	_last_node_name = _to_node
	_last_node_port = _to_port
	position = release_position + graph_edit.get_screen_position() 
	self.popup()
