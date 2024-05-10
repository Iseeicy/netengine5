class_name InputAxis1d
extends RefCounted

#
#   Public Variables
#

## The name of the action that, when pressed all the way, pulls this axis as
## far negative as possible.
var negative_action_name: String = ""

## The name of the action that, when pressed all the way, pushes this axis as
## far positive as possible.
var positive_action_name: String = ""

#
#   Godot Functions
#


func _init(negative_action_name: String, positive_action_name: String):
	self.negative_action_name = negative_action_name
	self.positive_action_name = positive_action_name
