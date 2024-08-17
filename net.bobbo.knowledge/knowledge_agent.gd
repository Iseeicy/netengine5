class_name KnowledgeAgent
extends Node

#
#	Exports
#

## Called when the value of this knowledge is changed
signal value_changed(new_value)

## The knowledge to represent
@export var knowledge: Knowledge

#
#	Godot Functions
#


func _enter_tree():
	knowledge.connect_updated_value(_on_knowledge_value_changed.bind())


func _exit_tree():
	knowledge.disconnect_updated_value(_on_knowledge_value_changed.bind())


func _ready() -> void:
	_on_knowledge_value_changed(knowledge.get_value())


#
#	Public Functions
#


func get_value():
	return knowledge.get_value()


func set_value(new_value):
	knowledge.set_value(new_value)


#
#	Signals
#


func _on_knowledge_value_changed(new_value) -> void:
	value_changed.emit(new_value)
