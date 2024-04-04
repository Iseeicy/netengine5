class_name VirtualCamera3D
extends Node3D

#
#   Constants
#

## The name of the group that ALL `VirtualCamera3D`s are stored in.
const GROUP_NAME: String = "vcams_3d_all"

## The name of the group that all VISIBLE `VirtualCamera3D`s are stored
## in. VCams will be added and removed to this group upon change in
## the `visible` property.
const VISIBLE_GROUP_NAME: String = "vcams_3d_visible"

## TODO
