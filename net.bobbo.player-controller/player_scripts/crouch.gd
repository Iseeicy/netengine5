extends PlayerControllerScript

#
#	Exported
#

@export var crouch_speed: float = 20

#
#	Variables
#

var crouch_current: float = 0
var crouch_target: float = 0
const crouch_action: String = "player_crouch"

#
#	Functions
#

func player_ready():
	self.assert_input_action(crouch_action)

func player_physics_process(delta: float):
	if Input.is_action_pressed(crouch_action):
		crouch_target = 0.5
	else:
		crouch_target = 1
		
	var previous_scale = player.height * crouch_current
	crouch_current = lerp(crouch_current, crouch_target, clamp(delta * crouch_speed, 0, 1))
	var new_scale = player.height * crouch_current
	var scale_difference = new_scale - previous_scale
	
	player.velocity.y += scale_difference * 0.5
	player.height = new_scale
