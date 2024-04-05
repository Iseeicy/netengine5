## Allows an agent to move their head node with mouse input.
extends CharacterAgentScript

#
#   Private Variables
#

@onready var _mouse_look: MouseLook3D = $MouseLook3D

#
#   Agent Functions
#


func character_agent_ready() -> void:
	# Put the mouselook under our head node
	_mouse_look.reparent(agent.head_node, false)
	_mouse_look.model_pivot = agent_3d.playermodel_pivot
