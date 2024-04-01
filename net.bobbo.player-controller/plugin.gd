@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("PlayerController", "CharacterBody3D", preload ("player_controller.gd"), preload ("icons/player_controller.png"))
	add_custom_type("PlayerControllerScript", "Node", preload ("script_runner/player_script.gd"), preload ("icons/player_script.png"))

func _exit_tree():
	remove_custom_type("PlayerControllerScript")
	remove_custom_type("PlayerController")
