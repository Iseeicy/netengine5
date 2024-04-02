@tool
extends CharacterBody3D
class_name CharacterAgent3D

#
#   Exports
#

## OPTIONAL. The character that this agent represents. If not 
## assigned, a default value will be assigned.
@export var character: CharacterDefinition = null

## The player scripts that define this agent's behaviour.
@export var agent_scripts: Array[PackedScene] = []

@export_group("Required Nodes")
## The node that represents the body position / rotation
## of this agent. Assigned to this agent's character.
@export var body_node: Node3D = self

## The node that represents the head position / aim of 
## this agent. Assigned to this agent's character.
@export var head_node: Node3D = null

## The inventory of this agent.
@export var inventory: ItemInventory = null

## The node that displays this agent's PlayerModel.
@export var playermodel: PlayerModel = null

## The node that `playermodel` is underneath. This will be
## rotated on the y-axis in order to rotate the playermodel.
@export var playermodel_pivot: Node3D = null

@export_group("Visuals")
## OPTIONAL. The playermodel to give this agent.
@export var initial_playermodel: PackedScene = null

#
#   Public Variables
#

## The node that manages character agent scripts on this agent.
var script_runner: CharacterAgentScriptRunner:
    get: return _script_runner
var _script_runner: CharacterAgentScriptRunner = null

## The node that handles interacting with this agent's items.
var item_interactor: ItemInteractor:
    get: return _item_interactor
var _item_interactor: ItemInteractor = null

## The collider of this agent.
var collider: CollisionShape3D:
    get: return _collider
var _collider: CollisionShape3D = null

#
#   Godot Functions
#

func _ready():
    # Find required nodes
    for child in get_children():
        if child is CollisionShape3D:
            _collider = child
            break

    # Setup our PlayerModel
    if initial_playermodel != null:
        playermodel.set_model(initial_playermodel)

    # Create a default character if there isn't one assigned
    if character == null:
        character = CharacterDefinition.new()
        character.name = "RUNTIME %s" % name
    
    # Make sure that the character def knows where 
    # this agent is
    character.body_node = body_node
    character.head_node = head_node

    # Setup the item interactor
    _item_interactor = ItemInteractor.new()
    add_child(_item_interactor)
    item_interactor.inventory = inventory
    item_interactor.character = character

    # Setup the script runner (DO THIS LAST)
    _script_runner = CharacterAgentScriptRunner.new()
    add_child(_script_runner)
    for script_scene in agent_scripts:
        var spawned_script = script_scene.instantiate()
        _script_runner.add_child(spawned_script)
        spawned_script.owner = self
    script_runner.initialize()
    script_runner.scripts_ready()

func _get_configuration_warnings():
    var warnings: Array[String] = []

    if not body_node:
        warnings.append("Value for `body_node` not assigned.")
    if not head_node:
        warnings.append("Value for `head_node` not assigned.")
    if not inventory:
        warnings.append("Value for `inventory` not assigned.")
    if not playermodel:
        warnings.append("Value for `playermodel` not assigned.")
    if not playermodel_pivot:
        warnings.append("Value for `playermodel_pivot` not assigned.")

    return warnings

func _process(delta):
    _process_before(delta)
    
    # Make sure the script runner is doing it's job
    script_runner.scripts_process(delta)

    _process_after(delta)

func _physics_process(delta):
    _physics_process_before(delta)
    
    # Make sure the script runner is doing it's job
    script_runner.scripts_physics_process(delta)

    _physics_process_after(delta)
    move_and_slide()

#
#   Virtual Functions
#

func _process_before(delta: float) -> void: return
func _process_after(delta: float) -> void: return
func _physics_process_before(delta: float) -> void: return
func _physics_process_after(delta: float) -> void: return
