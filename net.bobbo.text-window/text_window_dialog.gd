extends Resource
class_name TextWindowDialog

#
#	Exported
#

@export var text: String = ""
@export var character: CharacterSpeaker = null

#
#	Static Functions
#

# Creates a basic dialog with the given text
static func create_text(dialog_text: String) -> TextWindowDialog:
	var dialog = TextWindowDialog.new()
	dialog.text = dialog_text
	
	return dialog
