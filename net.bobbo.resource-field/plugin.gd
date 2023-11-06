@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type(
		"ResourceField",					# Type name
		"HBoxContainer", 					# Base type name
		preload("resource_field.gd"), 		# Script for type
		preload("icons/resource_field.png")	# Icon for type
	)

func _exit_tree():
	remove_custom_type("ResourceField")
