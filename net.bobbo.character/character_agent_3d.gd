@tool
class_name CharacterAgent3D
extends CharacterBody3D

#
#   Exports
#

## OPTIONAL. The character that this agent represents. If not assigned,
## a default value will be assigned.
@export var character: CharacterDefinition = null

## The player scripts that define this agent's behaviour.
@export var agent_scripts: Array[PackedScene] = []

## OPTIONAL. The entity input driving this agent. If not provided, an
## empty EntityInput will be created on _ready and used.
@export var input: EntityInput = null

@export_group("Required Nodes")
## The node that represents the body position / rotation of this agent.
## Assigned to this agent's character.
@export var body_node: Node3D = self

## The node that represents the head position / aim of this agent.
## Assigned to this agent's character.
@export var head_node: Node3D = null

## The inventory of this agent.
@export var inventory: ItemInventory = null

## The node that displays this agent's PlayerModelRenderer3D.
@export var playermodel: PlayerModelRenderer3D = null

## The node that `playermodel` is underneath. This will be rotated on
## the y-axis in order to rotate the playermodel.
@export var playermodel_pivot: Node3D = null

## The collider for this agent. There should only be ONE primary
## collider. If other colliders are added to this object, they will not
## be easily accessible.
@export var collider: CollisionShape3D = null

@export_group("Visuals")
## OPTIONAL. The playermodel to give this agent.
@export var initial_playermodel: PackedScene = null

#
#   Public Variables
#

## The node that manages character agent scripts on this agent.
var script_runner: CharacterAgentScriptRunner:
	get:
		return script_runner

## The node that handles interacting with this agent's items.
var item_interactor: ItemInteractor:
	get:
		return item_interactor

## The shape that this Agent's collider starts with on ready. Useful
## for checking how the collider shape has changed over time.
var default_collider_shape: Shape3D = null:
	get:
		return default_collider_shape

#
#   Godot Functions
#


func _ready():
	# EXIT EARLY if func called by editor. We need this bc the script
	# uses @tool.
	if Engine.is_editor_hint():
		return

	# Setup our PlayerModelRenderer3D
	if initial_playermodel != null:
		playermodel.set_model(initial_playermodel)

	# Create a default character if there isn't one assigned
	if character == null:
		character = CharacterDefinition.new()
		character.name = "RUNTIME %s" % name

	# Create the default entity input if there isn't any assigned
	if input == null:
		input = EntityInput.new()
		add_child(input)

	# Make sure that the character def knows where this agent is
	character.body_node = body_node
	character.head_node = head_node

	# Save a duplicate of the collider shape
	default_collider_shape = collider.shape.duplicate(true)

	# Setup the item interactor
	item_interactor = ItemInteractor.new()
	add_child(item_interactor)
	item_interactor.inventory = inventory
	item_interactor.character = character

	# Setup the script runner (DO THIS LAST)
	script_runner = CharacterAgentScriptRunner.new()
	add_child(script_runner)
	for script_scene in agent_scripts:
		var spawned_script = script_scene.instantiate()
		script_runner.add_child(spawned_script)
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
	if not collider:
		warnings.append("Value for `collider` not assigned.")

	# Give a warning if there's more than one collider
	var collider_counter = 0
	for child in get_children():
		if child is CollisionShape3D:
			collider_counter += 1
			if collider_counter > 1:
				warnings.append(
					(
						"There are multiple CollisionShape"
						+ " children. This is bad practice - there "
						+ "should only be one collider."
					)
				)
				break

	return warnings


func _process(delta):
	# EXIT EARLY if func called by editor. We need this bc the script
	# uses @tool.
	if Engine.is_editor_hint():
		return

	# Update the EntityInput for this agent
	input.gather_inputs(EntityInput.TickType.PROCESS)

	# Make sure the script runner is doing it's job
	_process_before(delta)
	script_runner.scripts_process(delta)
	_process_after(delta)


func _physics_process(delta):
	# EXIT EARLY if func called by editor. We need this bc the script
	# uses @tool.
	if Engine.is_editor_hint():
		return

	# Update the EntityInput for this agent
	input.gather_inputs(EntityInput.TickType.PROCESS_PHYSICS)

	# Make sure the script runner is doing it's job
	_physics_process_before(delta)
	script_runner.scripts_physics_process(delta)
	_physics_process_after(delta)
	move_and_slide()


#
#   Virtual Functions
#


func _process_before(_delta: float) -> void:
	return


func _process_after(_delta: float) -> void:
	return


func _physics_process_before(_delta: float) -> void:
	return


func _physics_process_after(_delta: float) -> void:
	return
