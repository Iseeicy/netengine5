extends Resource
class_name TextWindowChoice

#
#	Exported
#

@export var text: String = ""

#
#	Static Functions
#

# Creates a basic choice using just text
static func create_text_choice(choice_text: String) -> TextWindowChoice:
	var choice = TextWindowChoice.new()
	choice.text = choice_text
	
	return choice
