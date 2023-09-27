extends ProjectedControlBehaviour
class_name ProjectedControlBehaviourFillWhenClose

#
#	Exported
#

@export_group("Distance")
@export var closeness_threshold: float = 4
@export var max_distance: float = 15

#
#	Functions
#

func behaviour_process(delta: float) -> void:
	var distance = control.get_distance_to_target()
	
	# If we're further than the max distance,
	# don't display anything
	if distance > max_distance:
		control.visible = false
		control.position = control.get_unprojected_position()
		return
		
	# If we're under the closeness threshold, then fill
	# the screen
	if distance <= closeness_threshold:
		control.visible = true
		control.position = control.get_viewport_base_size() / 2.0
		control.scale = Vector2(0, 0)
		return
		
	# If we're between max distance and the closeness threshold,
	# Display normally
	control.position = control.get_unprojected_position()
	control.visible = not control.get_is_target_behind_cam()
	control.scale = Vector2.ONE / clamp(control.get_distance_to_target(), 1, INF)

#
#	Private Functions
#

