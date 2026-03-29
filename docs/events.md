# Evenements

## Server Events

Tous les events emettent le **charId** (identifiant permanent), jamais la source.

Ecouter avec `AddEventHandler()`.

| Event | Params | Declencheur |
|---|---|---|
| `core:jobChanged` | charId, newJob, oldJob | `player.setJob()` |
| `core:gangChanged` | charId, gang | `player.setGang()` |
| `core:groupChanged` | charId, group | `player.setGroup()` |
| `core:moneyChanged` | charId, type, amount, action | `player.addMoney/removeMoney/addGold/removeGold` |
| `core:itemChanged` | charId, item, count, action | `player.addItem/removeItem` |
| `core:taxChanged` | countyId, taxRate | `Core.Economy.SetTax()` |
| `core:mayorChanged` | countyId, charId | `Core.Economy.SetMayor()` |

### Exemples

```lua
-- Reagir a un changement de job
AddEventHandler('core:jobChanged', function(charId, newJob, oldJob)
    print('CharId', charId, 'passe de', oldJob.name, 'a', newJob.name)
end)

-- Logger les transactions
AddEventHandler('core:moneyChanged', function(charId, type, amount, action)
    print('CharId', charId, action, amount, type)
end)

-- Reagir a un changement de taxe
AddEventHandler('core:taxChanged', function(countyId, taxRate)
    print('Taxe de', countyId, 'changee a', taxRate .. '%')
end)
```

## Client Events

| Event | Params | Description |
|---|---|---|
| `core:playerSpawned` | charId, firstname, lastname | Joueur spawn apres selection |
| `core:spawn` | data (table) | Trigger le spawn client |
| `core:selectCharacter` | charList (table) | Ouvre la selection de personnage |
| `core:createCharacter` | - | Ouvre la creation de personnage |

### Exemple

```lua
AddEventHandler('core:playerSpawned', function(charId, firstname, lastname)
    print('Spawn en tant que', firstname, lastname, '(charId:', charId, ')')
end)
```

## Flow de connexion

```
Joueur se connecte
    -> playerConnecting (verif Discord + ban)
    -> core:playerJoined (charge les personnages)
    -> 0 perso: core:createCharacter
    -> 1 perso: core:spawn (direct)
    -> 2+ persos: core:selectCharacter -> core:charSelected -> core:spawn
    -> core:playerSpawned

Resource restart
    -> save tous les joueurs
    -> re-trigger core:playerJoined
    -> meme flow (pas besoin de reco)

Joueur drop
    -> playerDropped (save + cleanup index)
```

## Identifiants

| Identifiant | Usage | Scope |
|---|---|---|
| **charId** | ID permanent du joueur, utilise partout | Public (API, events, commandes) |
| **discord** | Discord ID, pour les bans et l'auth | Interne (auth, bans) |
| **source** | ID temporaire de session FiveM/RedM | Interne uniquement (transport reseau) |

Un script externe ne devrait **jamais** manipuler la source directement. Toujours passer par le charId :

```lua
-- Trouver un joueur par son charId
local LC = exports['DVRCore']:GetCore()
local player = LC.GetPlayerByCharId(42)
player.addMoney(100)

-- Admin: ban par charId
LC.Admin.Ban(42, 'Triche', 86400)

-- Commandes: le callback recoit deja le charId
LC.Commands.Register('heal', 'admin', function(charId, args)
    local targetId = tonumber(args[1])
    -- targetId = charId du joueur cible
end)
```
