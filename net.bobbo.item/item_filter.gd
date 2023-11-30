@tool
extends Resource
class_name ItemFilter

#
#	Virtual Functions
#

## Check to see if the given item passes through the filter.
## Returns true if the item passes the filter, false otherwise.
## This is meant to be extended!
func evaluate(item: ItemInstance) -> bool:
	return false
