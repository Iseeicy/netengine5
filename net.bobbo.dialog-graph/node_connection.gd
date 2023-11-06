## Represents a connection between two nodes in an easily serializable way.
extends Resource
class_name NodeConnection

#
#	Public Variables
#

## The ID of the node that this connection starts from
@export var from_id: int = -1

## The port on the node that this connection starts from
@export var from_port: int = 0

## The ID of the node that this connection goes to
@export var to_id: int = -1

## The port on the node that this connection goes to
@export var to_port: int = 0

#
#	Public Functions
#

## Copy the properties of this connection to another connection.
func copy_to(other: NodeConnection) -> void:
	other.from_id = self.from_id
	other.from_port = self.from_port
	other.to_id = self.to_id
	other.to_port = self.to_port

#
#	Static Functions
#

## Create a new connecion object in memory given details about the connection
static func create(node_from_id: int, node_from_port: int, node_to_id: int, node_to_port: int) -> NodeConnection:
	var connection = NodeConnection.new()
	connection.from_id = node_from_id
	connection.from_port = node_from_port
	connection.to_id = node_to_id
	connection.to_port = node_to_port
	
	return connection
