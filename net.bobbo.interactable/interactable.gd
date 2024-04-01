## Allows an object to be interactable in some way. Typically expected to be
## the child of some kind of body (something extending from CollisionObject3D
## or 2D).
@tool
extends Node
class_name Interactable

#
#	Exported Variables
#

## Emitted when this interactable has it's `is_hovering` value change.
signal is_hovering_changed(is_hovering: bool)

## Emitted when this interactable has it's `is_using` value change.
signal is_using_changed(is_using: bool)

#
#	Public Variables
#

## Is an interactor hovering over us RIGHT NOW?
## Emits `is_hovering_changed` when this value changes.
var is_hovering: bool:
	get: return _is_hovering
var _is_hovering: bool = false:
	get: return _is_hovering
	set(value):
		if value == _is_hovering: return
		_is_hovering = value
		is_hovering_changed.emit(value)

## Is an interactor using us RIGHT NOW?
## Emits `is_using_changed` when this value changes.
var is_using: bool:
	get: return _is_using
var _is_using: bool = false:
	get: return _is_using
	set(value):
		if value == _is_using: return
		_is_using = value
		is_using_changed.emit(value)

#
#	Godot Functions
#

func _get_configuration_warnings():
	var warnings: Array[String] = []
	
	# Display warning if our parent is not a node we expect it to be
	if not (get_parent() == null or get_parent() is CollisionObject3D or get_parent() is CollisionObject2D):
		warnings.append("Parent node is not a CollisionObject of some kind. " +
		"This may still work, but typically this should be the child of a CollisionObject.")

	return warnings

#
#	Public Static Functions
#

## Given a node, return a list of it's direct children that are `Interactable`
## nodes.
static func find_in_children(node: Node) -> Array[Interactable]:
	if node == null: return []
	var found: Array[Interactable] = []
	for child in node.get_children():
		if child is Interactable: found.append(child)
	return found

#
#	Public Functions
#

## Call to tell this interactable that it is JUST NOW starting to be used.
## Similar to an Input's `just_down` method. Will be ignored if this is
## already being used. Intended to be called by an InteractorRay.
func call_use_start() -> void:
	if is_using: return

	_is_using = true
	interactable_use_start()

## Call to tell this interactable that it is JUST NOW stopping being used.
## Similar to an Input's `just_up` method. Will be ignored if this is not
## currently being used. Intended to be called by an InteractoryRay.
func call_use_stop() -> void:
	if not is_using: return
	
	_is_using = false
	interactable_use_stop()

## Call to tell this interactable that it is JUST NOW starting to be
## hovered over. Similar to an Input's `just_down` method. Will be 
## ignored if this is already being hovered over. Intended to be called 
## by an InteractorRay.
func call_hover_start() -> void:
	if is_hovering: return

	_is_hovering = true
	interactable_hover_start()

## Call to tell this interactable that it is JUST NOW stopping being
## hovered over. Similar to an Input's `just_up` method. Will be 
## ignored if this is not currently being hovered over. Intended to be 
## called by an InteractorRay.
func call_hover_stop() -> void:
	if not is_hovering: return

	_is_hovering = false
	interactable_hover_stop()

#
#	Virtual Functions
#

## Override this to provide functionality when this interactable is
## just NOW being used.
func interactable_use_start() -> void: return

## Override this to provide functionality when this interactable is
## suddenly no longer being used.
func interactable_use_stop() -> void: return

## Override this to provide functionality when this interactable is
## suddenly being hovered over.
func interactable_hover_start() -> void: return

## Override this to provide functionality when this interactable is
## suddenly NOT being hovered over.
func interactable_hover_stop() -> void: return
