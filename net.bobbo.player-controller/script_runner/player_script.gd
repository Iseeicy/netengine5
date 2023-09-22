extends Node
class_name PlayerControllerScript

@onready var player: PlayerController
@onready var script_runner: PlayerControllerScriptRunner

#
#	Base Functions
#

func player_ready() -> void:
	player = _find_player()
	script_runner = _find_script_runner()

func player_process(_delta: float) -> void:
	return
	
func player_physics_process(_delta: float) -> void:
	return

#
#	Private Functions
#

func _find_player() -> PlayerController:
	var found_player = owner as PlayerController
	assert(found_player != null)
	return found_player

func _find_script_runner() -> PlayerControllerScriptRunner:
	return player.script_runner
	
