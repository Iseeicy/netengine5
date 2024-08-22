@tool
## A static class intended to assist with ProjectSettings for this plugin.
class_name DialogGraphProjectSettings
extends RefCounted

#
#   Constants
#

const DESCRIPTORS_SETTINGS_KEY := "netengine5/dialog_graph/descriptors"

const DEFAULT_DESCRIPTORS := [
	preload("nodes/entry/entry_desc.tres").resource_path,
	preload("nodes/dialog_text/dialog_text_desc.tres").resource_path,
	preload("nodes/choice_prompt/choice_prompt_desc.tres").resource_path,
	preload("nodes/forwarder/forwarder_desc.tres").resource_path,
]

#
#   Static Functions
#


static func internal_setup() -> void:
	# Setup the DialogGraphNodeDescriptor field
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

	if not ProjectSettings.has_setting(DESCRIPTORS_SETTINGS_KEY):
		ProjectSettings.set_setting(
			DESCRIPTORS_SETTINGS_KEY, DEFAULT_DESCRIPTORS
		)

	# Save our changes
	ProjectSettings.save()


static func get_descriptors() -> Array[DialogGraphNodeDescriptor]:
	var descriptor_paths: Array = ProjectSettings.get_setting(
		DESCRIPTORS_SETTINGS_KEY, DEFAULT_DESCRIPTORS
	)

	# Load all DialogGraphNodeDescriptors from our settings
	var descriptors: Array[DialogGraphNodeDescriptor] = []
	for path in descriptor_paths:
		if not path:
			continue

		var loaded_resource = load(path)
		if loaded_resource is DialogGraphNodeDescriptor:
			descriptors.append(loaded_resource)

	return descriptors
