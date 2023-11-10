@tool
extends ResourceSearchList
class_name KnowledgeBoolSearchList

#
#	Virtual Functions
#
	
func _is_resource_correct_type(resource) -> bool:
	return resource is KnowledgeBool
