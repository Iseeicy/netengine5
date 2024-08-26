class_name PlayerModelRenderer3D
extends Node3D

#
#	Signals
#

# Called when the playermodel is changed
signal changed(spawned_model: Node3D, model_scene: PackedScene)

#
#	Constants
#

# The internal model to use if none is provided
const DEFAULT_MODEL_SCENE: PackedScene = preload("default_player_model.tscn")

#
#	Exports
#

# The player model to load at start. If null,
# DEFAULT_MODEL_SCENE used instead
@export var initial_model: PackedScene = null

#
#	Public Variables
#

# The currently spawned model. Null if there is none
var spawned_model: Node3D = null

#
#	Godot Functions
#


func _ready():
	# If someone beat us to spawning a model, EXIT EARLY
	if spawned_model != null:
		return

	# If we have no model, use the internal default
	if initial_model == null:
		initial_model = DEFAULT_MODEL_SCENE

	# Spawn our starting model
	assert(initial_model)
	set_model(initial_model)


#
#	Functions
#


func set_model(model: PackedScene) -> void:
	clear_model()

	var new_model: Node3D = model.instantiate()
	add_child(new_model)
	new_model.owner = self
	spawned_model = new_model
	initial_model = model

	changed.emit(new_model, model)


func clear_model() -> void:
	if spawned_model == null:
		return

	spawned_model.queue_free()
	spawned_model = null
	changed.emit(null, null)
