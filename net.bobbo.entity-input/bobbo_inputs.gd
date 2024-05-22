class_name BobboInputs
extends RefCounted


class Player:
	class Move:
		const FORWARD := "player_move_forward"
		const BACKWARD := "player_move_back"
		const LEFT := "player_move_left"
		const RIGHT := "player_move_right"

		static var axis := InputAxis2d.new(
			InputAxis1d.new(LEFT, RIGHT), InputAxis1d.new(FORWARD, BACKWARD)
		)

	class Look:
		const UP := "player_look_up"
		const DOWN := "player_look_down"
		const LEFT := "player_look_left"
		const RIGHT := "player_look_right"

		static var axis := InputAxis2d.new(
			InputAxis1d.new(LEFT, RIGHT), InputAxis1d.new(DOWN, UP)
		)

	class Item:
		class Drop:
			const STACK := "player_drop_item_stack"
			const SINGLE := "player_drop_item_single"

		class Scroll:
			const FORWARD := "player_scroll_item_forward"
			const BACKWARD := "player_scroll_item_back"

		class Use:
			const PRIMARY := "player_use_item_0"
			const SECONDARY := "player_use_item_1"

	const SPRINT := "player_should_run"
	const JUMP := "player_jump"
	const CROUCH := "player_crouch"
	const INTERACT := "player_interact"
