@tool
extends DialogRunnerActiveHandlerState

#
#	Variables
#

var condition_data: KnowledgeJunctionNodeData:
	get:
		return data as KnowledgeJunctionNodeData

#
#	State Functions
#

func state_enter(_message: Dictionary = {}) -> void:
	_get_parent_state().state_enter(_message)
	
	## See if any of the conditions in this Knowledge Junction evalulate to true
	var a_condition_was_true = false
	for index in range(0, condition_data.conditions.size()):
		
		# If we find a condition that evalulates to true then go to the next node
		# connected by that condition
		if evalulate_condition_for_transition(condition_data.conditions[index]):
			go_to_next_node(index)
			a_condition_was_true = true
			break
	
	# If we didn't find a single condition that was true then by default just 
	# go to the first external connection
	if !a_condition_was_true:
		go_to_next_node(0)
	
func state_exit() -> void:
	_get_parent_state().state_exit()

#
#	Private Functions
#

func evalulate_condition_for_transition(condition: Dictionary) -> bool:
	match condition[KnowledgeJunctionNodeData.STATES_KEY][0]:
		0:
			var knowledge_bool = condition[KnowledgeJunctionNodeData.RESOURCES_KEY][0].get_value()
			var transition_if_false = condition[KnowledgeJunctionNodeData.STATES_KEY][1]
			
			# If the knowledge bool is true and we transition when true
			if knowledge_bool and !transition_if_false:
				return true
			# If the knowledge bool is false and we transition when false
			elif !knowledge_bool and transition_if_false:
				return true
		1:
			## Cast both of these to floats so they represent numbers the same way
			var value_1: float = condition[KnowledgeJunctionNodeData.RESOURCES_KEY][1].get_value()
			var value_2: float = 0
			
			# Getting value 2 from either form it could take
			if condition[KnowledgeJunctionNodeData.BUTTON_STATES_KEY][0]:
				value_2 = condition[KnowledgeJunctionNodeData.CONSTANT_KEY]
			else:
				value_2 = condition[KnowledgeJunctionNodeData.RESOURCES_KEY][2].get_value()
			
			match condition[KnowledgeJunctionNodeData.STATES_KEY][2]:
				0:
					# Equals
					return value_1 == value_2
				1:
					# Is Not Equal To
					return value_1 != value_2
				2:
					# Is Greater Than
					return value_1 > value_2
				3:
					# Is Greater Than or Equal To
					return value_1 >= value_2
				4:
					# Is Less Than
					return value_1 < value_2
				5:
					# Is Less Than or Equal To
					return value_1 <= value_2
		2:
			var bool1 = condition[KnowledgeJunctionNodeData.RESOURCES_KEY][3].get_value()
			var bool2 = condition[KnowledgeJunctionNodeData.RESOURCES_KEY][4].get_value()
			
			# If we are using the or operator or the and operator
			if condition[KnowledgeJunctionNodeData.STATES_KEY][3]:
				return bool1 or bool2
			else:
				return bool1 and bool2
	
	# If we don't end up finding anything else to return then return false
	return false
