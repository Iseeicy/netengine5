@tool
extends Resource
class_name ItemFilter

#
#	Virtual Functions
#

## Check to see if the given item passes through the filter for a given
## inventory.
## Returns true if the item passes the filter, false otherwise.
## This is meant to be extended!
func evaluate(item: ItemInstance, inventory: ItemInventory) -> bool:
	return false
