extends Node
class_name PlayerControllerScript

#
#	Variables
#

@onready var player: PlayerController
@onready var script_runner: PlayerControllerScriptRunner
var _is_running: bool = true

#
#	Functions
#

func call_player_ready() -> void:
	player = _find_player()
	script_runner = _find_script_runner()
	player_ready()

func call_player_process(delta: float) -> void:
	if _is_running:
		player_process(delta)
	
func call_player_physics_process(delta: float) -> void:
	if _is_running:
		player_physics_process(delta)

func assert_input_action(action_name: String) -> bool:
	if InputMap.has_action(action_name):
		return true
	else:
		printerr("No input defined for '%s'. %s stopped..." % [action_name, self.name])
		self.set_running(false)
		return false

#
#	Base Functions
#

func player_ready() -> void:
	return
	
func player_process(_delta: float) -> void:
	return
	
func player_physics_process(_delta: float) -> void:
	return

func set_running(should_run: bool) -> void:
	_is_running = should_run
	set_process(should_run)
	set_physics_process(should_run)
	set_process_unhandled_input(should_run)
	set_block_signals(!should_run)
	
func is_running() -> bool:
	return _is_running

#
#	Private Functions
#

func _find_player() -> PlayerController:
	var found_player = owner as PlayerController
	assert(found_player != null)
	return found_player

func _find_script_runner() -> PlayerControllerScriptRunner:
	return player.script_runner
	
