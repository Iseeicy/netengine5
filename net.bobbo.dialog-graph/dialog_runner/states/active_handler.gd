@tool
extends DialogRunnerState
class_name DialogRunnerActiveHandlerState

#
#	Public Variables
#

var id: int:
	get:
		return _get_parent_state().get_node_id()

var data: GraphNodeData:
	get:
		return _get_parent_state().get_node_data()

#
#	Public Functions
#

func go_to_next_node(port: int = -1) -> bool:
	# If there's no graph, stop the dialog and EXIT EARLY
	if graph == null:
		runner.stop_dialog()
		return false
	
	# Get the connections to this entry node
	var connections = graph.get_connections_from(id)
	
	# If there are NO connections, stop 
	if connections.size() == 0:
		runner.stop_dialog()
		return false
	
	# AT THIS POINT - we have at least one connection - so transition to the first one
	return runner.go_to_node(connections[port].to_id)

