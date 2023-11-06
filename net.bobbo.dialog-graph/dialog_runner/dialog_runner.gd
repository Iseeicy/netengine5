@tool
extends BobboStateMachine
class_name DialogRunner

#
#	Exports
#

## Emitted when `dialog_interact()` is called.
signal dialog_interacted()

## Emitted when `dialog_choice_hover()` is called.
signal dialog_choice_hovered(index: int)

## The window to use when displaying dialog text and choice prompts
@export var text_window: TextWindow

#
#	Private Variables
#

var _current_dialog: DialogGraph = null

#
#	Godot Functions
#

func _ready():
	# Spawn the data handlers
	for desc in GraphNodeDB.descriptors:
		$Active.add_child(desc.instantiate_handler())
	
	super()
	

#
#	Public Functions
#

## Interact with the currently running dialog sequence. Meant to be called in response
## to some input. Generally this will progress dialog or confirm an on-screen choice
func dialog_interact() -> void:
	dialog_interacted.emit()

## Hover over a dialog choice, if there's one running. Meant to be called in response
## to some input. Generally this will highlight an on-screen choice.
func dialog_choice_hover(index: int) -> void:
	dialog_choice_hovered.emit(index)

## Starts running a given dialog graph. If entry node param is not provided, dialog will start
## from the graph's entry node.
func run_dialog(dialog: DialogGraph, entry_node_id: int = -1) -> void:
	# If we can't find the explicitley provided entry node (or if there was no
	# explicit entry node) then use the graph's entry node
	if not dialog.contains_id(entry_node_id):
		entry_node_id = dialog.get_entry_id()
		
		# If for some reason there isn't an entry node in the graph, TELL US 
		# ABOUT IT and EXIT EARLY
		if entry_node_id == -1:
			printerr("Could not find entry node in dialog graph")
			return
	
	# AT THIS POINT - we have a confirmed existing dialog entry point in entry_node_id
	# If dialog is already running, stop it first!
	if is_running():
		stop_dialog()
	
	# Save the current dialog graph, and enter the entry node!
	_current_dialog = dialog
	go_to_node(entry_node_id)
	
## Skips to the given node in the currently running dialog graph.
## If the node could not be found, or if there is no dialog graph running, this returns false.
## OTHERWISE, this returns true.
func go_to_node(node_id: int) -> bool:
	# If we don't have any graph, EXIT EARLY.
	# ( we don't check if we're running here, bc we may actually not be running
	#   yet but still have the ability to go to a node, such as when we're just
	#   starting )
	if _current_dialog == null:
		return false
	if not _current_dialog.contains_id(node_id):
		return false
	
	var data = _current_dialog.get_node_data(node_id)
	var node_name = GraphNodeDB.find_descriptor_for_data(data).node_name
	
	# If we don't have a state for the given node implementation, EXIT EARLY
	var state_path = "Active/%s" % node_name
	var found_state = get_node_or_null(state_path) as DialogRunnerState
	if found_state == null:
		# If we can find a state that handles unknown dialog nodes,
		# then transition to that!
		state_path = "Active/Unknown"
		found_state = get_node_or_null(state_path) as DialogRunnerState
		if found_state == null:
			printerr("This DialogRunner does not support %s nodes." % node_name)
			return false
		print("Handling unknown %s node...!" % node_name)
	
	# AT THIS POINT - The desired node exists, and we can handle it... so...
	# HANDLE IT!
	var state_message: Dictionary = { "id": node_id, "data": data }
	transition_to(state_path, state_message)
	
	return true
	
## Are we currently running a dialog graph?
func is_running() -> bool:
	if state == null:
		return false
		
	return state.get_state_path().begins_with("Active")

func get_graph() -> DialogGraph:
	if not is_running():
		return null
	else:
		return _current_dialog

## Stops running the current dialog graph.
## If there is no graph running, returns false.
## OTHERWISE, returns true.
func stop_dialog() -> bool:
	if not is_running():
		return false
		
	text_window.close()
	_current_dialog = null
	transition_to("Inactive")
	return true
