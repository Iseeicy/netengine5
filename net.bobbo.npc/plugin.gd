@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("NPCAgent3D", "CharacterBody3D", preload ("npc_agent_3d.gd"), preload ("icons/npc_agent_3d.png"))

func _exit_tree():
	remove_custom_type("NPCAgent3D")
