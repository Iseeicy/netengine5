extends RayCast3D
class_name InteractorRay3D

signal interact_hover_changed(bool)
signal interact_hover_start
signal interact_hover_stop

const METHOD_INTERACT_START = "player_interact_start"
const METHOD_INTERACT_STOP = "player_interact_stop"
const METHOD_HOVER_START = "player_interact_hover_start"
const METHOD_HOVER_STOP = "player_interact_hover_stop"

var focused_interactable = null
var is_interacting = false

func _process(delta):
	if focused_interactable:
		if Input.is_action_just_pressed("player_interact") and !is_interacting:
			is_interacting = true
			call_interact_start(focused_interactable)
		if Input.is_action_just_released("player_interact") and is_interacting:
			is_interacting = false
			call_interact_stop(focused_interactable)

func _physics_process(_delta):
	var cur_collider = get_collider()
	if cur_collider == focused_interactable:
		return
		
	# We're colliding with a NEW THING
	var new_interactable = null
	
	# If we were hovering, stop
	if focused_interactable != null:
		call_hover_stop(focused_interactable)
		
		if is_interacting:
			is_interacting = false
			call_interact_stop(focused_interactable)
		
	# If this is an interactable object...
	if is_collider_interactable(cur_collider):
		# Save this collider
		new_interactable = get_collider()
		
		# Start hovering
		call_hover_start(new_interactable)
		
	if focused_interactable == null and new_interactable != null:
		interact_hover_start.emit()
		interact_hover_changed.emit(true)
	elif focused_interactable != null and new_interactable == null:
		interact_hover_stop.emit()
		interact_hover_changed.emit(false)
		
	focused_interactable = new_interactable
		
func is_collider_interactable(collider: Node) -> bool:
	if collider == null:
		return false
	
	for child in collider.get_children():
		if child is Interactable:
			return true
	return false

func call_hover_start(collider: Node):
	for child in collider.get_children():
		if child is Interactable:
			child.hover_start()
	
func call_hover_stop(collider: Node):
	for child in collider.get_children():
		if child is Interactable:
			child.hover_stop()

func call_interact_start(collider: Node):
	for child in collider.get_children():
		if child is Interactable:
			child.interact_start()
	
func call_interact_stop(collider: Node):
	for child in collider.get_children():
		if child is Interactable:
			child.interact_stop()
