@tool
class_name PlayerController
extends CharacterAgent3D


static func find(root: Node) -> PlayerController:
	if root is PlayerController:
		return root

	for child in root.get_children():
		var result = find(child)
		if result is PlayerController:
			return result
	return null
