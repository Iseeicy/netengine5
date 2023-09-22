@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type(
		"PlayerModel",						# Type name
		"Node3D", 							# Base type name
		preload("player_model.gd"), 		# Script for type
		preload("icons/player_model.png")	# Icon for type
	)

func _exit_tree():
	remove_custom_type("PlayerModel")
