@tool
## A node that controls generic TextWindow behavior, such
## as showing dialog and prompting the player with a choice.
## On it's own this doesn't do much - it just provides a
## common interface for other nodes to work with, then hands 
## off any responsibilities via a set of signals.
extends Control
class_name TextWindow

#
#	Exported
#

## Emitted when the state of this TextWindow's state machine
## is updated.
signal state_changed(state: TextWindowState, path: String)
## Emitted when new dialog is to be shown in this TextWindow
signal dialog_shown(dialog: TextWindowDialog)
## Emitted when a choice is to be prompted in this TextWindow
signal choice_prompt_shown(prompt: TextWindowChoicePrompt)
## Emitted when a choice is hovered over, but not chosen
signal choice_hovered(index: int, prompt: TextWindowChoicePrompt)
## Emitted when a choice is committed to
signal choice_confirmed(index: int, prompt: TextWindowChoicePrompt)
## Emitted when dialog that is currently being shown should be
## fast-forwarded through
signal fast_forwarded()
## Emitted when this TextWindow is closed
signal closed()

#
#	Variables
#

@onready var _state_machine: TextWindowStateMachine = $StateMachine
var current_choice_prompt: TextWindowChoicePrompt = null
var current_dialog: TextWindowDialog = null

#
#	Godot Functions
#

#
#	Functions
#

## Display dialog with this TextWindow
func show_dialog(dialog: TextWindowDialog) -> void:
	current_dialog = dialog
	dialog_shown.emit(dialog)
	
## Prompt the user to make a choice with this TextWindow
func show_choice_prompt(prompt: TextWindowChoicePrompt) -> void:
	current_choice_prompt = prompt
	choice_prompt_shown.emit(prompt)
	
## Fast forward to the end of any dialog being displayed
## on this TextWindow
func fast_forward() -> void:
	fast_forwarded.emit()
	
## Get the currently displaying dialog
func get_dialog() -> TextWindowDialog:
	return current_dialog
	
## Get the currently displaying choice prompt
func get_choice_prompt() -> TextWindowChoicePrompt:
	return current_choice_prompt

## Hover over a choice in the current choice prompt.
## - Returns true if the given index is in bounds
## - Returns false if the given index is out of bounds
func hover_choice(choice_index: int) -> bool:
	if current_choice_prompt == null:
		return false
	if choice_index < 0 or choice_index >= current_choice_prompt.choices.size():
		return false
		
	choice_hovered.emit(choice_index, current_choice_prompt)
	return true

## Confirm and commit to a choice in the current choice prompt.
## - Returns true if the given index is in bounds
## - Returns false if the given index is out of bounds
func confirm_choice(choice_index: int) -> bool:
	if current_choice_prompt == null:
		return false
	if choice_index < 0 or choice_index >= current_choice_prompt.choices.size():
		return false
		
	choice_confirmed.emit(choice_index, current_choice_prompt)
	return true
	
## Close this TextWindow
func close() -> void:
	closed.emit()
	
## Get the current active state of this TextWindow's state machine.
func get_state() -> TextWindowState:
	return _state_machine.state

#
#	Signals
#

func _on_state_machine_transitioned(state, path):
	state_changed.emit(state, path)
