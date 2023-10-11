extends Control
class_name TextWindow

#
#	Exported
#
signal state_changed(state: TextWindowState, path: String)
signal dialog_shown(dialog: TextWindowDialog)
signal choice_prompt_shown(prompt: TextWindowChoicePrompt)
signal choice_hovered(index: int, prompt: TextWindowChoicePrompt)
signal choice_confirmed(index: int, prompt: TextWindowChoicePrompt)
signal fast_forwarded()
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

func show_dialog(dialog: TextWindowDialog) -> void:
	current_dialog = dialog
	dialog_shown.emit(dialog)
	
func show_choice_prompt(prompt: TextWindowChoicePrompt) -> void:
	current_choice_prompt = prompt
	choice_prompt_shown.emit(prompt)
	
func fast_forward() -> void:
	fast_forwarded.emit()
	
func get_dialog() -> TextWindowDialog:
	return current_dialog
	
func get_choice_prompt() -> TextWindowChoicePrompt:
	return current_choice_prompt

func hover_choice(choice_index: int) -> bool:
	if current_choice_prompt == null:
		return false
	if choice_index < 0 or choice_index >= current_choice_prompt.choices.size():
		return false
		
	choice_hovered.emit(choice_index, current_choice_prompt)
	return true

func confirm_choice(choice_index: int) -> bool:
	if current_choice_prompt == null:
		return false
	if choice_index < 0 or choice_index >= current_choice_prompt.choices.size():
		return false
		
	choice_confirmed.emit(choice_index, current_choice_prompt)
	return true
	
func close() -> void:
	closed.emit()
	
func get_state() -> TextWindowState:
	return _state_machine.state

#
#	Signals
#

func _on_state_machine_transitioned(state, path):
	state_changed.emit(state, path)
