## A control that allows for creating and editing DialogGraphs.
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

## A list of all nodes that are currently selected.
var _selected_nodes: Array[DialogGraphNode] = []

#
#	Functions
#

## Delete a node from this graph and remove any connections referencing it.
func delete_node(node: GraphNode) -> void:
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

## Compile the state of the the visual dialog graph that this editor represents
## down to a specific DialogGraph resource so that it can be execute and/or
## saved.
func save_to_resource(packed_graph: PackedDialogGraph) -> void:
	# Collect all data from the graph node children, and store the node's name
	# as well
	var data_to_add: Array[GraphNodeData] = []
	var data_to_add_by_name: Dictionary = {} # String -> GraphNodeData
	for child in $GraphEdit.get_children():
		if not child is DialogGraphNode:
			continue
		# As long as this child is a dialog graph node, we can get it's data!
		var node_data = child.get_node_data()
		node_data.position = child.position_offset
		data_to_add.push_back(node_data)
		data_to_add_by_name[child.name] = node_data
	
	# Find the largest ID, and find IDs that need to be updated
	var largest_id: int = -1
	var data_to_add_ids_for: Array[GraphNodeData] = []
	for data in data_to_add:
		if data.id == -1:
			data_to_add_ids_for.push_back(data)
		elif data.id > largest_id:
			largest_id = data.id
	
	# Assign IDs to all data that doesn't have an ID yet
	for data in data_to_add_ids_for:
		largest_id += 1
		data.id = largest_id
	
	# Clear all connections and nodes from the packed graph
	packed_graph.clear()
	
	# Pack all of the data into the graph, and get a map that let's us find the
	# new ID for each given data
	var data_to_index_map = packed_graph.set_nodes(data_to_add)
	
	# Ensure that there is at least one entry node
	packed_graph.ensure_entry_node()
	
	# Get connections in the form of:
	# { from_port: 0, from: "graphname 0", to_port: 1, to: "Graphname 1" }
	var current_connections: Array[Dictionary] = $GraphEdit.get_connection_list()
	
	# Go through each connection and translate it to use the new set of IDs
	# instead of node names
	var translated_connections: Array[Dictionary] = []
	for conn in current_connections:
		translated_connections.push_back({
			"from_id": data_to_index_map[data_to_add_by_name[conn["from"]]],
			"from_port": conn["from_port"],
			"to_id": data_to_index_map[data_to_add_by_name[conn["to"]]],
			"to_port": conn["to_port"]
		})
	
	# Add all of the new connections
	packed_graph.connect_many_nodes(translated_connections)
	
## Clear the current state and load the state of a previously compiled 
## PackedDialogGraph.
func load_from_resource(packed_graph: PackedDialogGraph) -> void:
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
	
	if packed_graph == null:
		return
	
	# Ensure that this graph at least has an entry node
	packed_graph.ensure_entry_node()
	
	# Unpack the graph into something easy to work with
	var runtime_graph: RuntimeDialogGraph = RuntimeDialogGraph.new(packed_graph)
	
	# Stores spawned controls by their data (GraphNodeData -> DialogGraphNode)
	var control_by_node_data: Dictionary = {}
	
	# Create the controls for each node
	for node_data in runtime_graph.get_all_nodes():
		# Spawn the control, add it to the dict, and make it represent
		# this data
		var control: DialogGraphNode = _spawn_node(node_data.descriptor)
		if not control:
			continue
		
		control.position_offset = node_data.position
		control_by_node_data[node_data] = control
		control.set_node_data(node_data)
		
	# Actually connect the nodes
	for conn in runtime_graph.get_all_connections():
		# Get the nodes with these IDs
		var from_node = control_by_node_data[conn.from_node]
		var to_node = control_by_node_data[conn.to_node]
		
		# ...and connect em in the graph edit!
		$GraphEdit.connect_node(
			from_node.name, conn.from_port, 
			to_node.name, conn.to_port
		)

#
#	Private Functions
#

## Does the given node have a connection going from a certain port
## to another node?
func _is_node_port_connected(node_name: String, port: int) -> bool:
	# Get connections in the form of:
	# { from_port: 0, from: "GraphNode name 0", to_port: 1, 
	# to: "GraphNode name 1" }
	for connection in $GraphEdit.get_connection_list():
		if connection.from_port != port:
			continue
		if connection.from != node_name:
			continue
		
		# If this connection uses the requested port on the requested node,
		# then EXIT EARLY
		return true
	# OTHERWISE - we couldn't find any connections going from the requested
	# node via the requested port
	return false

## Spawn a new DialogGraphNode using the descriptor for a type of dialog node,
## and configure it to work with this GraphEdit.
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
	
	# Tell the node to call our class' function when the node is requesting to
	# have some of it's connections removed, so we can actually do it
	var this_node_remove_conns_req_func = func(side: int, slot: int):
		_on_node_remove_connections_request(new_node.name, side, slot)
	new_node.remove_connections_request.connect(
		this_node_remove_conns_req_func.bind()
	)
	
	$GraphEdit.add_child(new_node)
	return new_node

#
#	Signals
#

## Called when the RightClickMenu requests that we spawn a new node
func _on_add_node_spawn_node(desc: DialogGraphNodeDescriptor, spawn_pos: Vector2):
	var new_node: GraphNode = _spawn_node(desc)
	new_node.position_offset = spawn_pos

## Called when the RightClickMenu requests that we spawn a new node and connect
## it's output to some existing node.
func _on_right_click_menu_spawn_node_from(desc, spawn_pos, _to_node, _to_port):
	var new_node: GraphNode = _spawn_node(desc)
	new_node.position_offset = spawn_pos
	# FOR NOW - ignore connecting to some node. 

## Called when the RightClickMenu requests that we spawn a new node and connect
## it's input to some existing node.
func _on_right_click_menu_spawn_node_to(desc, spawn_pos, from_node, from_port):
	var new_node: GraphNode = _spawn_node(desc)
	new_node.position_offset = spawn_pos
	$GraphEdit.connect_node(from_node, from_port, new_node.name, 0)	

## Called when the GraphEdit requests that we delete a list of nodes.
func _on_graph_edit_delete_nodes_request(nodes):
	for node_name in nodes:
		var node_to_delete = $GraphEdit.get_node(node_name as NodePath) 
		delete_node(node_to_delete)

## Called when the GraphEdit requests that we connect two nodes together.
func _on_graph_edit_connection_request(from_node, from_port, to_node, to_port):
	# If the hovering node is already connected to something else, INGORE this
	if _is_node_port_connected(from_node, from_port):
		return
	
	$GraphEdit.connect_node(from_node, from_port, to_node, to_port)

## Called when the GraphEdit requests that we remove an existing connection.
func _on_graph_edit_disconnection_request(from_node, from_port, to_node, to_port):
	$GraphEdit.disconnect_node(from_node, from_port, to_node, to_port)
	
## Called when the GraphEdit selects a node.
func _on_graph_edit_node_selected(node):
	_selected_nodes.push_back(node)
	node_selected.emit(node)

## Called when the GraphEdit deselects a previously selected node.
func _on_graph_edit_node_deselected(node):
	if not node in _selected_nodes:
		return
	
	node_deselected.emit(node)
	_selected_nodes.erase(node)

func _on_node_remove_connections_request(node_name: String, side: int, slot: int) -> void:
	# If side is not set correctly, exit early
	if not (side == 1 or side == -1):
		return
	
	# Save all connections that reference this node. conn is in the form of
	# { 
	#	from_port: 0, 
	#	from: "GraphNode name 0", 
	#	to_port: 1, 
	#	to: "GraphNode name 1" 
	# }
	var connections_to_remove = []
	for conn in $GraphEdit.get_connection_list():
		if side == -1 and conn.to_port == slot and conn.to == node_name:
			connections_to_remove.push_back(conn)
		elif side == 1 and conn.from_port == slot and conn.from == node_name:
			connections_to_remove.push_back(conn)
			
	# Actually remove all of those saved connections
	for conn in connections_to_remove:
		$GraphEdit.disconnect_node(conn.from, conn.from_port, conn.to, conn.to_port)
	
