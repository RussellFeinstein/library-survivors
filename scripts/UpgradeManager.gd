# scripts/UpgradeManager.gd
# Inline upgrade pool for Phase 5.
# Phase 6 replaces UPGRADES with data loaded from data/upgrades.json via GameData.
#
# Effects:
#   {stat = "move_speed",     mult = 1.2}   – multiply the stat
#   {stat = "max_hp",         add  = 25}    – add to the stat (max_hp also heals)
#   {stat = "fire_rate_mult", mult = 1.25}  – multiply
#   {stat = "damage_mult",    mult = 1.2}   – multiply
extends Node

const UPGRADES: Array = [
	{id = "fleet_footed",   name = "Fleet Footed",   rarity = "common", tags = ["mobility"],
		desc = "Move 20% faster.",
		effect = {stat = "move_speed",     mult = 1.2}},
	{id = "tough_cover",    name = "Tough Cover",    rarity = "common", tags = ["survival"],
		desc = "Gain +25 max HP.",
		effect = {stat = "max_hp",         add  = 25}},
	{id = "quick_draw",     name = "Quick Draw",     rarity = "common", tags = ["offense"],
		desc = "Fire 25% faster.",
		effect = {stat = "fire_rate_mult", mult = 1.25}},
	{id = "sharp_quill",    name = "Sharp Quill",    rarity = "common", tags = ["offense"],
		desc = "Projectiles deal 20% more damage.",
		effect = {stat = "damage_mult",    mult = 1.2}},
	{id = "iron_binding",   name = "Iron Binding",   rarity = "rare",   tags = ["survival"],
		desc = "Gain +50 max HP.",
		effect = {stat = "max_hp",         add  = 50}},
	{id = "overdrive",      name = "Overdrive",      rarity = "rare",   tags = ["mobility"],
		desc = "Move 40% faster.",
		effect = {stat = "move_speed",     mult = 1.4}},
	{id = "rapid_fire",     name = "Rapid Fire",     rarity = "rare",   tags = ["offense"],
		desc = "Fire 50% faster.",
		effect = {stat = "fire_rate_mult", mult = 1.5}},
	{id = "ink_surge",      name = "Ink Surge",      rarity = "rare",   tags = ["offense"],
		desc = "Projectiles deal 40% more damage.",
		effect = {stat = "damage_mult",    mult = 1.4}},
	{id = "lethal_edition", name = "Lethal Edition", rarity = "epic",   tags = ["offense"],
		desc = "Projectiles deal double damage.",
		effect = {stat = "damage_mult",    mult = 2.0}},
	{id = "overclocked",    name = "Overclocked",    rarity = "epic",   tags = ["offense"],
		desc = "Fire twice as fast.",
		effect = {stat = "fire_rate_mult", mult = 2.0}},
	{id = "phantom_step",   name = "Phantom Step",   rarity = "epic",   tags = ["mobility"],
		desc = "Move 60% faster.",
		effect = {stat = "move_speed",     mult = 1.6}},
]


## Returns up to `count` unique upgrade dicts, randomly chosen from the pool.
func draft(count: int) -> Array:
	var pool: Array = UPGRADES.duplicate()
	pool.shuffle()
	return pool.slice(0, min(count, pool.size()))


## Applies the named upgrade's effect to `player`.
func apply(upgrade_id: String, player: Node) -> void:
	for upg: Dictionary in UPGRADES:
		if upg.get("id") == upgrade_id:
			_apply_effect(upg.get("effect", {}), player)
			return


func _apply_effect(effect: Dictionary, player: Node) -> void:
	var stat: String = effect.get("stat", "")
	if stat.is_empty():
		return
	if effect.has("add"):
		player.set(stat, player.get(stat) + effect.add)
		# Heal the same amount when increasing max_hp.
		if stat == "max_hp":
			player.hp = min(player.hp + effect.add, player.max_hp)
	elif effect.has("mult"):
		player.set(stat, player.get(stat) * effect.mult)
