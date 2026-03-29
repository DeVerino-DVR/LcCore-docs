# Skin API

API pour manipuler l'apparence des personnages via **jo.component** (jo_libs).

## Modules

| Module | Description |
|---|---|
| `jo.component` | Application de skin, composants, refresh ped |
| `Core.SkinData` | Donnees de configuration (heritage, features, yeux) |
| `Core.SkinEditor` | Editeur interactif complet (utilise Core.Menu) |

## jo.component

### Appliquer un skin complet

```lua
jo.component.applySkin(ped, standardSkin)
```

Applique un skin au format standard (table avec toutes les categories).

### Appliquer un composant individuel

```lua
jo.component.apply(ped, category, hash)
```

- `category` : categorie du composant (ex: `'hats'`, `'boots'`, `'shirts'`)
- `hash` : hash du composant a appliquer

### Refresh du ped

```lua
jo.component.refreshPed(ped)
```

Met a jour le rendu du ped apres des modifications.

### Attendre le chargement

```lua
jo.component.waitPedLoaded(ped)
```

Attend que le ped soit completement charge avant de continuer.

## Core.SkinData

### Heritage

```lua
Core.SkinData.Heritage -- 6 ethnies avec headList, albedo
Core.SkinData.Eyes     -- 14 couleurs d'yeux
```

### Face Features

```lua
Core.SkinData.FaceFeatures.head          -- 6 features (HeadSize, FaceW, FaceD, etc.)
Core.SkinData.FaceFeatures.eyesandbrows  -- 9 features
Core.SkinData.FaceFeatures.ears          -- 4 features
Core.SkinData.FaceFeatures.cheek         -- 3 features
Core.SkinData.FaceFeatures.jaw           -- 3 features
Core.SkinData.FaceFeatures.chin          -- 3 features
Core.SkinData.FaceFeatures.nose          -- 6 features
Core.SkinData.FaceFeatures.mouthandlips  -- 18 features
Core.SkinData.FaceFeatures.upperbody     -- 7 features
Core.SkinData.FaceFeatures.lowerbody     -- 2 features
```

Chaque feature : `{ label = 'Largeur nez', hash = 0x6E7F, comp = 'NoseW' }`

### Composants

```lua
Core.SkinData.ComponentCategories  -- Hashes joaat de toutes les categories (Hair, Beard, Boots, etc.)
Core.SkinData.TextureTypes         -- Albedo/normal/material par genre
Core.SkinData.OverlayCounts        -- Nombre d'overlays par categorie
Core.SkinData.DefaultSkin          -- Structure par defaut du skin (tous les champs)
Core.SkinData.DefaultClothing      -- Structure par defaut des vetements
```

## Core.SkinEditor

L'editeur utilise `Core.Menu` avec des sliders, grids et palettes pour modifier l'apparence en temps reel.

### Ouvrir l'editeur

```lua
Core.SkinEditor.Open('male', existingSkin or {}, function(skinData)
    -- skinData contient toutes les valeurs du skin
    print(json.encode(skinData))
end)
```

### Categories de l'editeur

| Categorie | Type de controle | Description |
|---|---|---|
| Heritage | Grid (selection) + preview live | Couleur de peau, tete (6 ethnies) |
| Visage | Sliders par zone | 8 zones avec features par paires |
| Yeux | Grid (selection) | 14 couleurs, preview live |
| Cheveux | Grid (selection) | Liste dynamique, preview live |
| Corps | Sliders | Bras, epaules, dos, poitrine, taille, hanches, cuisses, mollets |
| Taille | Slider | Echelle du ped (0.90 a 1.10) |

Les modifications sont appliquees en temps reel via `jo.component` et `SetCharExpression`.
