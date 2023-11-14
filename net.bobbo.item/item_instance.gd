@tool
extends Node
class_name ItemInstance

#
#	Exports
#

@export var descriptor: ItemDescriptor = null

#
#	Public Functions
#

func setup(desc: ItemDescriptor) -> void:
	descriptor = desc
