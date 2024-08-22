@tool
## A static class intended to assist with ProjectSettings for this plugin.
class_name DialogGraphProjectSettings
extends RefCounted

#
#   Constants
#

## The ProjectSettings key of the DialogGraphNodeDescriptor Array for
## GraphNodeDB to use.
const DESCRIPTORS_SETTINGS_KEY := "netengine5/dialog_graph/descriptors"

## The default value of the setting at DESCRIPTORS_SETTINGS_KEY
const DEFAULT_DESCRIPTORS := [
	preload("nodes/entry/entry_desc.tres").resource_path,
	preload("nodes/dialog_text/dialog_text_desc.tres").resource_path,
	preload("nodes/choice_prompt/choice_prompt_desc.tres").resource_path,
	preload("nodes/forwarder/forwarder_desc.tres").resource_path,
]

#
#   Public Functions
#


## Setup `net.bobbo.dialog-graph`'s ProjectSettings. Intended to only be called
## internally by this plugin.
static func internal_setup() -> void:
	_setup_descriptors_property()
	ProjectSettings.save()


## Get the DialogGraphNodeDescriptors identified in ProjectSettings.
static func get_descriptors() -> Array[DialogGraphNodeDescriptor]:
	var descriptor_paths: Array = ProjectSettings.get_setting(
		DESCRIPTORS_SETTINGS_KEY, DEFAULT_DESCRIPTORS
	)

	# Load all DialogGraphNodeDescriptors from our settings
	var results: Array[DialogGraphNodeDescriptor] = []
	for path in descriptor_paths:
		# Sometimes a path can be an empty string - skip if that's the case.
		if not path:
			continue

		# Load the resource at the given path, and add it to our results if the
		# resource is actually a DialogGraphNodeDescriptor
		var loaded_resource = load(path)
		if loaded_resource is DialogGraphNodeDescriptor:
			results.append(loaded_resource)
	return results


#
#	Private Functions
#


## Setup the settings for DESCRIPTORS_SETTINGS_KEY in ProjectSettings. This
## will ensure that the property is displayed correctly in the GUI, and ensure
## that a default value is set correctly.
static func _setup_descriptors_property() -> void:
	if not ProjectSettings.has_setting(DESCRIPTORS_SETTINGS_KEY):
		ProjectSettings.set_setting(
			DESCRIPTORS_SETTINGS_KEY, DEFAULT_DESCRIPTORS
		)

	ProjectSettings.add_property_info(
		{
			name = DESCRIPTORS_SETTINGS_KEY,
			type = TYPE_ARRAY,
			hint = PROPERTY_HINT_TYPE_STRING,
			hint_string = "%d/%d:*.tres" % [TYPE_STRING, PROPERTY_HINT_FILE]
		}
	)
	ProjectSettings.set_as_basic(DESCRIPTORS_SETTINGS_KEY, true)
	ProjectSettings.set_as_internal(DESCRIPTORS_SETTINGS_KEY, false)
	ProjectSettings.set_initial_value(
		DESCRIPTORS_SETTINGS_KEY, DEFAULT_DESCRIPTORS
	)
