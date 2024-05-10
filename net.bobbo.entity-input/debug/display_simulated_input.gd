extends Label

#
#   Exports
#

@export var simulated_input: SimulatedInput = null

#
#	Private Variables
#

var _logs: Array[String] = []

#
#   Godot Functions
#


func _process(_delta):
	_update_text()


func _physics_process(_delta):
	_save_log()


#
#   Private Functions
#


func _save_log():
	var new_log := ""

	for tick_name in EntityInput.TickType.keys():
		var current_states: Dictionary = (
			simulated_input
			. _current_states_by_tick_type[EntityInput.TickType[tick_name]]
		)

		if current_states.size() == 0:
			continue

		new_log += "%s:\n" % tick_name

		for state_name in current_states.keys():
			new_log += "\t%s = %s\n" % [state_name, current_states[state_name]]

	if new_log == "":
		return
	_logs.push_front("%s\n%s" % [Time.get_ticks_msec(), new_log])
	if _logs.size() > 9:
		_logs.pop_back()


func _update_text():
	text = ""
	for log in _logs:
		text += "%s\n" % log
