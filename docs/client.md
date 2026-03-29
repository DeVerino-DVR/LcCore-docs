# API Client

## Callbacks

Wrappent `jo.callback.triggerServer`. Toujours en `Await` avec return direct, jamais de `cb()`.

```lua
-- Core.Callback.Await = jo.callback.triggerServer
local data = Core.Callback.Await('core:getPlayerData')
print(data.name, data.money)

-- Avec arguments
local price, tax = Core.Callback.Await('core:getPrice', 10.0, 'new_hanover')
```

## Notifications

Les notifications utilisent `jo.notif.right()` (module jo_libs). Plus de `Core.Notify.*`.

### Depuis le client

```lua
jo.notif.right('Message ici')
```

### Depuis le server

```lua
jo.notif.right(source, 'Message ici')
```

## State Bags

Les State Bags sont mis a jour automatiquement par le server a chaque setter (`player.addMoney()`, `player.setJob()`, etc.). Cote client, les valeurs sont lisibles **instantanement** sans callback ni event.

### Lire une valeur

```lua
local LC = exports['DVRCore']:GetCore()

local money = LC.State.Get('money')
local job   = LC.State.Get('job')     -- { name, grade, label }
local gold  = LC.State.Get('gold')
local xp    = LC.State.Get('xp')
local dead  = LC.State.Get('isDead')
```

### Ecouter les changements

```lua
LC.State.OnChange('money', function(value)
    print('Argent:', value)
end)

LC.State.OnChange('job', function(job)
    print('Job:', job.name)
end)
```

### States disponibles

| Key | Type | Description |
|---|---|---|
| `charId` | number | ID du personnage actif |
| `name` | string | Prenom + Nom |
| `group` | string | user/admin/superadmin |
| `job` | table | { name, grade, label } |
| `gang` | string | Gang |
| `money` | number | Argent |
| `gold` | number | Or |
| `isDead` | boolean | Est mort |
| `xp` | number | Experience |
| `slots` | number | Nombre de slots |

## KVP (stockage local)

Pour les preferences du joueur. Stocke localement sur la machine, pas de reseau, pas de DB.

```lua
local LC = exports['DVRCore']:GetCore()

-- Sauvegarder
LC.KVP.Set('hud_visible', true)
LC.KVP.Set('volume', 0.8)

-- Lire
local visible = LC.KVP.GetBool('hud_visible', true)   -- default = true
local volume  = LC.KVP.GetFloat('volume', 1.0)
local county  = LC.KVP.GetString('last_county', '')
local prefs   = LC.KVP.GetJSON('user_prefs', {})
local count   = LC.KVP.GetInt('counter', 0)

-- Supprimer
LC.KVP.Delete('old_key')
```

## Input NUI

Pour les formulaires de saisie, utiliser `jo.input.nui()` :

```lua
local result = jo.input.nui({
    rows = {
        { label = 'Prenom', type = 'text' },
        { label = 'Nom', type = 'text' },
        { label = 'Age', type = 'number' },
    }
})

if result then
    print(result[1], result[2], result[3])
end
```
