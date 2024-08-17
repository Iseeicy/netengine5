@tool
class_name KnowledgeOperatorCondition
extends KnowledgeCondition

#
#	Enums
#

## All possible kinds of boolean operations that can be performed on
## `knowledge_left` and `knowledge_right`.
enum OperatorType {
	AND,  ## `knowledge_left && knowledge_right`
	OR,  ## `knowledge_left || knowledge_right`
}

#
#	Exports
#

## The knowledge on the left side of the operation.
@export var knowledge_left: Knowledge:
	get:
		return _knowledge_left
	set(new_knowledge):
		if _knowledge_left != null:
			_knowledge_left.disconnect_updated_value(
				_on_knowledge_value_changed
			)
		if new_knowledge != null:
			new_knowledge.connect_updated_value(_on_knowledge_value_changed)
		_knowledge_left = new_knowledge

## Specifically which kind of operation to perform
@export var operator: OperatorType = OperatorType.AND

## The knowledge on the right side of the operation.
@export var knowledge_right: Knowledge:
	get:
		return _knowledge_right
	set(new_knowledge):
		if _knowledge_right != null:
			_knowledge_right.disconnect_updated_value(
				_on_knowledge_value_changed
			)
		if new_knowledge != null:
			new_knowledge.connect_updated_value(_on_knowledge_value_changed)
		_knowledge_right = new_knowledge

#
#	Private Values
#

var _knowledge_left: Knowledge = null
var _knowledge_right: Knowledge = null

#
#	Condition Functions
#


func evaluate() -> bool:
	if knowledge_left == null or knowledge_right == null:
		return false

	# Use the given operator type to apply actual operators
	match operator:
		OperatorType.AND:
			return knowledge_left.get_value() and knowledge_right.get_value()
		OperatorType.OR:
			return knowledge_left.get_value() or knowledge_right.get_value()

	return false


#
#	Signals
#


## Whenever one of our assigned knowledges has it's value updated, re-calculate
## OUR value
func _on_knowledge_value_changed(_unused) -> void:
	self.recalculate_value()
