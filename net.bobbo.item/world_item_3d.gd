## The physical representation of an ItemInstance when placed into the game
## world. Has an identical API to WorldItem2D - but this is a 3D rigidbody
## instead.
extends RigidBody3D
class_name WorldItem3D

#
#	Public Variables
#

## Can this item be picked up right now?
var can_pickup: bool:
	get:
		return _pickup_timer_finished

#
#	Private Variables
#

var _item_instance: ItemInstance
var _pickup_timer_finished: bool = true

#
#	Public Functions
#

## Setup this world item. Intended to be called by the ItemInstance that this
## world item represents.
func setup(item: ItemInstance) -> void:
	_item_instance = item

## Start the pickup timer, making it so that the player can not pick up this item
## until timeout. This prevents the player from picking up items as soon as
## they're dropped.
func start_pickup_timer(pickup_timeout: float=2) -> void:
	_pickup_timer_finished = false
	get_tree().create_timer(pickup_timeout).timeout.connect(_on_pickup_timer_timeout.bind())

## Returns the item instance that this world item represents.
func get_item_instance() -> ItemInstance:
	return _item_instance

#
#	Signals
#

func _on_pickup_timer_timeout() -> void:
	_pickup_timer_finished = true