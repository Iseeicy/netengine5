## Represents an item's view model, which acts as a visual representation of
## an ItemInstance when it is currently being held by a player. Has an 
## identical API to ItemViewModel3D - but this is a 2D node instead.
extends Node2D
class_name ItemViewModel2D

#
#	Exports
#

@export var animation_tree: AnimationTree = null

#
#	Public Variables
#

const item_ready_param = "parameters/item_ready/request"

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

## Tells the view model that it is on screen and ready to be used.
func item_ready() -> void:
	if animation_tree:
		animation_tree.active = true
		animation_tree[item_ready_param] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE