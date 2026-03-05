# scripts/Game.gd
# Root game scene: the central "wiring room" that connects every major system.
#
# Design rule: scripts never reference each other directly.  Instead, Game.gd
# injects every dependency in _ready() so each subsystem stays decoupled:
#
#   Player    — doesn't know which projectile scene to use or which container
#               to add children to.  Game.gd owns those and hands them over.
#   Spawner   — doesn't know the player's position, which enemy scene to use,
#               or where to parent enemies.  Game.gd provides all of that.
#   Enemy     — doesn't preload XpOrb.tscn; it receives the scene + container
#               from Game → Spawner → Enemy so the orb type is swappable.
#   HUD       — receives a player reference to poll HP/XP/level each frame.
#   Draft     — receives a list of upgrade dicts from UpgradeManager; emits
#               upgrade_chosen when the player picks one.
extends Node2D

const PROJECTILE_SCENE := preload("res://scenes/Projectile.tscn")
const ENEMY_SCENE      := preload("res://scenes/Enemy.tscn")
const XP_ORB_SCENE     := preload("res://scenes/XpOrb.tscn")

@onready var _player: CharacterBody2D      = $Player
@onready var _enemy_container: Node2D      = $EnemyContainer
@onready var _projectile_container: Node2D = $ProjectileContainer
@onready var _xp_orb_container: Node2D    = $XpOrbContainer
@onready var _enemy_spawner: Node          = $EnemySpawner
@onready var _hud                          = $HUD
@onready var _upgrade_manager: Node        = $UpgradeManager
@onready var _upgrade_draft                = $UpgradeDraft

# Guard against a second level-up signal firing while the draft is still open.
# (Possible if an XP orb contacts the player during the time-scale=0 pause.)
var _draft_open: bool = false


func _ready() -> void:
	Input.set_custom_mouse_cursor(_make_crosshair(), Input.CURSOR_ARROW, Vector2(16.0, 16.0))

	# ---- Player dependencies ----------------------------------------
	_player.projectile_scene     = PROJECTILE_SCENE
	_player.projectile_container = _projectile_container
	_player.died.connect(_on_player_died)
	_player.level_up.connect(_on_player_level_up)

	# ---- Spawner dependencies ---------------------------------------
	_enemy_spawner.enemy_scene     = ENEMY_SCENE
	_enemy_spawner.enemy_container = _enemy_container
	_enemy_spawner.player          = _player
	_enemy_spawner.xp_orb_scene   = XP_ORB_SCENE
	_enemy_spawner.xp_container   = _xp_orb_container

	# ---- HUD --------------------------------------------------------
	_hud.set_player(_player)


# TODO: replace with a real crosshair asset once art is available.
# Load it with: Input.set_custom_mouse_cursor(load("res://assets/crosshair.png"), ...)
func _make_crosshair() -> ImageTexture:
	const SIZE   := 32
	const CENTER := 15   # pixel index of centre (0-based)
	const GAP    := 4    # blank pixels each side of centre
	var img := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	for i in range(SIZE):
		if i < CENTER - GAP or i > CENTER + GAP:
			img.set_pixel(i, CENTER, Color.WHITE)  # horizontal
			img.set_pixel(CENTER, i, Color.WHITE)  # vertical
	return ImageTexture.create_from_image(img)


func _on_player_died() -> void:
	# Phase 7 will replace this with the Results screen.
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _on_player_level_up(new_level: int) -> void:
	if _draft_open:
		return  # skip if a draft is already showing
	_draft_open = true

	# Freeze the game world (physics + process deltas become 0).
	Engine.time_scale = 0.0
	_hud.show_level_up(new_level)

	# Show 3 random upgrades and wait for the player to pick one.
	var upgrades := _upgrade_manager.draft(3)
	_upgrade_draft.setup(upgrades)
	_upgrade_draft.visible = true

	# await suspends this coroutine until the player presses a card.
	# UpgradeDraft.gd has process_mode = ALWAYS so it receives input
	# even while Engine.time_scale = 0.
	var chosen_id: String = await _upgrade_draft.upgrade_chosen

	_upgrade_draft.visible = false
	_hud.hide_level_up()
	_upgrade_manager.apply(chosen_id, _player)
	Engine.time_scale = 1.0
	_draft_open = false
