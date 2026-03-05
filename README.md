# Library Survivors

A top-down 2D survivors-like prototype built in **Godot 4.x** with a library theme, controller-first UI, and data-driven content.

## How to Run

1. Install [Godot 4.6+](https://godotengine.org/download)
2. Open Godot, click **Import**, select this folder's `project.godot`
3. Press **F5** (or the Play button) to run

> Main scene: `res://scenes/MainMenu.tscn` → **Start Run** launches `Game.tscn`

---

## Controls

| Action         | Keyboard/Mouse        | Controller              |
|----------------|-----------------------|-------------------------|
| Move           | WASD                  | Left stick              |
| Aim            | Mouse cursor          | Right stick             |
| Fire primary   | Left click / Space    | Right trigger (RT)      |
| Confirm (UI)   | Enter                 | A (South button)        |
| Cancel (UI)    | Escape                | B (East button)         |
| Pause          | Escape / P            | Start                   |

> Aim: right stick is checked first; if magnitude < 0.15 (deadzone), falls back to mouse-to-player direction.

> Fire mode: **hold-to-fire** — primary weapon fires continuously while held and cooldown has elapsed.

> Upgrade draft: use **d-pad / left stick** to move between the 3 cards, **A / Enter** to confirm.

---

## Architecture Overview

```
library-survivors/
├── project.godot              # Godot project config + input map
├── README.md                  # This file
├── MEMORY.md                  # Project phase tracker / dev notes
│
├── scenes/                    # .tscn scene files
│   ├── MainMenu.tscn          # [Phase 3] ✅ Start Run, Quit — controller navigable
│   ├── Game.tscn              # [Phase 5] ✅ Core gameplay root (+ UpgradeManager, UpgradeDraft)
│   ├── Enemy.tscn             # [Phase 3] ✅ Enemy scene (instanced by EnemySpawner)
│   ├── Projectile.tscn        # [Phase 3] ✅ Projectile scene (instanced by Player)
│   ├── XpOrb.tscn             # [Phase 4] ✅ XP orb scene (dropped by enemies on death)
│   └── Results.tscn           # [Phase 7] Win/lose + rewards
│
├── scripts/                   # GDScript files (logic only, no scene nodes)
│   ├── InputHelper.gd         # [Phase 2] ✅ Move/aim/confirm helpers (autoload)
│   ├── MainMenu.gd            # [Phase 3] ✅ Menu button wiring
│   ├── Game.gd                # [Phase 5] ✅ Wires all systems; draft flow on level_up
│   ├── Player.gd              # [Phase 4] ✅ Movement, HP, primary fire, XP/leveling
│   ├── Enemy.gd               # [Phase 4] ✅ Chase AI, contact damage, death, XP drop
│   ├── Projectile.gd          # [Phase 3] ✅ Travel, pierce, hit detection
│   ├── EnemySpawner.gd        # [Phase 4] ✅ Timed spawning; injects orb scene/container
│   ├── XpOrb.gd               # [Phase 4] ✅ Homing pickup, XP grant on contact
│   ├── UpgradeManager.gd      # [Phase 5] ✅ 11-upgrade inline pool; draft + apply
│   ├── WeaponPrimary.gd       # [Phase 6] Data-driven primary weapon
│   ├── WeaponSecondary.gd     # [Phase 6] Data-driven secondary weapon (auto)
│   └── RunState.gd            # [Phase 7] Seed, timer, currency tallying
│
├── ui/                        # UI scenes and scripts
│   ├── HUD.tscn               # [Phase 4] ✅ HP bar, XP bar, level label, run timer
│   ├── HUD.gd                 # [Phase 4] ✅ Polls player each frame; shows level-up banner
│   ├── UpgradeDraft.tscn      # [Phase 5] ✅ 3-card controller-navigable draft overlay
│   ├── UpgradeDraft.gd        # [Phase 5] ✅ Populates cards, emits upgrade_chosen signal
│   ├── UpgradeCard.tscn       # [Phase 5] ✅ Single card: name, desc, rarity, tags
│   └── UpgradeCard.gd         # [Phase 5] ✅ Fills card labels from an upgrade dict
│
├── autoload/                  # Singleton scripts (registered in Project Settings)
│   ├── SaveManager.gd         # [Phase 7] load/write save.json, run summaries
│   └── GameData.gd            # [Phase 6] Loads and caches all JSON data files
│
├── data/                      # JSON data files (runtime-loaded)
│   ├── README.md              # Schema documentation for all data files
│   ├── tags.json              # [Phase 6] 8 library-themed tags
│   ├── characters.json        # [Phase 6] Character definitions + base stats
│   ├── weapons_primary.json   # [Phase 6] Primary weapon definitions
│   ├── weapons_secondary.json # [Phase 6] Secondary weapon definitions
│   └── upgrades.json          # [Phase 6] 18+ upgrade definitions
│
└── assets/
    └── placeholders/          # 24x24 and 8x8–16x16 placeholder sprites
```

---

## Collision Layers

| Layer | Value | Used by            |
|-------|-------|--------------------|
| 1     | 1     | Player             |
| 2     | 2     | Enemies            |
| 3     | 4     | Player projectiles |
| 4     | 8     | XP orbs            |

---

## Upgrade Pool (Phase 5 — inline)

| ID              | Name           | Rarity | Effect                     |
|-----------------|----------------|--------|----------------------------|
| fleet_footed    | Fleet Footed   | common | move_speed ×1.2            |
| tough_cover     | Tough Cover    | common | max_hp +25 (+ heal)        |
| quick_draw      | Quick Draw     | common | fire_rate_mult ×1.25       |
| sharp_quill     | Sharp Quill    | common | damage_mult ×1.2           |
| iron_binding    | Iron Binding   | rare   | max_hp +50 (+ heal)        |
| overdrive       | Overdrive      | rare   | move_speed ×1.4            |
| rapid_fire      | Rapid Fire     | rare   | fire_rate_mult ×1.5        |
| ink_surge       | Ink Surge      | rare   | damage_mult ×1.4           |
| lethal_edition  | Lethal Edition | epic   | damage_mult ×2.0           |
| overclocked     | Overclocked    | epic   | fire_rate_mult ×2.0        |
| phantom_step    | Phantom Step   | epic   | move_speed ×1.6            |

> Phase 6 will migrate this pool to `data/upgrades.json` and load it via GameData.

---

## Build Phases

| # | Phase                          | Status      |
|---|--------------------------------|-------------|
| 1 | Project skeleton + repo        | **Done**    |
| 2 | Input map + InputHelper        | **Done**    |
| 3 | Player, Enemy, core Game.tscn  | **Done**    |
| 4 | XP/Leveling + HUD              | **Done**    |
| 5 | Upgrade Draft UI               | **Done**    |
| 6 | Data files + weapon system     | Pending     |
| 7 | Save system + Results + wire-up| Pending     |
| 8 | Polish + README sync           | Pending     |

---

## TODOs for Next Steps (Post v1)

- Add remaining secondary weapons (target: 8 total)
- Tag-weighted drafting ("Featured Sections" seeded per run)
- Meta shop — spend Crowns/Seals on permanent unlocks
- Additional characters with unique primaries
- Boss encounter at 20:00 instead of instant win
- Enemy variety (types beyond basic chaser)
