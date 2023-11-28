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

## default_player_height is needed for proper uncrouching height calculations 
## if the maximum player height were to change during gameplay at any point this 
## value would need to somehow be updated to account for that default is 2 
## because the default height in player_controller is 2
var _default_player_height: float = 2
var _should_be_crouched: bool = false

const _standing_height_multiplier: float = 1
const _crouching_height_multiplier: float = 0.5

#
#	Functions
#

func player_ready():
	_default_player_height = player.height
	self.assert_input_action(crouch_action)

func player_physics_process(delta: float):
	if Input.is_action_pressed(crouch_action) or _should_force_crouch():
		crouch_target = _crouching_height_multiplier
		_should_be_crouched = true
	else:
		crouch_target = _standing_height_multiplier

	var previous_scale = player.height * crouch_current
	crouch_current = lerp(crouch_current, crouch_target, clamp(delta * crouch_speed, 0, 1))
	var new_scale = player.height * crouch_current
	var scale_difference = new_scale - previous_scale
	
	player.velocity.y += scale_difference * _crouching_height_multiplier
	player.height = new_scale

func _should_force_crouch():
	# Get the 3D physics space from a Node3D like the player_pivot
	var space_state = player.model_pivot.get_world_3d().direct_space_state
	
	var raycast_position_offset = 0
	if(_should_be_crouched):
		raycast_position_offset = (_default_player_height / 2) * _crouching_height_multiplier
	
	# Calculate origin and ending of raycast
	var origin = player.position + player.up_direction * raycast_position_offset
	
	# We subract by an offset of 0.001 due to a float precision error that can 
	# occur when an obstruction is just barely above the player causing the 
	# raycast to barely detect it and making the player crouch so that doesn't
	# happen
	var end = origin + player.up_direction * (_default_player_height / 2 - 0.001)
	
	# Create the raycast
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	
	# Exclude the player from raycast calculations
	query.exclude = [player]
	
	# Cast the raycast
	var ceiling_collision = space_state.intersect_ray(query)
	
	# If we detect an object at the top of the player
	if ceiling_collision:
		return true
	else:
		_should_be_crouched = false
		return false
