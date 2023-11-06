@tool
extends DialogRunnerActiveHandlerState

#
#	Public Variables
#

var text_data: DialogTextNodeData:
	get:
		return data as DialogTextNodeData
		
var index: int

#
#	Private Variables
#

var _skip_instead_of_progress: bool

#
#	State Functions
#

func state_enter(_message: Dictionary = {}) -> void:
	_get_parent_state().state_enter(_message)
	runner.dialog_interacted.connect(_on_dialog_interacted.bind())
	text_window.state_changed.connect(_on_text_window_state_changed.bind())
	
	index = -1
	_skip_instead_of_progress = false
	_display_next_text()
	
func state_exit() -> void:
	text_window.state_changed.disconnect(_on_text_window_state_changed.bind())
	runner.dialog_interacted.disconnect(_on_dialog_interacted.bind())	
	_get_parent_state().state_exit()

#
#	Private Functions
#

func _display_next_text() -> void:
	# Fast forward instead of progressing to the next text in the dialog, if
	# necessary.
	if _skip_instead_of_progress:
		text_window.fast_forward()
		return
	
	index += 1
	
	# If we're out of text for this node, move on
	if index >= text_data.text.size():
		go_to_next_node()
		return
	
	# OTHERWISE - show this text!
	text_window.show_dialog(TextWindowDialog.create_text(text_data.text[index]))


#
#	Signals
#

func _on_dialog_interacted() -> void:
	_display_next_text()

## WHenever the text window state changes, check to see if the window is
## showing text. If it is, we'll fast-forward the text instead of just
## jumping to the next dialog.
func _on_text_window_state_changed(_state: TextWindowState, path: String) -> void:
	_skip_instead_of_progress = path.ends_with("Showing")
