@tool
extends DialogGraphNode

#
#	Exports
#

@export var text_edit_scene: PackedScene

#
#	Variables
#

@onready var _starting_size: Vector2 = size 
var _text_edits: Array[TextEdit] = []

var _casted_data: DialogTextNodeData:
	get:
		return _data

#
#	Public Functions
#

func set_node_data(data: GraphNodeData) -> GraphNodeData:
	var casted_data = data as DialogTextNodeData
	if casted_data == null:
		return null
	
	# Clear any old edits
	for edit in _text_edits:
		_free_edit_control(edit)
	_text_edits.clear()
	
	# Add controls for new texts
	for single_text in casted_data.text:
		var new_edit = _new_edit_control()
		_text_edits.push_back(new_edit)
		new_edit.text = single_text
	
	return super(casted_data)

#
#	Private Functions
#

func _add_new_edit() -> void:
	var new_edit = _new_edit_control()
	_text_edits.push_back(new_edit)
	_casted_data.text.push_back("")
	data_updated.emit(_casted_data)

func _remove_last_edit() -> void:
	if _text_edits.size() == 0:
		return
	
	var old_edit = _text_edits.pop_back()
	_free_edit_control(old_edit)
	_casted_data.text.pop_back()
	data_updated.emit(_casted_data)	

func _new_edit_control() -> TextEdit:
	var new_edit = text_edit_scene.instantiate()
	$TextContainer.add_child(new_edit)
	
	var this_index = _text_edits.size()
	var text_changed_func = func():
		_on_text_changed(this_index, new_edit.text)
	new_edit.text_changed.connect(text_changed_func.bind())
	
	return new_edit
	
func _free_edit_control(old_edit: TextEdit) -> void:
	old_edit.queue_free()
	size = _starting_size

#
#	Signals
#

func _on_remove_line_button_pressed():
	_remove_last_edit()

func _on_add_line_button_pressed():
	_add_new_edit()
	
func _on_text_changed(index: int, new_text: String) -> void:
	_casted_data.text[index] = new_text
	data_updated.emit(_casted_data)
	
