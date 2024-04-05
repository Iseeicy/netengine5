## Represents an item's view model, which acts as a visual representation of
## an ItemInstance when it is currently being held by a player. Has an 
## identical API to ItemViewModel2D - but this is a 3D node instead.
extends Node3D
class_name ItemViewModel3D

#
#	Exports
#

## Emitted when this node is being freed.
signal view_model_freed()

## The animation tree used to control this view model.
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
#	Godot Functions
#

func _notification(what: int):
	# When this object is free'd, tell other nodes (keyley the ItemInstance) about it
	if what == NOTIFICATION_PREDELETE:
		view_model_freed.emit()

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