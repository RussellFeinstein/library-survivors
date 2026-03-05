# scripts/EnemySpawner.gd
# Spawns enemies at random positions around the player, increasing rate over time.
extends Node

const SPAWN_RADIUS_MIN := 350.0
const SPAWN_RADIUS_MAX := 500.0
const MAX_ENEMIES := 50

var enemy_scene: PackedScene = null
var enemy_container: Node2D = null
var player: Node2D = null

var _spawn_timer: float = 2.0   # grace period before the first spawn
var _spawn_interval: float = 3.0
var _elapsed: float = 0.0


func _process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return
	if enemy_scene == null or enemy_container == null:
		return

	_elapsed += delta
	# Every 30 s reduce interval by 0.2 s, floored at 0.5 s.
	_spawn_interval = max(0.5, 3.0 - floor(_elapsed / 30.0) * 0.2)

	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = _spawn_interval
		_spawn_enemy()


func _spawn_enemy() -> void:
	if enemy_container.get_child_count() >= MAX_ENEMIES:
		return
	var angle := randf() * TAU
	var dist := randf_range(SPAWN_RADIUS_MIN, SPAWN_RADIUS_MAX)
	var spawn_pos := player.global_position + Vector2(cos(angle), sin(angle)) * dist
	var enemy: Node2D = enemy_scene.instantiate()
	enemy.global_position = spawn_pos
	enemy_container.add_child(enemy)
