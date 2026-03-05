# scripts/Game.gd
# Root game scene: wires Player, EnemySpawner, handles game-over.
extends Node2D

const PROJECTILE_SCENE := preload("res://scenes/Projectile.tscn")
const ENEMY_SCENE := preload("res://scenes/Enemy.tscn")

@onready var _player: CharacterBody2D = $Player
@onready var _enemy_container: Node2D = $EnemyContainer
@onready var _projectile_container: Node2D = $ProjectileContainer
@onready var _enemy_spawner: Node = $EnemySpawner


func _ready() -> void:
	# Wire player dependencies.
	_player.projectile_scene = PROJECTILE_SCENE
	_player.projectile_container = _projectile_container
	_player.died.connect(_on_player_died)

	# Wire spawner dependencies.
	_enemy_spawner.enemy_scene = ENEMY_SCENE
	_enemy_spawner.enemy_container = _enemy_container
	_enemy_spawner.player = _player


func _on_player_died() -> void:
	# Phase 3: brief pause then return to main menu.
	# Phase 7 will replace this with the Results screen.
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
