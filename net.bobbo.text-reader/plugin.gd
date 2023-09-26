@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type(
		"TextReaderLabel",					# Type name
		"RichTextLabel", 					# Base type name
		preload("text_reader_label.gd"), 		# Script for type
		preload("icons/text_reader_label.png")	# Icon for type
	)
	add_custom_type(
		"TextReaderSettings",					# Type name
		"Resource",								# Base type name
		preload("text_reader_settings.gd"), 		# Script for type
		preload("icons/text_reader_settings.png")	# Icon for type
	)
	add_custom_type(
		"TextSpeaker",							# Type name
		"Node",								# Base type name
		preload("text_speaker.gd"), 		# Script for type
		preload("icons/text_speaker.png")	# Icon for type
	)

func _exit_tree():
	remove_custom_type("TextReaderLabel")
	remove_custom_type("TextReaderSettings")
	remove_custom_type("TextSpeaker")
