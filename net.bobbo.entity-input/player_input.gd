extends EntityInput
class_name PlayerInput

#
#   Entity Input Functions
#

func get_local_movement_dir() -> Vector3:
    # TODO - this should support analog at some point
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