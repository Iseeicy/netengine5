@tool
extends ResourceSearchFilter
class_name KnowledgeBoolSearchFilter

#
#	Virtual Functions
#
	
func should_resource_be_included(path: String, resource: Resource) -> bool:
	return resource is KnowledgeBool
