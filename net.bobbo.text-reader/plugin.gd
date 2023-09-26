@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type(
		"TextReader",					# Type name
		"Node", 					# Base type name
		preload("text_reader.gd"), 		# Script for type
		preload("icons/text_reader.png")	# Icon for type
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
	add_custom_type(
		"TextSounds",						# Type name
		"Resource",							# Base type name
		preload("text_sounds.gd"), 			# Script for type
		preload("icons/text_speaker.png")	# Icon for type
	)

func _exit_tree():
	remove_custom_type("TextReader")
	remove_custom_type("TextReaderSettings")
	remove_custom_type("TextSpeaker")
	remove_custom_type("TextSounds")
