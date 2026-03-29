# Character - Creation de personnage

## Flow

1. Le joueur se connecte, le serveur detecte 0 personnages -> `core:createCharacter`
2. Intro cinematique (AnimScene RDO avec Sheriff + Deputy)
3. Selection du genre avec `jo.promptNui` (TAB pour changer, ENTER pour confirmer)
4. Le ped marche vers le miroir, camera suit
5. Formulaire via `jo.input.nui` (prenom, nom, date de naissance, nationalite, taille)
6. Editeur de skin via `Core.SkinEditor` (heritage, visage, yeux, cheveux, corps, taille)
7. Spawn aleatoire

## Selection du genre

```lua
local group = jo.promptNui.createGroup('Choix du genre')
group:addPrompt('TAB', 'Changer', 0)
group:addPrompt('ENTER', 'Confirmer', 0)
group:display()

-- Boucle de selection
while selecting do
    if jo.promptNui.isCompleted(group, 'TAB') then
        -- Alterner male/female
    end
    if jo.promptNui.isCompleted(group, 'ENTER') then
        selecting = false
    end
    Wait(0)
end
group:hide()
```

## Formulaire de creation

```lua
local result = jo.input.nui({
    rows = {
        { label = 'Prenom', type = 'text' },
        { label = 'Nom', type = 'text' },
        { label = 'Date de naissance', type = 'text' },
        { label = 'Nationalite', type = 'text' },
    }
})
```

## Selection de personnage (2+ persos)

Quand le joueur a plusieurs personnages, la selection utilise `Core.Menu` :

```lua
Core.Menu.Register('char_select', {
    title = 'Personnages',
    onBack = function() end,  -- pas de retour possible
    items = items,            -- liste des personnages
}, function(data)
    -- Selectionner le personnage
end)
Core.Menu.Show('char_select')
```

## Fichiers

| Fichier | Role |
|---------|------|
| `client/spawn.lua` | Flow complet (animscene, genre, formulaire, spawn) |
| `client/modules/skin/editor.lua` | Editeur de skin avec Core.Menu (sliders, grids, palettes) |
| `client/modules/skin/data.lua` | Donnees skin (heritage, face features, yeux, composants) |
| `client/modules/skin/skin.lua` | API skin via jo.component |
| `config/character.lua` | Config creation (camera views, positions) |

## Config

```lua
Config.Creation = {
    genderViews = {
        { pos = vector3(...), rot = vector3(...), fov = 35.0, focus = 4.0 }, -- Male
        { pos = vector3(...), rot = vector3(...), fov = 35.0, focus = 4.0 }, -- Female
    },
}
```

## Events

| Event | Direction | Description |
|-------|-----------|-------------|
| `core:createCharacter` | Server -> Client | Declenche la creation (0 personnages) |
| `core:createChar` | Client -> Server | Envoie les donnees du nouveau personnage |
| `core:spawn` | Server -> Client | Spawn le joueur aux coordonnees |
| `core:playerSpawned` | Client event | Declenche apres le spawn |
| `core:selectCharacter` | Server -> Client | Ouvre la selection (2+ persos) |

## Editeur de skin

L'editeur utilise `Core.SkinEditor.Open(gender, skin, onDone)` qui cree des menus `Core.Menu` avec sliders, grids et palettes pour chaque categorie.

### Categories

- **Heritage** : couleur de peau (6 ethnies), choix de tete (grid selection)
- **Visage** : 8 zones avec sliders par paires (via `SetCharExpression`)
- **Yeux** : 14 couleurs, preview live en navigant
- **Cheveux** : liste dynamique via grid, preview live
- **Corps** : sliders (bras, epaules, dos, poitrine, taille, hanches, cuisses, mollets)
- **Taille** : echelle du ped (0.90 a 1.10)

Les modifications sont appliquees en temps reel via `jo.component`.
