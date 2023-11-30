@tool
extends ItemFilter
class_name ItemFilterByDescriptor

#
#	Exports
#

## The descriptor to match when filtering.
@export var descriptor: ItemDescriptor = null

#
#	Virtual Functions
#

## Check to see if the given item's descriptor matches the descriptor that we
## are looking for.
## Returns true if the item passes the filter, false otherwise.
func evaluate(item: ItemInstance, inventory: ItemInventory) -> bool:
	return item.get_descriptor() == descriptor
