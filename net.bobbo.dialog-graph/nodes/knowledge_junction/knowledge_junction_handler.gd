@tool
extends DialogRunnerActiveHandlerState

#
#	Variables
#

var condition_data: KnowledgeJunctionNodeData:
	get:
		return data as KnowledgeJunctionNodeData

## Translates between the index of a visible condition, and the condition's actual
## index in the data it's from. This is to account for potentially non-visible
## condition.
var _condition_index_translation: Dictionary = {}

#
#	State Functions
#

func state_enter(_message: Dictionary = {}) -> void:
	_get_parent_state().state_enter(_message)
	text_window.request_choice_hover.connect(_on_text_window_request_choice_hover.bind())
	text_window.request_choice_confirm.connect(_on_text_window_request_choice_confirm.bind())
	text_window.choice_confirmed.connect(_on_text_window_choice_confirm.bind())
	
	_condition_index_translation.clear()
	var visible_conditions: Array[Dictionary] = []
	
	for index in range(0, condition_data.options.size()):
		# If there's no visibility condition to this choice, then it's always
		# considered visible.
		if condition_data.options[index].get(KnowledgeJunctionNodeData.CONDITIONS_VIS_COND_KEY, null) == null:
			_condition_index_translation[visible_conditions.size()] = index
			visible_conditions.push_back(condition_data.options[index])
			continue
	
		# If there IS a visibility condition, then if it's currently true,
		# then this condition is visible
		if condition_data.options[index][KnowledgeJunctionNodeData.CONDITIONS_VIS_COND_KEY].get_value():
			_condition_index_translation[visible_conditions.size()] = index
			visible_conditions.push_back(condition_data.options[index])

	# Construct the prompt to display in the text window
	var prompt = _options_to_condition(condition_data.text, visible_conditions)
	text_window.show_condition(prompt)
	
func state_exit() -> void:
	text_window.choice_confirmed.disconnect(_on_text_window_choice_confirm.bind())
	text_window.request_choice_confirm.disconnect(_on_text_window_request_choice_confirm.bind())
	text_window.request_choice_hover.disconnect(_on_text_window_request_choice_hover.bind())
	_get_parent_state().state_exit()

#
#	Private Functions
#

func _options_to_condition(text: String, options: Array[Dictionary]) -> TextWindowChoicePrompt:
	# Extract the text for each option and store it into an array
	var text_options: Array[String] = []
	for option in options:
		text_options.append(
			option.get(KnowledgeJunctionNodeData.CONDITIONS_TEXT_KEY, "")
		)
	
	return TextWindowChoicePrompt.create_prompt_with_text(text, text_options)

#
#	Signals
#

func _on_text_window_request_choice_hover(index: int) -> void:
	text_window.hover_choice(index)
	
## Called if the text window itself is requesting that we confirm
## a choice. This will happen if the text window has on-screen buttons
## that drive the choice selection.
func _on_text_window_request_choice_confirm(index: int) -> void:
	text_window.confirm_choice(index)

## Called when the text window has confirmed a choice
func _on_text_window_choice_confirm(visible_index: int, _prompt: TextWindowChoicePrompt) -> void:
	var index = _condition_index_translation[visible_index]
	
	# Get the connections to this condition node
	var connections = graph.get_connections_from(data)
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
