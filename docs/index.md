# DVRCore Framework

Framework custom pour LastCountry (RedM).

## Principes

- **Discord ID** comme identifiant unique
- **API intuitive** : `player.addMoney()`, `player.addItem()`, `player.setJob()`
- **State Bags** : sync temps reel server -> client
- **KVP** : preferences locales sans reseau
- **Callbacks return-based** : `DVRCore.Callback.Await()` avec return direct
- **Notifications natives** RedM (pas de NUI pour les notifs)
- **Optimise 800+ joueurs** : zero boucle, tout en cache table
- **Multi-personnage** : 1 perso = spawn direct, 2+ = selection

## Structure

```
DVRCore/
├── fxmanifest.lua
├── config/config.lua
├── shared/shared.lua
├── client/
│   ├── dataview.lua              -- Buffer binaire pour natives RDR3
│   ├── callbacks.lua             -- Callback system (return-based)
│   ├── spawn.lua                 -- Spawn, animscene intro, creation de perso
│   ├── api.lua                   -- Exports client
│   ├── main.lua                  -- Entry point
│   └── modules/
│       ├── core/
│       │   ├── camera.lua        -- API Camera (Create, Interp, PostFX)
│       │   ├── prompts.lua       -- API Prompts natifs RDR3
│       │   ├── state.lua         -- State Bags (lecture)
│       │   ├── kvp.lua           -- KVP (stockage local)
│       │   └── utils.lua         -- LoadModel, LoadAnimDict
│       ├── ui/
│       │   └── menu.lua          -- Menu API avec stack (Open/Push/Back)
│       ├── skin/
│       │   ├── skin.lua          -- API skin natives (composants, overlays)
│       │   ├── data.lua          -- Donnees skin (heritage, features, yeux)
│       │   └── editor.lua        -- Editeur interactif (grille 2D, live update)
│       ├── notifications/
│       │   └── notifications.lua -- Notifications natives RDR3
│       └── inventory/
│           └── inventory.lua     -- Inventaire
├── server/
│   ├── callbacks.lua
│   ├── commands.lua
│   ├── api.lua
│   ├── main.lua
│   ├── classes/
│   │   ├── player.lua            -- Player API + State Bags
│   │   └── character.lua         -- Character data
│   └── modules/
│       ├── core/
│       │   ├── database.lua      -- Auto-creation tables
│       │   ├── cron.lua          -- Cron scheduler
│       │   └── saves.lua         -- Auto-save
│       ├── economy/economy.lua   -- Taxes par comte
│       └── player/admin.lua      -- Admin
├── web/                          -- NUI (React + Vite)
│   └── src/interfaces/menu/     -- Menu React avec grille 2D
└── docs/
```

## Pages

- [API Server](./server.md) - Player, economy, callbacks
- [API Client](./client.md) - State Bags, KVP, notifications
- [Menu](./menu.md) - Menu API avec stack, grille 2D, callbacks live
- [Skin](./skin.md) - Skin API, editeur, overlays, expressions
- [Camera](./camera.md) - Camera API
- [Prompts](./prompts.md) - Prompts natifs RDR3
- [Character](./character.md) - Flow de creation de personnage
- [Economie & Taxes](./economy.md) - Systeme de comtes
- [Base de donnees](./database.md) - Schema SQL
- [Evenements](./events.md) - Liste des events
