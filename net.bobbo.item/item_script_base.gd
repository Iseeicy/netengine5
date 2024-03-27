extends Node
class_name ItemScriptBase

#
#   Classes
#

class ItemInput extends RefCounted:
    #
    #   Public Variables
    #
    
    ## Is this input JUST being pressed, right now?
    var just_down: bool:
        get: return _supported and Input.is_action_just_pressed(_action)
    ## Is this input actively being held down?
    var pressing: bool:
        get: return _supported and Input.is_action_pressed(_action)
    ## Is this input JUST being released, right now?
    var just_up: bool:
        get: return _supported and Input.is_action_just_released(_action)
    
    #
    #   Private Variables
    #

    ## The name of the action representing this input.
    var _action: String = ""
    ## Is this input supported currently?
    var _supported: bool

    #
    #   Godot Functions
    #

    func _init(action_name: String):
        _action = action_name
        _supported = InputMap.has_action(action_name)

#
#   Signals
#

## Emitted when this item has been selected.
signal selected_start()

## Emitted when this item has been unselected.
signal selected_stop()

#
#   Variables
#

## The key for the primary "use item" action. Traditionally left mouse.
## Can be overriden to provide input from some other source.
var use_0_input: ItemInput = ItemInput.new("player_use_item_0")

## The key for the secondary "use item" action. Traditionally right mouse.
## Can be overriden to provide input from some other source.
var use_1_input: ItemInput = ItemInput.new("player_use_item_1")

## Is this item currently selected by an `ItemInteractor`?
var is_selected: bool:
    get: return _is_selected
var _is_selected: bool = false

## The `ItemInstance` that this script belongs to.
var instance: ItemInstance:
    get: return _item_instance
var _item_instance: ItemInstance = null

#
#   Public Functions
#

func setup(parent_instance: ItemInstance) -> void:
    _item_instance = parent_instance

## Call to trigger `item_selected_start` on subclasses.
func call_selected_start() -> void:
    _is_selected = true
    item_selected_start()
    selected_start.emit()

## Call to trigger `item_selected_process` on subclasses.
func call_selected_process() -> void:
    item_selected_process()

## Call to trigger `item_selected_stop` on subclasses.
func call_selected_stop() -> void:
    _is_selected = false
    item_selected_stop()
    selected_stop.emit()

#
#   Base Functions
#

## Called when an `ItemInteractor` begins selecting this item. 
func item_selected_start() -> void: return

## Called each frame that an `ItemInteractor`is selecting this item. 
func item_selected_process() -> void: return

## Called when an `ItemInteractor` stops selecting this item. 
func item_selected_stop() -> void: return