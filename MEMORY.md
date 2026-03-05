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

### Phase 2 — Input Map + InputHelper ✅
**Completed**: 2026-03-04

Files created/modified:
- `project.godot` — added 8 input actions + `[autoload]` for InputHelper + version bumped to 0.2.0
- `scripts/InputHelper.gd` — autoload singleton with all documented methods

Input actions registered:
- `move_up` / `move_down` / `move_left` / `move_right`: keyboard only (W/A/S/D)
  - Analog stick movement is handled directly in `get_move_vector()` via `Input.get_joy_axis()`
  - Reason: action-based analog via `Input.get_axis()` loses full range above deadzone threshold
- `fire_primary`: left mouse button, Space, right trigger (JoypadMotion axis 5)
- `confirm`: Enter, A button (JoypadButton 0)
- `cancel`: Escape, B button (JoypadButton 1)
- `pause`: P, Escape, Start button (JoypadButton 6)
  - Escape is on both `cancel` and `pause` intentionally; context determines which fires

InputHelper decisions:
- `get_move_vector()`: left stick (JOY_AXIS_LEFT_X/Y) first, WASD fallback
- `get_aim_vector(player_pos)`: right stick (JOY_AXIS_RIGHT_X/Y) first, mouse fallback
  - Mouse world position: `viewport.get_canvas_transform().affine_inverse() * viewport.get_mouse_position()`
  - This correctly accounts for Camera2D offset without needing a node reference
- No `aim_x`/`aim_y` action entries: right stick read directly, cleaner than action-based axis

---

### Phase 3 — Player, Enemy, core Game.tscn ✅
**Completed**: 2026-03-04

Files created:
- `scripts/MainMenu.gd` — grabs focus on StartButton; routes to Game or quit
- `scripts/Game.gd` — wires Player (projectile_scene, projectile_container, died signal) and EnemySpawner; handles game-over → MainMenu after 1.5s delay
- `scripts/Player.gd` — movement (InputHelper), hold-to-fire, take_damage/died, `_die()` hook for Phase 4
- `scripts/Enemy.gd` — chase AI, contact damage via slide collision, `_die()` hook for Phase 4 XP drop
- `scripts/Projectile.gd` — Area2D travel at 400px/s, pierce logic, 3s auto-despawn
- `scripts/EnemySpawner.gd` — timer-based spawn at 350–500px radius, ramps from 3s to 0.5s interval over time, caps at 50 enemies
- `scenes/MainMenu.tscn` — Node2D + CanvasLayer + CenterContainer + VBoxContainer; controller navigable
- `scenes/Game.tscn` — root Game (Node2D) with inline Player, Camera2D child of Player, EnemyContainer, ProjectileContainer, EnemySpawner
- `scenes/Enemy.tscn` — CharacterBody2D, layer 2, mask 1, CircleShape2D r=12, red Polygon2D
- `scenes/Projectile.tscn` — Area2D, layer 4, mask 2, CircleShape2D r=5, yellow Polygon2D

Key decisions made this phase:
- **Player stats as vars** — `max_hp`, `move_speed`, `damage_mult`, `fire_rate_mult`, `base_fire_cooldown` are all public vars, not consts. Game.gd (Phase 6: GameData) applies character JSON values before first physics tick.
- **Enemy death**: `_die()` private method called when hp ≤ 0. Does `queue_free()` now; Phase 4 adds XP orb spawn inside `_die()`.
- **Contact damage**: Enemy checks `get_slide_collision_count()` each frame for Player collider; fires once per 1.0s via cooldown. Avoids Area2D complexity.
- **Collision layers**: Player=1/mask=2, Enemy=2/mask=1, Projectile=4/mask=2. Enemies don't collide with each other (mask doesn't include layer 2) so they pile/overlap — intended for Phase 3.
- **Camera2D as child of Player**: auto-follows with position_smoothing=true, speed=5. No Game.gd camera logic needed.
- **No pause in Phase 3**: Escape only fires `cancel`/`pause` input actions; nothing handles them in Game scene. Phase 4+ adds pause menu.

---

### Phase 4 — XP / Leveling + HUD 🔲
**Target files**:
- `scripts/XpOrb.gd` — Area2D, moves toward player if within pickup_radius, grants XP on collect
- `ui/HUD.tscn` + `ui/HUD.gd` — HP bar, level label, XP bar, run timer, crown/seal count
- XP curve: `xp_to_next = 10 + (level * 5)` (simple linear, easy to tune)
- On level up: emit `level_up` signal → pause tree (Engine.time_scale = 0) → open draft

**Hook points already in Phase 3**:
- `Enemy._die()` — add XP orb spawn here
- `Player.took_damage` signal — connect to HUD HP bar update
- `Player.died` signal — already consumed by Game.gd

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

**Character application workflow** (confirmed Phase 3):
- `Game._ready()` applies character stats to Player vars before first physics tick
- Phase 6: `Game._ready()` reads from `GameData.characters["librarian"]` and sets:
  - `_player.max_hp`, `_player.hp`, `_player.move_speed`, `_player.damage_mult`, `_player.fire_rate_mult`, `_player.base_fire_cooldown`

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
- Area2D `body_entered` fires for CharacterBody2D when Area2D.collision_mask matches the body's collision_layer — verified for Projectile→Enemy detection

---

## Data Schema Quick Reference

(Full schema in `data/README.md`)

**Upgrade effect types**: `stat_add`, `primary_mod`, `add_secondary`, `secondary_mod`

**Rarity values**: `"common"`, `"uncommon"`, `"rare"`

**Tag IDs**: `Bindings`, `Marginalia`, `Illumination`, `Indexing`, `Preservation`, `Circulation`, `Curation`, `Restricted`
