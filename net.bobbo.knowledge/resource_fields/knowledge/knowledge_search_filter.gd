@tool
extends ResourceSearchFilter
class_name KnowledgeSearchFilter

#
#	Virtual Functions
#
	
func should_resource_be_included(path: String, resource: Resource) -> bool:
	return resource is Knowledge
