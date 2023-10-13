## This node projects a Control node in a basic manner.
## It doesn't scale the node at all.
## It places the Control over the visible position of the focus target.
## When the focus target is offscreen, this node is hidden.
extends ControlProjection
class_name BasicProjection

## Extends the base ControlProjection `_process()` function
func _process(delta: float) -> void:
	super(delta)

	# For non-sticky controls, we have all we need. If the target
	# is off screen we'll just hide this node.
	position = get_unprojected_position()
	visible = not get_is_target_behind_cam()
