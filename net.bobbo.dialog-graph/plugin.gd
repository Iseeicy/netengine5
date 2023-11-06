@tool
extends EditorPlugin

#
#	Constants
#

const graph_editor_scene = preload("editor/dialog_graph_editor.tscn")
const dialog_preview_scene = preload("editor/preview_text_window/dialog_preview.tscn")

#
#	Private Variables
#

var _graph_editor_instance: DialogGraphEditor
var _dialog_preview_instance: DialogPreview
var _current_resource = null
var _temp_graph: DialogGraph = DialogGraph.new()

func _handles(object: Object) -> bool:
	return object is DialogGraph

func _edit(object: Object):
	if _graph_editor_instance == null:
		return
		
	if _current_resource != null:
		_graph_editor_instance.save_to_resource(_current_resource)
	
	_graph_editor_instance.load_from_resource(object)
	_current_resource = object
		
func _save_external_data():
	if _graph_editor_instance == null:
		return
	
	if _current_resource == null:
		return
		
	_graph_editor_instance.save_to_resource(_current_resource)
		

func _enter_tree():
	# Add the autoload
	add_autoload_singleton("GraphNodeDB", "autoload/graph_node_db.tscn")
	
	# Spawn the graph editor
	_graph_editor_instance = graph_editor_scene.instantiate()
	get_editor_interface().get_editor_main_screen().add_child(_graph_editor_instance)
	
	# Spawn the dialog preview
	_dialog_preview_instance = dialog_preview_scene.instantiate()
	add_control_to_bottom_panel(_dialog_preview_instance, "Dialog")
	
	# Connect the graph editor to the dialog preview
	_graph_editor_instance.node_selected.connect(_dialog_preview_instance._on_dialog_graph_editor_node_selected.bind())
	_graph_editor_instance.node_deselected.connect(_dialog_preview_instance._on_dialog_graph_editor_node_deselected.bind())
	_graph_editor_instance.node_data_updated.connect(_on_graph_node_update.bind())
	
	# Connect the preview to this plugin
	_dialog_preview_instance.request_graph_update.connect(_on_preview_request_graph_update.bind())
	
	_make_visible(false)

func _exit_tree():
	# Disconnect the preview from this plugin
	if _dialog_preview_instance:
		_dialog_preview_instance.request_graph_update.disconnect(_on_preview_request_graph_update.bind())
	
	# Disconnect the graph editor from the dialog preview
	if _graph_editor_instance and _dialog_preview_instance:
		_graph_editor_instance.node_data_updated.disconnect(_on_graph_node_update.bind())
		_graph_editor_instance.node_deselected.disconnect(_dialog_preview_instance._on_dialog_graph_editor_node_deselected.bind())
		_graph_editor_instance.node_selected.disconnect(_dialog_preview_instance._on_dialog_graph_editor_node_selected.bind())
	
	# Despawn the graph editor
	if _graph_editor_instance:
		_graph_editor_instance.queue_free()
		_graph_editor_instance = null
		
	# Despawn the dialog preview
	if _dialog_preview_instance:
		remove_control_from_bottom_panel(_dialog_preview_instance)
		_dialog_preview_instance.queue_free()
		_dialog_preview_instance = null
		
	# Remove the autoload
	remove_autoload_singleton("GraphNodeDB")
	

func _has_main_screen():
	return true
	
func _make_visible(visible):
	if _graph_editor_instance:
		_graph_editor_instance.visible = visible
	
func _get_plugin_name():
	return "Dialog Graph"
	
func _get_plugin_icon():
	return get_editor_interface().get_base_control().get_theme_icon("Node", "EditorIcons")

#
#	Private Functions
#

func _refresh_graph() -> void:
	if _graph_editor_instance == null or _dialog_preview_instance == null:
		return
	
	_graph_editor_instance.save_to_resource(_temp_graph)
	_dialog_preview_instance.update_graph(_temp_graph)

#
#	Signals
#

## When the dialog preview wants it's copy of the graph instance updated,
## update our internal verison of the current graph!
func _on_preview_request_graph_update() -> void:
	_refresh_graph()

func _on_graph_node_update(node, data) -> void:
	_refresh_graph()
