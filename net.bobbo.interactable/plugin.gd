@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type(
		"Interactable",						# Type name
		"Node", 							# Base type name
		preload("interactable.gd"), 		# Script for type
		preload("icons/interactable.png")	# Icon for type
	)
	add_custom_type(
		"InteractorRay3D",						# Type name
		"RayCast3D",							# Base type name
		preload("interactor_ray_3d.gd"), 		# Script for type
		preload("icons/interactor_ray_3d.png")	# Icon for type
	)

func _exit_tree():
	remove_custom_type("Interactable")
	remove_custom_type("InteractorRay3D")
