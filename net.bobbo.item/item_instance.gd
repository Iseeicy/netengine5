@tool
extends Node
class_name ItemInstance

#
#	Types
#

## The state of an item's existence in space.
enum SpaceState {
	NOWHERE = 0,		# This item doesn't exist anywhere other than in memory!
	IN_INVENTORY = 1,	# This item is in an inventory somewhere.
	IN_WORLD = 2,		# This item is in the game world somewhere.
}



#
#	Private Variables
#

var _descriptor: ItemDescriptor = null
## Generally where is this object spatially?
var _space_state: SpaceState = SpaceState.NOWHERE
## If this instance is IN_WORLD, then this is the WorldItem that represents us.
var _current_world_item: WorldItem = null
## If this instance is IN_INVENTORY, then this is the ItemInventory that the
## item is currently contained in.
var _current_parent_inventory: ItemInventory = null
## How many items are represented by this instance.
var _current_stack_size: int = 1

#
#	Public Functions
#

## Setup this item. Intended to be called by the ItemDescriptor that this item
## belongs to.
func setup(desc: ItemDescriptor) -> void:
	_descriptor = desc

## Returns the ItemDescriptor that this item belongs to.
func get_descriptor() -> ItemDescriptor: return _descriptor

## Returns the current SpaceState of this item.
func get_space_state() -> SpaceState: return _space_state

## Returns how many items are represented by this instance. Typically for equipment
## this is 1, though for materials this number could increase.
func get_stack_size() -> int: return _current_stack_size

## If this instance is in the game world, then this returns the object that
## represents it. Otherwise, this returns null
func get_world_item() -> WorldItem:
	return _current_world_item if _space_state == SpaceState.IN_WORLD else null

## Spawn and return a new instance of this item's view model, if there is one. 
## Returns null if there isn't one
func instantiate_view_model() -> ItemViewModel:
	if _descriptor.view_model_scene == null:
		return null
	
	var new_view_model = _descriptor.view_model_scene.instantiate()
	new_view_model.setup(self)
	return new_view_model

## Places this item instance in the game world. If it was in an inventory, it is
## removed from that inventory.
## Returns
## - `true` if the item was placed in the game world
## - `false` if the item is already in the game world
## - `false` if there is no scene in the descriptor for a WorldItem
func put_in_world() -> bool:
	if _space_state == SpaceState.IN_WORLD:
		return false
	if _descriptor.world_item_scene == null:
		return false
	
	# TODO
	return true

## Places this item instance in an inventory. If it was in the world, it is
## removed from the game world. If it was in a different inventory, it is
## removed from that inventory.
## Returns:
## - `true` if the item was place in the inventory
## - `false` if the item was rejected by the inventory
func put_in_inventory(inventory: ItemInventory) -> bool:
	# TODO
	return false
