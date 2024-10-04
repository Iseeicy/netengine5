@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type(
		"PlayerModel2D",  # Type name
		"Node2D",  # Base type name
		preload("player_model_2d.gd"),  # Script for type
		preload("icons/player_model_2d.png")  # Icon for type
	)
	add_custom_type(
		"PlayerModel3D",  # Type name
		"Node3D",  # Base type name
		preload("player_model_3d.gd"),  # Script for type
		preload("icons/player_model_3d.png")  # Icon for type
	)
	add_custom_type(
		"PlayerModelRenderer2D",  # Type name
		"Node2D",  # Base type name
		preload("player_model_renderer_2d.gd"),  # Script for type
		preload("icons/player_model_renderer_2d.png")  # Icon for type
	)
	add_custom_type(
		"PlayerModelRenderer3D",  # Type name
		"Node3D",  # Base type name
		preload("player_model_renderer_3d.gd"),  # Script for type
		preload("icons/player_model_renderer_3d.png")  # Icon for type
	)


func _exit_tree():
	remove_custom_type("PlayerModelRenderer3D")
	remove_custom_type("PlayerModelRenderer2D")
	remove_custom_type("PlayerModel3D")
	remove_custom_type("PlayerModel2D")
