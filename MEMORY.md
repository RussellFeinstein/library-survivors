# Library Survivors — Project Memory

This file is the persistent dev log and decision record for the project.
Update it at the end of every phase. It is NOT a user-facing doc.

---

## Project Identity

- **Engine**: Godot 4.3+ (GL Compatibility renderer, 2D)
- **Genre**: Survivors-like (top-down, auto-combat, upgrade drafting)
- **Theme**: Library (currencies: Crowns + Seals; tags: library-themed)
- **Run length**: 20 minutes max
- **Save file**: `user://save.json` via SaveManager autoload

---

## Locked Design Decisions

These are finalized and should not be revisited without a deliberate design change:

| Decision | Choice | Rationale |
|---|---|---|
| Aim input | Right stick first, mouse fallback | Clean dual-input; deadzone = 0.15 |
| Fire mode | Hold-to-fire | Natural for survivors; no micro-clicking |
| Secondary cap | 3 slots max | Drafting constraint, not technical |
| Upgrade draft | 3 cards, no skip (v1) | Forces meaningful choice |
| Currencies | Crowns (common) + Seals (milestone) | Separate spend tiers |
| Crown formula | `floor(duration_seconds / 30)` | Simple, scales with survival |
| First-win Seal | 1 Seal, milestone-gated | Prevents farming |
| Seed source | `Time.get_unix_time_from_system()` as int | Time-based, stored in run summary |
| Sprite size | Characters 24x24, projectiles 8x8–16x16 | Placeholder-friendly |
| Renderer | GL Compatibility | Lightweight for 2D |

---

## Phase Tracker

### Phase 1 — Project Skeleton ✅
**Completed**: 2026-03-04

Files created:
- `project.godot` — Godot 4.3 project, GL Compatibility renderer, 1280x720
- `README.md` — full architecture overview, controls, phase table
- `MEMORY.md` — this file
- `data/README.md` — schema stub for all JSON data files
- `.gitignore` — standard Godot 4 ignore rules
- Folder structure: `/scenes`, `/scripts`, `/ui`, `/data`, `/assets/placeholders`, `/autoload`

Outstanding: All scenes/scripts/data are stubs — nothing runnable yet.

---

### Phase 2 — Input Map + InputHelper 🔲
**Target files**:
- `project.godot` — add input actions: `move_up`, `move_down`, `move_left`, `move_right`, `aim_x` (axis), `aim_y` (axis), `fire_primary`, `confirm`, `cancel`, `pause`
- `scripts/InputHelper.gd` — autoload singleton:
  - `get_move_vector() -> Vector2`
  - `get_aim_vector(player_pos: Vector2) -> Vector2`
  - `is_confirm_pressed() -> bool`
  - `is_cancel_pressed() -> bool`
  - `is_pause_pressed() -> bool`
  - `is_fire_held() -> bool`

Notes:
- Right stick uses `Input.get_joy_axis(0, JOY_AXIS_RIGHT_X/Y)`
- Deadzone for stick aim: 0.15
- Mouse aim: `(get_global_mouse_position() - player_pos).normalized()`

---

### Phase 3 — Player, Enemy, core Game.tscn 🔲
**Target files**:
- `scenes/Game.tscn` — root scene with Player, EnemySpawner, Camera2D
- `scripts/Player.gd` — CharacterBody2D, move, aim, fire primary
- `scripts/Enemy.gd` — CharacterBody2D, chase player, contact damage
- `scripts/Projectile.gd` — Area2D, travel, pierce, hit enemy
- `scenes/MainMenu.tscn` — Start Run, Quit (controller navigable)

Player stats (from character data, Phase 6 finalizes):
- `max_hp`: 100, `move_speed`: 150, `damage_mult`: 1.0, `fire_rate_mult`: 1.0

Fire: holds `fire_primary`, projectile spawns at player position toward `get_aim_vector()`

---

### Phase 4 — XP / Leveling + HUD 🔲
**Target files**:
- `scripts/XpOrb.gd` — Area2D, moves toward player if within pickup_radius, grants XP on collect
- `ui/HUD.tscn` + `ui/HUD.gd` — HP bar, level label, XP bar, run timer, crown/seal count
- XP curve: `xp_to_next = 10 + (level * 5)` (simple linear, easy to tune)
- On level up: emit `level_up` signal → pause tree (Engine.time_scale = 0) → open draft

---

### Phase 5 — Upgrade Draft UI 🔲
**Target files**:
- `ui/UpgradeDraft.tscn` + `ui/UpgradeDraft.gd`
- `ui/UpgradeCard.tscn` (sub-scene for each card)
- 3 cards, left/right D-pad navigation, A to confirm, B blocked (no skip in v1)
- UpgradeManager.gd: pool filtering (no add_secondary if slots == 3), weighted random draw

---

### Phase 6 — Data Files + Weapon System 🔲
**Target files**:
- `data/tags.json`, `data/characters.json`, `data/weapons_primary.json`
- `data/weapons_secondary.json`, `data/upgrades.json`
- `autoload/GameData.gd` — loads + caches all JSON at startup
- `scripts/WeaponPrimary.gd` — fires projectiles, respects cooldown_mult, projectile_count, spread, pierce
- `scripts/WeaponSecondary.gd` — auto-triggers on cooldown, behavior varies by type

Secondary weapon types (3 to start):
- `tome_volley` — burst of projectiles around player
- `ward_shield` — orbiting hitbox (area + duration)
- `recall_bolt` — homing projectile

---

### Phase 7 — Save System + Results + Wire-up 🔲
**Target files**:
- `autoload/SaveManager.gd`
- `scenes/Results.tscn` — shows result, crowns, seals, Return to Menu
- `scripts/RunState.gd` — seed, timer, crown/seal tallying, emits `run_ended`
- Wire Game → Results → MainMenu flow

Crown formula: `floor(duration_seconds / 30)`
Seal rule: 1 Seal on first-ever win (`milestones.first_win_awarded`)

---

### Phase 8 — Polish + README Sync 🔲
- Verify all README counts, controls, file list are accurate
- Test full run loop (KBM + simulated controller)
- Fix any cross-phase wiring gaps

---

## Known Gotchas / Watch-outs

- Godot 4 `Engine.time_scale = 0` pauses AnimationPlayer and physics — resume with `= 1.0` after draft close
- `Input.get_joy_axis()` uses device index 0 — fine for single player
- `user://save.json` path resolves differently on Windows vs Linux; Godot handles this automatically
- JSON loading in Godot 4: use `FileAccess.open()` + `JSON.parse_string()`, not the Godot 3 API
- Input actions must be registered in `project.godot` before `InputHelper.gd` can read them
- Secondary slot cap check must happen in UpgradeManager before rolling the draft pool, not after

---

## Data Schema Quick Reference

(Full schema in `data/README.md`)

**Upgrade effect types**: `stat_add`, `primary_mod`, `add_secondary`, `secondary_mod`

**Rarity values**: `"common"`, `"uncommon"`, `"rare"`

**Tag IDs**: `Bindings`, `Marginalia`, `Illumination`, `Indexing`, `Preservation`, `Circulation`, `Curation`, `Restricted`
