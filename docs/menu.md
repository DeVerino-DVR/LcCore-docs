# Menu API

API de menus style ox_lib, rendue via l'iframe NUI de jo_libs. Les menus sont envoyes par `SendNUIMessage` vers le module menu de jo_libs.

## API

### Core.Menu.Register(id, data, cb)

Enregistre un menu avec son callback de selection.

```lua
Core.Menu.Register('mon_menu', {
    title = 'Mon Menu',
    subtitle = 'Options',
    numberOnScreen = 11,
    onBack = function()
        Core.Menu.Hide()
    end,
    items = {
        { title = 'Option 1', textRight = '$10' },
        { title = 'Option 2', subtitle = 'Description' },
    },
}, function(data)
    -- data.index, data.item, etc.
    print('Selection:', data.index)
end)
```

### Core.Menu.Show(id)

Affiche un menu enregistre par son ID.

```lua
Core.Menu.Show('mon_menu')
```

### Core.Menu.Hide()

Cache le menu actif.

### Core.Menu.GetOpen()

Retourne l'ID du menu actuellement ouvert, ou `nil`.

### Core.Menu.SetOptions(id, options, index)

Met a jour les options d'un menu enregistre. Si `index` est specifie, met a jour seulement l'item a cet index.

```lua
-- Mettre a jour tous les items
Core.Menu.SetOptions('mon_menu', nouveauxItems)

-- Mettre a jour un seul item
Core.Menu.SetOptions('mon_menu', { title = 'Nouveau titre', textRight = '$20' }, 3)
```

### Pattern alternatif : Create + SetCurrent + Show

```lua
Core.Menu.Create('shop', {
    title = 'Boutique',
    subtitle = 'Valentine',
    items = { ... },
    onBack = function() Core.Menu.Hide() end,
})

Core.Menu.SetCurrent('shop')
Core.Menu.Show(true, true)
```

## Donnees du menu

| Propriete | Type | Description |
|---|---|---|
| `title` | string | Titre du menu |
| `subtitle` | string? | Sous-titre |
| `items` | table | Liste des items |
| `numberOnScreen` | number? | Nombre max d'items visibles |
| `onBack` | function? | Callback quand le joueur fait retour (Backspace/Escape) |
| `onClose` | function? | Alternative a `onBack` |

## Options d'un item

| Propriete | Type | Description |
|---|---|---|
| `title` | string | Texte principal |
| `textRight` | string? | Texte a droite |
| `subtitle` | string? | Sous-titre sous le label |
| `disabled` | boolean? | Grise l'item |
| `child` | string? | ID d'un sous-menu (ouvre ce menu au clic) |
| `onClick` | function? | Callback au clic |
| `onChange` | function? | Callback quand un slider/grid change |
| `sliders` | table[]? | Sliders, grids, ou palettes |

## Types de sliders

### Slider (barre)

```lua
{
    type = 'slider',
    min = 0,
    max = 100,
    value = 50,
    step = 1,
}
```

### Grid (selection de valeur)

```lua
{
    type = 'grid',
    values = { 'Petit', 'Moyen', 'Grand' },
    current = 1,   -- index de la valeur actuelle (1-based)
    label = true,   -- afficher le label de la valeur
}
```

### Palette (couleur)

```lua
{
    type = 'palette',
    palette = 'hair',  -- nom de la palette
    max = 63,          -- nombre de couleurs
    current = 0,       -- index actuel
}
```

## Exemples

### Menu simple avec callback

```lua
Core.Menu.Register('epicerie', {
    title = 'Epicerie',
    subtitle = 'Valentine',
    onBack = function()
        Core.Menu.Hide()
    end,
    items = {
        { title = 'Pain',    textRight = '$2.50', onClick = function() print('Pain achete') end },
        { title = 'Viande',  textRight = '$8.00', onClick = function() print('Viande achetee') end },
        { title = 'Whiskey', textRight = '$5.00', onClick = function() print('Whiskey achete') end },
    },
}, function(data)
    print('Item selectionne:', data.index)
end)

Core.Menu.Show('epicerie')
```

### Menu avec sous-menus (child)

```lua
Core.Menu.Register('details_pain', {
    title = 'Pain',
    subtitle = 'Details',
    onBack = function()
        Core.Menu.Show('epicerie')
    end,
    items = {
        { title = 'Acheter', onClick = function() print('Achete!') end },
        { title = 'Prix', textRight = '$2.50', disabled = true },
    },
}, function() end)

Core.Menu.Register('epicerie', {
    title = 'Epicerie',
    subtitle = 'Valentine',
    onBack = function() Core.Menu.Hide() end,
    items = {
        { title = 'Pain', textRight = '$2.50', child = 'details_pain' },
        { title = 'Viande', textRight = '$8.00' },
    },
}, function() end)

Core.Menu.Show('epicerie')
```

### Menu avec sliders

```lua
Core.Menu.Register('parametres', {
    title = 'Parametres',
    onBack = function() Core.Menu.Hide() end,
    items = {
        {
            title = 'Volume',
            sliders = {
                { type = 'slider', min = 0, max = 100, value = 80, step = 5 },
            },
            onChange = function(data)
                print('Volume:', data.value)
            end,
        },
        {
            title = 'Taille',
            sliders = {
                { type = 'grid', values = {'S', 'M', 'L', 'XL'}, current = 2, label = true },
            },
            onChange = function(data)
                print('Taille:', data.value)
            end,
        },
        {
            title = 'Couleur cheveux',
            sliders = {
                { type = 'palette', palette = 'hair', max = 63, current = 0 },
            },
            onChange = function(data)
                print('Couleur:', data.value)
            end,
        },
    },
}, function() end)

Core.Menu.Show('parametres')
```

### Mise a jour dynamique

```lua
-- Mettre a jour le prix d'un item
Core.Menu.SetOptions('epicerie', { title = 'Pain', textRight = '$3.00' }, 1)

-- Reconstruire toute la liste
local nouveauxItems = {}
for _, item in pairs(stock) do
    table.insert(nouveauxItems, { title = item.label, textRight = '$' .. item.prix })
end
Core.Menu.SetOptions('epicerie', nouveauxItems)
```
