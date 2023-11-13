@tool
extends Resource
class_name ResourceSearchFilter

#
#	Virtual Functions
#

## A virtual function meant to be overidden.
## Should the given resource pass through the filter?
## - `path`: The absolute path of the resource.
## - `resource`: The temporarily loaded resource itself.
## Returns true if the resource passes through the filter, false otherwise.
func should_resource_be_included(path: String, resource: Resource) -> bool:
	return resource is Resource
