extends Resource
class_name CharacterSpeaker

#
#	Exported
#

@export var name: String = "UNNAMED"
@export var text_reader_settings: TextReaderSettings = null

var _is_physical: bool = false
var _tracked_node = null
var _position = Vector3.ZERO

#
#	Functions
#

func is_physical() -> bool:
	return _is_physical

func get_tracked_node():
	return _tracked_node
	
func set_tracked_node(node):
	_tracked_node = node
	if node:
		_is_physical = true

func get_position():
	if _tracked_node:
		return _tracked_node.global_position
	
	return _position
	
func set_position(pos):
	_position = pos
	_is_physical = true
