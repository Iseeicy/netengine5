## If the DialogRunner can't find a handler for a given node, it will
## use this handler instead. This handler simply tries to skip the node
## and move on to the next one. The show must go on!
@tool
extends DialogRunnerActiveHandlerState

#
#	State Functions
#

func state_enter(_message: Dictionary = {}) -> void:
	_get_parent_state().state_enter(_message)
	go_to_next_node()
	
func state_exit() -> void:
	_get_parent_state().state_exit()
