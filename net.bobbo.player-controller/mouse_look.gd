extends Node3D
class_name MouseLook

#
#	Exported
#

@export var mouse_sensitivity_x: float = 1
@export var mouse_sensitivity_y: float = 1
@export var model_pivot: Node3D = null

#
#	Variables
#

var look_event_queue: Array[Vector2] = []

#
#	Functions
#

func _input(event):
	# If the mouse isn't captured, ignore this event
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	
	# If the mouse moved, store this movement to process later
	if event is InputEventMouseMotion:
		var sensitivity = Vector2(mouse_sensitivity_x, mouse_sensitivity_y)
		look_event_queue.push_front(event.relative * sensitivity)

func _process(_delta):
	# Handle all queue'd look events
	while look_event_queue.size() > 0:
		apply_look_event(look_event_queue.pop_back())
		
	# If we have a display pivot (playermodel?)
	# then rotate it!
	if model_pivot != null:
		model_pivot.rotation.y = rotation.y
	
func apply_look_event(look_event: Vector2):
	var new_rotation = rotation_degrees
	new_rotation.x = clampf(new_rotation.x - look_event.y, -90, 90)
	new_rotation.y -= look_event.x
	rotation_degrees = new_rotation
	
func set_offset(offset: Vector3):
	$Camera3D.position = offset

func get_offset() -> Vector3:
	return $Camera3D.position
