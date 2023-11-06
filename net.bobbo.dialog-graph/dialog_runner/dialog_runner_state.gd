@tool
extends BobboState
class_name DialogRunnerState

#
#	Variables
#

## The dialog runner that we belong to
var runner: DialogRunner:
	get:
		return _state_machine as DialogRunner

## The TextWindow that the dialog runner is using
var text_window: TextWindow:
	get:
		return _state_machine.text_window

## The DialogGraph that the dialog runner is currently running through
var graph: DialogGraph:
	get:
		return _state_machine.get_graph()
