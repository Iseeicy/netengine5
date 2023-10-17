extends Node

#
#	Exports
#

signal amount_updated()
signal key_added(resource_path: String)
signal key_removed(resource_path: String)

#
#	Variables
#

var _knowledge_data: Dictionary = {} # Resource Path -> Value

#
#	Public Functions
#

func connect_updated_value(resource_path: String, callable: Callable):
	var signal_key = _get_value_updated_signal_key(resource_path)
	
	if not has_user_signal(signal_key):
		add_user_signal(signal_key, [
			{ "name": "new_value" }
		])
		
	connect(signal_key, callable)
	
func disconnect_updated_value(resource_path: String, callable: Callable):
	var signal_key = _get_value_updated_signal_key(resource_path)
	
	if not has_user_signal(signal_key):
		return
		
	disconnect(signal_key, callable)

func get_knowledge_value(resource_path: String):
	## If we don't have this knowledge, try to load it's default
	if not resource_path in _knowledge_data:
		_set_value(resource_path, _get_default(resource_path))
	
	return _knowledge_data[resource_path]
	
func set_knowledge_value(resource_path: String, value):
	_set_value(resource_path, value)

func get_all() -> Dictionary:
	return _knowledge_data

func save_state(path: String) -> void:
	var save_file = FileAccess.open(path, FileAccess.WRITE)
	
	for resource_path in _knowledge_data:
		save_file.store_var(resource_path)
		save_file.store_var(_knowledge_data[resource_path])
	
	
func load_state(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return false # Error! We don't have a save to load.
		
	var new_all_knowledge: Dictionary = {}
	var save_file = FileAccess.open(path, FileAccess.READ)
	
	while save_file.get_position() < save_file.get_length():
		var found_resource_path = save_file.get_var()
		var found_val = save_file.get_var()
		
		new_all_knowledge[found_resource_path] = found_val
		
	_set_entire_data(new_all_knowledge)
	return true

#
#	Private Functions
#

func _set_value(resource_path: String, new_value):
	var is_new = resource_path in _knowledge_data
	
	_knowledge_data[resource_path] = new_value
	key_added.emit(resource_path)
	amount_updated.emit()
	
	# Call the dynamic signal if relevant
	var signal_key = _get_value_updated_signal_key(resource_path)
	if has_user_signal(signal_key):
		emit_signal(signal_key, new_value)

func _set_entire_data(new_knowledge_data: Dictionary):
	var old_data = _knowledge_data
	_knowledge_data = new_knowledge_data
	
	# Go through all new keys, and if a key that existed in the
	# old dicitonary has been updated, tell us about it!
	for new_key in new_knowledge_data.keys():
		if new_key in old_data:
			if new_knowledge_data[new_key] != old_data[new_key]:
				var signal_key = _get_value_updated_signal_key(new_key)
				if has_user_signal(signal_key):
					emit_signal(signal_key, new_knowledge_data[new_key])

func _get_value_updated_signal_key(resource_path: String) -> String:
	return "updated_%s" % resource_path

func _get_default(resource_path: String):
	if not FileAccess.file_exists(resource_path):
		return null
		
	var locator = load(resource_path) as Knowledge
	if locator == null:
		return null

	return locator.get_default_value()

## Given an instance of Knowlege, get it's class name.
## We need to manually perform this because Godot does not
## allow us to access the name of the custom class as of writing.
func _knowledge_to_class_name(knowledge: Knowledge) -> String:
	if knowledge is KnowledgeBool:
		return "KnowledgeBool"
	elif knowledge is KnowledgeFloat:
		return "KnowledgeFloat"
	elif knowledge is KnowledgeInteger:
		return "KnowledgeInteger"
	elif knowledge is KnowledgeString:
		return "KnowledgeString"
	elif knowledge is Knowledge:
		return "Knowledge"
	else:
		return ""
		
func _knowledge_from_class_name(name: String):
	match(name):
		"KnowledgeBool":
			return KnowledgeBool.new()
	
	return null
