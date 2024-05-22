## Allows an agent to use items in their inventory.
extends CharacterAgentScript

#
#	Player Functions
#


func character_agent_process(_delta: float) -> void:
	# Get the currently selected item and item script. If there isn't
	# one, EXIT EARLY
	var item: ItemInstance = agent_3d.item_interactor.selected_item
	if item == null:
		return
	var item_script = item.get_item_script()
	if item_script == null:
		return

	# Populate the values for this items input
	_process_item_input(
		BobboInputs.Player.Item.Use.PRIMARY, item_script.use_0_input
	)
	_process_item_input(
		BobboInputs.Player.Item.Use.SECONDARY, item_script.use_1_input
	)


#
#   Private Functions
#


## Given some input action and an ItemInput object, fill in the values
## that the ItemInput needs to properly represent the agent's input
## state.
func _process_item_input(
	action_name: String, input: ItemScriptBase.ItemInput
) -> void:
	# If we don't support this input, EXIT EARLY
	if not InputMap.has_action(action_name):
		return

	input.just_down = agent_3d.input.is_action_just_pressed(action_name)
	input.pressing = agent_3d.input.is_action_pressed(action_name)
	input.just_up = agent_3d.input.is_action_just_released(action_name)
