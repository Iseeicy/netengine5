@tool
class_name RuntimeDialogGraph
extends RefCounted

#
#	Classes
#


## A structure used to store what nodes are connected to what
class Connection:
	extends RefCounted
	## The node that this connection starts from
	var from_node: GraphNodeData = null
	## The port that this connection is coming from, on `from_node`
	var from_port: int = -1
	## The node that this connection goes to
	var to_node: GraphNodeData = null
	## The port that this connection is going to, on `to_node`
	var to_port: int = -1


#
#	Private Variables
#

## All of the nodes, stored by ID (int -> GraphNodeData)
var _nodes: Dictionary = {}
## All of the connections in the graph
var _connections: Array[Connection] = []

#
#	Constructor
#


## Creates a new RuntimeDialogGraph, given a source packed graph to create from
func _init(source_graph: PackedDialogGraph) -> void:
	var new_nodes: Dictionary = {}
	var new_conns: Array[Connection] = []

	# Unpack all of the node data and store them in the above dict
	for node_dict in source_graph.nodes:
		var node_data = _unpack_node_data(node_dict)
		new_nodes[node_data.id] = node_data
	_nodes = new_nodes

	# Unpack all of the connections and store them in the above array
	for conn_dict in source_graph.connections:
		new_conns.append(_unpack_connection(conn_dict))
	_connections = new_conns


#
#	Public Functions
#


## Does this graph have a node with the given ID?
func has_id(id: int) -> bool:
	return id in _nodes.keys()


## Returns a node in the graph with the given ID. Returns null if there is no
## node with the given ID.
func get_node(id: int) -> GraphNodeData:
	return _nodes.get(id, null)


## Returns a list of all nodes in the graph.
func get_all_nodes() -> Array[GraphNodeData]:
	var correctly_typed_array: Array[GraphNodeData] = []
	for data in _nodes.values():
		correctly_typed_array.append(data)
	return correctly_typed_array


## Returns the entry node. Returns null if there is not an entry node.
func get_entry_node() -> GraphNodeData:
	for node in _nodes.values():
		if node is EntryNodeData:
			return node
	return null


## Returns a list of all connections in the graph.
func get_all_connections() -> Array[Connection]:
	return _connections


## Returns a list of all connections from or to the given node
func get_connections_to_and_from(node: GraphNodeData) -> Array[Connection]:
	return _connections.filter(
		func(conn): return conn.from_node == node or conn.to_node == node
	)


## Returns a list of all connections from the given node
func get_connections_from(node: GraphNodeData) -> Array[Connection]:
	return _connections.filter(func(conn): return conn.from_node == node)


## Returns a list of all connections to the given node
func get_connections_to(node: GraphNodeData) -> Array[Connection]:
	return _connections.filter(func(conn): return conn.to_node == node)


#
#	Private Functions
#


## Given some node data's dictionary, unpack it into an actual node data object.
func _unpack_node_data(node_dict: Dictionary) -> GraphNodeData:
	# Use the descriptor cached in the node dict to figure out what kind of
	# data structure to construct
	var desc: DialogGraphNodeDescriptor = node_dict[
		GraphNodeData.DESCRIPTOR_KEY
	]
	var data = desc.instantiate_data()

	# Supply the actual internal data to the data structure
	data.set_dict(node_dict)
	return data


## Given a packed connection, unpack it into a connection object we can use.
func _unpack_connection(conn_dict: Dictionary) -> Connection:
	var conn: Connection = Connection.new()
	conn.from_node = get_node(conn_dict["from_id"])
	conn.from_port = conn_dict["from_port"]
	conn.to_node = get_node(conn_dict["to_id"])
	conn.to_port = conn_dict["to_port"]
	return conn
