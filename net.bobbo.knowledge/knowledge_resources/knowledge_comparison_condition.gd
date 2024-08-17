@tool
class_name KnowledgeComparisonCondition
extends KnowledgeCondition

#
#	Enums
#

## All possible kinds of comparison that can be performed on `knowledge_left`
## and `knowledge_right`.
enum ComparisonType {
	EQUALS,  ## `knowledge_left == knowledge_right`
	NOT_EQUALS,  ## `knowledge_left != knowledge_right`
	GREATER_THAN,  ## `knowledge_left > knowledge_right`
	GREATER_THAN_OR_EQUAL_TO,  ## `knowledge_left >= knowledge_right`
	LESS_THAN,  ## `knowledge_left < knowledge_right`
	LESS_THAN_OR_EQUAL_TO  ## `knowledge_left <= knowledge_right`
}

#
#	Exports
#

## The knowledge on the left side of the comparison.
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

## Specifically which kind of comparison to make
@export var comparison: ComparisonType = ComparisonType.EQUALS

## The knowledge on the right side of the comparison
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

	# Use the given comparison type to apply actual operators
	var result: bool
	match comparison:
		ComparisonType.EQUALS:
			result = knowledge_left.get_value() == knowledge_right.get_value()
		ComparisonType.NOT_EQUALS:
			result = knowledge_left.get_value() != knowledge_right.get_value()
		ComparisonType.GREATER_THAN:
			result = knowledge_left.get_value() > knowledge_right.get_value()
		ComparisonType.GREATER_THAN_OR_EQUAL_TO:
			result = knowledge_left.get_value() >= knowledge_right.get_value()
		ComparisonType.LESS_THAN:
			result = knowledge_left.get_value() < knowledge_right.get_value()
		ComparisonType.LESS_THAN_OR_EQUAL_TO:
			result = knowledge_left.get_value() <= knowledge_right.get_value()
		_:
			result = false

	return result


#
#	Signals
#


## Whenever one of our assigned knowledges has it's value updated, re-calculate
## OUR value
func _on_knowledge_value_changed(_unused) -> void:
	self.recalculate_value()
