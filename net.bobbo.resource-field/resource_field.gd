@tool
extends HBoxContainer
class_name ResourceField

#
#	Exports
#

signal target_resource_updated(resource: Resource)

## The filter to use when sorting through what resources this field allows.
@export var filter: ResourceSearchFilter = null

#
#	Private Variables
#

const QUICK_FIND_ID: int = 0
const LOAD_ID: int = 1
const CLEAR_ID: int = 2

var _target_resource: Resource = null

#
#	Godot Functions
#

func _ready():
	$MenuButton.get_popup().id_pressed.connect(_on_menu_button_id_pressed.bind())
	$QuickFindDialog.filter = filter

#
#	Public Functions
#

func get_target_resource() -> Resource:
	return _target_resource
	
func set_target_resource(resource: Resource) -> void:
	if resource == _target_resource:
		return
	
	_target_resource = resource
	
	# Set the button's text
	var display_item_text = "<empty>"
	if resource != null:
		display_item_text = resource.resource_path.split('/')[-1]
	$MenuButton.text = display_item_text
	
	$MenuButton.get_popup().set_item_disabled(CLEAR_ID, resource == null)
		
	
	target_resource_updated.emit(resource)

#
#	Signals
#

func _on_menu_button_id_pressed(id: int):
	match(id):
		QUICK_FIND_ID:
			$QuickFindDialog.show()
		LOAD_ID:
			return
		CLEAR_ID:
			set_target_resource(null)

func _on_arrow_button_pressed():
	$MenuButton.show_popup()


func _on_quick_find_dialog_confirmed_path(path):
	set_target_resource(load(path))
