@tool
extends EditorPlugin

const graph_editor_scene = preload("dialog_graph_editor.tscn")
const dialog_preview_scene = preload("dialog_preview.tscn")

var main_graph_editor_instance: DialogGraphEditor
var dialog_preview_instance: DialogPreview
var current_resource = null
var _temp_graph: DialogGraph = DialogGraph.new()

func _handles(object: Object) -> bool:
	return object is DialogGraph

func _edit(object: Object):
	if main_graph_editor_instance == null:
		return
		
	if current_resource != null:
		main_graph_editor_instance.save_to_resource(current_resource)
	
	main_graph_editor_instance.load_from_resource(object)
	current_resource = object
		
func _save_external_data():
	if main_graph_editor_instance == null:
		return
	
	if current_resource == null:
		return
		
	main_graph_editor_instance.save_to_resource(current_resource)
		

func _enter_tree():
	# Spawn the graph editor
	main_graph_editor_instance = graph_editor_scene.instantiate()
	get_editor_interface().get_editor_main_screen().add_child(main_graph_editor_instance)
	
	# Spawn the dialog preview
	dialog_preview_instance = dialog_preview_scene.instantiate()
	add_control_to_bottom_panel(dialog_preview_instance, "Dialog")
	
	# Connect the graph editor to the dialog preview
	main_graph_editor_instance.node_selected.connect(dialog_preview_instance._on_dialog_graph_editor_node_selected.bind())
	main_graph_editor_instance.node_deselected.connect(dialog_preview_instance._on_dialog_graph_editor_node_deselected.bind())
	main_graph_editor_instance.node_data_updated.connect(_on_graph_node_update.bind())
	
	# Connect the preview to this plugin
	dialog_preview_instance.request_graph_update.connect(_on_preview_request_graph_update.bind())
	
	_make_visible(false)

func _exit_tree():
	# Disconnect the preview from this plugin
	if dialog_preview_instance:
		dialog_preview_instance.request_graph_update.disconnect(_on_preview_request_graph_update.bind())
	
	# Disconnect the graph editor from the dialog preview
	if main_graph_editor_instance and dialog_preview_instance:
		main_graph_editor_instance.node_data_updated.disconnect(_on_graph_node_update.bind())
		main_graph_editor_instance.node_deselected.disconnect(dialog_preview_instance._on_dialog_graph_editor_node_deselected.bind())
		main_graph_editor_instance.node_selected.disconnect(dialog_preview_instance._on_dialog_graph_editor_node_selected.bind())
	
	# Despawn the graph editor
	if main_graph_editor_instance:
		main_graph_editor_instance.queue_free()
		main_graph_editor_instance = null
		
	# Despawn the dialog preview
	if dialog_preview_instance:
		remove_control_from_bottom_panel(dialog_preview_instance)
		dialog_preview_instance.queue_free()
		dialog_preview_instance = null
		

func _has_main_screen():
	return true
	
func _make_visible(visible):
	if main_graph_editor_instance:
		main_graph_editor_instance.visible = visible
	
func _get_plugin_name():
	return "Dialog Graph"
	
func _get_plugin_icon():
	return get_editor_interface().get_base_control().get_theme_icon("Node", "EditorIcons")

#
#	Private Functions
#

func _refresh_graph() -> void:
	if main_graph_editor_instance == null or dialog_preview_instance == null:
		return
	
	main_graph_editor_instance.save_to_resource(_temp_graph)
	dialog_preview_instance.update_graph(_temp_graph)

#
#	Signals
#

## When the dialog preview wants it's copy of the graph instance updated,
## update our internal verison of the current graph!
func _on_preview_request_graph_update() -> void:
	_refresh_graph()

func _on_graph_node_update(node, data) -> void:
	_refresh_graph()
