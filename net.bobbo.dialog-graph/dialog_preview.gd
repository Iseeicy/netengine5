@tool
extends Control
class_name DialogPreview

#
#	Exports
#

@export var graph_editor: DialogGraphEditor

#
#	Private Variables
#

@onready var _dialog_runner: DialogRunner = $DialogRunner
var _selected_nodes: Array[DialogGraphNode] = []
var _temp_graph: DialogGraph = DialogGraph.new()

#
#	Private Functions
#

func _update_selected_nodes() -> void:
	# Update the internal version of our graph
	graph_editor.save_to_resource(_temp_graph)
	
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
	_selected_nodes.push_back(node)
	_update_selected_nodes()

func _on_dialog_graph_editor_node_deselected(node: DialogGraphNode):
	_selected_nodes.erase(node)
	_update_selected_nodes()


