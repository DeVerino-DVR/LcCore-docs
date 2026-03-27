# Menu API

API pour ouvrir des menus RDR2 depuis le Lua. Meme style partout (character, inventory, etc.).

## Client - Ouvrir un menu

```lua
LcCore.Menu.Open({
    title = 'Mon Menu',
    subtitle = 'Options',
    items = {
        { label = 'Option simple' },
        { label = 'Avec right label', rightLabel = '$150.00' },
        { label = 'Avec scroll', values = {'Choix A', 'Choix B', 'Choix C'}, defaultIndex = 1 },
        { label = 'Checkbox', checked = false },
        { label = 'Separateur', type = 'separator' },
        { label = 'Avec description', description = 'Description affichee en bas du menu.' },
        { label = 'Desactive', disabled = true },
        { label = 'Saisie texte', type = 'text' },
    },
    position = 'top-left',   -- top-left | top-right | bottom-left | bottom-right
    maxVisibleItems = 11,     -- max items visibles (scroll au-dela)
    canClose = true,          -- false = impossible de fermer avec Escape
}, function(index, scrollIndex)
    -- Callback quand un item est selectionne (Enter ou click)
    print('Selectionne index:', index, 'scroll:', scrollIndex)
end, function()
    -- Callback quand le menu est ferme
    print('Menu ferme')
end)
```

## Client - Fermer un menu

```lua
LcCore.Menu.Close()
```

## Options d'un item

| Propriete | Type | Description |
|---|---|---|
| `label` | string | Texte de l'item (obligatoire) |
| `rightLabel` | string? | Texte a droite |
| `description` | string? | Description en bas du menu (280px fixe) |
| `values` | string[]? | Liste de valeurs scrollables (fleches gauche/droite) |
| `defaultIndex` | number? | Index de depart pour les values (1-based) |
| `checked` | boolean? | Affiche une checkbox, toggle avec Enter |
| `type` | string? | `'separator'` ou `'text'` |
| `disabled` | boolean? | Grise l'item |
| `close` | boolean? | `false` = ne ferme pas le menu apres selection |

## Events

| Event | Params | Description |
|---|---|---|
| `lc:menu:checkChanged` | index, checked | Checkbox togglee |
| `lc:menu:indexChanged` | index, scrollIndex | Scroll value changee |

### Ecouter les events

```lua
AddEventHandler('lc:menu:checkChanged', function(index, checked)
    print('Checkbox', index, 'est maintenant', checked)
end)

AddEventHandler('lc:menu:indexChanged', function(index, scrollIndex)
    print('Item', index, 'scroll a', scrollIndex)
end)
```

## Dimensions (identiques partout)

| Element | Taille |
|---|---|
| Menu largeur | 400px |
| Item hauteur | 48px |
| Zone description | 280px (fixe) |
| Max items visibles | 11 (configurable) |
| Header | ratio 4:1 (image 432x108) |
| Font labels | ChineseRocks 15px |
| Font header | RDRLino 36px |
| Font right labels | RDRLino 13px |
| Animation open | 250ms unfold |
| Animation close | 200ms fold |

## Exemple complet

```lua
-- Menu de magasin
LcCore.Menu.Open({
    title = 'Epicerie',
    subtitle = 'Valentine',
    items = {
        { label = 'Pain',    rightLabel = '$2.50',  description = 'Du bon pain frais.' },
        { label = 'Viande',  rightLabel = '$8.00',  description = 'Viande de boeuf.' },
        { label = 'Whiskey', rightLabel = '$5.00',  description = 'Un bon whiskey.' },
        { type = 'separator', label = 'Outils' },
        { label = 'Corde',   rightLabel = '$3.00' },
        { label = 'Couteau', rightLabel = '$12.00' },
    },
}, function(index)
    print('Achete item index:', index)
end)
```
