extends Node
class_name CharacterAgentScript

#
#	Public Variables
#

## The CharacterAgent that this script belongs to. Can be `CharacterAgent3D`,
## `CharacterAgent2D`, or null
var agent: Variant:
	get:
		return agent_3d if agent_3d != null else agent_2d

## The 3D agent that we belong to, if there is one.
var agent_3d: CharacterAgent3D:
	get:
		if agent_3d == null: agent_3d = owner as CharacterAgent3D
		return agent_3d

## The 2D agent that we belong to, if there is one.
# TODO - add agent 2d
@onready var agent_2d = null

## The script runner that belongs to our parent agent, if there is one
var script_runner: CharacterAgentScriptRunner:
	get:
		if agent == null: return null
		return agent.script_runner

#
#	Private Variables
#
		
## Is this character script executing?
var _is_running: bool = true

#
#	Public Functions
#

func call_character_agent_ready() -> void:
	character_agent_ready()

func call_character_agent_process(delta: float) -> void:
	if _is_running:
		character_agent_process(delta)
	
func call_character_agent_physics_process(delta: float) -> void:
	if _is_running:
		character_agent_physics_process(delta)

#
#	Base Functions
#

func character_agent_ready() -> void:
	return
	
func character_agent_process(_delta: float) -> void:
	return
	
func character_agent_physics_process(_delta: float) -> void:
	return

func set_running(should_run: bool) -> void:
	_is_running = should_run
	set_process(should_run)
	set_physics_process(should_run)
	set_process_unhandled_input(should_run)
	set_block_signals(!should_run)
	
func is_running() -> bool:
	return _is_running
