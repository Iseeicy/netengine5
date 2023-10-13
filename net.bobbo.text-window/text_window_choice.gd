## A resource that represents a SINGLE choice / option of a
## TextWindow. This is used alongside a TextWindowChoicePrompt.
extends Resource
class_name TextWindowChoice

#
#	Exported
#

## The text to display when representing this choice
@export var text: String = ""

#
#	Static Functions
#

## Creates a basic choice using just text
static func create_text_choice(choice_text: String) -> TextWindowChoice:
	var choice = TextWindowChoice.new()
	choice.text = choice_text
	
	return choice
