@tool
extends ItemFilter
class_name ItemFilterOr

#
#	Exports
#

## The filters to use. When this filter is evaluated, it will check all of
## these filters first.
@export var filters: Array[ItemFilter] = []

#
#	Virtual Functions
#

## Check to see if the given item passes through ANY filters.
## Returns true if the item passes any single filter, false otherwise.
func evaluate(item: ItemInstance, inventory: ItemInventory) -> FilterResult:
	# Check to see if this item passes through ANY filter.
	for filter in filters:
		# If we pass a single filter, STOP IMMEDIATELY.
		if filter.evaluate(item, inventory) == FilterResult.PASS: 
			return FilterResult.PASS
	# If we pass no filters, this is FALSE
	return FilterResult.REJECT
