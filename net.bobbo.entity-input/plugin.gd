@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type(
		"EntityInput",
		"Node",
		preload("entity_input.gd"),
		preload("icons/entity_input.png")
	)
	add_custom_type(
		"PlayerInput",
		"Node",
		preload("player_input.gd"),
		preload("icons/player_input.png")
	)
	add_custom_type(
		"PlayerInputAction",
		"Node",
		preload("player_input_action.gd"),
		preload("icons/player_input.png")
	)
	add_custom_type(
		"SimulatedInput",
		"Node",
		preload("simulated_input.gd"),
		preload("icons/entity_input.png")
	)


func _exit_tree():
	remove_custom_type("SimulatedInput")
	remove_custom_type("PlayerInputAction")
	remove_custom_type("PlayerInput")
	remove_custom_type("EntityInput")
