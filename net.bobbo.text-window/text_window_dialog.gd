## A resource that represents a single window's worth of 
## dialog, optionally spoken by a character.
extends Resource
class_name TextWindowDialog

#
#	Exported
#

## The dialog text to display (usually through a TextReader)
## when this dialog is shown.
@export var text: String = ""
## (OPTIONAL) The character that is speaking this line of
## dialog. If provided, this will tell the TextWindow how
## to read the dialog, and where the dialog is coming from.
@export var character: CharacterDefinition = null

#
#	Static Functions
#

## Creates a basic dialog with the given text
static func create_text(dialog_text: String) -> TextWindowDialog:
	var dialog = TextWindowDialog.new()
	dialog.text = dialog_text
	
	return dialog
