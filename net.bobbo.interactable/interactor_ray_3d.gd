extends RayCast3D
class_name InteractorRay3D

signal interact_hover_changed(bool)
signal interact_hover_start
signal interact_hover_stop

const METHOD_INTERACT_START = "player_interact_start"
const METHOD_INTERACT_STOP = "player_interact_stop"
const METHOD_HOVER_START = "player_interact_hover_start"
const METHOD_HOVER_STOP = "player_interact_hover_stop"

var focused_inter_parent = null
var is_using = false

func _process(delta):
	if focused_inter_parent:
		var current_interactables = Interactable.find_in_children(focused_inter_parent)
		
		if Input.is_action_just_pressed("player_interact") and !is_using:
			is_using = true
			call_interact_start(current_interactables)
		if Input.is_action_just_released("player_interact") and is_using:
			is_using = false
			call_interact_stop(current_interactables)

func _physics_process(_delta):
	var current_collider = get_collider()
	if current_collider == focused_inter_parent:
		return
	
	var current_interactables = Interactable.find_in_children(focused_inter_parent)
	var new_interactables = Interactable.find_in_children(current_collider)

	# If we were hovering, stop
	if focused_inter_parent != null:
		call_hover_stop(current_interactables)
		
		if is_using:
			is_using = false
			call_interact_stop(current_interactables)
		
	# If this is an interactable object... start hovering
	if is_collider_interactable(new_interactables):
		call_hover_start(new_interactables)
		
	if current_interactables.size() == 0 and new_interactables.size() != 0:
		interact_hover_start.emit()
		interact_hover_changed.emit(true)
	elif current_interactables.size() != 0 and new_interactables.size() == 0:
		interact_hover_stop.emit()
		interact_hover_changed.emit(false)
		
	focused_inter_parent = current_collider
		
func is_collider_interactable(interactables: Array[Interactable]) -> bool:
	return interactables.size() > 0

func call_hover_start(interactables: Array[Interactable]):
	for interactable in interactables:
		interactable.call_hover_start()
	
func call_hover_stop(interactables: Array[Interactable]):
	for interactable in interactables:
		interactable.call_hover_stop()

func call_interact_start(interactables: Array[Interactable]):
	for interactable in interactables:
		interactable.call_use_start()
	
func call_interact_stop(interactables: Array[Interactable]):
	for interactable in interactables:
		interactable.call_use_stop()
