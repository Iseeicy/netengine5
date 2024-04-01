@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("CharacterScriptRunner", "Node", preload ("script_runner/character_script_runner.gd"), preload ("icons/character_script_runner.png"))
	add_custom_type("CharacterScript", "Node", preload ("script_runner/character_script.gd"), preload ("icons/character_script.png"))
	add_custom_type("CharacterAgent3D", "CharacterBody3D", preload ("character_agent_3d.gd"), preload ("icons/character_definition.png"))
	add_custom_type("CharacterDefinition", "Resource", preload ("character_definition.gd"), preload ("icons/character_definition.png"))

func _exit_tree():
	remove_custom_type("CharacterDefinition")
	remove_custom_type("CharacterAgent3D")
	remove_custom_type("CharacterScript")
	remove_custom_type("CharacterScriptRunner")
