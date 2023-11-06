## Represents basic data relating to a GraphNode. Meant to be extended.
@tool
extends Resource
class_name GraphNodeData

#
#	Exports
#

## The position of this node in the graph that it belongs to.
@export var position: Vector2 = Vector2.ZERO
