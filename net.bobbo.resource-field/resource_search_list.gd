@tool
extends ItemList
class_name ResourceSearchList

#
#	Private Variables
#

var _search_query: String = ""
var _known_files: Array[String] = []

#
#	Godot Functions
#

func _ready():
	scan_filesystem()
	refresh_list()

#
#	Public Functions
#

func set_search_query(query: String) -> void:
	_search_query = query
	refresh_list()

func scan_filesystem() -> void:
	var result_list: Array[String] = []
	_scan_dir("res://", result_list)
	_known_files = result_list

func refresh_list() -> void:
	clear()
	
	for file in _known_files:
		if _file_matches_search(file, _search_query):
			add_item(file)
	
#
#	Private Functions
#
	
func _scan_dir(path: String, result_list: Array[String]) -> void:
	if _should_ignore_dir(path):
		return
	
	var dir = DirAccess.open(path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var current_file_name = dir.get_next()
	while current_file_name != "":
		var full_path
		if path == "res://":
			full_path = path + current_file_name
		else:
			full_path = path + "/" + current_file_name
		
		if dir.current_is_dir():
			_scan_dir(full_path, result_list)
		else:
			if _should_include_file(full_path):
				result_list.push_back(full_path)
		current_file_name = dir.get_next()

func _should_ignore_dir(absolute_path: String) -> bool:
	if absolute_path == "res://.godot":
		return true
		
	return false
	
func _should_include_file(absolute_path: String) -> bool:
	if not absolute_path.ends_with(".tres"):
		return false
		
	var found_resource = load(absolute_path)
	if not _is_resource_correct_type(found_resource):
		return false
		
	return true
	
func _file_matches_search(absolute_path: String, query: String) -> bool:
	if query == "":
		return true
		
	return absolute_path.contains(query)
	
#
#	Virtual Functions
#

## Is the given resource the right class type?
## We need to make this a virtual function because for SOME
## reason, Godot doesn't expose custom resource class names
## when getting the class for a resource - but it DOES work
## with the `is` keyword. Buh.
func _is_resource_correct_type(resource) -> bool:
	return resource is Resource
