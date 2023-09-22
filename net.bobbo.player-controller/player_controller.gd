extends CharacterBody3D
class_name PlayerController

#
#	Exported
#

@export var player_scripts: Array[PackedScene] = []
@export var initial_model: PackedScene = null

#
#	Variables
#

@onready var script_runner: PlayerControllerScriptRunner = $ScriptRunner
@onready var mouselook: MouseLook3D = $CameraOrigin/MouseLook3D
@onready var camera: Camera3D = $CameraOrigin/Camera3D
@onready var interactor: InteractorRay3D = $CameraOrigin/InteractorRay3D
@onready var model_pivot: Node3D = $BodyPivot
@onready var model: PlayerModel = $BodyPivot/PlayerModel
@onready var collider: CollisionShape3D = $Collider
var camera_offset: Vector3 = Vector3.ZERO
var height: float = 2

#
#	Functions
#

func _ready():
	if initial_model != null:
		model.set_model(initial_model)
	
	for script_scene in player_scripts:
		var spawned_script = script_scene.instantiate()
		script_runner.add_child(spawned_script)
		spawned_script.owner = self
	script_runner.initialize()
	script_runner.scripts_ready()

func _process(delta):
	camera_offset = Vector3.ZERO
	script_runner.scripts_process(delta)
	camera.position = camera_offset
	collider.shape.height = height
	
func _physics_process(delta):
	height = 2
	script_runner.scripts_physics_process(delta)
	collider.shape.height = height
	move_and_slide()
	
# Read the player's current ground-plane input
func get_movement_dir() -> Vector3:
	var input = Vector3.ZERO
	
	# If the player isn't focused, don't read input
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return input
		
	if Input.is_action_pressed("player_move_forward"):
		input += Vector3.FORWARD
	if Input.is_action_pressed("player_move_back"):
		input -= Vector3.FORWARD
	if Input.is_action_pressed("player_move_left"):
		input += Vector3.LEFT
	if Input.is_action_pressed("player_move_right"):
		input -= Vector3.LEFT
		
	if input != Vector3.ZERO:
		input = input.normalized()
		
	return input
	
func get_rotated_move_dir() -> Vector3:
	return get_movement_dir().rotated(	# Rot input to match facing dir
		Vector3.UP, 			# vert axis to rotate around
		model_pivot.rotation.y	# how much to rot in radians
	)
	
static func find(root: Node) -> PlayerController:
	if root is PlayerController:
		return root
	else:
		for child in root.get_children():
			var result = find(child)
			if result is PlayerController:
				return result
		return null

