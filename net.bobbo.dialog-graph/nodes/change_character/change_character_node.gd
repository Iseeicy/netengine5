@tool
extends DialogGraphNode

#
#	Private Variables
#

var _casted_data: ChangeCharacterNodeData:
	get:
		return _data

#
#	Public Functions
#

func set_node_data(data: GraphNodeData) -> GraphNodeData:
	var casted_data = data as ChangeCharacterNodeData
	if casted_data == null:
		return null
	
	$CharacterDefResourceField.set_target_resource(casted_data.character_definition)
	return super(casted_data)

func _on_character_def_resource_field_target_resource_updated(resource):
	_casted_data.character_definition = resource

	
