@tool
extends Resource
class_name ChoicePromptNodeDataOption

#
#	Exports
#

## The text to display to the user, for this single option
@export var text: String = ""

## Optionally control the visibility of this option based on the value of this
## knowledge boolean. If null, this option will always be visibile.
@export var visibility_condition: KnowledgeBool = null
