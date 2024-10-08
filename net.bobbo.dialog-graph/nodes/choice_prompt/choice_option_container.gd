@tool
class_name ChoicePromptOptionContainer
extends PanelContainer

#
#	Exports
#

signal settings_visibility_changed(is_visible: bool)
signal text_changed(new_text: String)
signal visibility_condition_changed(condition: KnowledgeBool)

#
#	Private Variables
#

var _line_label: Label
var _line_edit: LineEdit
var _settings_button: Button
var _settings_container: Control
var _condition_resource_field: ResourceField
var _settings_open = false

#
#	Godot Functions
#


func _ready():
	var vbox_container := $MarginContainer/VBoxContainer
	_line_label = vbox_container.get_node("OptionEditContainer/LineLabel")
	_line_edit = vbox_container.get_node("OptionEditContainer/LineEdit")
	_settings_button = vbox_container.get_node(
		"OptionEditContainer/SettingsButton"
	)
	_settings_container = vbox_container.get_node("OptionSettingsContainer")
	_condition_resource_field = vbox_container.get_node(
		"OptionSettingsContainer/HBoxContainer/KnowledgeBoolResourceField"
	)
	_set_settings_open(false)


#
#	Pulic Functions
#


func setup(index: int):
	_line_label.text = "%s:" % index


func get_text() -> String:
	return _line_edit.text


func set_option(new_option: Dictionary) -> void:
	_line_edit.set_text(
		new_option.get(ChoicePromptNodeData.OPTIONS_TEXT_KEY, "")
	)
	_condition_resource_field.set_target_resource(
		new_option.get(ChoicePromptNodeData.OPTIONS_VIS_COND_KEY, null)
	)


#
#	Private Functions
#


func _set_settings_open(is_open: bool):
	_settings_open = is_open
	_settings_container.visible = is_open

	if is_open:
		_settings_button.text = " ^ "
	else:
		_settings_button.text = " v "
	settings_visibility_changed.emit(is_open)


func _on_settings_button_pressed():
	_set_settings_open(!_settings_open)


func _on_line_edit_text_changed(new_text):
	text_changed.emit(new_text)


func _on_knowledge_bool_resource_field_target_resource_updated(resource):
	visibility_condition_changed.emit(resource)
