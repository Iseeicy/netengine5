extends PlayerControllerScript

#
#	Exported
#

@export var crouch_speed: float = 20

#
#	Variables
#

var crouch_current: float = 0
var crouch_target: float = 0
const crouch_action: String = "player_crouch"

#max_player_height is needed for proper uncrouching height calculations if the maximum player height were to change
#during gameplay at any point this value would need to somehow be updated to account for that
#default is 2 because the default height in player_controller is 2
var max_player_height: float = 2

#This value reports the total height above the player's origin, it's also used to clamp what the player's height
#can be set to
var height_above: float = INF

#
#	Functions
#

func player_ready():
	max_player_height = player.height
	self.assert_input_action(crouch_action)

func player_physics_process(delta: float):
	if Input.is_action_pressed(crouch_action):
		crouch_target = 0.5
	else:
		crouch_target = 1
		
	var previous_scale = player.height * crouch_current
	crouch_current = lerp(crouch_current, crouch_target, clamp(delta * crouch_speed, 0, 1))
	var new_scale = player.height * crouch_current
	var scale_difference = new_scale - previous_scale
	
	player.velocity.y += scale_difference * 0.5
	
	#make it so that the crouch can only go as low as regularly crouching and only high enough 
	#such that the player doesn't get stuck if an object is detected above them
	player.height = clamp(new_scale, max_player_height / 2, height_above)

#we need the physics thread in order to calculate a raycast
func _physics_process(delta):
	#get the 3D physics space from a Node3D like the player_pivot
	var space_state = player.model_pivot.get_world_3d().direct_space_state
	
	#calculate origin and ending of raycast
	var origin = player.position
	var end = player.position + Vector3(0, max_player_height / 2, 0)
	
	#create the raycast
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	
	#exclude the player from raycast calculations and make the ray collide with areas
	query.exclude = [player]
	query.collide_with_areas = true
	
	#cast the raycast
	var result = space_state.intersect_ray(query)
	
	#if we detect an object at the top of the player
	if result:
		#before this equation I subtracted by an offset of 0.001 so that way the height didn't exactly match
		#so the player wouldn't get stuck, thankfully the equations I came up with seem to not need it
		
		#calculate proper height to fit below object above the player
		#Need to have a slightly different equation in case this happens to get proper crouch height
		if(abs(player.position.y) > abs(result.position.y)):
			height_above = abs(player.position.y - result.position.y + (max_player_height / 4)) + (max_player_height / 2)
		else:
			height_above = abs(result.position.y - player.position.y + (max_player_height / 4))
	else:
		#unlock player height if there is no object detected at the top of the player
		height_above = INF
