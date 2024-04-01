extends Node
class_name ItemScriptBase
# TODO - how can animations be made easier?
# TODO - what is an animation library?

#
#   Classes
#

class ItemInput extends RefCounted:
    ## Is this input JUST being pressed, right now?
    var just_down: bool = false
    ## Is this input actively being held down?
    var pressing: bool = false
    ## Is this input JUST being released, right now?
    var just_up: bool = false

    func reset() -> void:
        just_down = false
        pressing = false
        just_up = false

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
## Typically values are provided in some PlayerScript.
var use_0_input: ItemInput = ItemInput.new()

## The key for the secondary "use item" action. Traditionally right mouse.
## Typically values are provided in some PlayerScript.
var use_1_input: ItemInput = ItemInput.new()

## Is this item currently selected by an `ItemInteractor`?
var is_selected: bool:
    get: return _is_selected
var _is_selected: bool = false

## The `ItemInstance` that this script belongs to.
var instance: ItemInstance:
    get: return _item_instance
var _item_instance: ItemInstance = null

## The `ItemInteractor` that is interacting with this item.
var interactor: ItemInteractor:
    get: return _interactor
var _interactor: ItemInteractor = null

## The `CharacterDefinition` that is using this item currently.
var character: CharacterDefinition:
    get:
        if interactor: return interactor.character
        return null

## The `PlayerController` that is using this item, if there is one.
## TODO - I don't know if I like this. How would an NPC use the same item code in this
## scenario?
var player3d: PlayerController:
    get:
        if character and character.body_node is PlayerController:
            return character.body_node
        return null

#
#   Public Functions
#

func setup(parent_instance: ItemInstance) -> void:
    _item_instance = parent_instance

## Call to trigger `item_selected_start` on subclasses.
func call_selected_start(parent_interactor: ItemInteractor) -> void:
    _is_selected = true
    _interactor = parent_interactor
    item_selected_start()
    selected_start.emit()

## Call to trigger `item_selected_process` on subclasses.
func call_selected_process(delta: float) -> void:
    item_selected_process(delta)

## Call to trigger `item_selected_stop` on subclasses.
func call_selected_stop() -> void:
    _is_selected = false
    item_selected_stop()
    use_0_input.reset()
    use_1_input.reset()
    _interactor = null
    selected_stop.emit()

## Trigger a oneshot animation on all viewmodels.
func viewmodel_animation_oneshot(key: String) -> void:
    instance.set_viewmodel_anim_param("parameters/%s/request" % key, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

#
#   Base Functions
#

## Called when an `ItemInteractor` begins selecting this item. 
func item_selected_start() -> void: return

## Called each frame that an `ItemInteractor`is selecting this item. 
func item_selected_process(_delta: float) -> void: return

## Called when an `ItemInteractor` stops selecting this item. 
func item_selected_stop() -> void: return