@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type(
		"PlayerModelRenderer3D",  # Type name
		"Node3D",  # Base type name
		preload("player_model_renderer_3d.gd"),  # Script for type
		preload("icons/player_model.png")  # Icon for type
	)


func _exit_tree():
	remove_custom_type("PlayerModelRenderer3D")
