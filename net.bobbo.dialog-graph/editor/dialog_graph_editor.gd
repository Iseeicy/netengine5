@tool
extends Control
class_name DialogGraphEditor

#
#	Exports
#

## Emitted when the GraphEdit selects a node. Extended for better control
signal node_selected(node: DialogGraphNode)

## Emitted when the GraphEdit deselects a node, or nodes are cleared. 
## Extended for better control.
signal node_deselected(node: DialogGraphNode)

## Emitted when the data inside some node of this graph is updated.
signal node_data_updated(node: DialogGraphNode, data: GraphNodeData)

#
#	Private Variables
#

var _selected_nodes: Array[DialogGraphNode] = []

#
#	Functions
#

func delete_node(node: GraphNode):
	var connections_to_remove = []
	
	# Deslect the node
	_on_graph_edit_node_deselected(node)
	
	# Save all connections that reference this node. conn is in the form of
	# { from_port: 0, from: "GraphNode name 0", to_port: 1, to: "GraphNode name 1" }.
	for conn in $GraphEdit.get_connection_list():
		if conn.from == node.name or conn.to == node.name:
			connections_to_remove.push_back(conn)
			
	# Actually remove all of those saved connections
	for conn in connections_to_remove:
		$GraphEdit.disconnect_node(conn.from, conn.from_port, conn.to, conn.to_port)
	
	node.queue_free()

func save_to_resource(dialog_graph: DialogGraph) -> void:
	# Collect the node data from children, and note what GraphNode child
	# it belongs to.
	var data_to_add: Array = []
	for child in $GraphEdit.get_children():
		if not (child is DialogGraphNode):
			continue
			
		var node_data = child.get_node_data()
		node_data.position = child.position_offset
		data_to_add.push_back([child, node_data])
	
	# Tell the given graph that we have a new list of nodes. This will update
	# the graph's node list internally and keep IDs correctly
	var updated_data_to_add: Array[GraphNodeData] = []
	for data in data_to_add:
		updated_data_to_add.push_back(data[1])
	dialog_graph.update_nodes(updated_data_to_add)
	
	# Use the dialog graph and our previously cached array of GraphNode children
	# to create a map that allows us to translate the child name into the
	# graph's node ID.
	var name_to_id: Dictionary = {}
	var data_to_id_map = dialog_graph.create_node_to_index_map()
	for data_pair in data_to_add:
		var child = data_pair[0]			# The child graph node
		var node_data = data_pair[1]		# The data of the node itself
		var id = data_to_id_map[node_data]	# The id of this data in the graph
		name_to_id[child.name] = id
	
	# Get connections in the form of:
	# { from_port: 0, from: "GraphNode name 0", to_port: 1, to: "GraphNode name 1" }
	var new_connections: Array[NodeConnection] = []
	for connection in $GraphEdit.get_connection_list():
		new_connections.push_back(
			NodeConnection.create(
				name_to_id[connection.from], 
				connection.from_port, 
				name_to_id[connection.to], 
				connection.to_port
			)
		)
	dialog_graph.update_connections(new_connections)

func load_from_resource(dialog_graph: DialogGraph) -> void:
	# Deselect all nodes
	for node in _selected_nodes:
		node_deselected.emit(node)
	_selected_nodes.clear()
	
	# Clean out the existing graph edit
	$GraphEdit.clear_connections()
	for child in $GraphEdit.get_children():
		if not (child is DialogGraphNode):
			continue
		child.queue_free()
	
	if dialog_graph == null:
		return
	
	# Stores spawned controls by their ID (int -> DialogGraphNode)
	var control_by_id: Dictionary = {}
	
	# Create the controls for each node
	for id in dialog_graph.all_nodes.keys():
		var data: GraphNodeData = dialog_graph.all_nodes[id]
		var desc = GraphNodeDB.find_descriptor_for_data(data)
		
		if desc.graph_node_scene == null:
			printerr("Couldn't find control for %s" % data)
			continue
			
		# Spawn the control, add it to the dict, and make it represent
		# this data
		var control: DialogGraphNode = _spawn_node(desc)
		control.position_offset = data.position
		control_by_id[id] = control
		control.set_node_data(data)
		
	# Actually connect the nodes
	for conn in dialog_graph.connections:
		# Get the nodes with these IDs
		var from_node = control_by_id[conn.from_id]
		var to_node = control_by_id[conn.to_id]
		
		# ...and connect em in the graph edit!
		$GraphEdit.connect_node(
			from_node.name, conn.from_port, 
			to_node.name, conn.to_port
		)
	
	

#
#	Private Functions
#

func _is_node_port_connected(node_name: String, port: int) -> bool:
	# Get connections in the form of:
	# { from_port: 0, from: "GraphNode name 0", to_port: 1, to: "GraphNode name 1" }
	for connection in $GraphEdit.get_connection_list():
		if connection.from_port != port:
			continue
		if connection.from != node_name:
			continue
		
		return true
	return false

func _spawn_node(desc: DialogGraphNodeDescriptor) -> DialogGraphNode:
	var new_node: DialogGraphNode = desc.instantiate_graph_node()
	
	# Tell the node to call our classes function when it wants
	# to be removed.
	var close_this_node = func():
		delete_node(new_node)
	new_node.close_request.connect(close_this_node.bind())
	
	# Tell the node to call our class's function when the node has
	# it's data updated, so that we may react to this change
	var this_node_updated = func(new_data):
		node_data_updated.emit(new_node, new_data)
	new_node.data_updated.connect(this_node_updated.bind())
	
	$GraphEdit.add_child(new_node)
	return new_node


#
#	Signals
#

func _on_add_node_spawn_node(desc: DialogGraphNodeDescriptor, spawn_pos: Vector2):
	var new_node: GraphNode = _spawn_node(desc)
	new_node.position_offset = spawn_pos
	
func _on_right_click_menu_spawn_node_from(desc, spawn_pos, _to_node, _to_port):
	var new_node: GraphNode = _spawn_node(desc)
	new_node.position_offset = spawn_pos

func _on_right_click_menu_spawn_node_to(desc, spawn_pos, from_node, from_port):
	var new_node: GraphNode = _spawn_node(desc)
	new_node.position_offset = spawn_pos
	$GraphEdit.connect_node(from_node, from_port, new_node.name, 0)	
	
func _on_graph_edit_delete_nodes_request(nodes):
	for node_name in nodes:
		var node_to_delete = $GraphEdit.get_node(node_name as NodePath) 
		delete_node(node_to_delete)
		
func _on_graph_edit_connection_request(from_node, from_port, to_node, to_port):
	# If the hovering node is already connected to something else, INGORE this
	if _is_node_port_connected(from_node, from_port):
		return
	
	$GraphEdit.connect_node(from_node, from_port, to_node, to_port)

func _on_graph_edit_disconnection_request(from_node, from_port, to_node, to_port):
	$GraphEdit.disconnect_node(from_node, from_port, to_node, to_port)

func _on_graph_edit_node_selected(node):
	_selected_nodes.push_back(node)
	node_selected.emit(node)

func _on_graph_edit_node_deselected(node):
	if not node in _selected_nodes:
		return
	
	node_deselected.emit(node)
	_selected_nodes.erase(node)
	
