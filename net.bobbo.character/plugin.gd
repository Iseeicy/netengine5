@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("CharacterDefinition", "Resource", preload("character_definition.gd"), preload("icons/character_definition.png"))

func _exit_tree():
	remove_custom_type("CharacterDefinition")
