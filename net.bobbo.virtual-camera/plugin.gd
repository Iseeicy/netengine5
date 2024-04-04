@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type(
		"EntityCamera2D",
		"Node2D",
		preload("entity_camera_2d.gd"),
		preload("icons/entity_camera_2d.png")
	)
	add_custom_type(
		"EntityCamera3D",
		"Node3D",
		preload("entity_camera_3d.gd"),
		preload("icons/entity_camera_3d.png")
	)
	add_custom_type(
		"VirtualCamera2D",
		"Node2D",
		preload("virtual_camera_2d.gd"),
		preload("icons/virtual_camera_2d.png")
	)
	add_custom_type(
		"VirtualCamera3D",
		"Node3D",
		preload("virtual_camera_3d.gd"),
		preload("icons/virtual_camera_3d.png")
	)


func _exit_tree():
	remove_custom_type("VirtualCamera3D")
	remove_custom_type("VirtualCamera2D")
	remove_custom_type("EntityCamera3D")
	remove_custom_type("EntityCamera2D")
