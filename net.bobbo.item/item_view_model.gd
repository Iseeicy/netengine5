extends Node
class_name ItemViewModel

#
#	Private Variables
#

var _item_instance: ItemInstance

#
#	Public Functions
#

## Setup this view model. Intended to be called by the ItemInstance that this
## model belongs to.
func setup(item: ItemInstance) -> void:
	_item_instance = item

## Returns the item instance that this model belongs to.
func get_item_instance() -> ItemInstance:
	return _item_instance
