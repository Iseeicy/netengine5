## Represents basic data relating to a GraphNode. Meant to be extended.
@tool
extends RefCounted
class_name GraphNodeData

const ID_KEY: String = "_i"
const POSITION_KEY: String = "_p"
const DESCRIPTOR_KEY: String = "_d"

#
#	Public Variables
#

## The identifier of this node in the Graph that it belongs to.
var id: int = 0:
	get:
		return _get_internal_data(ID_KEY, -1)
	set(new_id):
		_set_internal_data(ID_KEY, new_id)

## The position of this node in the graph that it belongs to.
var position: Vector2 = Vector2.ZERO:
	get:
		return _get_internal_data(POSITION_KEY, Vector2.ZERO)
	set(new_position):
		_set_internal_data(POSITION_KEY, new_position)

## The descriptor that this node belongs to.
var descriptor: DialogGraphNodeDescriptor:
	get:
		return _get_internal_data(DESCRIPTOR_KEY, null)
	set(new_descriptor):
		_set_internal_data(DESCRIPTOR_KEY, new_descriptor)

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
	
#
#	Private Functions
#

func _get_internal_data(key: String, default):
	if not key in _internal_data.keys():
		_internal_data[key] = default
	return _internal_data[key]

func _set_internal_data(key: String, value) -> void:
	_internal_data[key] = value
