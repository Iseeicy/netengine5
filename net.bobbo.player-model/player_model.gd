extends Node3D
class_name PlayerModel

#
#	Exported
#

# Called when the playermodel is changed
signal changed(spawned_model: Node3D, model_scene: PackedScene)

# The player model to load at start. If null, 
# default_model_scene used instead
@export var initial_model: PackedScene = null

#
#	Variables
#

# The currently spawned model. Null if there is none
var spawned_model: Node3D = null

# The internal model to use if none is provided
const default_model_scene: PackedScene = preload("default_player_model.tscn")

#
#	Godot Functions
#

func _ready():
	# If someone beat us to spawning a model, EXIT EARLY
	if spawned_model != null:
		return
	
	# If we have no model, use the internal default
	if initial_model == null:
		initial_model = default_model_scene
	
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
		
