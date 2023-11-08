@tool
extends KnowledgeBool
class_name KnowledgeCondition

#
#	Private Variables
#

## Has this condition been initialized yet? This is used to force
## `recalculate_value()` to setup it's evaluate results in the KnowledgeDB.
var _needs_init: bool = true

#
#	Virtual Functions
#

## Run this condition and see if it's true or false.
## This is meant to be extended!
func evaluate() -> bool:
	return false

#
#	Public Functions
#

## Force this condition to re-calculate it's value. If the value has changed
## since last evaluation, it will update it in the KnowledgeDB!
func recalculate_value() -> void:
	var new_value = evaluate()
	
	# If our value changed or we haven't been initialized
	if KnowledgeDB.get_knowledge_value(self) != new_value or _needs_init:
		_needs_init = false
		
		# Tell the knowledge database about our value!
		KnowledgeDB.set_knowledge_value(self, new_value)

#
#	Knowledge Functions
#

func get_value() -> bool:
	return KnowledgeDB.get_knowledge_value(self)
	
func set_value(_new_value: bool) -> void:
	recalculate_value()
	
func connect_updated_value(callable: Callable) -> void:
	KnowledgeDB.connect_updated_value(self, callable)
	
func disconnect_updated_value(callable: Callable) -> void:
	KnowledgeDB.disconnect_updated_value(self, callable)
