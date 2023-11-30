@tool
extends ItemFilter
class_name ItemFilterAnd

#
#	Exports
#

## The filters to use. When this filter is evaluated, it will check each of
## these filters first.
@export var filters: Array[ItemFilter] = []

#
#	Virtual Functions
#

## Check to see if the given item passes through ALL filters.
## Returns true if the item passes the filter, false otherwise.
func evaluate(item: ItemInstance, inventory: ItemInventory) -> bool:
	# Check to see if this item passes through EVERY filter.
	for filter in filters:
		# If we fail a single filter, STOP IMMEDIATELY.
		if not filter.evaluate(item, inventory): return false
	# As long as we pass all filters, we're good to go!
	return true
