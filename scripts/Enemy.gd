# scripts/Enemy.gd
# CharacterBody2D: chases the player and deals contact damage via slide collision.
#
# Stats are public vars so EnemySpawner (or later a wave config) can vary them
# per enemy type. Phase 3 uses one type; future phases add variants.
extends CharacterBody2D

const CONTACT_COOLDOWN_MAX := 1.0  # seconds between contact damage applications

var hp: int = 30
var move_speed: float = 60.0
var damage: int = 10

var _player: Node2D = null
var _contact_cooldown: float = 0.0


func _ready() -> void:
	add_to_group("enemies")
	# Deferred so the Player node is already in the "player" group when we search.
	call_deferred("_find_player")


func _find_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_player = players[0] as Node2D


func _physics_process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return

	# Chase the player.
	var dir := (_player.global_position - global_position).normalized()
	velocity = dir * move_speed
	move_and_slide()

	# Contact damage: fires once per CONTACT_COOLDOWN_MAX when colliding with player.
	_contact_cooldown -= delta
	if _contact_cooldown <= 0.0:
		for i in get_slide_collision_count():
			var collider := get_slide_collision(i).get_collider()
			if collider == _player:
				_player.take_damage(damage)
				_contact_cooldown = CONTACT_COOLDOWN_MAX
				break


func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		_die()


func _die() -> void:
	# Phase 4: spawn XP orb here before freeing.
	queue_free()
