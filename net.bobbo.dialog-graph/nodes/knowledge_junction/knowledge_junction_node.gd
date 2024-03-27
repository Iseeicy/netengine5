@tool
extends DialogGraphNode

#
#	Exports
#

## The scene that holds all the UI for a condition
@export var condition_maker_scene: PackedScene

#
#	Variables
#

@onready var _starting_size: Vector2 = size

# The node's list of all its conditions
var _conditions: Array[KnowledgeJunctionConditionContainer] = []

# The node's data
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
	
	# Write the default values for all the data within the new condition
	_casted_data.conditions.push_back({ 
		KnowledgeJunctionNodeData.STATES_KEY: [0, 0, 0, 0] as Array[int], 
		KnowledgeJunctionNodeData.RESOURCES_KEY: [null, null, null, null, null] as Array[Knowledge], 
		KnowledgeJunctionNodeData.BUTTON_STATES_KEY: [true, false] as Array[bool], 
		KnowledgeJunctionNodeData.CONSTANT_KEY: 0
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
	
	# Bind these functions within the node to these signals within the new 
	# condition for updating data
	new_condition.state_changed.connect(_on_state_changed.bind())
	new_condition.resource_field_updated.connect(_on_resource_field_changed.bind())
	new_condition.button_state_changed.connect(_on_button_state_changed.bind())
	new_condition.constant_value_changed.connect(_on_value_changed.bind())
	return new_condition

func _free_condition_control(old_condition: KnowledgeJunctionConditionContainer) -> void:
	var this_index = _conditions.size()
	set_slot(this_index + 1, this_index == 0, 0, Color.CYAN, false, 0, Color.YELLOW)
	
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
	
# Data Changed Signals
# Here I made it so that they all send the index of their condition when they
# send their signals so that the data can properly update each condition with
# its data based off the condition's personal account of its data
func _on_state_changed(index: int) -> void:
	_casted_data.conditions[index][KnowledgeJunctionNodeData.STATES_KEY] = _conditions[index].states
	data_updated.emit(_casted_data)

func _on_resource_field_changed(index: int) -> void:
	# Funny story about this signal, I had an issue where I accidentally wrote 
	# over the NodeData array when reloading which made me wonder for a hot 
	# second what was happening until I realized that by loading the values for 
	# the resource fields and assigning them one at at time, it caused this 
	# signal to trigger overwritting the data only allowing one of the resource 
	# fields to be written too, I got around this by just making a temporary 
	# array to store the values before assigning them to their fields
	_casted_data.conditions[index][KnowledgeJunctionNodeData.RESOURCES_KEY] = _conditions[index].resources
	data_updated.emit(_casted_data)

func _on_button_state_changed(index: int) -> void:
	_casted_data.conditions[index][KnowledgeJunctionNodeData.BUTTON_STATES_KEY] = _conditions[index].buttons
	data_updated.emit(_casted_data)

func _on_value_changed(index: int) -> void:
	_casted_data.conditions[index][KnowledgeJunctionNodeData.CONSTANT_KEY] = _conditions[index].constant_value
	data_updated.emit(_casted_data)
