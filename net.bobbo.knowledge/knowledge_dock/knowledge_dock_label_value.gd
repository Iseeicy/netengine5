extends Label

@export var tree: Tree
var _current_key = null

func _on_knowledge_dock_tree_item_selected():
	_current_key = tree.get_selected().get_metadata(0) as String

func _process(delta):
	if _current_key == null:
		return
		
	text = str(KnowledgeDB.get_knowledge_value(_current_key))
	
