class_name InputAxis2d
extends RefCounted

#
#   Exports
#

## The x axis of this 2D axis
var x: InputAxis1d = null

## The y axis of this 2D axis
var y: InputAxis1d = null

#
#   Godot Functions
#


func _init(x: InputAxis1d, y: InputAxis1d):
	self.x = x
	self.y = y
