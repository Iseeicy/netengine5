## The physical representation of an ItemInstance when placed into the game
## world. Has an identical API to WorldItem3D - but this is a 2D rigidbody
## instead.
extends RigidBody2D
class_name WorldItem2D

#
#	Private Variables
#

var _item_instance: ItemInstance

#
#	Public Functions
#

## Setup this world item. Intended to be called by the ItemInstance that this
## world item represents.
func setup(item: ItemInstance) -> void:
	_item_instance = item

## Returns the item instance that this world item represents.
func get_item_instance() -> ItemInstance:
	return _item_instance
