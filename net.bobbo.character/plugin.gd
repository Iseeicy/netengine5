@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("CharacterSpeaker", "Resource", preload("character_speaker.gd"), preload("icons/character_speaker.png"))

func _exit_tree():
	remove_custom_type("CharacterSpeaker")
