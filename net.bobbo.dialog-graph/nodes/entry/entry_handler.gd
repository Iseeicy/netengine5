@tool
extends DialogRunnerActiveHandlerState

#
#	State Functions
#

func state_enter(_message: Dictionary = {}) -> void:
	_get_parent_state().state_enter(_message)
	call_deferred("go_to_next_node")
	
func state_exit() -> void:
	_get_parent_state().state_exit()
