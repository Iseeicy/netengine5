## A specific state that an NPC can be in. Intended to be stored under
## an NPCStateMachine.
class_name NPCState
extends BobboState

#
#   Public Variables
#

## The agent that we belong to.
var agent: Variant:
	get:
		return _state_machine.agent

## The 3D agent that we belong to.
var agent_3d: NPCAgent3D:
	get:
		return _state_machine.agent_3d

## The 2D agent that we belong to.
var agent_2d:
	get:
		return _state_machine.agent_2d

var input: SimulatedInput:
	get:
		return _state_machine.input
