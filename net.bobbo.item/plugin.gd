@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("ItemDescriptor", "Resource", preload("item_descriptor.gd"), preload("icons/item_descriptor.png"))
	add_custom_type("ItemFilter", "Resource", preload("item_filter.gd"), preload("icons/item_filter.png"))
	add_custom_type("ItemInstance", "Node", preload("item_instance.gd"), preload("icons/item.png"))
	add_custom_type("ItemInventory", "Node", preload("item_inventory.gd"), preload("icons/item_inventory.png"))
	add_custom_type("ItemViewModel", "Node", preload("item_view_model.gd"), preload("icons/item_view_model.png"))
	add_custom_type("WorldItem2D", "RigidBody2D", preload("world_item_2d.gd"), preload("icons/world_item_2d.png"))
	add_custom_type("WorldItem3D", "RigidBody3D", preload("world_item_3d.gd"), preload("icons/world_item_3d.png"))

func _exit_tree():
	remove_custom_type("WorldItem3D")
	remove_custom_type("WorldItem2D")
	remove_custom_type("ItemViewModel")
	remove_custom_type("ItemInventory")
	remove_custom_type("ItemInstance")
	remove_custom_type("ItemFilter")
	remove_custom_type("ItemDescriptor")
