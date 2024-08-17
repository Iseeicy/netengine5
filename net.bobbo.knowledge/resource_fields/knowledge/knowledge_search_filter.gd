@tool
class_name KnowledgeSearchFilter
extends ResourceSearchFilter

#
#	Virtual Functions
#


func should_resource_be_included(_path: String, resource: Resource) -> bool:
	return resource is Knowledge
