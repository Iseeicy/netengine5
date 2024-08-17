## A control used to preview the current state of the DialogGraphEditor.
@tool
class_name DialogPreview
extends VBoxContainer

#
#	Exports
#

## Emitted when the preview would like it's dialog graph reference updated
signal request_graph_update

#
#	Private Variables
#

## A list of nodes that are currently selected. We keep track of this so that
## we can figure out what the last selected node was.
var _selected_nodes: Array[DialogGraphNode] = []
## A reference to the internal PackedDialogGraph cache to use and run through with
## this preview.
var _temp_graph: PackedDialogGraph = PackedDialogGraph.new()

## The DialogRunner that we'll use to execute the current PackedDialogGraph
@onready var _dialog_runner: DialogRunner = $DialogRunner

#
#	Public Functions
#


## Update the graph that this preview is using, and re-start executing it
## from the last selected node if there is one.
func update_graph(new_graph: PackedDialogGraph) -> void:
	_temp_graph = new_graph

	if _selected_nodes.size() > 0:
		var data = _selected_nodes[-1].get_node_data()

		if data:
			_dialog_runner.run_dialog(_temp_graph, data.id)
	else:
		_dialog_runner.stop_dialog()


#
#	Signals
#


## Called when the DialogGraphEditor selects a node in the graph.
func _on_dialog_graph_editor_node_selected(node: DialogGraphNode):
	_selected_nodes.push_back(node)
	request_graph_update.emit()


## Called when the DialogGraphEditor deselects a previously selected node in
## the graph.
func _on_dialog_graph_editor_node_deselected(node: DialogGraphNode):
	_selected_nodes.erase(node)
	request_graph_update.emit()
