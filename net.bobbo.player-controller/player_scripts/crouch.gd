extends PlayerControllerScript

#
#	Constants
#

const CROUCH_ACTION: String = "player_crouch"

#
#	Exported
#

@export var crouch_speed: float = 20

#
#	Variables
#

var crouch_current: float = 0
var crouch_target: float = 0

#
#	Functions
#


func character_agent_physics_process(delta: float):
	if agent_3d.input.is_action_pressed(CROUCH_ACTION):
		crouch_target = 0.5
	else:
		crouch_target = 1

	var previous_scale = player.height * crouch_current
	crouch_current = lerp(
		crouch_current, crouch_target, clamp(delta * crouch_speed, 0, 1)
	)
	var new_scale = player.height * crouch_current
	var scale_difference = new_scale - previous_scale

	player.velocity.y += scale_difference * 0.5
	player.height = new_scale
