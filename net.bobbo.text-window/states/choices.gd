@tool
extends TextWindowState

#
#	Exported
#

@export_group("Required Scenes")
## The scene to instantiate for each choice, when a ChoicePrompt
## is shown on this TextWindow
@export var choice_button_scene: PackedScene

@export_group("Required References")
## The node that contains Controls relating to choices
## This is made visible/invisible when relevant.
@export var choice_contents: Control
## The node to spawn choice buttons underneath.
@export var choice_button_parent: Control
## The TextReader to cancel when choices are displayed.
@export var text_reader: TextReader

#
#	Variables
#

var _current_buttons: Array[Control] = []

#
#	State Functions
#

func state_enter(_message: Dictionary = {}) -> void:
	_parent_state.state_enter(_message)
	
	if text_reader.get_state() != TextReader.State.Empty:
		text_reader.cancel_reading()
		
	var prompt: TextWindowChoicePrompt = _message.get("prompt", null)
	
	_clean_choice_buttons()
	if prompt:
		_spawn_choice_buttons(prompt)
	
	choice_contents.visible = true
	
func state_unhandled_input(event: InputEvent) -> void:
	_parent_state.state_unhandled_input(event)
	
func state_process(delta: float) -> void:
	_parent_state.state_process(delta)
	
func state_physics_process(delta: float) -> void:
	_parent_state.state_physics_process(delta)
	
func state_exit() -> void:
	_parent_state.state_exit()
	
	choice_contents.visible = false
	_clean_choice_buttons()

#
#	Private Functions
#

func _clean_choice_buttons():
	for child in _current_buttons:
		child.queue_free()
	_current_buttons.clear()

func _spawn_choice_buttons(prompt: TextWindowChoicePrompt):
	var index: int = 0
	for choice in prompt.choices:
		# Spawn a choice button for each choice
		var new_button = _add_new_button()
		
		# Apply metadata
		new_button.set_meta("prompt", prompt)
		new_button.set_meta("choice", choice)
		new_button.set_meta("choice_index", index)
		
		# Update the button's visuals
		if 'text' in new_button:
			new_button.text = choice.text
		
		# Connect the button's signals
		_create_button_signals(new_button, index)
		index += 1

func _add_new_button() -> Control:
	var new_button = choice_button_scene.instantiate()
	choice_button_parent.add_child(new_button)
	_current_buttons.append(new_button)
	return new_button
	
func _create_button_signals(button: Control, index: int) -> void:
	var on_hover_func = func():
		# Have the text window request to hover this element. It's up
		# to whatever is controlling it to actually approve this.
		text_window.request_choice_hover.emit(index)
	
	var on_press_func = func():
		# Have the text window request to confirm this element. It's up
		# to whatever is controlling it to actually approve this.
		text_window.request_choice_confirm.emit(index)
	
	if 'focus_entered' in button:
		button.focus_entered.connect(on_hover_func.bind())
	if 'mouse_entered' in button:
		button.mouse_entered.connect(on_hover_func.bind())
	if 'pressed' in button:
		button.pressed.connect(on_press_func.bind())

#
#	Signals
#

# Called when the text window wants to display a choice prompt
func _on_text_window_choice_prompt_shown(prompt: TextWindowChoicePrompt):
	# Transition to this state if a choice prompt should be played!
	_state_machine.transition_to(_state_path, { "prompt": prompt })
