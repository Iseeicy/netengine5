extends Tree

#
#	Godot Functions
#


func _enter_tree():
	KnowledgeDB.key_added.connect(_on_knowledge_key_added.bind())
	KnowledgeDB.key_removed.connect(_on_knowledge_key_removed.bind())


func _exit_tree():
	KnowledgeDB.key_removed.disconnect(_on_knowledge_key_removed.bind())
	KnowledgeDB.key_added.disconnect(_on_knowledge_key_added.bind())


#
#	Private Functions
#


## Refreshes the contents of the tree to match the currently
## known knowledge.
func _update_tree():
	clear()
	var tree_root = create_item()
	tree_root.set_text(0, "All Knowledge")

	var all_knowledge = KnowledgeDB.get_all()

	var tree_info: Dictionary = {}
	for some_knowledge in all_knowledge.keys():
		_create_tree_branch(tree_root, tree_info, some_knowledge)


## Given a path string, removes the protocol at the start
func _remove_protocol_from_path(path: String) -> String:
	var index = path.find("://")
	if index < 0:
		return path

	return path.substr(index + 3)


## Creates the branch of a tree given info about the
## leaf that we should be making branches for. This will
## re-use previously created branches if they match!
func _create_tree_branch(
	parent_node: TreeItem, info: Dictionary, knowledge: Knowledge
) -> void:
	var split_path = _remove_protocol_from_path(knowledge.resource_path).split(
		"/"
	)

	for x in range(1, split_path.size() + 1):
		var split_slice = split_path.slice(0, x)
		var path = "/".join(split_slice)

		# If a node already exists for this part of the subpath,
		# MOVE ON
		if path in info:
			parent_node = info[path]
			continue

		var new_node = create_item(parent_node)
		new_node.set_metadata(0, knowledge)
		info[path] = new_node

		var end_of_path = split_slice[-1]

		if "." in end_of_path:
			end_of_path = end_of_path.split(".")[0]
			new_node.set_selectable(0, true)
			new_node.set_icon(0, preload("../icons/knowledge_icon.png"))
			new_node.set_icon_max_width(0, 32)
		else:
			new_node.set_selectable(0, false)

		new_node.set_text(0, end_of_path)
		parent_node = new_node


func _on_knowledge_key_removed(_knowledge):
	_update_tree()


func _on_knowledge_key_added(_knowledge):
	_update_tree()
