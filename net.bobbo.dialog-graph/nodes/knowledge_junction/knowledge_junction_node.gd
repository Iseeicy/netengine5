@tool
extends DialogGraphNode

#
#	Exports
#

@export var condition_maker_scene: PackedScene

#
#	Variables
#

@onready var _starting_size: Vector2 = size 
var _conditions: Array[KnowledgeJunctionConditionContainer] = []

var _casted_data: KnowledgeJunctionNodeData:
	get:
		return _data

#
#	Public Functions
#

func set_node_data(data: GraphNodeData) -> GraphNodeData:
	var casted_data = data as KnowledgeJunctionNodeData
	if casted_data == null:
		return null
	
	# Remove any conditions that exist
	for condition in _conditions:
		_free_condition_control(condition)
	_conditions.clear()	
	
	var result = super(casted_data)
	
	# Create controls for every condition
	for condition_data in casted_data.conditions:
		var new_condition = _new_condition_control()
		_conditions.push_back(new_condition)
		new_condition.set_condition(condition_data)
	
	_update_size()
	return result

#
#	Private Functions
#

func _update_size():
	size = _starting_size

func _add_new_condition() -> void:
	var new_condition = _new_condition_control()
	_conditions.push_back(new_condition)	
	_casted_data.conditions.push_back({ 
		KnowledgeJunctionNodeData.CONDITIONS_TEXT_KEY: "", 
		KnowledgeJunctionNodeData.CONDITIONS_VIS_COND_KEY: null, 
	})
	data_updated.emit(_casted_data)

func _remove_last_condition() -> void:
	if _conditions.size() == 0:
		return

	var old_condition = _conditions.pop_back()
	_free_condition_control(old_condition)
	_casted_data.conditions.pop_back()
	data_updated.emit(_casted_data)
	
	# Request that any connections on the port we just removed be removed as
	# well, so that there's no invalid connections.
	remove_connections_request.emit(1, _casted_data.conditions.size())

func _new_condition_control() -> KnowledgeJunctionConditionContainer:
	var new_condition = condition_maker_scene.instantiate()
	add_child(new_condition)
	
	var this_index = _conditions.size()
	new_condition.setup(this_index)
	set_slot(this_index + 1, false, 0, Color.CYAN, true, 0, Color.YELLOW)
	
	# Hook into the condition container's signal that fires
	# when the settings panel is opened and closed,
	# becaues we need to adjust the size of this when
	# the size of the condition changes.
	new_condition.settings_visibility_changed.connect(
		_on_settings_visibility_changed.bind()
	)
	
	# Create custom functions that pass the index of this condition in to our
	# internal signal functions, so that we know what condition called
	var text_changed_function = func(new_text: String):
		_on_condition_changed(this_index, new_text)
	var on_visibility_condition_changed_function = func(new_conditon: KnowledgeBool):
		_on_visibility_condition_changed(this_index, new_conditon)
		
	new_condition.text_changed.connect(text_changed_function.bind())
	new_condition.visibility_condition_changed.connect(on_visibility_condition_changed_function.bind())
	return new_condition

func _free_condition_control(old_condition: KnowledgeJunctionConditionContainer) -> void:
	var this_index = _conditions.size()
	set_slot(this_index + 1, this_index == 0, 0, Color.CYAN, false, 0, Color.YELLOW)
	
	old_condition.settings_visibility_changed.disconnect(
		_on_settings_visibility_changed.bind()
	)
	old_condition.queue_free()
	old_condition.visible = false
	_update_size()

#
#	Signals
#

func _on_remove_line_button_pressed():
	_remove_last_condition()

func _on_add_line_button_pressed():
	_add_new_condition()

func _on_settings_visibility_changed(_is_visible: bool):
	_update_size()

func _on_condition_changed(index: int, new_text: String) -> void:
	_casted_data.conditions[index].text = new_text
	data_updated.emit(_casted_data)

func _on_visibility_condition_changed(index: int, condition: KnowledgeBool) -> void:
	_casted_data.conditions[index][KnowledgeJunctionNodeData.CONDITIONS_VIS_COND_KEY] = condition
	data_updated.emit(_casted_data)
