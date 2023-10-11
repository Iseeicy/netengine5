extends TextWindowState

#
#	State Functions
#

func state_enter(_message: Dictionary = {}) -> void:
	text_window.visible = true
