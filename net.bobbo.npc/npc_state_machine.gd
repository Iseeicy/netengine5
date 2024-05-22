## The brain of an NPCAgent3D or NPCAgent2D.
class_name NPCStateMachine
extends BobboStateMachine

#
#   Exports
#

## The input simulator to use when trying to control the character agent
## that this belongs to.
@export var input: SimulatedInput = null

#
#   Public Variables
#

## The NPCAgent that this state machine belongs to. Can be `NPCAgent3D`,
## `NPCAgent2D`, or null
var agent: Variant:
	get:
		return agent_3d if agent_3d != null else agent_2d

## The 3D agent that we belong to, if there is one.
var agent_3d: NPCAgent3D:
	get:
		if agent_3d == null:
			agent_3d = owner as NPCAgent3D
		return agent_3d

## The 2D agent that we belong to, if there is one.
# TODO - add agent 2d
var agent_2d = null

#
#   Godot Functions
#


func _init():
	pass
