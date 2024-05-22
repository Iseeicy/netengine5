@tool
class_name BobboInputs
extends RefCounted

#
#	Player Inputs
#


class Player:
	class Move:
		const FORWARD := "player_move_forward"
		const BACKWARD := "player_move_back"
		const LEFT := "player_move_left"
		const RIGHT := "player_move_right"

		static var axis := InputAxis2d.new(
			InputAxis1d.new(LEFT, RIGHT), InputAxis1d.new(FORWARD, BACKWARD)
		)

		static func register_inputs() -> void:
			ProjectInput.new(FORWARD).bind_keycode(KEY_W)
			ProjectInput.new(BACKWARD).bind_keycode(KEY_S)
			ProjectInput.new(LEFT).bind_keycode(KEY_A)
			ProjectInput.new(RIGHT).bind_keycode(KEY_D)

		static func unregister_inputs() -> void:
			ProjectInput.remove(FORWARD)
			ProjectInput.remove(BACKWARD)
			ProjectInput.remove(LEFT)
			ProjectInput.remove(RIGHT)

	class Look:
		const UP := "player_look_up"
		const DOWN := "player_look_down"
		const LEFT := "player_look_left"
		const RIGHT := "player_look_right"

		static var axis := InputAxis2d.new(
			InputAxis1d.new(LEFT, RIGHT), InputAxis1d.new(DOWN, UP)
		)

		static func register_inputs() -> void:
			return  # Nothing to register

		static func unregister_inputs() -> void:
			return  # Nothing to register

	class Item:
		class Drop:
			const STACK := "player_drop_item_stack"
			const SINGLE := "player_drop_item_single"

			static func register_inputs() -> void:
				ProjectInput.new(STACK).bind_keycode(
					KEY_W, {"shift_pressed": true}
				)
				ProjectInput.new(SINGLE).bind_keycode(KEY_Q)

			static func unregister_inputs() -> void:
				ProjectInput.remove(STACK)
				ProjectInput.remove(SINGLE)

		class Scroll:
			const FORWARD := "player_scroll_item_forward"
			const BACKWARD := "player_scroll_item_back"

			static func register_inputs() -> void:
				ProjectInput.new(FORWARD).bind_mouse_button(
					MOUSE_BUTTON_WHEEL_DOWN
				)
				ProjectInput.new(BACKWARD).bind_mouse_button(
					MOUSE_BUTTON_WHEEL_UP
				)

			static func unregister_inputs() -> void:
				ProjectInput.remove(FORWARD)
				ProjectInput.remove(BACKWARD)

		class Use:
			const PRIMARY := "player_use_item_0"
			const SECONDARY := "player_use_item_1"

			static func register_inputs() -> void:
				ProjectInput.new(PRIMARY).bind_mouse_button(MOUSE_BUTTON_LEFT)
				ProjectInput.new(SECONDARY).bind_mouse_button(
					MOUSE_BUTTON_RIGHT
				)

			static func unregister_inputs() -> void:
				ProjectInput.remove(PRIMARY)
				ProjectInput.remove(SECONDARY)

		static func register_inputs() -> void:
			Drop.register_inputs()
			Scroll.register_inputs()
			Use.register_inputs()

		static func unregister_inputs() -> void:
			Drop.unregister_inputs()
			Scroll.unregister_inputs()
			Use.unregister_inputs()

	const SPRINT := "player_should_run"
	const JUMP := "player_jump"
	const CROUCH := "player_crouch"
	const INTERACT := "player_interact"

	static func register_inputs() -> void:
		Move.register_inputs()
		Look.register_inputs()
		Item.register_inputs()

		ProjectInput.new(SPRINT).bind_keycode(KEY_SHIFT)
		ProjectInput.new(JUMP).bind_keycode(KEY_SPACE)
		ProjectInput.new(CROUCH).bind_keycode(KEY_CTRL)
		ProjectInput.new(INTERACT).bind_keycode(KEY_E)

	static func unregister_inputs() -> void:
		Move.unregister_inputs()
		Look.unregister_inputs()
		Item.unregister_inputs()

		ProjectInput.remove(SPRINT)
		ProjectInput.remove(JUMP)
		ProjectInput.remove(CROUCH)
		ProjectInput.remove(INTERACT)


#
#	Public Static Functions
#


## Adds all applicable keys from this static class to the InputMap, so
## that player input can be read. This is intended to be called by the
## plugin setup process.
static func add_to_input_map() -> void:
	Player.register_inputs()
	ProjectSettings.save()


## Removes all applicable keys of this static class from the InputMap,
## so that player input is no longer being read. This is intended to be
## called by the plugin teardown process.
static func remove_from_input_map() -> void:
	Player.unregister_inputs()
	ProjectSettings.save()
