@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type(
		"BobboState",  # Type name
		"Node",  # Base type name
		preload("bobbo_state.gd"),  # Script for type
		preload("icons/bobbo_state.png")  # Icon for type
	)
	add_custom_type(
		"BobboStateMachine",  # Type name
		"Node",  # Base type name
		preload("bobbo_state_machine.gd"),  # Script for type
		preload("icons/bobbo_state_machine.png")  # Icon for type
	)


func _exit_tree():
	remove_custom_type("BobboState")
	remove_custom_type("BobboStateMachine")
