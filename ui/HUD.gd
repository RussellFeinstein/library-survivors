# ui/HUD.gd
# Heads-up display: HP bar, XP bar, level label, run timer, "LEVEL UP!" banner.
#
# Design notes:
#   - process_mode = PROCESS_MODE_ALWAYS so the banner timer ticks even while
#     Engine.time_scale = 0 (level-up pause). The run timer uses delta which is
#     0 when time_scale = 0, so it naturally freezes during the pause.
#   - Game.gd calls set_player() once in _ready(), then calls show_level_up() /
#     hide_level_up() around the pause window. The XP/HP bars are polled each
#     frame from the player reference — no extra signals needed in Phase 4.
extends CanvasLayer

@onready var _hp_bar: ProgressBar = $VBoxContainer/TopRow/HpBar
@onready var _xp_bar: ProgressBar = $VBoxContainer/XpBar
@onready var _level_label: Label   = $VBoxContainer/TopRow/LevelLabel
@onready var _timer_label: Label   = $VBoxContainer/TopRow/TimerLabel
@onready var _level_up_label: Label = $LevelUpLabel

var _player: Node2D = null
var _elapsed: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_level_up_label.visible = false


func set_player(p: Node2D) -> void:
	_player = p
	# Initialise bars to the player's starting state immediately.
	if _player:
		_hp_bar.max_value = _player.max_hp
		_hp_bar.value     = _player.hp
		_xp_bar.max_value = _player.xp_to_next
		_xp_bar.value     = _player.xp
		_level_label.text = "LVL %d" % _player.level


func _process(delta: float) -> void:
	# delta is 0 when Engine.time_scale = 0, so the timer pauses automatically.
	_elapsed += delta
	_timer_label.text = _format_time(_elapsed)

	if _player == null or not is_instance_valid(_player):
		return

	_hp_bar.max_value = _player.max_hp
	_hp_bar.value     = _player.hp
	_xp_bar.max_value = _player.xp_to_next
	_xp_bar.value     = _player.xp
	_level_label.text = "LVL %d" % _player.level


func show_level_up(new_level: int) -> void:
	_level_up_label.text    = "LEVEL UP! → %d" % new_level
	_level_up_label.visible = true


func hide_level_up() -> void:
	_level_up_label.visible = false


func _format_time(seconds: float) -> String:
	var s := int(seconds)
	return "%02d:%02d" % [s / 60, s % 60]
