extends Resource
class_name ProjectedControlBehaviour

var control: ProjectedControl

#
#	Functions
#

func call_behaviour_init(projected_control: ProjectedControl) -> void:
	self.control = projected_control
	return behaviour_init(projected_control)

func call_behaviour_process(delta: float) -> void:
	return behaviour_process(delta)

#
#	Abstract Functions
#

func behaviour_init(projected_control: ProjectedControl) -> void:
	return
	
func behaviour_process(delta: float) -> void:
	return
