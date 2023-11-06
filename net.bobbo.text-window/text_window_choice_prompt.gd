## A resource that represents a prompt asking the user to make
## a choice in a TextWindow.
extends Resource
class_name TextWindowChoicePrompt

#
#	Exported
#

## (OPTIONAL) The text to display when showing this prompt
@export var text: String = ""
## The choices to display in the TextWindow when this prompt
## is shown.
@export var choices: Array[TextWindowChoice] = []

#
#	Static Functions
#

## Creates a choice prompt with text and text choices
static func create_prompt_with_text(text: String, text_choices: Array[String]) -> TextWindowChoicePrompt:
	var prompt = TextWindowChoicePrompt.new()
	prompt.text = text
	for choice in text_choices:
		prompt.choices.append(TextWindowChoice.create_text_choice(choice))
		
	return prompt

## Creates a basic prompt with just a set of text choices
static func create_basic_prompt(text_choices: Array[String]) -> TextWindowChoicePrompt:
	var prompt = TextWindowChoicePrompt.new()
	for choice in text_choices:
		prompt.choices.append(TextWindowChoice.create_text_choice(choice))
	
	return prompt
