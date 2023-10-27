@tool
extends Control
class_name DialogPreview

#
#	Private Variables
#

var _text_window: TextWindow

#
#	Godot Functions
#

func _ready():
	_text_window = $DialogPreviewTextWindow

#
#	Public Functions
#

func get_text_window() -> TextWindow:
	return _text_window
