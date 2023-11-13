@tool
extends Resource
class_name PackedDialogGraph

#
#	Exports
#

## All of the nodes in the graph. Elements are shallow copies of the dict that
## GraphNodeData is backed by.
@export var nodes: Array[Dictionary] = []
## A list of connections between the nodes in the graph. Elements are dicts in
## the format of { "from_id": int, "from_port": int, "to_id": int, "to_port": int }
@export var connections: Array[Dictionary] = []

#
#	Private Variables
#

## The last ID used for a node. Valid IDs should always be positive.
var _last_id: int = -1

#
#	Public Functions
#

## Clear all nodes and connections
func clear() -> void:
	nodes.clear()
	connections.clear()
	_last_id = -1

## Ensures that there is one entry node in this graph.
func ensure_entry_node() -> void:
	# If we have an entry node, EXIT EARLY
	if _has_node_with_descriptor(GraphNodeDB.find_descriptor_by_name("Entry")):
		return
	
	# OTHERWISE - no entry node. Let's add one!
	var new_entry_data = GraphNodeDB.create_data("Entry")
	add_node(new_entry_data)

## Returns the node dict belonging to the given ID if there is one 
## Returns null otherwise
func get_node_dict(id: int):
	for node_dict in nodes:
		if node_dict.get("_i", null) == id:
			return node_dict
	return null

## Does the graph contain this ID?
func has_id(id: int) -> bool:
	return get_node_dict(id) != null

## Add a new node to the graph given it's data.
## Returns the ID of the new node.
func add_node(data: GraphNodeData) -> int:
	var new_id = _get_next_id()
	data.id = new_id
	nodes.push_back(data.get_dict().duplicate())
	_sort_nodes()
	return new_id

## Adds multiple new nodes to the graph, given their data.
## Returns a dict mapping the ID of the new node to it's data 
# (GraphNodeData -> int). This is more performant than running `add_node` a
# bunch.
func add_many_nodes(many_data: Array[GraphNodeData]) -> Dictionary:
	var index_map: Dictionary = {}
	
	for data in many_data:
		var new_id = _get_next_id()
		data.id = new_id
		nodes.push_back(data.get_dict().duplicate())
		index_map[data] = new_id
	
	_sort_nodes()
	return index_map

## Overrides the node dictionary with many new nodes, given their data.
## This is different than `add_many_nodes` because it resets the entire node
## array, and uses the IDs already found in the given data rather than
## assigning new IDs. This CLEARS ALL CONNECTIONS!
func set_nodes(many_data: Array[GraphNodeData]) -> Dictionary:
	# If there's no data, just clear and EXIT EARLY
	if many_data.size() == 0:
		clear()
		return {}
	
	# OTHERWISE, there is TOTALLY data to set!
	var index_map: Dictionary = {}
	var new_nodes: Array[Dictionary] = []
	var largest_id = many_data[0].id
	
	for data in many_data:
		# Keep track of the largest ID
		if data.id > largest_id:
			largest_id = data.id
		
		# Duplicate the node data to hold it
		new_nodes.push_back(data.get_dict().duplicate())
		
		# Keep track of what data maps to which ID
		index_map[data] = data.id
	
	# Apply changes!
	nodes = new_nodes
	_last_id = largest_id
	connections.clear()
	_sort_nodes()
	
	return index_map

## Remove an existing node from graph, given it's ID.
## Returns true if the node was removed, false otherwise.
func remove_node(id: int) -> bool:
	var node_dict_to_remove = get_node_dict(id)
	
	var conns_to_remove: Array[Dictionary] = []
	for conn in connections:
		if conn["from_id"] == id or conn["to_id"] == id:
			conns_to_remove.append(conn)
		
	if node_dict_to_remove != null:
		nodes.erase(node_dict_to_remove)
	for conn_to_remove in conns_to_remove:
		connections.erase(conn_to_remove)
	
	return node_dict_to_remove != null

## Connects two nodes together. Returns true if it worked, false otherwise.
func connect_nodes(from_id: int, from_port: int, to_id: int, to_port: int) -> bool:
	if not has_id(from_id) or not has_id(to_id):
		return false
	
	var new_connection: Dictionary = {}
	new_connection["from_id"] = from_id
	new_connection["from_port"] = from_port
	new_connection["to_id"] = to_id
	new_connection["to_port"] = to_port
	connections.append(new_connection)
	_sort_connections()
	return true

## Given an array of connections, connect them all. This is more performant than
## running `connect_nodes` a bunch.
func connect_many_nodes(new_connections: Array[Dictionary]) -> void:
	var cleaned_connections: Array[Dictionary] = []
	
	# Given our input connections, clean them and verify that they're valid
	# connections
	for conn in new_connections:
		var new_conn: Dictionary = {}
		new_conn["from_id"] = conn.get("from_id", null)
		if new_conn["from_id"] == null:
			continue
		new_conn["from_port"] = conn.get("from_port", null)
		if new_conn["from_port"] == null:
			continue
		new_conn["to_id"] = conn.get("to_id", null)
		if new_conn["to_id"] == null:
			continue
		new_conn["to_port"] = conn.get("to_port", null)
		if new_conn["to_port"] == null:
			continue
		if not has_id(new_conn["from_id"]) or not has_id(new_conn["to_id"]):
			continue
		cleaned_connections.append(new_conn)
	
	# Add all the new connections!
	connections.append_array(cleaned_connections)
	_sort_connections()

#
#	Private Functions
#

## Sort the connection array by each property
func _sort_connections() -> void:
	var sort_func = func(a, b):
		if a["from_id"] < b["from_id"]:
			return true
		elif a["from_id"] == b["from_id"]:
			if a["from_port"] < b["from_port"]:
				return true
			elif a["from_port"] == b["from_port"]:
				if a["to_id"] < b["to_id"]:
					return true
				elif a["to_id"] == b["to_id"]:
					if a["to_port"] <= b["to_port"]:
						return true
		return false
	connections.sort_custom(sort_func)

## Sort the node array by the ID of each node
func _sort_nodes() -> void:
	nodes.sort_custom(func(a, b): return a["_i"] < b["_i"])

## Return what the starting state of _last_id should be.
## This will either be the largest ID that has previously been used,
## or 0 if there aren't any nodes.
func _init_last_id() -> int:
	if nodes.size() <= 0:
		return -1
		
	var largest_id: int = nodes[0]["_i"]
	
	# Find the largest ID in the list of dicts
	for node_dict in nodes:
		if node_dict["_i"] > largest_id:
			largest_id = node_dict["_i"]
	return largest_id

## Generate the next ID for a node. This initializes _last_id if it
## has not been initialized yet.
func _get_next_id() -> int:
	if _last_id == -1:
		_last_id = _init_last_id()
	
	_last_id += 1
	return _last_id

func _has_node_with_descriptor(descriptor: DialogGraphNodeDescriptor) -> bool:
	for node_dict in nodes:
		if node_dict.get("_d", null) == descriptor:
			return true
	return false
