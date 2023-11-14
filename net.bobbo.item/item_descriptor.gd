@tool
extends Resource
class_name ItemDescriptor

#
#	Exports
#

## The name of the item used for keys. Should use snake case. No spaces!
@export var item_name: String = ""
## For stacks of this item, how many items can be stored in a single stack?
@export var max_stack_size: int = 1

@export_group("Scenes")
## The scene that contains the view model for this item. Root node should
## inherit from ItemViewModel.
@export var view_model_scene: PackedScene
## The scene that contans the object to be spawned in the world for this item.
## Root node should inherit from WorldItem.
@export var world_item_scene: PackedScene

@export_group("UI")
## The name to use when displaying this item's name to the user. If empty, then
## `item_name` will be used instead.
@export var display_name: String = ""
## A string used to categorize this item. This is typically used by the
## inventory UI in some way to display this item in a specific way.
@export var category: String = ""
## An icon used to preview this item, usually in an inventory
@export var preview_icon: Texture2D = null

#
#	Functions
#

## Constructs a new instance of this kind of item.
func create_instance() -> ItemInstance:
	var instance = ItemInstance.new()
	instance.setup(self)
	instance.name = "%s_%s" % [item_name, get_instance_id()]
	return instance

## Returns the name to display to the user, for this item. If display name is
## not set, this will return the item's internal name
func get_display_name() -> String:
	return display_name if not display_name.is_empty() else item_name
