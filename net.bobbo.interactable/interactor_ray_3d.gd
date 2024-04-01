## A `RayCast3D` that specifically aims to intersect with objects
## containing `Interactable` nodes. This will automatically call
## any found `Interactable`'s hover functions.
extends RayCast3D
class_name InteractorRay3D

#
#	Exports
#

## Emitted when the value of `is_hovering` has changed.
signal is_hovering_changed(is_hovering: bool)

#
#	Public Variables
#

## Is this ray currently hovering over an interactable object?
## Emits `is_hovering_changed` when this value changes.
var is_hovering: bool:
	get: return _is_hovering
var _is_hovering: bool = false:
	get: return _is_hovering
	set(value):
		if value == _is_hovering: return
		_is_hovering = value
		is_hovering_changed.emit(value)

#
#	Private Variables
#

## The object that this ray is currently intersecting with, if any.
## Typically this is the parent body of any collision shapes, like a
## Rigidbody or StaticBody.
var _focused_object: CollisionObject3D = null

#
#	Godot Functions
#

func _physics_process(_delta):
	# If the object intersecting with this ray is NOT the object that
	# we already know about, then UPDATE IT!
	if _focused_object != get_collider():
		_set_focused_object(get_collider())

func _notification(what: int):
	# When this object is free'd, force unfocus
	if what == NOTIFICATION_PREDELETE:
		_set_focused_object(null)

#
#	Public Functions
#

## Get a list of interactables that we are hovering over. When `is_hovering`
## is true, this will have more than 0 elements.
func get_focused_interactables() -> Array[Interactable]:
	return Interactable.find_in_children(_focused_object)

#
#	Private Functions
#

## Targets a new object, and calls proper Interactable methods on the old
## + new objects if applicable.
func _set_focused_object(new_focused_object: CollisionObject3D) -> void:
	if _focused_object == new_focused_object: return
	
	var old_interactables = Interactable.find_in_children(_focused_object)
	var new_interactables = Interactable.find_in_children(new_focused_object)

	# Stop hovering / using old interactables
	for old_inter in old_interactables:
		if old_inter.is_hovering: old_inter.call_hover_stop()
		if old_inter.is_using: old_inter.call_use_stop()

	# Start hovering new interactables
	for new_inter in new_interactables:
		new_inter.call_hover_start()

	# Mark that we either ARE or ARE NOT hovering
	_is_hovering = new_interactables.size() > 0
	_focused_object = new_focused_object
