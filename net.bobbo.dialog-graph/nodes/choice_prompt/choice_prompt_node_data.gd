@tool
extends GraphNodeData
class_name ChoicePromptNodeData

## The text to show when displaying this prompt
@export var text: String = ""
## A list of text choices to present the user
@export var choices: Array[String] = []
## Visibility conditions for any of the `choices` (int -> KnowledgeBool)
@export var visibility_conditions: Dictionary = {}
