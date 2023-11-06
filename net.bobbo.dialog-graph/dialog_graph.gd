@tool
extends Resource
class_name DialogGraph

#
#	Exports
#

## All of the nodes in the graph, stored by ID (int -> GraphNodeData)
@export var all_nodes: Dictionary = {
	0: EntryNodeData.new()
}

## A list of connections between the nodes in the graph
@export var connections: Array[NodeConnection] = []

#
#	Private Variables
#

var _last_id: int = 0

#
#	Public Functions
#

# Create a dict that allows us to get the index of a node using it's data
func create_node_to_index_map() -> Dictionary:
	var nodes_to_index: Dictionary = {}
	for index in all_nodes.keys():
		nodes_to_index[all_nodes[index]] = index
		
	return nodes_to_index

func update_nodes(new_data: Array[GraphNodeData]) -> void:
	var nodes_to_index = create_node_to_index_map()
	
	# Cache all data that isn't in the current node list.
	# Keep track of the largest ID
	# Store data that IS in the current node list, in the correct data map
	var correct_data_map: Array = []
	var data_without_index: Array[GraphNodeData] = []
	var largest_id = 0
	for data in new_data:
		var found_index = nodes_to_index.get(data, -1)
		if found_index == -1:
			data_without_index.push_back(data)
			continue
		
		if found_index > largest_id:
			largest_id = found_index
			
		correct_data_map.push_back([found_index, data])
		
	# Assign indexes to data that needs it
	for data in data_without_index:
		largest_id += 1
		correct_data_map.push_back([largest_id, data])
		
	# Sort the correct data map by it's indexes
	correct_data_map.sort_custom(func(a, b): return a[0] < b[0])
	
	# Apply the new dict
	all_nodes.clear()
	for data_pair in correct_data_map:
		all_nodes[data_pair[0]] = data_pair[1]
	_last_id = largest_id
	

func clear() -> void:
	all_nodes.clear()
	connections.clear()
	_last_id = -1

func add_node(data: GraphNodeData) -> int:
	var new_id = _get_next_id()
	all_nodes[new_id] = data
	return new_id

func contains_id(id: int) -> bool:
	return id in all_nodes

func connect_node(new_connection: NodeConnection) -> bool:
	if not contains_id(new_connection.from_id) or not contains_id(new_connection.to_id):
		return false
		
	connections.push_back(new_connection)
	return true
	
## Given a list of new connections, update the internal connections array
## to match the same connections but RE-USE the previously used resources
func update_connections(new_connections: Array[NodeConnection]) -> void:
	# Re-use as many connection resources as we can
	for x in range(0, min(connections.size(), new_connections.size())):
		new_connections[x].copy_to(connections[x])
	# If we have less new connections than we are storing...
	# ...then Remove all now unused connections
	if new_connections.size() < connections.size():
		while new_connections.size() < connections.size():
			connections.pop_back()
	# If we have more new connections than we are storing...
	# ...then add all brand new connections
	elif new_connections.size() > connections.size():
		for x in range(connections.size(), new_connections.size()):
			connections.push_back(new_connections[x])

func get_entry_id() -> int:
	for id in all_nodes.keys():
		var node = all_nodes[id]
		if node is EntryNodeData:
			return id
			
	return -1
	
func get_node_data(id: int) -> GraphNodeData:
	return all_nodes[id]
	
func find_id_from_data(data: GraphNodeData) -> int:
	for id in all_nodes.keys():
		if all_nodes[id] == data:
			return id
			
	return -1
	
## Returns a list of all connections from or to the given node
func get_connections_to_and_from(id: int) -> Array[NodeConnection]:
	return connections.filter(
		func(conn): return conn.from_id == id or conn.to_id == id
	)

## Returns a list of all connections from the given node
func get_connections_from(id: int) -> Array[NodeConnection]:
	return connections.filter(
		func(conn): return conn.from_id == id
	)
	
## Returns a list of all connections to the given node
func get_connections_to(id: int) -> Array[NodeConnection]:
	return connections.filter(
		func(conn): return conn.to_id == id
	)
	
#
#	Private Functions
#

func _init_last_id() -> int:
	if all_nodes.size() > 0:
		return all_nodes.keys().max()
	else:
		return 0

func _get_next_id() -> int:
	if _last_id == -1:
		_last_id = _init_last_id()
	
	_last_id += 1
	return _last_id	
