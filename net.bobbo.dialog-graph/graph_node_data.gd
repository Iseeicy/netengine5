## Represents basic data relating to a GraphNode. Meant to be extended.
@tool
extends RefCounted
class_name GraphNodeData

#
#	Public Variables
#

## The identifier of this node in the Graph that it belongs to.
var id: int = 0:
	get:
		return _internal_data.get("_i", -1)
	set(new_id):
		_internal_data["_i"] = new_id

## The position of this node in the graph that it belongs to.
var position: Vector2 = Vector2.ZERO:
	get:
		return _internal_data.get("_p", Vector2.ZERO)
	set(new_position):
		_internal_data["_p"] = new_position

## The descriptor that this node belongs to.
var descriptor: DialogGraphNodeDescriptor:
	get:
		return _internal_data.get("_d", null)
	set(new_descriptor):
		_internal_data["_d"] = new_descriptor

#
#	Private Variables
#

## The internal dictionary that backs all data for this type.
var _internal_data: Dictionary = {}

#
#	Public Functions
#

## Get the dictionary that backs this type
func get_dict() -> Dictionary:
	return _internal_data
	
## Set the dictionary that backs this type
func set_dict(new_dict: Dictionary) -> void:
	_internal_data = new_dict
