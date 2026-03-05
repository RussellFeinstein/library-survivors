# scripts/XpOrb.gd
# Area2D: floats in place; drifts toward the player when within pickup_radius;
# calls Player.add_xp() and frees itself on contact.
# pickup_radius and move_speed are vars so upgrades can modify them at runtime.
extends Area2D

var pickup_radius: float = 200.0   # px — start homing once player is this close
var move_speed: float    = 50.0   # px/s — base speed when homing toward player

var xp_value: int = 1

var _player: Node2D = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Deferred so the Player node is fully in the "player" group first.
	call_deferred("_find_player")


func _find_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_player = players[0] as Node2D


func _process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return

	# Causes XP Orbs to accelerate
	var dist := global_position.distance_to(_player.global_position)
	if dist <= pickup_radius:
		var dir := (_player.global_position - global_position).normalized()
		var t := 1.0 - (dist / pickup_radius)          # 0 at edge, 1 at player
		var speed := move_speed * (1.0 + t * t * 14.0)  # cubic: slow cruise, hard snap at end
		global_position += dir * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if body.has_method("add_xp"):
		body.add_xp(xp_value)
	queue_free()
