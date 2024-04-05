## Allows an agent to crouch
extends CharacterAgentScript

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

## Is the entity trying to crouch right now?
var should_crouch: bool = false

#
#	Character Agent Functions
#


func character_agent_process(_delta: float):
	# Cache our input in process so we can use it in physics_process
	should_crouch = agent_3d.input.is_action_pressed(CROUCH_ACTION)


func character_agent_physics_process(delta: float):
	if not _supports_collider():
		return

	if should_crouch:
		crouch_target = 0.5
	else:
		crouch_target = 1

	var default_height := _get_default_collider_height()

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
