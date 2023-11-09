@tool
extends DialogGraphNode

#
#	Exports
#

@export var choice_option_scene: PackedScene

#
#	Variables
#

@onready var _starting_size: Vector2 = size 
var _choice_options: Array[ChoicePromptOptionContainer] = []

var _casted_data: ChoicePromptNodeData:
	get:
		return _data

#
#	Public Functions
#

func set_node_data(data: GraphNodeData) -> GraphNodeData:
	var casted_data = data as ChoicePromptNodeData
	if casted_data == null:
		return null
	
	# Remove any choices that exist
	for option in _choice_options:
		_free_option_control(option)
	_choice_options.clear()	
	
	# Set all of the text choices
	for choice in casted_data.choices:
		var new_option = _new_option_control()
		_choice_options.push_back(new_option)
		new_option.set_text(choice)
	
	# Set all of the visibility conditions
	for vis_index in casted_data.visibility_conditions.keys():
		if vis_index >= casted_data.choices.size():
			continue
		_choice_options[vis_index].set_visibility_condition(
			casted_data.visibility_conditions[vis_index]
		)
	
	_update_size()
	return super(casted_data)

#
#	Private Functions
#

func _update_size():
	size = _starting_size

func _add_new_option() -> void:
	var new_option = _new_option_control()
	_choice_options.push_back(new_option)	
	_casted_data.choices.push_back("")
	data_updated.emit(_casted_data)

func _remove_last_option() -> void:
	if _choice_options.size() == 0:
		return

	var old_option = _choice_options.pop_back()
	_free_option_control(old_option)
	_casted_data.choices.pop_back()
	
	var index = _casted_data.choices.size()
	_casted_data.visibility_conditions.erase(index)
	data_updated.emit(_casted_data)
	
func _new_option_control() -> ChoicePromptOptionContainer:
	var new_option = choice_option_scene.instantiate()
	add_child(new_option)
	
	var this_index = _choice_options.size()
	new_option.setup(this_index)
	set_slot(this_index + 1, false, 0, Color.CYAN, true, 0, Color.YELLOW)
	
	# Hook into the option container's signal that fires
	# when the settings panel is opened and closed,
	# becaues we need to adjust the size of this when
	# the size of the option changes.
	new_option.settings_visibility_changed.connect(
		_on_settings_visibility_changed.bind()
	)
	
	# Create custom functions that pass the index of this choice in to our
	# internal signal functions, so that we know what choice called
	var text_changed_function = func(new_text: String):
		_on_text_changed(this_index, new_text)
	var on_visibility_condition_changed_function = func(new_conditon: KnowledgeBool):
		_on_visibility_condition_changed(this_index, new_conditon)
		
	new_option.text_changed.connect(text_changed_function.bind())
	new_option.visibility_condition_changed.connect(on_visibility_condition_changed_function.bind())
	return new_option
	
func _free_option_control(old_option: ChoicePromptOptionContainer) -> void:
	var this_index = _choice_options.size()
	set_slot(this_index + 1, this_index == 0, 0, Color.CYAN, false, 0, Color.YELLOW)
	
	old_option.settings_visibility_changed.disconnect(
		_on_settings_visibility_changed.bind()
	)
	old_option.queue_free()
	old_option.visible = false
	_update_size()
	
	
#
#	Signals
#

func _on_remove_line_button_pressed():
	_remove_last_option()

func _on_add_line_button_pressed():
	_add_new_option()

func _on_settings_visibility_changed(_is_visible: bool):
	_update_size()
	
func _on_text_changed(index: int, new_text: String) -> void:
	_casted_data.choices[index] = new_text
	data_updated.emit(_casted_data)
	
func _on_visibility_condition_changed(index: int, condition: KnowledgeBool) -> void:
	# If the resource field cleared it's value, erase this condition from
	# our data
	if condition == null:
		_casted_data.visibility_conditions.erase(index)
	# If the resource field assigned a new value, set this new condition
	# in our data
	else:
		_casted_data.visibility_conditions[index] = condition
	
	data_updated.emit(_casted_data)
