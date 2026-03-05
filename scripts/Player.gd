# scripts/Player.gd
# CharacterBody2D: player movement (via InputHelper), primary fire, and HP.
#
# All stats are public vars so Game.gd (and later GameData) can override them
# when applying a character definition. For Phase 3 the defaults match the
# "Librarian" character spec in MEMORY.md; Phase 6 replaces them from JSON.
extends CharacterBody2D

signal died
signal took_damage(amount: int)

# ---- Stats (set from outside before first physics tick) ----
var max_hp: int = 100
var hp: int = 100
var move_speed: float = 150.0
var damage_mult: float = 1.0
var fire_rate_mult: float = 1.0
## Base seconds between shots. Actual cooldown = base_fire_cooldown / fire_rate_mult.
## Phase 6: set this from the primary weapon definition loaded by GameData.
var base_fire_cooldown: float = 0.4

# ---- Dependencies (set by Game.gd before first physics tick) ----
var projectile_scene: PackedScene = null
var projectile_container: Node = null

# ---- Private ----
var _fire_timer: float = 0.0
var _aim_dir: Vector2 = Vector2.RIGHT


func _ready() -> void:
	add_to_group("player")


func _physics_process(delta: float) -> void:
	# Movement
	velocity = InputHelper.get_move_vector() * move_speed
	move_and_slide()

	# Aim: preserve last non-zero direction so the player keeps facing on idle stick.
	var aim := InputHelper.get_aim_vector(global_position)
	if aim.length_squared() > 0.01:
		_aim_dir = aim

	# Primary fire on hold
	_fire_timer -= delta
	if InputHelper.is_fire_held() and _fire_timer <= 0.0:
		_fire()
		_fire_timer = base_fire_cooldown / fire_rate_mult


func _fire() -> void:
	if projectile_scene == null or projectile_container == null:
		return
	var proj: Node2D = projectile_scene.instantiate()
	proj.global_position = global_position
	proj.setup(_aim_dir, int(10.0 * damage_mult), 1)
	projectile_container.add_child(proj)


func take_damage(amount: int) -> void:
	if hp <= 0:
		return
	hp = max(0, hp - amount)
	emit_signal("took_damage", amount)
	if hp == 0:
		_die()


func _die() -> void:
	# Phase 4+: play death animation, freeze input, etc. before emitting.
	emit_signal("died")
