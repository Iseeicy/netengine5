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

## _default_player_height is needed for proper uncrouching height calculations 
## if the maximum player height were to change during gameplay at any point this 
## value would need to somehow be updated to account for that default is 2 
## because the default height in player_controller is 2
var _default_player_height: float = 2

var _ray_cast: RayCast3D

const _standing_height_multiplier: float = 1
const _crouching_height_multiplier: float = 0.5

#
#	Functions
# 

func player_ready():
	_default_player_height = player.height
	
	# Assign raycast (have to do it here to avoid an error)
	_ray_cast = $CrouchRay3D
	
	# Reparent the ray to the player
	_ray_cast.reparent(player, false)
	
	# Set inital target position so we're not a frame behind
	_ray_cast.target_position = player.up_direction * (_default_player_height / 2 + 0.01)
	
	self.assert_input_action(crouch_action)

func player_physics_process(delta: float):
	# We have two different equations for calculating the target position
	# of the raycast to account for changes in distance from an above surface
	# when crouching
	
	# We also add by an offset of 0.01 due to a float precision error that
	# can occur when an obstruction is just barely above the player causing the 
	# raycast to barely detect it and making it so that the player may or may
	# not crouch, if we subtracted then it would result the player getting
	# getting stuck if a surface is just barely above the player so by adding
	# it makes the player crouch automatically
	
	# _ray_cast.get_collider() returns the object colliding with the ray so that
	# we can see if we are colliding with an object above the player
	if Input.is_action_pressed(crouch_action) or _ray_cast.get_collider():
		crouch_target = _crouching_height_multiplier
		
		# Did a similar thing as line 38 to avoid the second line
		var target_position_height = _default_player_height - _crouching_height_multiplier + 0.01
		_ray_cast.target_position = player.up_direction * target_position_height
	else:
		crouch_target = _standing_height_multiplier
		_ray_cast.target_position = player.up_direction * (_default_player_height / 2 + 0.01)

	var previous_scale = player.height * crouch_current
	crouch_current = lerp(crouch_current, crouch_target, clamp(delta * crouch_speed, 0, 1))
	var new_scale = player.height * crouch_current
	var scale_difference = new_scale - previous_scale
	
	player.velocity.y += scale_difference * _crouching_height_multiplier
	player.height = new_scale
