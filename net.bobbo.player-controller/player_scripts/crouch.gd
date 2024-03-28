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

## This value is set to 0.0001 to not be small enough to cause the player to get
## stuck in a hallway that is exactly the same height as them and not big enough
## to show a visible difference in height
const _margin_of_height_error = 0.0001
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
	_ray_cast.target_position = player.up_direction * (_default_player_height / 2 + _margin_of_height_error)
	
	self.assert_input_action(crouch_action)

func player_physics_process(delta: float):
	# We have three different equations for calculating the target position
	# of the raycast to account for changes in distance from an above surface
	# when crouching in multiple scenarios
	
	# _ray_cast.get_collider() returns the object colliding with the ray so that
	# we can see if we are colliding with an object above the player
	# _ray_cast.get_collision_point() allows us to get the world coordinates of 
	# the point we collide with
	# We make target_position_height so that way we can change how the raycast's
	# target position is calculated
	var target_position_height = _default_player_height - _crouching_height_multiplier
	
	# This has a margin of error so that way we can properly detect if we have a
	# surface that is the exact height of the player and account for that by 
	# setting the crouch target to what it would be when standing but subtracted
	# by the margin of error
	if _ray_cast.get_collider() and \
	_ray_cast.get_collision_point().y < player.position.y + _default_player_height / 2 + _margin_of_height_error and \
	_ray_cast.get_collision_point().y > player.position.y + _default_player_height / 2 - _margin_of_height_error:
		crouch_target = _standing_height_multiplier  - _margin_of_height_error
	
	# This just detects when we should properly be crouched and also makes sure
	# to detect whether or not we're grounded to avoid auto crouching when 
	# touching a ceiling while jumping
	elif Input.is_action_pressed(crouch_action) or (_ray_cast.get_collider() and player.is_on_floor()):
		crouch_target = _crouching_height_multiplier
	
	# This just detects when we should be standing and adjusts everything to be 
	# able to detect when we should crouch
	else:
		crouch_target = _standing_height_multiplier  - _margin_of_height_error
		target_position_height = _default_player_height / 2
		
	# Set the raycast's target position so it can detect surfaces
	_ray_cast.target_position = player.up_direction * target_position_height
	
	var previous_scale = player.height * crouch_current
	crouch_current = lerp(crouch_current, crouch_target, clamp(delta * crouch_speed, 0, 1))
	var new_scale = player.height * crouch_current
	var scale_difference = new_scale - previous_scale
	
	player.velocity.y += scale_difference * _crouching_height_multiplier
	player.height = new_scale
