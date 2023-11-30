@tool
extends ItemFilter
class_name ItemFilterNoDuplicates

#
#	Virtual Functions
#

## Check to see if the given inventory already has an item of the given item's
## type in it. If it has that type, return false. Otherwise returns true.
func evaluate(item: ItemInstance, inventory: ItemInventory) -> bool:
	# If the inventory already has this item's type, EXIT
	if inventory.contains_type(item.get_descriptor()): return false
	
	# OTHERWISE, we're good to go
	return true
