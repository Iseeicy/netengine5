extends Node
class_name EntityInput

#
#   Virtual Functions
#

## Returns the direction that this entity wants to try
## and move in. This value is local to the entity's
## assumed facing direction, NOT a global direction.
## Example - if the entity wants to move forward, then
## this will be Vector3.FORWARD. Should be normalized.
## Returns:
##  `Vector3` - the target local movement direction.
func get_local_movement_dir() -> Vector3:
    return Vector3.ZERO