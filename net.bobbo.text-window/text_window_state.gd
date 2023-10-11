extends BobboState
class_name TextWindowState

#
#	Variables
#

var text_window: TextWindow:
	get:
		return _state_machine.text_window
