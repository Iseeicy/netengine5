@tool
extends EditorPlugin

#
#	Constants
#

## The scene containing the plugin's Dialog Graph Editor, to display in the
## main screen.
const GRAPH_EDITOR_SCENE = preload("editor/dialog_graph_editor.tscn")

## The scene containing the plugin's Dialog Preview TextWindow, to display in
## the bottom panel.
const DIALOG_PREVIEW_SCENE = preload(
	"editor/preview_text_window/dialog_preview.tscn"
)

## The icon asset for Dialog Graph resources
const DIALOG_GRAPH_ICON = preload("icons/dialog_graph.png")

## The icon asset for Dialog Runner State resources
const DIALOG_RUNNER_STATE_ICON = preload("icons/dialog_runner_state.png")

#
#	Private Variables
#

## The currently spawned instance of the Dialog Graph Editor.
var _graph_editor_instance: DialogGraphEditor = null

## The currently spawned instance of the Dialog Preview TextWindow.
var _dialog_preview_instance: DialogPreview

## The currently selected resource.
var _current_resource = null

## An internal DialogGraph that is constantly updated / rebuilt based on edits
## to the graph in the Dialog Graph Editor. This is used to visualize the
## current state of the live Dialog Graph, and preview navigating it at
## edit-time.
var _temp_packed_graph: PackedDialogGraph = PackedDialogGraph.new()

#
#	Entry / Exit
#


## Initialize this plugin. Called when the project is opened, or the plugin is
## enabled in ProjectSettings.
func _enter_tree():
	# Add types
	add_custom_type(
		"DialogGraphNode",
		"Resource",
		preload("dialog_graph_node.gd"),
		DIALOG_GRAPH_ICON
	)
	add_custom_type(
		"DialogGraphNodeDescriptor",
		"Resource",
		preload("dialog_graph_node_descriptor.gd"),
		DIALOG_GRAPH_ICON
	)
	add_custom_type(
		"GraphNodeData",
		"Resource",
		preload("graph_node_data.gd"),
		DIALOG_GRAPH_ICON
	)
	add_custom_type(
		"PackedDialogGraph",
		"Resource",
		preload("packed_dialog_graph.gd"),
		DIALOG_GRAPH_ICON
	)
	add_custom_type(
		"DialogRunner",
		"Node",
		preload("dialog_runner/dialog_runner.gd"),
		preload("icons/dialog_runner.png")
	)
	add_custom_type(
		"DialogRunnerState",
		"Node",
		preload("dialog_runner/dialog_runner_state.gd"),
		DIALOG_RUNNER_STATE_ICON
	)
	add_custom_type(
		"DialogRunnerStateActive",
		"Node",
		preload("dialog_runner/states/active.gd"),
		DIALOG_RUNNER_STATE_ICON
	)
	add_custom_type(
		"DialogRunnerActiveHandlerState",
		"Node",
		preload("dialog_runner/states/active_handler.gd"),
		DIALOG_RUNNER_STATE_ICON
	)
	add_custom_type(
		"DialogRunnerStateInactive",
		"Node",
		preload("dialog_runner/states/inactive.gd"),
		DIALOG_RUNNER_STATE_ICON
	)
	add_custom_type(
		"DialogRunnerActiveUnknownHandlerState",
		"Node",
		preload("dialog_runner/states/unknown_handler.gd"),
		DIALOG_RUNNER_STATE_ICON
	)

	# Spawn the graph editor
	_graph_editor_instance = GRAPH_EDITOR_SCENE.instantiate()
	get_editor_interface().get_editor_main_screen().add_child(
		_graph_editor_instance
	)

	# Spawn the dialog preview
	_dialog_preview_instance = DIALOG_PREVIEW_SCENE.instantiate()
	add_control_to_bottom_panel(_dialog_preview_instance, "Dialog")

	# Connect the graph editor to the dialog preview
	_graph_editor_instance.node_selected.connect(
		_dialog_preview_instance._on_dialog_graph_editor_node_selected.bind()
	)
	_graph_editor_instance.node_deselected.connect(
		_dialog_preview_instance._on_dialog_graph_editor_node_deselected.bind()
	)
	_graph_editor_instance.node_data_updated.connect(
		_on_graph_node_update.bind()
	)

	# Connect the preview to this plugin
	_dialog_preview_instance.request_graph_update.connect(
		_on_preview_request_graph_update.bind()
	)

	_make_visible(false)


## De-initialize this plugin. Called when the project closes, or the plugin is
## disabled in ProjectSettings.
func _exit_tree():
	# Disconnect the preview from this plugin
	if _dialog_preview_instance:
		_dialog_preview_instance.request_graph_update.disconnect(
			_on_preview_request_graph_update.bind()
		)

	# Disconnect the graph editor from the dialog preview
	if _graph_editor_instance and _dialog_preview_instance:
		_graph_editor_instance.node_data_updated.disconnect(
			_on_graph_node_update.bind()
		)
		_graph_editor_instance.node_deselected.disconnect(
			(
				_dialog_preview_instance
				. _on_dialog_graph_editor_node_deselected
				. bind()
			)
		)
		_graph_editor_instance.node_selected.disconnect(
			(
				_dialog_preview_instance
				. _on_dialog_graph_editor_node_selected
				. bind()
			)
		)

	# Despawn the graph editor
	if _graph_editor_instance:
		_graph_editor_instance.queue_free()
		_graph_editor_instance = null

	# Despawn the dialog preview
	if _dialog_preview_instance:
		remove_control_from_bottom_panel(_dialog_preview_instance)
		_dialog_preview_instance.queue_free()
		_dialog_preview_instance = null

	# Remove types
	remove_custom_type("DialogRunnerActiveUnknownHandlerState")
	remove_custom_type("DialogRunnerStateInactive")
	remove_custom_type("DialogRunnerActiveHandlerState")
	remove_custom_type("DialogRunnerStateActive")
	remove_custom_type("DialogRunnerState")
	remove_custom_type("DialogRunner")
	remove_custom_type("GraphNodeData")
	remove_custom_type("PackedDialogGraph")
	remove_custom_type("DialogGraphNodeDescriptor")
	remove_custom_type("DialogGraphNode")


#
#	Editor Plugin Getters
#


## Returns the display name of this plugin, used when drawing a tab for it on
## the main screen of the Godot editor (alongside 2D, 3D, Script, etc).
func _get_plugin_name() -> String:
	return "Dialog Graph"


## Returns the icon representing this plugin, used when drawing a tab for it on
## the main screen of the Godot editor (alongside 2D, 3D, Script, etc).
func _get_plugin_icon() -> Texture2D:
	return get_editor_interface().get_base_control().get_theme_icon(
		"Node", "EditorIcons"
	)


## Does this plugin have a main screen control to draw?
func _has_main_screen():
	return true  # Yes it does! We show the dialog graph editor.


#
#	Editor Plugin Functions
#


## Given an unspecified object, does this plugin have a way to handle editing
## that object?
## Returns true if the object is a PackedDialogGraph.
func _handles(object: Object) -> bool:
	return object is PackedDialogGraph


## Focus on editing an object, or no longer focus on any object.
func _edit(object: Object):
	if _graph_editor_instance == null:
		return

	if _current_resource != null:
		_graph_editor_instance.save_to_resource(_current_resource)

	_graph_editor_instance.load_from_resource(object)
	_current_resource = object


## Called when the editor wants to save
func _save_external_data():
	if _graph_editor_instance == null:
		return

	if _current_resource == null:
		return

	_graph_editor_instance.save_to_resource(_current_resource)


## Called when the Dialog Graph Editor should become visible / invisible
func _make_visible(visible):
	if _graph_editor_instance:
		_graph_editor_instance.visible = visible


#
#	Private Functions
#


## Update our internal cached dialog graph so that we can use it for a dialog
## preview if possible.
func _refresh_graph() -> void:
	if _graph_editor_instance == null or _dialog_preview_instance == null:
		return

	# Write the current state of our graph editor control into the cached
	# dialog graph, then update the dialog preview
	_graph_editor_instance.save_to_resource(_temp_packed_graph)
	_dialog_preview_instance.update_graph(_temp_packed_graph)


#
#	Signals
#


## When the dialog preview wants it's copy of the graph instance updated,
## update our internal verison of the current graph!
func _on_preview_request_graph_update() -> void:
	_refresh_graph()


## When the contents of a node in the graph is updated, update our internal
## version of the current graph!
func _on_graph_node_update(_node, _data) -> void:
	_refresh_graph()
