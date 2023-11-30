## Filters items by enforcing that any given item may not already have an item
## of the same type exist already in the given inventory.
@tool
extends ItemFilter
class_name ItemFilterNoDuplicates

#
#	Virtual Functions
#

## Check to see if the given inventory already has an item of the given item's
## type in it. If it has that type, return false. Otherwise returns true.
func evaluate(item: ItemInstance, inventory: ItemInventory) -> FilterResult:
	# If the inventory already has this item's type, EXIT
	if inventory.contains_type(item.get_descriptor()): 
		return FilterResult.REJECT
	
	# OTHERWISE, we're good to go
	return FilterResult.PASS
