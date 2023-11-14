@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("ItemDescriptor", "Resource", preload("item_descriptor.gd"), preload("icons/item.png"))
	add_custom_type("ItemInstance", "Node", preload("item_instance.gd"), preload("icons/item.png"))
	add_custom_type("ItemInventory", "Node", preload("item_inventory.gd"), preload("icons/item.png"))
	add_custom_type("ItemViewModel", "Node", preload("item_view_model.gd"), preload("icons/item.png"))
	add_custom_type("WorldItem", "Node", preload("world_item.gd"), preload("icons/item.png"))

func _exit_tree():
	remove_custom_type("WorldItem")
	remove_custom_type("ItemViewModel")
	remove_custom_type("ItemInventory")
	remove_custom_type("ItemInstance")
	remove_custom_type("ItemDescriptor")
