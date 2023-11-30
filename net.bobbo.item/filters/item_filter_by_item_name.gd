@tool
extends ItemFilter
class_name ItemFilterByItemName

#
#	Exports
#

## The regex string to use when matching the item name
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

## Check to see if the regex pattern matches the given item's item_name string.
## Returns true if there's a match, false otherwise.
func evaluate(item: ItemInstance, inventory: ItemInventory) -> bool:
	return _compiled_regex.search(item.get_descriptor().item_name) != null
