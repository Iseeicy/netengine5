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

## The body node of this character in-game, if there is one. Typically
## the root of the character. Should be either Node3D or Node2D.
var body_node: Variant:
	get: return body_node
	set(value):
		if not (value == null or value is Node2D or value is Node3D):
			push_warning("Tried to assign a value to `body_node` that isn't null, Node2D, or Node3D (%s)" % value)
			body_node = null
		else:
			body_node = value

## The head / aim direction node of this character in game, if there is
## one. Typically the head of the character, or where the character's camera
## would be. Should be either Node3D or Node2D.
var head_node: Variant:
	get: return head_node
	set(value):
		if not (value == null or value is Node2D or value is Node3D):
			push_warning("Tried to assign a value to `head_node` that isn't null, Node2D, or Node3D (%s)" % value)
			head_node = null
		else:
			head_node = value

## Is this character currently located in the game world?
var is_physical: bool:
	get: return body_node != null or head_node != null

#
#	Private Variables
#

## Raw untyped Dictionary (NO TYPE hint so it can be null) backing
## the `data` property.
var _data_raw = null
