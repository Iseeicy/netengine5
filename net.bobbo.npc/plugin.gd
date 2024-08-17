@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type(
		"NPCAgent3D",
		"CharacterBody3D",
		preload("npc_agent_3d.gd"),
		preload("icons/npc_agent_3d.png")
	)
	add_custom_type(
		"NPCStateMachine",
		"Node",
		preload("npc_state_machine.gd"),
		preload("icons/npc_state_machine.png")
	)
	add_custom_type(
		"NPCState",
		"Node",
		preload("npc_state.gd"),
		preload("icons/npc_state.png")
	)


func _exit_tree():
	remove_custom_type("NPCState")
	remove_custom_type("NPCStateMachine")
	remove_custom_type("NPCAgent3D")
