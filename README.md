# Library Survivors

A top-down 2D survivors-like prototype built in **Godot 4.x** with a library theme, controller-first UI, and data-driven content.

## How to Run

1. Install [Godot 4.3+](https://godotengine.org/download)
2. Open Godot, click **Import**, select this folder's `project.godot`
3. Press **F5** (or the Play button) to run

> Main scene: `res://scenes/MainMenu.tscn` (not yet implemented — see Phase tracker below)

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

> Aim approach: right stick is checked first; if its magnitude < 0.15 (deadzone), aim falls back to mouse-to-player direction. Documented in `scripts/InputHelper.gd` (Phase 2).

> Fire mode: **hold-to-fire** — primary weapon fires continuously while the fire input is held and the cooldown has elapsed.

---

## Architecture Overview

```
library-survivors/
├── project.godot              # Godot project config + input map
├── README.md                  # This file
├── MEMORY.md                  # Project phase tracker / dev notes
│
├── scenes/                    # .tscn scene files
│   ├── MainMenu.tscn          # [Phase 3] Start Run, Quit
│   ├── Game.tscn              # [Phase 3] Core gameplay
│   └── Results.tscn           # [Phase 7] Win/lose + rewards
│
├── scripts/                   # GDScript files (logic only, no scene nodes)
│   ├── InputHelper.gd         # [Phase 2] Move/aim/confirm helpers
│   ├── Player.gd              # [Phase 3] Movement, HP, weapon dispatch
│   ├── Enemy.gd               # [Phase 3] Movement toward player, contact damage
│   ├── Projectile.gd          # [Phase 3] Travel, hit, pierce logic
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

## Build Phases

| # | Phase                          | Status      |
|---|--------------------------------|-------------|
| 1 | Project skeleton + repo        | **Done**    |
| 2 | Input map + InputHelper        | **Done**    |
| 3 | Player, Enemy, core Game.tscn  | Pending     |
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
