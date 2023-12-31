@tool
extends ConfirmationDialog
class_name QuickFindDialog

#
#	Exports
#

## Emitted when the path to a resource has been confirmed / picked
signal confirmed_path(path: String)

## The filter to use for this dialog's resource list.
@export var filter: ResourceSearchFilter = null

#
#	Private Variables
#

## The currently selected path. This isn't necessarily the confirmed
## path, until the `confirmed_path` signal is called.
var _selected_path: String = ""
## The search list used to display all resource options
var _search_list: ResourceSearchList = null

#
#	Godot Functions
#

func _ready():
	confirmed.connect(_on_confirmed.bind())
	get_ok_button().disabled = true
	
	# Wait for the parent node of this to be ready.
	# We do this so parent nodes have a chance to override
	# our search_list_scene variable :3
	await get_parent().ready
	
	# Setup the search list and connect it to us
	_search_list = $VBoxContainer/ResourceSearchList
	_search_list.filter = filter
	_search_list.item_selected.connect(
		_on_resource_search_list_item_selected.bind()
	)
	_search_list.scan_filesystem()

#
#	Public Functions
#

func get_selected_path() -> String:
	return _selected_path

#
#	Signals
#

## Called when this dialog progresses. Emits the confirmed_path 
## signal with the currently selected path
func _on_confirmed() -> void:
	confirmed_path.emit(_selected_path)

## Called when the search list child selects a path.
func _on_resource_search_list_item_selected(index: int):
	get_ok_button().disabled = false
	_selected_path = _search_list.get_item_text(index)

