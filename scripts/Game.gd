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
extends Node2D

const PROJECTILE_SCENE := preload("res://scenes/Projectile.tscn")
const ENEMY_SCENE      := preload("res://scenes/Enemy.tscn")
const XP_ORB_SCENE     := preload("res://scenes/XpOrb.tscn")

@onready var _player: CharacterBody2D      = $Player
@onready var _enemy_container: Node2D      = $EnemyContainer
@onready var _projectile_container: Node2D = $ProjectileContainer
@onready var _xp_orb_container: Node2D    = $XpOrbContainer
@onready var _enemy_spawner: Node          = $EnemySpawner
@onready var _hud                          = $HUD   # CanvasLayer with HUD.gd


func _ready() -> void:
	Input.set_custom_mouse_cursor(_make_crosshair(), Input.CURSOR_ARROW, Vector2(16.0, 16.0))

	# ---- Player dependencies ----------------------------------------
	# projectile_scene: Player._fire() calls .instantiate() on this.
	#   Null-checked inside Player, so if missing the player just can't fire.
	#   Game.gd owns the scene so Phase 6 can swap in a weapon-specific scene.
	# projectile_container: bullets are parented here, NOT under the player —
	#   if they were children of Player they would move with the player.
	_player.projectile_scene     = PROJECTILE_SCENE
	_player.projectile_container = _projectile_container
	# Signals: Player emits, Game.gd decides what those events cause.
	#   .died      → route to game-over / results
	#   .level_up  → pause physics, show upgrade draft (Phase 5), then resume
	_player.died.connect(_on_player_died)
	_player.level_up.connect(_on_player_level_up)

	# ---- Spawner dependencies ---------------------------------------
	# enemy_scene / enemy_container: spawner instantiates and parents enemies;
	#   Game.gd owns both so the spawner needs zero scene-tree knowledge.
	# player: spawner places enemies 350–500 px from player.global_position and
	#   guards with is_instance_valid(player) to stop when the player is gone.
	# xp_orb_scene / xp_container: injected from Game → Spawner → Enemy.
	#   Enemy receives them before add_child so it can drop XP in _die().
	#   Passing the scene rather than preloading in Enemy.gd keeps Enemy
	#   decoupled — a future elite enemy type could receive a different orb
	#   scene with zero Enemy.gd changes.
	_enemy_spawner.enemy_scene     = ENEMY_SCENE
	_enemy_spawner.enemy_container = _enemy_container
	_enemy_spawner.player          = _player
	_enemy_spawner.xp_orb_scene   = XP_ORB_SCENE
	_enemy_spawner.xp_container   = _xp_orb_container

	# ---- HUD --------------------------------------------------------
	# Give the HUD a player reference so it can poll hp/xp/level each frame
	# without requiring extra signals on the Player.
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
	# Setting time_scale = 0 freezes all delta-based nodes (physics, _process
	# with normal delta) so the world is truly paused.
	# Phase 5 will open the upgrade draft here; for Phase 4 we show a banner
	# and auto-resume after 1 real second.
	Engine.time_scale = 0.0
	_hud.show_level_up(new_level)
	# ignore_time_scale = true (4th arg) makes the timer run in real time
	# even while time_scale = 0, so we don't wait forever.
	await get_tree().create_timer(1.0, true, false, true).timeout
	_hud.hide_level_up()
	Engine.time_scale = 1.0
