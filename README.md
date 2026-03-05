# Library Survivors

A top-down 2D survivors-like prototype built in **Godot 4.x** with a library theme, controller-first UI, and data-driven content.

## How to Run

1. Install [Godot 4.3+](https://godotengine.org/download)
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
│   ├── Game.tscn              # [Phase 3] ✅ Core gameplay root
│   ├── Enemy.tscn             # [Phase 3] ✅ Enemy scene (instanced by EnemySpawner)
│   ├── Projectile.tscn        # [Phase 3] ✅ Projectile scene (instanced by Player)
│   └── Results.tscn           # [Phase 7] Win/lose + rewards
│
├── scripts/                   # GDScript files (logic only, no scene nodes)
│   ├── InputHelper.gd         # [Phase 2] ✅ Move/aim/confirm helpers (autoload)
│   ├── MainMenu.gd            # [Phase 3] ✅ Menu button wiring
│   ├── Game.gd                # [Phase 3] ✅ Wires Player ↔ Spawner, handles game-over
│   ├── Player.gd              # [Phase 3] ✅ Movement, HP, primary fire
│   ├── Enemy.gd               # [Phase 3] ✅ Chase AI, contact damage, death
│   ├── Projectile.gd          # [Phase 3] ✅ Travel, pierce, hit detection
│   ├── EnemySpawner.gd        # [Phase 3] ✅ Timed spawning around player
│   ├── XpOrb.gd               # [Phase 4] Pickup radius, XP grant
│   ├── UpgradeManager.gd      # [Phase 5] Draft pool logic, effect application
│   ├── WeaponPrimary.gd       # [Phase 6] Data-driven primary weapon
│   ├── WeaponSecondary.gd     # [Phase 6] Data-driven secondary weapon (auto)
│   └── RunState.gd            # [Phase 7] Seed, timer, currency tallying
│
├── ui/                        # UI scenes and scripts
│   ├── HUD.tscn               # [Phase 4] HP, level, XP bar, timer, currencies
│   ├── HUD.gd
│   ├── UpgradeDraft.tscn      # [Phase 5] 3-card controller-navigable draft
│   ├── UpgradeDraft.gd
│   └── UpgradeCard.tscn       # [Phase 5] Single card: name, desc, rarity, tags
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

---

## Build Phases

| # | Phase                          | Status      |
|---|--------------------------------|-------------|
| 1 | Project skeleton + repo        | **Done**    |
| 2 | Input map + InputHelper        | **Done**    |
| 3 | Player, Enemy, core Game.tscn  | **Done**    |
| 4 | XP/Leveling + HUD              | Pending     |
| 5 | Upgrade Draft UI               | Pending     |
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
