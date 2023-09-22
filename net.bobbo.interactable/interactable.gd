extends Node
class_name Interactable

#
#	Exported Variables
#

signal interact_changed(bool)
signal interact_started
signal interact_stopped
signal hover_changed(bool)
signal hover_started
signal hover_stopped

#
#	Variables
#

var hovering = false
var interacting = false

#
#	Functions
#

func interact_start():
	if interacting:
		return
	
	interacting = true
	interact_started.emit()
	interact_changed.emit(interacting)
	
func interact_stop():
	if !interacting:
		return
		
	interacting = false
	interact_stopped.emit()
	interact_changed.emit(interacting)
	
func hover_start():
	if hovering:
		return
		
	hovering = true
	hover_started.emit()
	hover_changed.emit(hovering)
	
func hover_stop():
	if !hovering:
		return
	
	hovering = false
	hover_stopped.emit()
	hover_changed.emit(hovering)
