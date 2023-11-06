@tool
extends PanelContainer
class_name ChoicePromptOptionContainer

#
#	Exports
#

signal settings_visibility_changed(is_visible: bool)
signal text_changed(new_text: String)

#
#	Private Variables
#

var _line_label: Label
var _line_edit: LineEdit
var _settings_button: Button
var _settings_container: Control
var _settings_open = false

#
#	Godot Functions
#

func _ready():
	_line_label = $MarginContainer/VBoxContainer/OptionEditContainer/LineLabel
	_line_edit = $MarginContainer/VBoxContainer/OptionEditContainer/LineEdit
	_settings_button = $MarginContainer/VBoxContainer/OptionEditContainer/SettingsButton
	_settings_container = $MarginContainer/VBoxContainer/OptionSettingsContainer
	_set_settings_open(false)

#
#	Pulic Functions
#

func setup(index: int):
	_line_label.text = "%s:" % index
	
func get_text() -> String:
	return _line_edit.text
	
func set_text(new_text: String) -> void:
	_line_edit.set_text(new_text)

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
