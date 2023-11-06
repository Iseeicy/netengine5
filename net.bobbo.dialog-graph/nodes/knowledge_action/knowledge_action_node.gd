@tool
extends DialogGraphNode

#
#	Godot Functions
#

func _ready():
	_display_settings_for_resource(null)

#
#	Private Functions
#

func _display_settings_for_resource(resource: Resource) -> void:
	$Types/Unknown.visible = false
	$Types/Bool.visible = false
	$Types/Integer.visible = false
	$Types/Float.visible = false
	$Types/String.visible = false
	$HSeparator.visible = false
	
	if resource != null:
		$HSeparator.visible = true
		if resource is KnowledgeBool:
			$Types/Bool.visible = true
		elif resource is KnowledgeInteger:
			$Types/Integer.visible = true
		elif resource is KnowledgeFloat:
			$Types/Float.visible = true
		elif resource is KnowledgeString:
			$Types/String.visible = true
		else:
			$Types/Unknown.visible = true

#
#	Signals
#

func _on_knowledge_resource_field_target_resource_updated(resource):
	_display_settings_for_resource(resource)
