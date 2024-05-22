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
		"PlayerInputAnalog",
		"Node",
		preload("player_input_analog.gd"),
		preload("icons/player_input_analog.png")
	)
	add_custom_type(
		"PlayerInputMouse",
		"Node",
		preload("player_input_mouse.gd"),
		preload("icons/player_input.png")
	)
	add_custom_type(
		"SimulatedInput",
		"Node",
		preload("simulated_input.gd"),
		preload("icons/simulated_input.png")
	)

	BobboInputs.add_to_input_map()


func _exit_tree():
	BobboInputs.remove_from_input_map()

	remove_custom_type("SimulatedInput")
	remove_custom_type("PlayerInputMouse")
	remove_custom_type("PlayerInputAnalog")
	remove_custom_type("PlayerInputAction")
	remove_custom_type("PlayerInput")
	remove_custom_type("EntityInput")
