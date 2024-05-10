## Allows an agent to move their head node with mouse input.
extends CharacterAgentScript

#
#	Exports
#

@export var sensitivity_x: float = 0.25
@export var sensitivity_y: float = 0.25

#
#   Private Variables
#

## An input wrapper to make getting mouse movement easier
var _look_axis: InputAxis2d = InputAxis2d.new(
	InputAxis1d.new("player_look_left", "player_look_right"),
	InputAxis1d.new("player_look_down", "player_look_up")
)

#
#   Agent Functions
#


func character_agent_process(_delta: float) -> void:
	var look_movement := (
		agent_3d.input.read_axis_2d(_look_axis)
		* Vector2(sensitivity_x, sensitivity_y)
	)

	# Calculate the rotation amount then apply
	var new_rotation: Vector3 = agent_3d.head_node.rotation_degrees
	new_rotation.x = clampf(new_rotation.x - look_movement.y, -90.0, 90.0)
	new_rotation.y -= look_movement.x
	agent_3d.head_node.rotation_degrees = new_rotation
	agent_3d.head_node.orthonormalize()

	# Make the playermodel rotate with the head
	agent_3d.playermodel_pivot.rotation.y = agent.head_node.rotation.y
