extends Node
class_name PlayerControllerScriptRunner

# The scripts to run. These are usually children of this node
var scripts: Array[PlayerControllerScript]

#
#	Functions
#

func initialize() -> void:
	scripts = _find_scripts_in_children()	

func scripts_ready():
	for script in scripts:
		script.call_player_ready()

func scripts_process(delta):
	for script in scripts:
		script.call_player_process(delta)
		
func scripts_physics_process(delta):
	for script in scripts:
		script.call_player_physics_process(delta)

#
#	Private Functions
#

# Sort through the top level child nodes and compile a list of scripts
func _find_scripts_in_children() -> Array[PlayerControllerScript]:
	var results: Array[PlayerControllerScript] = []
	
	for node in get_children():
		if node is PlayerControllerScript:
			results.append(node)
			
	return results
