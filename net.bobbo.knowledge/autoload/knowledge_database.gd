@tool
extends Node

#
#	Exports
#

signal amount_updated()
signal key_added(knowledge: Knowledge)
signal key_removed(knowledge: Knowledge)

#
#	Variables
#

var _knowledge_data: Dictionary = {} # Knowledge Resource -> Value

#
#	Public Functions
#

func connect_updated_value(knowledge: Knowledge, callable: Callable):
	var signal_key = _get_value_updated_signal_key(knowledge)
	
	if not has_user_signal(signal_key):
		add_user_signal(signal_key, [
			{ "name": "new_value" }
		])
		
	connect(signal_key, callable)
	
func disconnect_updated_value(knowledge: Knowledge, callable: Callable):
	
	var signal_key = _get_value_updated_signal_key(knowledge)
	
	if not has_user_signal(signal_key):
		return
		
	disconnect(signal_key, callable)

func get_knowledge_value(knowledge: Knowledge):
	## If we don't have this knowledge, try to load it's default
	if not knowledge in _knowledge_data.keys():
		_set_value(knowledge, knowledge.get_default_value())
	
	return _knowledge_data[knowledge]
	
func set_knowledge_value(knowledge: Knowledge, value):
	_set_value(knowledge, value)

func get_all() -> Dictionary:
	return _knowledge_data

func save_state(path: String) -> void:
	var save_file = FileAccess.open(path, FileAccess.WRITE)
	
	for knowledge in _knowledge_data:
		save_file.store_var(knowledge.resource_path)
		save_file.store_var(_knowledge_data[knowledge])
	
	
func load_state(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return false # Error! We don't have a save to load.
		
	var new_all_knowledge: Dictionary = {}
	var save_file = FileAccess.open(path, FileAccess.READ)
	
	while save_file.get_position() < save_file.get_length():
		var found_resource_path = save_file.get_var()
		var found_val = save_file.get_var()
		
		if not ResourceLoader.exists(found_resource_path):
			printerr("Couldn't find resource at '%s'" % found_resource_path)
			continue
		
		# Try to load the knowledge at that resource path
		var found_resource = load(found_resource_path) as Knowledge
		if found_resource == null:
			printerr("Resource at '%s' was not Knowledge" % found_resource_path)
			continue
		
		new_all_knowledge[found_resource] = found_val
		
	_set_entire_data(new_all_knowledge)
	return true

#
#	Private Functions
#

func _set_value(knowledge: Knowledge, new_value):
	var is_new = knowledge in _knowledge_data.keys()
	
	_knowledge_data[knowledge] = new_value
	key_added.emit(knowledge)
	amount_updated.emit()
	
	# Call the dynamic signal if relevant
	var signal_key = _get_value_updated_signal_key(knowledge)
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

func _get_value_updated_signal_key(knowledge: Knowledge) -> String:
	return "updated_%s" % knowledge.get_instance_id()

func _get_default(resource_path: String):
	if not ResourceLoader.exists(resource_path):
		return null
		
	var locator = load(resource_path) as Knowledge
	if locator == null:
		return null

	return locator.get_default_value()
