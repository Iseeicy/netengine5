## This node projects a Control so that when it's offscreen, the control sticks
## to the edges of the screen.
## This is ideal for things like waypoints, maps, or indicators showing where 
## objects are relative to you.
extends ControlProjection
class_name StickyProjection

#
#	Exported
#

## Called when the visibility of the sticky projection is changed.
signal sticky_visibility_changed(is_visible: bool)

@export_group("Offscreen Behaviour")
## (OPTIONAL) Node to rotate when off screen
@export var node_rotate_offscreen: Node = null

@export_group("Edge Margin")
@export var edge_margin_left = 50
@export var edge_margin_right = 50
@export var edge_margin_top = 50
@export var edge_margin_bottom = 50

#
#	Variables
#

var _last_sticky_is_visible: bool = false

#
#	Functions
#

func _ready() -> void:
	super()
	sticky_visibility_changed.emit(false)

func _process(delta: float) -> void:
	super(delta)
	
	# For sticky controls, we have to correct the unprojected
	# position in order to address the edges of the screen
	position = _correct_unprojected_position()
	_handle_sticky_children()
	visible = true

#
#	Private Functions
#

func _correct_unprojected_position():
	var unprojected_position = get_unprojected_position()
	var viewport_base_size = get_viewport_base_size()
	var cam = get_camera()
	
	# We need to handle the axes differently.
		
	# For the screen's X axis, the projected position is useful to us,
	# but we need to force it to the side if it's also behind.
	if get_is_target_behind_cam():
		if unprojected_position.x < viewport_base_size.x / 2:
			unprojected_position.x = viewport_base_size.x - edge_margin_right
		else:
			unprojected_position.x = edge_margin_left
			
	# For the screen's Y axis, the projected position is NOT useful to us
	# because we don't want to indicate to the user that they need to look
	# up or down to see something behind them. Instead, here we approximate
	# the correct position using difference of the X axis Euler angles
	# (up/down rotation) and the ratio of that with the camera's FOV.
	# This will be slightly off from the theoretical "ideal" position.
	if get_is_target_behind_cam() or \
			unprojected_position.x < edge_margin_left or \
			unprojected_position.x > viewport_base_size.x - edge_margin_right:
		var look = cam.global_transform.looking_at(get_focus_position(), Vector3.UP)
		var diff = _calc_angle_diff(look.basis.get_euler().x, cam.global_transform.basis.get_euler().x)
		unprojected_position.y = viewport_base_size.y * (0.5 + (diff / deg_to_rad(cam.fov)))

	return Vector2(
		clamp(unprojected_position.x, edge_margin_left, 
			viewport_base_size.x - edge_margin_right
		),
		clamp(unprojected_position.y, edge_margin_top, 
			viewport_base_size.y - edge_margin_bottom
		)
	)

func _calc_angle_diff(from, to):
	var diff = fmod(to - from, TAU)
	return fmod(2.0 * diff, TAU) - diff
	
func _handle_sticky_children():
	var viewport_base_size = get_viewport_base_size()
	var sticky_rotation: float = 0
	var sticky_is_visible: bool = true
	var overflow: float = 0
	
	if position.x <= edge_margin_left:
		# Left overflow.
		overflow = -TAU / 8.0
		sticky_is_visible = false
		sticky_rotation = TAU / 4.0
	elif position.x >= viewport_base_size.x - edge_margin_right:
		# Right overflow.
		overflow = TAU / 8.0
		sticky_is_visible = false
		sticky_rotation = TAU * 3.0 / 4.0

	if position.y <= edge_margin_top:
		# Top overflow.
		sticky_is_visible = false
		sticky_rotation = TAU / 2.0 + overflow
	elif position.y >= viewport_base_size.y - edge_margin_bottom:
		# Bottom overflow.
		sticky_is_visible = false
		sticky_rotation = -overflow
		
	if node_rotate_offscreen:
		node_rotate_offscreen.rotation = sticky_rotation
		
	if _last_sticky_is_visible != sticky_is_visible:
		_last_sticky_is_visible = sticky_is_visible
		sticky_visibility_changed.emit(sticky_is_visible)
