@tool
extends GraphNodeData
class_name ChoicePromptNodeData

## The text to show when displaying this prompt
@export var text: String = ""
## A list of options to present the user
@export var options: Array[ChoicePromptNodeDataOption] = []
