## Filters items using some filter, but negates the result of the filter's
## evaluate function.
@tool
extends ItemFilter
class_name ItemFilterNegate

#
#	Exports
#

## The filters to negate.
@export var filter: ItemFilter = null

#
#	Virtual Functions
#

## Check to see if the given item passes through the filter, then negates the
## result.
## Returns false if the item passes the filter, true otherwise.
func evaluate(item: ItemInstance, inventory: ItemInventory) -> FilterResult:
	if filter.evaluate(item, inventory) == FilterResult.PASS:
		return FilterResult.REJECT
	
	return FilterResult.PASS
