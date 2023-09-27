extends ProjectedControlBehaviour
class_name ProjectedControlBehaviourHide

func behaviour_process(delta: float) -> void:
	# For non-sticky controls, we have all we need. If the target
	# is off screen we'll just hide this node.
	control.position = control.get_unprojected_position()
	control.visible = not control.get_is_target_behind_cam()
