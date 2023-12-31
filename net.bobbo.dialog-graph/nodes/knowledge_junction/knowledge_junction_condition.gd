@tool
extends PanelContainer
class_name KnowledgeJunctionConditionContainer

#
#	Signals
#

## Option Signals
## Condition Type: Condition = 0, CustomComparison = 1, CustomOperator = 2
## Condition State: True = 0, False = 1
## Comparison Type: Equals = 0, Not Equal To = 1, Is Greater Than = 2, 
## Is Greater Than Or Equal To = 3, Is Less Than = 4, Is Less Than Or Equal 
## To = 5
## Operator Type: And = 0, Or = 1
signal state_changed(index: int)
signal resource_field_updated(index: int)
signal button_state_changed(index: int)
signal constant_value_changed(index: int)

#
#	Public Variables
#
var index: int = -1
var states: Array[int] = [0, 0, 0, 0]
var resources: Array[Knowledge] = [null, null, null, null, null]
var buttons: Array[bool] = [true, false]
var constant_value: float = 0

#
#	Private Variables
#

## Condition Type Containers
var _condition_container: VBoxContainer
var _custom_comparison_container: VBoxContainer
var _custom_operator_container: VBoxContainer

## Secondary Comparison Value Containers
var _constant_container: HBoxContainer
var _knowledge_container: HBoxContainer

var _line_label: Label
var _condition_type: OptionButton
## The knowledge boolean resource field for a regular condition
var _condition_resource_field: ResourceField
var _condition_state_button: OptionButton
## The resource field for the first knowledge number for comparison
var _value_resource_field: ResourceField
var _comparison_type_button: OptionButton
## These buttons let the user say if they want to use a constant or knowledge 
## for comparison
var _is_constant_button: CheckButton
var _is_knowledge_button: CheckButton
var _constant_value: SpinBox
## The resource field for the second knowledge number for comparison
var _knowledge_value_resource_field: ResourceField
var _operator_resource_field_1: ResourceField
var _operator_type_button: OptionButton
var _operator_resource_field_2: ResourceField

#
#	Godot Functions
#

func _ready():
	_condition_container = $MarginContainer/VBoxContainer/ConditionContainer
	_custom_comparison_container = $MarginContainer/VBoxContainer/CustomComparisonContainer
	_custom_operator_container = $MarginContainer/VBoxContainer/CustomOperatorConditionEditContainer
	_constant_container = $MarginContainer/VBoxContainer/CustomComparisonContainer/ConstantHBoxContainer
	_knowledge_container = $MarginContainer/VBoxContainer/CustomComparisonContainer/KnowledgeHBoxContainer
	_line_label = $MarginContainer/VBoxContainer/ConditionTypeContainer/LineLabel
	_condition_type = $MarginContainer/VBoxContainer/ConditionTypeContainer/ConditionType
	_condition_resource_field = $MarginContainer/VBoxContainer/ConditionContainer/HBoxContainer/ConditionResourceField
	_condition_state_button = $MarginContainer/VBoxContainer/ConditionContainer/ConditionStateButton
	_value_resource_field = $MarginContainer/VBoxContainer/CustomComparisonContainer/ResourceHBoxContainer/ValueResourceField
	_comparison_type_button = $MarginContainer/VBoxContainer/CustomComparisonContainer/ComparisonTypeButton
	_is_constant_button = $MarginContainer/VBoxContainer/CustomComparisonContainer/ButtonsHBoxContainer/IsConstantButton
	_is_knowledge_button = $MarginContainer/VBoxContainer/CustomComparisonContainer/ButtonsHBoxContainer/IsKnowledgeButton
	_constant_value = $MarginContainer/VBoxContainer/CustomComparisonContainer/ConstantHBoxContainer/SpinBox
	_knowledge_value_resource_field = $MarginContainer/VBoxContainer/CustomComparisonContainer/KnowledgeHBoxContainer/SecondValueResourceField
	_operator_resource_field_1 = $MarginContainer/VBoxContainer/CustomOperatorConditionEditContainer/Knowledge1HBoxContainer/KnowledgeResourceField
	_operator_type_button = $MarginContainer/VBoxContainer/CustomOperatorConditionEditContainer/OperatorTypeButton
	_operator_resource_field_2 = $MarginContainer/VBoxContainer/CustomOperatorConditionEditContainer/KnowledgeHBoxContainer/SecondKnowledgeResourceField

#
#	Public Functions
#

func setup(index: int):
	self.index = index
	_line_label.text = "%s:" % index

func set_condition(new_condition: Dictionary) -> void:
	var condition_type = new_condition.get(KnowledgeJunctionNodeData.STATES_KEY, 0)[0]
	_condition_container.visible = false
	_custom_comparison_container.visible = false
	_custom_operator_container.visible = false
	
	match condition_type:
		0:
			_condition_container.visible = true
		1:
			_custom_comparison_container.visible = true
		2:
			_custom_operator_container.visible = true
	
	_condition_type.selected = condition_type
	_condition_state_button.selected = new_condition.get(KnowledgeJunctionNodeData.STATES_KEY, 0)[1]
	_comparison_type_button.selected = new_condition.get(KnowledgeJunctionNodeData.STATES_KEY, 0)[2]
	_operator_type_button.selected = new_condition.get(KnowledgeJunctionNodeData.STATES_KEY, 0)[3]
	
	var resources: Array[Knowledge] = new_condition.get(KnowledgeJunctionNodeData.RESOURCES_KEY, null)
	_condition_resource_field.set_target_resource(resources[0])
	_value_resource_field.set_target_resource(resources[1])
	_knowledge_value_resource_field.set_target_resource(resources[2])
	_operator_resource_field_1.set_target_resource(resources[3])
	_operator_resource_field_2.set_target_resource(resources[4])
	
	var is_constant = new_condition.get(KnowledgeJunctionNodeData.BUTTON_STATES_KEY, false)[0]
	var is_knowledge = new_condition.get(KnowledgeJunctionNodeData.BUTTON_STATES_KEY, false)[1]
	
	_constant_container.visible = is_constant
	_knowledge_container.visible = is_knowledge
	_is_constant_button.button_pressed = is_constant
	_is_knowledge_button.button_pressed = is_knowledge
	
	_constant_value.get_line_edit().set_text(str(new_condition.get(KnowledgeJunctionNodeData.CONSTANT_KEY, "")))
	_constant_value.apply()
#
#	Private Functions
#

# Option Signals
func _on_condition_type_selected(index):
	_condition_container.visible = false
	_custom_comparison_container.visible = false
	_custom_operator_container.visible = false
	
	match index:
		0:
			_condition_container.visible = true
		1:
			_custom_comparison_container.visible = true
		2:
			_custom_operator_container.visible = true
	
	states = [_condition_type.selected, _condition_state_button.selected, 
	_comparison_type_button.selected, _operator_type_button.selected]
	state_changed.emit(self.index)

func _on_state_selected(index):
	states = [_condition_type.selected, _condition_state_button.selected, 
	_comparison_type_button.selected, _operator_type_button.selected]
	state_changed.emit(self.index)

func _on_resource_field_updated(resource):
	resources = [
	_condition_resource_field.get_target_resource(), _value_resource_field.get_target_resource(), 
	_knowledge_value_resource_field.get_target_resource(), 
	_operator_resource_field_1.get_target_resource(), 
	_operator_resource_field_2.get_target_resource()]
	resource_field_updated.emit(index)

# Button Signals
func _on_constant_button_toggled(button_pressed):
	_constant_container.visible = true
	_knowledge_container.visible = false
	
	buttons = [true, false]
	button_state_changed.emit(index)
	
func _on_knowledge_button_toggled(button_pressed):
	_constant_container.visible = false
	_knowledge_container.visible = true
	
	buttons = [false, true]
	button_state_changed.emit(index)

# Constant Signal
func _on_constant_value_changed(value):
	constant_value = value
	constant_value_changed.emit(index)
