extends BobboStateMachine
class_name TextWindowStateMachine

#
#	Exported
#

## The TextWindow that this State Machine should control
@onready var text_window: TextWindow = get_parent() as TextWindow
