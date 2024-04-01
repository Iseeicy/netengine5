extends Resource
class_name CharacterDefinition

#
#	Exports
#

## The display name of this character.
@export var name: String = "UNNAMED"

## The default values of untyped data belonging to this character.
## TODO - Make custom editor for this that makes it easier to work with
@export var default_data: Dictionary = {}

@export_group("Text Reading")
## An optional set of settings used when a TextReader is showing dialog from
## this character.
@export var text_reader_settings: TextReaderSettings = null

#
#	Public Variables
#

## The runtime values of untyped data belonging to this character
var data: Dictionary:
	get:
		if _data_raw == null:
			_data_raw = default_data.duplicate(true)
		return _data_raw

#
#	Private Variables
#

## Raw untyped Dictionary (NO TYPE hint so it can be null) backing
## the `data` property.
var _data_raw = null

## Is this character currenty located in-game?
var _is_physical: bool = false

## If not null, this node's position is the character's physical position
var _tracked_node = null

## If _tracked_node is null, this is the character's physical position
var _position = Vector3.ZERO

#
#	Functions
#

## Is this character currently located in the game world?
func is_physical() -> bool:
	return _is_physical

## Get the node that this character is currently tracked to. Expected to have
## a `.position` property.
func get_tracked_node():
	return _tracked_node
	
## Assign a node for this character to track to. This will override the return
## result of `.get_position()` to be the global position of this node.
func set_tracked_node(node):
	_tracked_node = node
	if node:
		_is_physical = true

## The position of this character in the game world. Uses the tracked node if
## set, otherwise just uses an internal position variable.
func get_position():
	if _tracked_node:
		return _tracked_node.global_position
	
	return _position
	
## Set the internal position of this character, which is used if there's no
## tracked node set.
func set_position(pos):
	_position = pos
	_is_physical = true
