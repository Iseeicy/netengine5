## Filters items using a RegEx on the return of `get_display_name()` on an
## item's descriptor.
@tool
extends ItemFilter
class_name ItemFilterByDisplayName

#
#	Exports
#

## The regex string to use when matching the display name
@export var regex_string: String = ".":
	set(value):
		_compiled_regex = RegEx.create_from_string(value)
		regex_string = value
	get:
		return regex_string

#
#	Private Variables
#

var _compiled_regex: RegEx = null

#
#	Virtual Functions
#

## Check to see if the regex pattern matches the given item's display name.
## Returns true if there's a match, false otherwise.
func evaluate(item: ItemInstance, inventory: ItemInventory) -> FilterResult:
	# Run the regex on the display name
	var found_match = _compiled_regex.search(
		item.get_descriptor().get_display_name()
	) != null
	
	return FilterResult.PASS if found_match else FilterResult.REJECT
