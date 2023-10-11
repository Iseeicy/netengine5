extends Resource
class_name TextWindowChoicePrompt

#
#	Exported
#

@export var text: String = ""
@export var choices: Array[TextWindowChoice] = []

#
#	Static Functions
#

# Creates a basic prompt with just a set of text choices
static func create_basic_prompt(text_choices: Array[String]) -> TextWindowChoicePrompt:
	var prompt = TextWindowChoicePrompt.new()
	for choice in text_choices:
		prompt.choices.append(TextWindowChoice.create_text_choice(choice))
	
	return prompt
