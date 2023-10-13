extends TextWindowState

func _ready():
	_get_parent_state().text_reader.reading_finished.connect(
		_on_text_reader_finished.bind()
	)

#
#	State Functions
#

func state_enter(_message: Dictionary = {}) -> void:
	_parent_state.state_enter(_message)
	
	var dialog = _message.get("dialog", null) as TextWindowDialog
	if dialog == null:
		_parent_state.text_reader.cancel_reading()
		_parent_state.header_label.text = ""
		return
		
	_parent_state.text_reader.start_reading(
		dialog.text,
		dialog.character.text_reader_settings
	)
	
	# Get the character name
	var character_name: String = ""
	if dialog.character != null:
		character_name = dialog.character.name
	character_name = _message.get("character_name", character_name)
	
	# Apply the character name
	_parent_state.header_label.text = character_name
	
func state_unhandled_input(event: InputEvent) -> void:
	_parent_state.state_unhandled_input(event)
	
func state_process(delta: float) -> void:
	_parent_state.state_process(delta)
	
func state_physics_process(delta: float) -> void:
	_parent_state.state_physics_process(delta)
	
func state_exit() -> void:
	_parent_state.state_exit()

#
#	Signals
#

# Called by the text window when dialog should be shown
func _on_text_window_dialog_shown(dialog):
	# Transition to this state if dialog should be played!
	_state_machine.transition_to(_state_path, { "dialog": dialog })

# Called by the text window when dialog should be fast forwarded
func _on_text_window_fast_forwarded():
	if _state_machine.state != self:
		return

	# If this is the active state, then just skip to the next state
	_state_machine.transition_to("Open/Dialog/Shown")
	
# Called by the text reader whenever text has be finished
func _on_text_reader_finished(reason: TextReader.ReadFinishReason):
	if _state_machine.state != self:
		return
		
	# If this is the active state, go to the next one
	_state_machine.transition_to("Open/Dialog/Shown")
