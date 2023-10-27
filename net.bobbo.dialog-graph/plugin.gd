@tool
extends EditorPlugin

const graph_editor_scene = preload("dialog_graph_editor.tscn")
const dialog_preview_scene = preload("dialog_preview.tscn")

var main_graph_editor_instance: DialogGraphEditor
var dialog_preview_instance: DialogPreview
var current_resource = null

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
	main_graph_editor_instance = graph_editor_scene.instantiate()
	dialog_preview_instance = dialog_preview_scene.instantiate()
	get_editor_interface().get_editor_main_screen().add_child(main_graph_editor_instance)
	add_control_to_bottom_panel(dialog_preview_instance, "Dialog")
	_make_visible(false)

func _exit_tree():
	if main_graph_editor_instance:
		main_graph_editor_instance.queue_free()
		
	if dialog_preview_instance:
		remove_control_from_bottom_panel(dialog_preview_instance)
		dialog_preview_instance.queue_free()

func _has_main_screen():
	return true
	
func _make_visible(visible):
	if main_graph_editor_instance:
		main_graph_editor_instance.visible = visible
	
func _get_plugin_name():
	return "Dialog Graph"
	
func _get_plugin_icon():
	return get_editor_interface().get_base_control().get_theme_icon("Node", "EditorIcons")
