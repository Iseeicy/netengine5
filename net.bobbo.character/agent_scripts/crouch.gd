## Allows an agent to crouch
extends CharacterAgentScript

#
#	Exported
#

@export var crouch_speed: float = 20

#
#	Variables
#

var _ray_cast: RayCast3D

## This value is set to 0.0001 to not be small enough to cause the agent to get
## stuck in a hallway that is exactly the same height as them and not big enough
## to show a visible difference in height
const _margin_of_height_error = 0.0001

var crouch_current: float = 0
var crouch_target: float = 0

#
#	Character Agent Functions
#

func character_agent_ready():
	# Assign raycast (have to do it here to avoid an error)
	_ray_cast = $CrouchRay3D
	
	# Reparent the ray to the agent
	_ray_cast.reparent(agent_3d, false)

func character_agent_physics_process(delta: float):
	if not _supports_collider():
		return

	if agent_3d.input.is_action_pressed(BobboInputs.Player.CROUCH):
		crouch_target = 0.5
	else:
		crouch_target = 1

	var default_height := _get_default_collider_height()
	
	# We have three different equations for calculating the target position
	# of the raycast to account for changes in distance from an above surface
	# when crouching in multiple scenarios
	
	# _ray_cast.get_collider() returns the object colliding with the ray so that
	# we can see if we are colliding with an object above the agent
	# _ray_cast.get_collision_point() allows us to get the world coordinates of 
	# the point we collide with
	# We make target_position_height so that way we can change how the raycast's
	# target position is calculated
	var target_position_height = default_height - 0.5
	
	# This has a margin of error so that way we can properly detect if we have a
	# surface that is the exact height of the agent and account for that by 
	# setting the crouch target to what it would be when standing but subtracted
	# by the margin of error
	# I also would have formmated this better but this was the most readable way
	# I could get it to wrap around
	if _ray_cast.get_collider() and \
	_ray_cast.get_collision_point().y < agent_3d.position.y + default_height / 2 + _margin_of_height_error and \
	_ray_cast.get_collision_point().y > agent_3d.position.y + default_height / 2 - _margin_of_height_error:
		crouch_target = 1 - _margin_of_height_error
	
	# This just detects when we should properly be crouched and also makes sure
	# to detect whether or not we're grounded to avoid auto crouching when 
	# touching a ceiling while jumping
	elif should_crouch or (_ray_cast.get_collider() and agent_3d.is_on_floor()):
		crouch_target = 0.5
	
	# This just detects when we should be standing and adjusts everything to be 
	# able to detect when we should crouch
	else:
		crouch_target = 1 - _margin_of_height_error
		target_position_height = default_height / 2
		
	# Set the raycast's target position so it can detect surfaces
	_ray_cast.target_position = agent_3d.up_direction * target_position_height

	var previous_scale = default_height * crouch_current
	crouch_current = lerp(
		crouch_current, crouch_target, clamp(delta * crouch_speed, 0, 1)
	)
	var new_scale = default_height * crouch_current
	var scale_difference = new_scale - previous_scale

	agent_3d.velocity.y += scale_difference * 0.5
	_set_collider_height(new_scale)


#
#	Private Functions
#


func _supports_collider() -> bool:
	if agent_3d.collider.shape is CapsuleShape3D:
		return true
	return false


func _get_default_collider_height() -> float:
	if agent_3d.default_collider_shape is CapsuleShape3D:
		return agent_3d.default_collider_shape.height
	return 0


func _get_collider_height() -> float:
	if agent_3d.collider.shape is CapsuleShape3D:
		return agent_3d.collider.shape.height
	return 0


func _set_collider_height(height: float) -> void:
	if agent_3d.collider.shape is CapsuleShape3D:
		agent_3d.collider.shape.height = height
