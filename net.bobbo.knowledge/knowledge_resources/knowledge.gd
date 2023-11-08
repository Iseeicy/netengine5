@tool
## A base class for resource-based knowledge. Not meant
## to be used on it's own.
##
## Created resources have their knowledge values tracked at runtime,
## so that many systems can interact with them.
extends Resource
class_name Knowledge

#
#	Variables
#

var _default_value = null

#
#	Public Functions
#

func get_default_value():
	return _default_value

func get_value():
	return KnowledgeDB.get_knowledge_value(self)
	
func set_value(new_value):
	KnowledgeDB.set_knowledge_value(self, new_value)
	
func connect_updated_value(callable: Callable) -> void:
	KnowledgeDB.connect_updated_value(self, callable)
	
func disconnect_updated_value(callable: Callable) -> void:
	KnowledgeDB.disconnect_updated_value(self, callable)
