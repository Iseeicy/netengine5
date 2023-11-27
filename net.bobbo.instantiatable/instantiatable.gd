@tool
extends Resource
class_name Instantiatable

#
#	Types
#

## The potential sources that this will use to instantiate a new object
enum SourceType {
	SCRIPT,			## A new node will be created with this script attached
	PACKED_SCENE,	## A scene will be instantiated
}

#
#	Exports
#

## The type of source that will be used, when instantiating
@export var type: SourceType = SourceType.SCRIPT:
	set(val):
		# Update the value and tell Godot to refresh the inspector
		type = val
		notify_property_list_changed()

#
#	Private Variables
#

## The current source, if `type` is SCRIPT.
var _script: Script = null:
	set(value):
		if value == null:
			_script = null
			return
		
		if not _is_script_valid(value):
			printerr("'%s' is not a valid Script" % value)
			return
		
		_script = value

## The current source, if `type` is PACKED_SCENE
var _packed_scene: PackedScene = null:
	set(value):
		if value == null:
			_packed_scene = null
			return
		
		if not _is_packed_scene_valid(value):
			printerr("'%s' is not a valid PackedScene" % value)
			return
		
		_packed_scene = value

#
#	Godot Functions
#

func _get_property_list():
	var properties: Array[Dictionary] = []
	properties.append({
		"name": "_packed_scene",
		"type": TYPE_OBJECT,
		"usage": _usage_for_type(SourceType.PACKED_SCENE),
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		"hint_string": "PackedScene"
	})
	properties.append({
		"name": "_script",
		"type": TYPE_OBJECT,
		"usage": _usage_for_type(SourceType.SCRIPT),
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		"hint_string": "Script"
	})
	
	return properties

#
#	Public Functions
#

## Instantiate the source.
## Returns a node of some kind, depending on the source. Can return null if
## something is configured incorrectly.
func instantiate() -> Node:
	match type:
		SourceType.SCRIPT:
			if _script == null: return null
			var node = ClassDB.instantiate(_script.get_instance_base_type())
			if not node is Node: return null
			
			node.script = _script
			return node
		SourceType.PACKED_SCENE:
			return _packed_scene.instantiate()
	return null

#
#	Virtual Functions
#

## Is the given script a valid source that we could use?
func _is_script_valid(script: Script) -> bool:
	return true

## Is the given packed scene a valid source that we could use?
func _is_packed_scene_valid(packed_scene: PackedScene) -> bool:
	return true

#
#	Private Functions
#

func _usage_for_type(required_type: SourceType) -> int:
	if type == required_type:
		return PROPERTY_USAGE_DEFAULT
	else:
		return PROPERTY_USAGE_NO_EDITOR
