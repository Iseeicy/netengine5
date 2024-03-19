## Represents an item's view model, which acts as a visual representation of
## an ItemInstance when it is currently being held by a player. Has an 
## identical API to ItemViewModel2D - but this is a 3D node instead.
extends Node3D
class_name ItemViewModel3D

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
