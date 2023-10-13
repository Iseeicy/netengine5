@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("ProjectionCharacterFocus", "Node", preload("projection_character_focus.gd"), preload("icons/projection_character_focus.png"))
	add_custom_type("TextWindow", "Control", preload("text_window.gd"), preload("icons/text_window.png"))
	add_custom_type("TextWindowChoice", "Resource", preload("text_window_choice.gd"), preload("icons/text_window_choice.png"))
	add_custom_type("TextWindowChoicePrompt", "Resource", preload("text_window_choice_prompt.gd"), preload("icons/text_window_choice_prompt.png"))
	add_custom_type("TextWindowDialog", "Resource", preload("text_window_dialog.gd"), preload("icons/text_window_dialog.png"))
	add_custom_type("TextWindowStateMachine", "Node", preload("text_window_state_machine.gd"), preload("icons/text_window_state_machine.png"))
	add_custom_type("TextWindowState", "Node", preload("text_window_state.gd"), preload("icons/text_window_state.png"))

func _exit_tree():
	remove_custom_type("ProjectionCharacterFocus")
	remove_custom_type("TextWindow")
	remove_custom_type("TextWindowChoice")
	remove_custom_type("TextWindowChoicePrompt")
	remove_custom_type("TextWindowDialog")
	remove_custom_type("TextWindowStateMachine")
	remove_custom_type("TextWindowState")
