@tool
extends DialogRunnerActiveHandlerState

#
#	Public Variables
#

var choice_data: ChoicePromptNodeData:
	get:
		return data as ChoicePromptNodeData

#
#	State Functions
#

func state_enter(_message: Dictionary = {}) -> void:
	_get_parent_state().state_enter(_message)
	text_window.request_choice_hover.connect(_on_text_window_request_choice_hover.bind())
	text_window.request_choice_confirm.connect(_on_text_window_request_choice_confirm.bind())
	text_window.choice_confirmed.connect(_on_text_window_choice_confirm.bind())
	
	# Construct the prompt to display in the text window
	var prompt = TextWindowChoicePrompt.create_prompt_with_text(
		choice_data.text, 
		choice_data.choices
	)
	
	text_window.show_choice_prompt(prompt)
	
func state_exit() -> void:
	text_window.choice_confirmed.disconnect(_on_text_window_choice_confirm.bind())
	text_window.request_choice_confirm.disconnect(_on_text_window_request_choice_confirm.bind())
	text_window.request_choice_hover.disconnect(_on_text_window_request_choice_hover.bind())
	_get_parent_state().state_exit()
	
#
#	Signals
#

## Called if the text window itself is requesting that we hover
## a choice. This will happen if the text window has on-screen buttons
## that drive the choice selection.
func _on_text_window_request_choice_hover(index: int) -> void:
	text_window.hover_choice(index)
	
## Called if the text window itself is requesting that we confirm
## a choice. This will happen if the text window has on-screen buttons
## that drive the choice selection.
func _on_text_window_request_choice_confirm(index: int) -> void:
	text_window.confirm_choice(index)

## Called when the text window has confirmed a choice
func _on_text_window_choice_confirm(index: int, _prompt: TextWindowChoicePrompt) -> void:
	# Get the connections to this choice node
	var connections = graph.get_connections_from(id)
	var translated_index = -1
	
	# Try to find the connection that uses our chosen index
	var i = 0
	for conn in connections:
		if conn.from_port == index:
			translated_index = i
			break
		else:
			i += 1
	
	go_to_next_node(translated_index)
