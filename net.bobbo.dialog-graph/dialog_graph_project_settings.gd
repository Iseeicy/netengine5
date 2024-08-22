@tool
## A static class intended to assist with ProjectSettings for this plugin.
class_name DialogGraphProjectSettings
extends RefCounted

#
#   Constants
#

const DESCRIPTORS_SETTINGS_KEY := "netengine5/dialog_graph/descriptors"

const DEFAULT_DESCRIPTORS := [
	preload("nodes/entry/entry_desc.tres"),
	preload("nodes/dialog_text/dialog_text_desc.tres"),
	preload("nodes/choice_prompt/choice_prompt_desc.tres"),
	preload("nodes/forwarder/forwarder_desc.tres"),
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
			hint = PROPERTY_HINT_RESOURCE_TYPE,
			hint_string = "DialogGraphNodeDescriptor"
		}
	)
	ProjectSettings.set_as_basic(DESCRIPTORS_SETTINGS_KEY, true)
	ProjectSettings.set_as_internal(DESCRIPTORS_SETTINGS_KEY, false)
	ProjectSettings.set_initial_value(
		DESCRIPTORS_SETTINGS_KEY, DEFAULT_DESCRIPTORS
	)

	# Save our changes
	ProjectSettings.save()


static func get_descriptors() -> Array:
	return ProjectSettings.get_setting(
		DESCRIPTORS_SETTINGS_KEY, DEFAULT_DESCRIPTORS
	)


static func set_descriptors(new_descriptors: Array) -> void:
	ProjectSettings.set_setting(DESCRIPTORS_SETTINGS_KEY, new_descriptors)
