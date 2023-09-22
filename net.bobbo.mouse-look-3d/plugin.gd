@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type(
		"MouseLook3D",						# Type name
		"Node", 							# Base type name
		preload("mouse_look_3d.gd"), 		# Script for type
		preload("icons/mouse_look_3d.png")	# Icon for type
	)

func _exit_tree():
	remove_custom_type("MouseLook3D")
