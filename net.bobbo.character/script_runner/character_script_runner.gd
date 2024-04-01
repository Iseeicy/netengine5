extends Node
class_name CharacterAgentScriptRunner

# The scripts to run. These are usually children of this node
var scripts: Array[CharacterAgentScript]

#
#	Functions
#

func initialize() -> void:
	scripts = _find_scripts_in_children()

func scripts_ready():
	for script in scripts:
		script.call_character_agent_ready()

func scripts_process(delta):
	for script in scripts:
		script.call_character_agent_process(delta)
		
func scripts_physics_process(delta):
	for script in scripts:
		script.call_character_agent_physics_process(delta)

#
#	Private Functions
#

# Sort through the top level child nodes and compile a list of scripts
func _find_scripts_in_children() -> Array[CharacterAgentScript]:
	var results: Array[CharacterAgentScript] = []
	
	for node in get_children():
		if node is CharacterAgentScript:
			results.append(node)
			
	return results
