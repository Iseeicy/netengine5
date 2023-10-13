extends BobboState
class_name TextWindowState

#
#	Variables
#

## The TextWindow that this state is controlling
var text_window: TextWindow:
	get:
		return _state_machine.text_window
