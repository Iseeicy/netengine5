## Represents a certain type of item. Acts as a factory for ItemInstances of
## the item type it represents.
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
## Root node should inherit from WorldItem2D or WorldItem3D.
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

## Constructs many new stacked instances of this kind of item, respecting max
## stack size.
func create_many_instances(count: int) -> Array[ItemInstance]:
	var result: Array[ItemInstance] = []
	
	# While we still have items to stack....
	while count > 0:
		var instance = create_instance()
		
		# Figure out how much we can fit in this instance, and fit it
		var stack_size = min(instance.get_max_stack_size(), count)
		instance.set_stack_size(stack_size)
		
		# Keep track of how many we have left to fit
		count -= stack_size
		result.append(instance)
	
	return result

## Returns the name to display to the user, for this item. If display name is
## not set, this will return the item's internal name
func get_display_name() -> String:
	return display_name if not display_name.is_empty() else item_name
