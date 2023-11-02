@tool
extends VBoxContainer
class_name DialogPreview

#
#	Exports
#

## Emitted when the preview would like it's dialog graph reference updated
signal request_graph_update()

#
#	Private Variables
#

@onready var _dialog_runner: DialogRunner = $DialogRunner
var _selected_nodes: Array[DialogGraphNode] = []
var _temp_graph: DialogGraph = DialogGraph.new()

#
#	Public Functions
#

func update_graph(new_graph: DialogGraph) -> void:
	_temp_graph = new_graph
	
	if _selected_nodes.size() > 0:
		var data = _selected_nodes[-1].get_node_data()
		var node_id = _temp_graph.find_id_from_data(data)
		
		if node_id != -1:
			_dialog_runner.run_dialog(_temp_graph, node_id)
	else:
		_dialog_runner.stop_dialog()

#
#	Signals
#

func _on_dialog_graph_editor_node_selected(node: DialogGraphNode):
	print("selected ", node)
	_selected_nodes.push_back(node)
	request_graph_update.emit()

func _on_dialog_graph_editor_node_deselected(node: DialogGraphNode):
	print("deselected ", node)
	
	_selected_nodes.erase(node)
	request_graph_update.emit()


