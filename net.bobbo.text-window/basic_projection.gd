extends ControlProjection
class_name BasicProjection

func _process(delta: float) -> void:
	super(delta)

	# For non-sticky controls, we have all we need. If the target
	# is off screen we'll just hide this node.
	position = get_unprojected_position()
	visible = not get_is_target_behind_cam()
