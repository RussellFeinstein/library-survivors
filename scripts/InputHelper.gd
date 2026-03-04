# scripts/InputHelper.gd
# Autoload singleton — registered in Project Settings as "InputHelper".
# Access globally: InputHelper.get_move_vector(), etc.
#
# Aim approach: right stick (JOY_AXIS_RIGHT_X/Y) is checked first.
#   If stick magnitude < AIM_DEADZONE (0.15), aim falls back to mouse direction
#   computed from world-space mouse position relative to player_pos.
#
# Move approach: left stick (JOY_AXIS_LEFT_X/Y) is checked first with
#   MOVE_DEADZONE (0.15). Falls back to WASD via Input.get_axis().

extends Node

const MOVE_DEADZONE := 0.15
const AIM_DEADZONE  := 0.15


func get_move_vector() -> Vector2:
	# Left analog stick takes priority for smooth analog movement.
	var stick := Vector2(
		Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	)
	if stick.length() > MOVE_DEADZONE:
		return stick.limit_length(1.0)
	# Keyboard fallback — returns values in [-1, 1] per axis.
	return Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)


func get_aim_vector(player_pos: Vector2) -> Vector2:
	# Right analog stick takes priority.
	var stick := Vector2(
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	)
	if stick.length() > AIM_DEADZONE:
		return stick.normalized()
	# Mouse fallback: convert viewport mouse position to world coordinates via
	# the inverse of the canvas transform (accounts for Camera2D offset).
	var vp := get_viewport()
	if vp:
		var world_mouse: Vector2 = vp.get_canvas_transform().affine_inverse() \
				* vp.get_mouse_position()
		var dir := world_mouse - player_pos
		if dir.length_squared() > 1.0:
			return dir.normalized()
	return Vector2.RIGHT  # Safe default: aim right.


func is_fire_held() -> bool:
	return Input.is_action_pressed("fire_primary")


func is_confirm_pressed() -> bool:
	return Input.is_action_just_pressed("confirm")


func is_cancel_pressed() -> bool:
	return Input.is_action_just_pressed("cancel")


func is_pause_pressed() -> bool:
	return Input.is_action_just_pressed("pause")
