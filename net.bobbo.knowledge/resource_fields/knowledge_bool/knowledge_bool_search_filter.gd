@tool
class_name KnowledgeBoolSearchFilter
extends ResourceSearchFilter

#
#	Virtual Functions
#


func should_resource_be_included(_path: String, resource: Resource) -> bool:
	return resource is KnowledgeBool
