# scripts/Projectile.gd
# Area2D: travels in a fixed direction, damages enemies on contact, respects pierce count.
extends Area2D

const SPEED := 400.0
const LIFETIME := 3.0  # auto-despawn after this many seconds

var _direction: Vector2 = Vector2.RIGHT
var _damage: int = 10
var _pierce: int = 1
var _life: float = 0.0
var _hit_bodies: Array = []  # prevents double-hitting the same enemy per projectile


func setup(direction: Vector2, damage: int, pierce: int) -> void:
	_direction = direction.normalized()
	_damage = damage
	_pierce = pierce


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position += _direction * SPEED * delta
	_life += delta
	if _life >= LIFETIME:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("enemies"):
		return
	if body in _hit_bodies:
		return
	_hit_bodies.append(body)
	if body.has_method("take_damage"):
		body.take_damage(_damage)
	_pierce -= 1
	if _pierce <= 0:
		queue_free()
