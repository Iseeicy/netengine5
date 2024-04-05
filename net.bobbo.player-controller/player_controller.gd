@tool
class_name PlayerController
extends CharacterAgent3D

#
#	Variables
#

var camera_offset: Vector3 = Vector3.ZERO
var height: float = 2

@onready var mouselook: MouseLook3D = $Head/MouseLook3D
@onready var camera: VirtualCamera3D = $Head/VirtualCamera3D
@onready var interactor: InteractorRay3D = $Head/InteractorRay3D

#
#	Functions
#


func _process_before(_delta):
	camera_offset = Vector3.ZERO


func _process_after(_delta):
	camera.position = camera_offset
	collider.shape.height = height


func _physics_process_before(_delta):
	height = 2


func _physics_process_after(_delta):
	collider.shape.height = height


static func find(root: Node) -> PlayerController:
	if root is PlayerController:
		return root

	for child in root.get_children():
		var result = find(child)
		if result is PlayerController:
			return result
	return null
