@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("TextWindow", "Control", preload("text_window.gd"), preload("icons/text_window.png"))
	add_custom_type("ControlProjection", "Control", preload("control_projection.gd"), preload("icons/text_window.png"))
	add_custom_type("BasicProjection", "Control", preload("basic_projection.gd"), preload("icons/text_window.png"))
	add_custom_type("DistanceFillProjection", "Control", preload("distance_fill_projection.gd"), preload("icons/text_window.png"))
	add_custom_type("StickyProjection", "Control", preload("sticky_projection.gd"), preload("icons/text_window.png"))

func _exit_tree():
	remove_custom_type("TextWindow")
	remove_custom_type("ControlProjection")
	remove_custom_type("BasicProjection")
	remove_custom_type("DistanceFillProjection")
	remove_custom_type("StickyProjection")
