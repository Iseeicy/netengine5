## A node that renders a PlayerModel2D and allows for easy swapping.
class_name PlayerModelRender2D
extends Node2D

#
#	Signals
#

## Called when the playermodel is updated.
signal changed(spawned_model: PlayerModel3D, source_scene: PackedScene)

#
#	Constants
#

## The internal model to use if none is provided
const DEFAULT_MODEL_SCENE: PackedScene = preload(
	"default_player_model_2d.tscn"
)

#
#	Exports
#

## The player model to load at start. If null, `DEFAULT_MODEL_SCENE` is used
## instead.
@export var initial_model: PackedScene = null

#
#	Public Variables
#

## The currently spawned model. Null if there is none.
var _current_model: PlayerModel2D = null

## The original scene of the currently spawned model. Null if there is none.
var _current_model_scene: PackedScene = null

#
#	Godot Functions
#


func _ready():
	# If someone beat us to spawning a model, EXIT EARLY
	if _current_model != null:
		return

	# If we have no model, use the internal default
	if initial_model == null:
		initial_model = DEFAULT_MODEL_SCENE

	# Spawn our starting model
	assert(initial_model)
	set_model(initial_model)


#
#	Public Functions
#


## Assign or clear the model to be rendered.
## Args:
##	`new_model_scene`: The packed `PlayerModel2D` scene that will be rendered.
##		If this is null, then it will clear the current model.
func set_model(new_model_scene: PackedScene) -> void:
	# If we're already using this model, EXIT EARLY
	if new_model_scene == _current_model_scene:
		return

	# Cache this value so we can use it to determine if `changed` is called.
	var old_model_scene := _current_model_scene

	# If we have a model already, despawn it
	if _current_model == null:
		_current_model.queue_free()
		_current_model = null
		_current_model_scene = null

	# If we're not just despawning, then spawn the new model
	_current_model_scene = new_model_scene
	if new_model_scene != null:
		_current_model = new_model_scene.instantiate()
		add_child(_current_model)
		_current_model.owner = self

	# Call the `changed` signal if we're using a new model
	if old_model_scene != new_model_scene:
		changed.emit(_current_model, _current_model_scene)


## Returns the currently rendered PlayerModel2D, or null if there is none.
func get_model() -> PlayerModel2D:
	return _current_model


## Returns the source scene of the currently rendered PlayerModel2D, or null if
## there is none.
func get_model_scene() -> PackedScene:
	return _current_model_scene


## Assigns the value of some animation parameter.
## Args:
## 	`param`: The key of the animation parameter to set.
## 	`value`: The value to assign to the animation parameter.
func set_anim_param(param: String, value: Variant) -> void:
	if _current_model:
		_current_model.set_anim_param(param, value)


## Assigns the value of an AnimationTree's main_state transition.
## Args:
## 	`value`: The value to assign to main_state. Should be something like
##		"in_control", "sitting", etc.
func set_main_state(value: String) -> void:
	if _current_model:
		_current_model.set_main_state(value)


## Assigns the value of an AnimationTree's movement state transition.
## Args:
## 	`value`: The value to assign to movement/state. Should be something like
##		"ground", "air", etc.
func set_movement_state(value: String) -> void:
	if _current_model:
		_current_model.set_movement_state(value)


## Assigns multiple generic parameters based on player movement.
## Args:
## 	`input_movement`: The movement vector to assign. If facing forward, X is
##		left to right and Y is forward to backward.
func set_movement_vector(input_movement: Vector2) -> void:
	if _current_model:
		_current_model.set_movement_vector(input_movement)


## Fires a oneshot animation node.
## Args:
## 	`param`: The key of the oneshot node's request parameter.
func fire_oneshot(param: String) -> void:
	if _current_model:
		_current_model.fire_oneshot(param)
