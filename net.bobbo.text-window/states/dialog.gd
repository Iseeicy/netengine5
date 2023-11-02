@tool
extends TextWindowState

#
#	Exported
#

@export_group("Required References")
## (OPTIONAL) The node containing the window's header label.
## This is made visible/invisible when relevant
@export var header_container: Control
## A label used to display the current character name if relevant
@export var header_label: Control
## The node containing the main text content used for dialog
## This is made visible/invisible when relevant
@export var text_content: Control
## The TextReader to use when displaying dialog text
@export var text_reader: TextReader

#
#	State Functions
#

func state_enter(_message: Dictionary = {}) -> void:
	_parent_state.state_enter(_message)
	
	if header_container:
		header_container.visible = true
	header_label.visible = true
	text_content.visible = true
	
func state_unhandled_input(event: InputEvent) -> void:
	_parent_state.state_unhandled_input(event)
	
func state_process(delta: float) -> void:
	_parent_state.state_process(delta)
	
func state_physics_process(delta: float) -> void:
	_parent_state.state_physics_process(delta)
	
func state_exit() -> void:
	_parent_state.state_exit()
	
	if header_container:
		header_container.visible = false
	header_label.visible = false
	text_content.visible = false
	
