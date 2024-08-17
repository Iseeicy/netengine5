## The base class that all dialog node handler states should extend from.
## States extending this will be placed underneath the DialogRunner's 'Active'
## state.
@tool
class_name DialogRunnerActiveHandlerState
extends DialogRunnerState

#
#	Public Variables
#

## The data representing the DialogGraph node that we are currently handling.
var data: GraphNodeData:
	get:
		return _get_parent_state().get_node_data()

#
#	Public Functions
#


## Go to the next node in the graph.
## Optionally accepts the port that should be used for naviation.
## If no port is provided, the last connection is always used.
## Returns false if there is no node to navigate to.
## Returns true if we hae navigated to the next node.
func go_to_next_node(port: int = -1) -> bool:
	# If there's no graph, stop the dialog and EXIT EARLY
	if graph == null:
		runner.stop_dialog()
		return false

	# Get the connections to this entry node
	var connections: Array[RuntimeDialogGraph.Connection] = (
		graph.get_connections_from(data)
	)

	# If there are NO connections, stop
	if connections.size() == 0:
		runner.stop_dialog()
		return false

	# AT THIS POINT - we have at least one connection - so transition to the
	# first one
	return runner.go_to_node(connections[port].to_node)
