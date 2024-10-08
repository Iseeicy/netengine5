## A node that allows for navigation through a DialogGraph resource, displaying
## the current state using a TextWindow. References the GraphNodeDB to figure
## out how to handle specific kinds of nodes in a graph.
@tool
class_name DialogRunner
extends BobboStateMachine

#
#	Exports
#

## Emitted when `dialog_interact()` is called.
signal dialog_interacted

## Emitted when `dialog_choice_hover()` is called.
signal dialog_choice_hovered(index: int)

## The window to use when displaying dialog text and choice prompts
@export var text_window: TextWindow

#
#	Private Variables
#

var _current_dialog: RuntimeDialogGraph = null

#
#	Godot Functions
#


func _ready():
	# Spawn the data handlers
	for desc in GraphNodeDB.descriptors:
		$Active.add_child(desc.instantiate_handler())

	super()  # Call the normal StateMachine _ready() func


#
#	Public Functions
#


## Interact with the currently running dialog sequence. Meant to be called in
## response to some input. Generally this will progress dialog or confirm an
## on-screen choice
func dialog_interact() -> void:
	dialog_interacted.emit()


## Hover over a dialog choice, if there's one running. Meant to be called in
## response to some input. Generally this will highlight an on-screen choice.
func dialog_choice_hover(index: int) -> void:
	dialog_choice_hovered.emit(index)


## Unpacks and starts running a packed dialog graph. If `entry_node_id` is not
## provided, dialog will start from the graph's entry node.
func run_dialog(
	packed_graph: PackedDialogGraph, entry_node_id: int = -1
) -> void:
	# Unpack the dialog graph into something we can actually use
	var runtime_graph: RuntimeDialogGraph = RuntimeDialogGraph.new(
		packed_graph
	)

	# Forward all logic to the runtime run method
	run_runtime_dialog(runtime_graph, entry_node_id)


## Starts running a runtime dialog graph. If `entry_node_id` is not provided,
## dialog will start from the graph's entry node.
func run_runtime_dialog(
	runtime_graph: RuntimeDialogGraph, entry_node_id: int = -1
) -> void:
	# If we can't find the explicitley provided entry node (or if there was no
	# explicit entry node) then use the graph's entry node
	if not runtime_graph.has_id(entry_node_id):
		var entry_node = runtime_graph.get_entry_node()

		# If for some reason there isn't an entry node in the graph, TELL US
		# ABOUT IT and EXIT EARLY
		if not entry_node:
			printerr("Could not find entry node in dialog graph")
			return

		entry_node_id = entry_node.id

	# AT THIS POINT - we have a confirmed existing dialog entry point in
	# entry_node_id. If dialog is already running, stop it first!
	if is_running():
		stop_dialog()

	# Save the current dialog graph, and enter the entry node!
	_current_dialog = runtime_graph
	go_to_node(runtime_graph.get_node(entry_node_id))


## Skips to the given node in the currently running dialog graph.
## If the node could not be found, or if there is no dialog graph running, this
## returns false. OTHERWISE, this returns true.
func go_to_node(node: GraphNodeData) -> bool:
	# If we don't have any graph, EXIT EARLY.
	# ( we don't check if we're running here, bc we may actually not be running
	#   yet but still have the ability to go to a node, such as when we're just
	#   starting )
	if _current_dialog == null:
		return false

	var node_name = node.descriptor.node_name

	# If we don't have a state for the given node implementation, EXIT EARLY
	var state_path = "Active/%s" % node_name
	var found_state = get_node_or_null(state_path) as DialogRunnerState
	if found_state == null:
		# If we can find a state that handles unknown dialog nodes,
		# then transition to that!
		state_path = "Active/Unknown"
		found_state = get_node_or_null(state_path) as DialogRunnerState
		if found_state == null:
			printerr(
				"This DialogRunner does not support %s nodes." % node_name
			)
			return false
		print("Handling unknown %s node...!" % node_name)

	# AT THIS POINT - The desired node exists, and we can handle it... so...
	# HANDLE IT!
	var state_message: Dictionary = {"node_data": node}
	transition_to(state_path, state_message)

	return true


## Are we currently running a dialog graph?
func is_running() -> bool:
	if state == null:
		return false

	return state.get_state_path().begins_with("Active")


## Returns the current graph if we're running through one.
func get_graph() -> RuntimeDialogGraph:
	if not is_running():
		return null
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
