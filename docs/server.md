# API Server

## Recuperer le Core

```lua
local LC = exports['DVRCore']:GetCore()
```

## Player

Toutes les methodes sont directement sur l'objet player. Chaque setter met a jour automatiquement le State Bag correspondant. Le **charId** est l'identifiant permanent du joueur (pas la source).

```lua
-- Par charId (recommande, identifiant permanent)
local player = LC.GetPlayerByCharId(42)

-- Par source (interne uniquement)
local player = LC.GetPlayer(source)
```

### Identite

| Methode | Retour | Description |
|---|---|---|
| `player.getCharId()` | number | **ID permanent du joueur** |
| `player.getName()` | string | "Prenom Nom" |
| `player.getDiscord()` | string | Discord ID |
| `player.getName()` | string | "Prenom Nom" |
| `player.getFirstname()` | string | Prenom |
| `player.getLastname()` | string | Nom |
| `player.getSource()` | number | Source (interne, ne pas exposer) |

### Groupe

| Methode | Retour | Description |
|---|---|---|
| `player.getGroup()` | string | 'user' / 'admin' / 'superadmin' |
| `player.setGroup(group)` | - | Change le groupe (+ State Bag) |

### Job

Le job est stocke en JSON : `{ name, grade, label }`

| Methode | Retour | Description |
|---|---|---|
| `player.getJob()` | table | `{ name, grade, label }` |
| `player.setJob(name, grade, label?)` | - | Change le job (+ State Bag + event) |

### Gang

| Methode | Retour | Description |
|---|---|---|
| `player.getGang()` | string | Gang actuel |
| `player.setGang(gang)` | - | Change le gang |

### Argent

| Methode | Retour | Description |
|---|---|---|
| `player.getMoney()` | number | Argent |
| `player.addMoney(amount)` | - | Ajoute de l'argent |
| `player.removeMoney(amount)` | boolean | Retire (false si pas assez) |
| `player.getGold()` | number | Or |
| `player.addGold(amount)` | - | Ajoute de l'or |
| `player.removeGold(amount)` | boolean | Retire (false si pas assez) |

### Inventaire

| Methode | Retour | Description |
|---|---|---|
| `player.getInventory()` | table | `{ {name, count}, ... }` |
| `player.addItem(item, count)` | - | Ajoute un item |
| `player.removeItem(item, count)` | boolean | Retire (false si pas assez) |
| `player.getItemCount(item)` | number | Quantite d'un item |
| `player.getSlots()` | number | Nombre de slots |
| `player.addSlots(amount)` | - | Ajoute des slots |

### Coords & Status

| Methode | Retour | Description |
|---|---|---|
| `player.getCoords()` | vector3 | Position |
| `player.setCoords(coords)` | - | Change la position |
| `player.isDead()` | boolean | Est mort |
| `player.setDead(state)` | - | Change l'etat mort |
| `player.getXP()` | number | Experience |
| `player.addXP(amount)` | - | Ajoute de l'XP |

### Skin

| Methode | Retour | Description |
|---|---|---|
| `player.getSkin()` | table | Donnees skin |
| `player.setSkin(skin)` | - | Change le skin |

### Multi-personnage

| Methode | Retour | Description |
|---|---|---|
| `player.getCharacters()` | table | Tous les personnages |
| `player.getCharCount()` | number | Nombre de personnages |
| `player.setActiveChar(charId)` | boolean | Selectionne un personnage |
| `player.getActiveChar()` | table? | Personnage actif |

## Recherche de joueurs

```lua
-- Recommande: par charId (identifiant permanent, O(1))
LC.GetPlayerByCharId(42)

-- Par discord (O(1))
LC.GetPlayerByDiscord('1234')

-- Interne: par source
LC.GetPlayer(source)

-- Tous les joueurs
LC.GetPlayers()

-- Obtenir la source depuis un charId
LC.GetSourceByCharId(42)
```

## Admin (par charId)

```lua
LC.Admin.IsAdmin(charId)
LC.Admin.SetGroup(charId, 'admin')
LC.Admin.Kick(charId, 'Raison')
LC.Admin.Ban(charId, 'Raison', 86400, adminCharId)
LC.Admin.Unban('discord_id')
```

## Commandes

```lua
-- Le callback recoit le charId, pas la source
LC.Commands.Register('heal', 'admin', function(charId, args)
    local targetId = tonumber(args[1]) -- charId de la cible
    local target = LC.GetPlayerByCharId(targetId)
    if target then
        target.setDead(false)
    end
end)
```

## Sauvegarde

```lua
LC.SavePlayer(source) -- sauvegarde un joueur
LC.SaveAll()          -- sauvegarde tout le monde
```

Auto-save toutes les 5 minutes (configurable).

## Callbacks

### Register

```lua
DVRCore.Callback.Register('dvr:getPlayerData', function(source)
    local player = DVRCore.GetPlayer(source)
    return {
        name  = player.getName(),
        money = player.getMoney(),
        job   = player.getJob(),
    }
end)
```

Le client appelle avec `DVRCore.Callback.Await()` et recoit le return directement.
