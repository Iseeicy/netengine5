@tool
extends Node
class_name ItemInventory

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

#
#	Public Functions
#

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

	
