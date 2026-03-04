# Data File Schemas

All files in this directory are loaded at runtime by `autoload/GameData.gd`.
Edit these files to add content without touching GDScript.

---

## tags.json

Array of tag definition objects.

```json
[
  { "id": "Bindings",     "desc": "Relates to physical structure and binding of books." },
  { "id": "Marginalia",   "desc": "Notes and annotations in the margins." },
  ...
]
```

| Field | Type   | Required | Notes                     |
|-------|--------|----------|---------------------------|
| id    | string | yes      | Unique. Used in upgrade tags array. |
| desc  | string | yes      | Flavor text only.         |

---

## characters.json

Array of playable character definitions.

```json
[
  {
    "id": "librarian",
    "name": "The Librarian",
    "desc": "Keeper of the stacks.",
    "primary_weapon_id": "quill_shot",
    "base_stats": {
      "max_hp": 100,
      "move_speed": 150.0,
      "damage_mult": 1.0,
      "fire_rate_mult": 1.0,
      "pickup_radius": 40.0
    },
    "sprite": "res://assets/placeholders/librarian.png"
  }
]
```

| Field             | Type   | Required | Notes                                        |
|-------------------|--------|----------|----------------------------------------------|
| id                | string | yes      | Unique. Used in save `unlocked_character_ids`.|
| name              | string | yes      |                                              |
| desc              | string | yes      | Flavor text.                                 |
| primary_weapon_id | string | yes      | Must match an entry in `weapons_primary.json`.|
| base_stats        | object | yes      | See stat keys below.                         |
| sprite            | string | yes      | `res://` path to placeholder texture.        |

**Stat keys**: `max_hp`, `move_speed`, `damage_mult`, `fire_rate_mult`, `pickup_radius`

---

## weapons_primary.json

Array of primary weapon definitions.

```json
[
  {
    "id": "quill_shot",
    "name": "Quill Shot",
    "desc": "Fires a sharp quill toward the aimed direction.",
    "base_damage": 12,
    "base_cooldown": 0.5,
    "projectile_count": 1,
    "pierce": 0,
    "spread_deg": 0.0,
    "projectile_speed": 400.0,
    "projectile_sprite": "res://assets/placeholders/projectile_8x8.png"
  }
]
```

| Field             | Type   | Required | Notes                                        |
|-------------------|--------|----------|----------------------------------------------|
| id                | string | yes      | Unique.                                      |
| name              | string | yes      |                                              |
| base_damage       | int    | yes      | Before `damage_mult` is applied.             |
| base_cooldown     | float  | yes      | Seconds between shots.                       |
| projectile_count  | int    | yes      | Projectiles fired per shot.                  |
| pierce            | int    | yes      | Extra enemies a projectile passes through.   |
| spread_deg        | float  | yes      | Total spread cone in degrees (0 = straight). |
| projectile_speed  | float  | yes      | Pixels per second.                           |
| projectile_sprite | string | yes      | `res://` path.                               |

---

## weapons_secondary.json

Array of secondary weapon definitions (auto-trigger, slot-equipped).

```json
[
  {
    "id": "tome_volley",
    "name": "Tome Volley",
    "desc": "Bursts pages in all directions around the player.",
    "type": "volley",
    "base_damage": 8,
    "base_cooldown": 2.5,
    "projectile_count": 8,
    "projectile_speed": 300.0,
    "radius": 0.0,
    "duration": 0.0,
    "sprite": "res://assets/placeholders/secondary_tome.png"
  }
]
```

| Field            | Type   | Required | Notes                                              |
|------------------|--------|----------|----------------------------------------------------|
| id               | string | yes      | Unique.                                            |
| name             | string | yes      |                                                    |
| type             | string | yes      | `"volley"`, `"orbit"`, `"homing"` — governs behavior in `WeaponSecondary.gd`. |
| base_damage      | int    | yes      |                                                    |
| base_cooldown    | float  | yes      | Seconds between activations.                       |
| projectile_count | int    | yes      | Projectiles per activation (0 if not applicable).  |
| projectile_speed | float  | yes      |                                                    |
| radius           | float  | yes      | Orbit radius in pixels (0 if not used).            |
| duration         | float  | yes      | Active duration in seconds (0 if not used).        |

---

## upgrades.json

Array of upgrade definitions. At least 18 required for v1.

```json
[
  {
    "id": "sturdy_binding",
    "name": "Sturdy Binding",
    "desc": "Reinforced covers add resilience. +20 max HP.",
    "rarity": "common",
    "tags": ["Bindings", "Preservation"],
    "weight": 10,
    "effect": {
      "type": "stat_add",
      "stat": "max_hp",
      "value": 20
    },
    "requires": null
  }
]
```

| Field    | Type         | Required | Notes                                                          |
|----------|--------------|----------|----------------------------------------------------------------|
| id       | string       | yes      | Unique.                                                        |
| name     | string       | yes      |                                                                |
| desc     | string       | yes      |                                                                |
| rarity   | string       | yes      | `"common"`, `"uncommon"`, or `"rare"`                          |
| tags     | string[]     | yes      | 1–2 tag IDs from `tags.json`.                                  |
| weight   | int          | yes      | Higher = more likely to appear in draft pool.                  |
| effect   | object       | yes      | See effect payload schemas below.                              |
| requires | string\|null | yes      | Upgrade `id` that must be owned first, or `null`.              |

### Effect Payload Schemas

#### A) stat_add
```json
{ "type": "stat_add", "stat": "<stat_key>", "value": <number> }
```
`stat` values: `max_hp`, `move_speed`, `damage_mult`, `fire_rate_mult`, `pickup_radius`

#### B) primary_mod
```json
{ "type": "primary_mod", "mod": "<mod_key>", "value": <number> }
```
`mod` values: `projectile_count_add`, `pierce_add`, `spread_deg_add`, `cooldown_mult`

#### C) add_secondary
```json
{ "type": "add_secondary", "weapon_id": "<secondary_id>" }
```
Only eligible if player has fewer than 3 secondary slots filled. `weapon_id` must match `weapons_secondary.json`.

#### D) secondary_mod
```json
{ "type": "secondary_mod", "weapon_id": "<secondary_id>", "mod": "<mod_key>", "value": <number> }
```
`mod` values: `damage_mult`, `cooldown_mult`, `projectile_count_add`, `radius_add`, `duration_add`

---

## Planned Content (v1 target)

| File                  | Count  | Breakdown                                          |
|-----------------------|--------|----------------------------------------------------|
| tags.json             | 8      | All 8 library tags                                 |
| characters.json       | 1      | librarian                                          |
| weapons_primary.json  | 1      | quill_shot                                         |
| weapons_secondary.json| 3      | tome_volley, ward_shield, recall_bolt              |
| upgrades.json         | 18     | 6 stat_add, 6 primary_mod, 3 add_secondary, 3 secondary_mod |
