extends TextWindowState

#
#	State Functions
#

func state_enter(_message: Dictionary = {}) -> void:
	_parent_state.state_enter(_message)
	
func state_unhandled_input(event: InputEvent) -> void:
	_parent_state.state_unhandled_input(event)
	
func state_process(delta: float) -> void:
	_parent_state.state_process(delta)
	
func state_physics_process(delta: float) -> void:
	_parent_state.state_physics_process(delta)
	
func state_exit() -> void:
	_parent_state.state_exit()
