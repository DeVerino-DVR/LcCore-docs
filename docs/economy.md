# Economie & Taxes par Comte

## Concept

Chaque comte a :
- Un **taux de taxe** (pourcentage)
- Un **maire** (charId d'un joueur)

Quand un script demande un prix, `Core.Economy.GetPrice()` applique automatiquement la taxe du comte.

## Comtes par defaut

| ID | Label |
|---|---|
| `new_hanover` | Comte de New Hanover |
| `lemoyne` | Comte de Lemoyne |
| `new_austin` | Comte de New Austin |
| `west_elizabeth` | Comte de West Elizabeth |
| `ambarino` | Comte d'Ambarino |

## API Server

### Calculer un prix avec taxe

```lua
local prixFinal, montantTaxe = Core.Economy.GetPrice(10.0, 'new_hanover')
-- Si taxe = 15% -> prixFinal = 11.5, montantTaxe = 1.5
```

### Gestion des comtes

```lua
Core.Economy.GetCounties()                    -- tous les comtes (cache)
Core.Economy.GetCounty('new_hanover')         -- un comte
Core.Economy.SetTax('new_hanover', 15)        -- 15% de taxe
Core.Economy.SetMayor('new_hanover', charId)  -- definir le maire
Core.Economy.GetMayor('new_hanover')          -- charId du maire
Core.Economy.IsMayor(source)                  -- maire de n'importe quel comte?
Core.Economy.IsMayor(source, 'new_hanover')   -- maire de ce comte?
```

## Exemple: script boucher

```lua
local LC = exports['DVRCore']:GetCore()

-- Le joueur vend de la viande
local basePrix = 10.0
local county = 'new_hanover' -- detecte par zone

local prixFinal, taxe = Core.Economy.GetPrice(basePrix, county)
-- Le maire a mis 15% -> prixFinal = 11.5

local player = LC.GetPlayer(source)
player.addMoney(prixFinal)
```

## Callbacks pour le panel (maire)

```lua
-- Client: recuperer tous les comtes
local counties = Core.Callback.Await('core:economy:getCounties')

-- Client: modifier la taxe (verifie si maire ou admin)
local success = Core.Callback.Await('core:economy:setTax', 'new_hanover', 15)
```

## Events

| Event | Params | Description |
|---|---|---|
| `core:taxChanged` | countyId, taxRate | Taxe modifiee |
| `core:mayorChanged` | countyId, charId | Maire change |
