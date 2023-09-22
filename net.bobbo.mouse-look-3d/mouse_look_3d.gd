extends Node
class_name MouseLook3D

#
#	Exported
#

@export var sensitivity_x: float = 1
@export var sensitivity_y: float = 1
@export var model_pivot: Node3D = null

#
#	Variables
#

var parent_3d: Node3D
var _look_event_queue: Array[Vector2] = []

#
#	Godot Functions
#

func _ready():
	parent_3d = get_parent() as Node3D
	assert(parent_3d != null)

# Take input from the mouse and queue up actions to make the camera rotate
func _input(event):
	# If the mouse isn't captured, ignore this event
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	
	# If the mouse moved, store this movement to process later
	if event is InputEventMouseMotion:
		var sensitivity = Vector2(sensitivity_x, sensitivity_y)
		_look_event_queue.push_front(event.relative * sensitivity)

# Actually rotate the camera if necessary every frame
func _process(_delta):
	# Handle all queue'd look events
	while _look_event_queue.size() > 0:
		_apply_look_event(_look_event_queue.pop_back())
		
	# If we have a display pivot (playermodel?)
	# then rotate it!
	if model_pivot != null:
		model_pivot.rotation.y = parent_3d.rotation.y
	
#
#	Private Functions
#

func _apply_look_event(look_event: Vector2):
	var new_rotation: Vector3 = parent_3d.rotation_degrees
	new_rotation.x = clampf(new_rotation.x - look_event.y, -90, 90)
	new_rotation.y -= look_event.x
	parent_3d.rotation_degrees = new_rotation
	
