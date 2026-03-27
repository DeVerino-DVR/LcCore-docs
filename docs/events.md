# Evenements

## Server Events

Tous les events emettent le **charId** (identifiant permanent), jamais la source.

Ecouter avec `AddEventHandler()`.

| Event | Params | Declencheur |
|---|---|---|
| `lc:jobChanged` | charId, newJob, oldJob | `player.setJob()` |
| `lc:gangChanged` | charId, gang | `player.setGang()` |
| `lc:groupChanged` | charId, group | `player.setGroup()` |
| `lc:moneyChanged` | charId, type, amount, action | `player.addMoney/removeMoney/addGold/removeGold` |
| `lc:itemChanged` | charId, item, count, action | `player.addItem/removeItem` |
| `lc:taxChanged` | countyId, taxRate | `LcCore.Economy.SetTax()` |
| `lc:mayorChanged` | countyId, charId | `LcCore.Economy.SetMayor()` |

### Exemples

```lua
-- Reagir a un changement de job
AddEventHandler('lc:jobChanged', function(charId, newJob, oldJob)
    print('CharId', charId, 'passe de', oldJob.name, 'a', newJob.name)
end)

-- Logger les transactions
AddEventHandler('lc:moneyChanged', function(charId, type, amount, action)
    print('CharId', charId, action, amount, type)
end)

-- Reagir a un changement de taxe
AddEventHandler('lc:taxChanged', function(countyId, taxRate)
    print('Taxe de', countyId, 'changee a', taxRate .. '%')
end)
```

## Client Events

| Event | Params | Description |
|---|---|---|
| `lc:playerSpawned` | charId, firstname, lastname | Joueur spawn apres selection |
| `lc:spawn` | data (table) | Trigger le spawn client |
| `lc:selectCharacter` | charList (table) | Ouvre la selection de personnage |
| `lc:createCharacter` | - | Ouvre la creation de personnage |
| `lc:notify` | type, ... | Notification native |

### Exemple

```lua
AddEventHandler('lc:playerSpawned', function(charId, firstname, lastname)
    print('Spawn en tant que', firstname, lastname, '(charId:', charId, ')')
end)
```

## Flow de connexion

```
Joueur se connecte
    -> playerConnecting (verif Discord + ban)
    -> lc:playerJoined (charge les personnages)
    -> 0 perso: lc:createCharacter
    -> 1 perso: lc:spawn (direct)
    -> 2+ persos: lc:selectCharacter -> lc:charSelected -> lc:spawn
    -> lc:playerSpawned

Resource restart
    -> save tous les joueurs
    -> re-trigger lc:playerJoined
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
local LC = exports['LcCore']:GetCore()

-- Trouver un joueur par son charId
local player = LC.GetPlayerByCharId(42)
player.addMoney(100)
player.addItem('bread', 5)

-- Admin: ban par charId
LC.Admin.Ban(42, 'Triche', 86400)

-- Commandes: le callback recoit deja le charId
LC.Commands.Register('heal', 'admin', function(charId, args)
    local targetId = tonumber(args[1])
    -- targetId = charId du joueur cible
end)
```
