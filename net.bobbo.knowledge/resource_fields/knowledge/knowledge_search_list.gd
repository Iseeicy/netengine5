extends ResourceSearchList
class_name KnowledgeSearchList

#
#	Virtual Functions
#
	
func _is_resource_correct_type(resource) -> bool:
	return resource is Knowledge
