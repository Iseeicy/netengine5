@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type(
		"TextWindow",						# Type name
		"Control", 							# Base type name
		preload("text_window.gd"), 			# Script for type
		preload("icons/text_window.png")	# Icon for type
	)
	add_custom_type(
		"ProjectedControl",					# Type name
		"Control", 							# Base type name
		preload("text_window.gd"), 			# Script for type
		preload("icons/text_window.png")	# Icon for type
	)

func _exit_tree():
	remove_custom_type("TextWindow")
	remove_custom_type("ProjectedControl")
