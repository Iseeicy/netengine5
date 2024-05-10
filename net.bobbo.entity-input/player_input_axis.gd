## A node representation of some configurable player input axis.
## Making this node based means we can allow a designer in Godot to
## combine analog inputs into an axis IN EDITOR, rather than modifying
## code. The name of this node should be the name of the axis to define.
@tool
class_name PlayerInputAxis
extends Node

#
#	Exports
#

## The action that represents this axis most positive value.
@export var positive_action: PlayerInputAnalog

## The action that represents this axis most negative value.
@export var negative_action: PlayerInputAnalog
