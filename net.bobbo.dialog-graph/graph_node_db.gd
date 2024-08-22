## A singleton class that acts as reference for what kinds of dialog nodes
## exist, and how to work with them.
@tool
class_name GraphNodeDB
extends RefCounted

#
#	Private Variables
#

var _descriptors: Array[DialogGraphNodeDescriptor]

#
#	Static Variables
#

## By extending RefCounted and creating a new instance of ourselves in a static
## variable, we can emulate a real singleton structure. This is better than
## using an autoload because we don't need access to the SceneTree and the
## singleton can exist without the user needing to enable the plugin, reducing
## parse errors.
static var _singleton := GraphNodeDB.new()

## A list of descriptors that represent what kind of dialog nodes exist.
## TODO - convert to maybe DialogGraphNodeDescriptor adding itself via a static
## constructor?
static var descriptors: Array[DialogGraphNodeDescriptor]:
	get:
		return _singleton._descriptors

#
#	Godot Functions
#


func _init():
	# Read the descriptors from the project settings
	var found_descriptors = DialogGraphProjectSettings.get_descriptors()
	_descriptors = []
	_descriptors.assign(found_descriptors)


#
#	Static Funcitons
#


## Given the name of a dialog node type, create a new instance of it's data
## object. Returns null if there is no node by `node_name` found.
static func create_data(node_name: String) -> GraphNodeData:
	var desc = find_descriptor_by_name(node_name)
	if desc == null:
		return null
	return desc.instantiate_data()


## Given the name of a dialog node type, find the `DialogGraphNodeDescriptor`
## that it belongs to. Returns null if there is no node by `node_name` found.
static func find_descriptor_by_name(
	node_name: String
) -> DialogGraphNodeDescriptor:
	for desc in descriptors:
		if desc.node_name == node_name:
			return desc
	return null


## Given some data script, find the descriptor that it belongs to.
static func find_descriptor_for_data_script(
	data_script: Script
) -> DialogGraphNodeDescriptor:
	for desc in descriptors:
		if desc.data_script == data_script:
			return desc
	return null


## Given some node data, find the descriptor that it belongs to.
static func find_descriptor_for_data(
	data: GraphNodeData
) -> DialogGraphNodeDescriptor:
	return find_descriptor_for_data_script(data.get_script())
