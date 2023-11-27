@tool
extends EditorPlugin

#
#	Godot Functions
#

func _enter_tree():
	add_custom_type("Instantiatable", "Resource", preload("instantiatable.gd"), preload("icons/instantiatable.png"))

func _exit_tree():
	remove_custom_type("Instantiatable")
