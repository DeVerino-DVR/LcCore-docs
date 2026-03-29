# DVRCore Framework

Framework custom pour RedM, base sur **jo_libs** (Jump On Studios).

## Principes

- **Discord ID** comme identifiant unique
- **jo_libs** pour tous les systemes UI (menus, notifications, prompts, inputs, skin)
- **State Bags** : sync temps reel server -> client
- **KVP** : preferences locales sans reseau
- **Callbacks return-based** : `Core.Callback.Await()` (wrap `jo.callback.triggerServer`)
- **Notifications jo_libs** : `jo.notif.right()` (plus de `Core.Notify.*`)
- **Optimise 800+ joueurs** : zero boucle, tout en cache table
- **Multi-personnage** : 1 perso = spawn direct, 2+ = selection
- **Framework bridge** : jo_libs detecte DVRCore automatiquement, les scripts Jump On natifs fonctionnent directement

## Dependances

- **jo_libs** : `@jo_libs/init.lua` en premier shared_script
- **oxmysql** : base de donnees MySQL

## fxmanifest

```lua
jo_libs {
    'framework-bridge',
    'callback',
    'notification',
    'prompt-nui',
    'nui',
    'raw-keys',
    'component',
    'ped-texture',
    'entity',
    'blip',
    'camera',
    'player',
    'me',
    'animation',
    'table',
    'utils',
    'dataview',
    'string',
    'timeout',
    'input',
}

ui_page 'nui://jo_libs/nui/index.html'
```

L'`ui_page` pointe vers l'iframe manager de jo_libs qui charge les modules NUI (menu, input, prompt).

## Structure

```
DVRCore/
├── fxmanifest.lua
├── config/
│   ├── config.lua
│   ├── groups.lua
│   ├── character.lua
│   ├── spawn.lua
│   ├── session.lua
│   └── death.lua
├── shared/
│   ├── shared.lua
│   └── items.lua
├── client/
│   ├── callbacks.lua             -- Callback system (wrap jo.callback)
│   ├── spawn.lua                 -- Spawn, animscene intro, creation de perso
│   ├── api.lua                   -- Exports client
│   ├── main.lua                  -- Entry point
│   └── modules/
│       ├── core/
│       │   ├── camera.lua        -- API Camera (Create, Interp, PostFX)
│       │   ├── state.lua         -- State Bags (lecture)
│       │   ├── kvp.lua           -- KVP (stockage local)
│       │   └── utils.lua         -- LoadModel, LoadAnimDict
│       ├── ui/
│       │   └── menu.lua          -- Core.Menu (SendNUIMessage vers jo_libs)
│       └── skin/
│           ├── skin.lua          -- API skin via jo.component
│           ├── data.lua          -- Donnees skin (heritage, features, yeux)
│           └── editor.lua        -- Editeur interactif (sliders, grids, palettes)
├── server/
│   ├── callbacks.lua             -- Wrap jo.callback.register
│   ├── commands.lua
│   ├── api.lua                   -- Exports server individuels
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
├── sql/
│   └── database.sql
└── docs/
```

## Pages

- [API Server](./server.md) - Player, economy, callbacks, exports
- [API Client](./client.md) - State Bags, KVP, notifications, callbacks
- [Menu](./menu.md) - Core.Menu API (style ox_lib, via jo_libs NUI)
- [Skin](./skin.md) - Skin API via jo.component
- [Camera](./camera.md) - Camera API
- [Prompts](./prompts.md) - Prompts NUI via jo.promptNui
- [Character](./character.md) - Flow de creation de personnage
- [Economie & Taxes](./economy.md) - Systeme de comtes
- [Base de donnees](./database.md) - Schema SQL
- [Evenements](./events.md) - Liste des events
