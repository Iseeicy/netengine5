@tool
extends Node
class_name ItemInventory

#
#	Types
#

## Used to indicate if an inventory operation succeeded, or if there was some
## kind of error.
enum InventoryError {
	OK = 1,				## There is no error
	SLOT_OCCUPIED = -1,	## The slot is occupied
	FILTER_DENIED = -2,	## The filter denied this
	NO_FIT = -3,		## The entire amount could not fit
	DIFFERENT_TYPES = -4,	## The two items are different types
}

#
#	Exports
#

## How many slots are there in this inventory?
@export var size: int = 64

#
#	Private Variables
#

## The data structure backing this inventory.
var _slots: Array[ItemInstance] = [] 

#
#	Godot Functions
#

func _ready():
	_slots.resize(size)	# Allocate enough slots for our size

func _exit_tree():
	# TODO - how do we handle getting rid of items?
	for item in get_all_items().keys():
		item.put_nowhere()

#
#	Public Functions
#

## Return how many items slots are stored in this inventory
func total_used_slots() -> int: return get_all_items().size()

## Return the item found at slot `index`, if there is one. Returns null if there
## is no item there.
func get_item_at_slot(index: int) -> ItemInstance: return _slots[index]

## Return the item found at the last filled slot, if there is any. Returns null
## if there isn't one.
func peek_last_filled_slot() -> ItemInstance:
	var index = find_last_filled_slot()	# Get the last filled index
	if index == -1: return null			# If there's no item, EXIT EARLY
	return get_item_at_slot(index)		# If there IS an item, return it!

## Puts an item into the given slot `index`.
## This may modify the stack size of `item` - potentially making it zero if
## entirely merged into the desired slot - so make sure to act accordingly.
## Returns:
##	`InventoryError.OK` if the item was stored in the slot 
##	`InventoryError.FILTER_DENIED` if the item did not pass through the filter
##	`InventoryError.DIFFERENT_TYPES` if the item was going to be merged, but
##		but could not be because it's not the same type as the item in the slot.
##	`InventoryError.NO_FIT` if the item was merged, but some or all of the item
##		stack could not fit.
func put_item_in_slot(index: int, item: ItemInstance) -> InventoryError:
	# If the item does not pass our filters, EXIT EARLY
	if not _does_item_pass_filters(item):
		return InventoryError.FILTER_DENIED
	
	# Find out what's already in this slot
	var existing_item = get_item_at_slot(index)
	
	# If the item should be merged into the item at this slot...
	if existing_item != null:
		# If these items are different types, EXIT EARLY
		if existing_item.get_descriptor() != item.get_descriptor():
			return InventoryError.DIFFERENT_TYPES
		
		item.merge_stack_into(existing_item) # Merge the items!
		
		# If we still have items that aren't merged, EXIT EARLY
		if item.get_stack_size() > 0:
			return InventoryError.NO_FIT
		
		# OTHERWISE, we merged entirely!
		return InventoryError.OK
	# If the item should just be set in the slot...
	else:
		# EASY - just set it!
		_slots[index] = item
		return InventoryError.OK

## Takes an item out of the given slot `index`.
## Returns the item in the slot, null if there isn't one.
func take_item_from_slot(index: int) -> ItemInstance:
	var found_item = _slots[index]
	_slots[index] = null
	return found_item

## Pushes an item into the inventory wherever it will fit. If there are slots
## the item can stack into, then it will stack before taking up an empty slot.
## This may modify the stack size of `item` - potentially making it zero if
## entirely merged into other stacks - so make sure to act accordingly.
## Returns:
## `InventoryError.OK` if the item was pushed into this inventory
## `InventoryError.FILTER_DENIED` if the item did not pass through the filter
## `InventoryError.NO_FIT` if some or all of the item stack could not fit
func push_item(item: ItemInstance) -> InventoryError:
	# If this item does not pass through the invetory filters, EXIT EARLY
	if not _does_item_pass_filters(item):
		return InventoryError.FILTER_DENIED
	
	# Find slots appropriate to merge into
	var stackable_slots = get_items_of_type(item.get_descriptor()).keys()
	
	# Loop through the stackable slots and try to fit all items in
	for item_to_stack_on in stackable_slots:
		## If we have nothing left to stack, then BREAK THE LOOP
		if item.get_stack_size() <= 0: break	
		# Merge into this item
		item.merge_stack_into(item_to_stack_on)
	
	# If we don't have anything left to stack, EXIT EARLY
	if item.get_stack_size() <= 0:
		return InventoryError.OK
	
	# OTHERWISE, we still have stuff to stack, so...
	# ...if we don't have an empty slot to fit the rest in, EXIT EARLY
	var empty_slot_index: int = find(null)
	if empty_slot_index == -1:
		return InventoryError.NO_FIT
	
	# At this point we for sure have an empty slot to put the rest of this item
	# in - so do it!
	return put_item_in_slot(empty_slot_index, item)

## Returns a list of every slot in this inventory, in order. Some slots may be
## empty, which means it will contain a null value.
func get_all_slots() -> Array[ItemInstance]: return _slots

## Returns a dictionary of all items that are stored in this inventory, mapped
## to their slot index in the inventory (ItemInstance -> int)
func get_all_items() -> Dictionary:
	var found_items: Dictionary = {}
	var index = 0 
	
	for slot in _slots:
		if slot != null:
			found_items[slot] = index
		index += 1
	
	return found_items

## Returns a dictionary of items stored in this inventory that use the given
## descriptor, mapped to their slot index (ItemInstance -> int)
func get_items_of_type(desc: ItemDescriptor) -> Dictionary:
	var found_items: Dictionary = {}
	var index = 0
	
	for slot in _slots:
		if slot != null and slot.get_descriptor() == desc:
			found_items[slot] = index
		index += 1
	
	return found_items

## Given an item assumed to be in this inventory, return the index of the slot
## that it's in. Returns -1 if not found.
func find(item: ItemInstance) -> int: return _slots.find(item)

## Find the index of the last filled slot in the inventory. Returns -1 if no
## slots are filled.
func find_last_filled_slot() -> int:
	var index: int = _slots.size()
	while index > 0:
		if _slots[index] != null:
			return index
		index -= 1
	return -1

## Is this item in the inventory?
func contains(item: ItemInstance) -> bool: return item in _slots

## Is there an item that uses the given descriptor in the inventory?
func contains_type(desc: ItemDescriptor) -> bool:
	for item in _slots:
		if item == null:
			continue
		if item.get_descriptor() == desc:
			return true
	return false

#
#	Private Functions
#

func _does_item_pass_filters(item: ItemInstance) -> bool:
	## TODO
	return true
