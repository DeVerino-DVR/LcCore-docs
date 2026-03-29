# Prompts API

API pour les prompts NUI via `jo.promptNui`. Les prompts s'affichent en bas de l'ecran avec des touches clavier (pas des control hashes natifs).

## API

### Creer un groupe

```lua
local group = jo.promptNui.createGroup('Titre du groupe')
```

### Ajouter un prompt

```lua
group:addPrompt(key, label, holdTime)
```

- `key` : string de la touche clavier (`'E'`, `'ENTER'`, `'ESCAPE'`, `'TAB'`, `'G'`, etc.)
- `label` : texte affiche a cote de la touche
- `holdTime` : duree de maintien en ms (0 = appui simple)

### Afficher / Cacher

```lua
group:display()   -- affiche le groupe de prompts
group:hide()      -- cache le groupe
```

### Verifier si complete

```lua
local done = jo.promptNui.isCompleted(group, key)
```

Retourne `true` quand le joueur a appuye (ou maintenu) la touche.

## Exemple complet

```lua
local group = jo.promptNui.createGroup('Selection du genre')
group:addPrompt('TAB', 'Changer', 0)
group:addPrompt('ENTER', 'Confirmer', 0)

group:display()

CreateThread(function()
    while selecting do
        if jo.promptNui.isCompleted(group, 'TAB') then
            -- Changer de genre
            switchGender()
        end
        if jo.promptNui.isCompleted(group, 'ENTER') then
            -- Confirmer la selection
            selecting = false
        end
        Wait(0)
    end
    group:hide()
end)
```

## Exemple avec maintien

```lua
local group = jo.promptNui.createGroup('Fouiller')
group:addPrompt('E', 'Fouiller le corps', 2000)  -- maintenir 2 secondes

group:display()

CreateThread(function()
    while active do
        if jo.promptNui.isCompleted(group, 'E') then
            -- Action apres maintien
            lootBody()
            active = false
        end
        Wait(0)
    end
    group:hide()
end)
```

## Differences avec l'ancien systeme

| Ancien (Core.Prompt) | Nouveau (jo.promptNui) |
|---|---|
| Control hashes natifs (`INPUT_FRONTEND_ACCEPT`) | Strings clavier (`'ENTER'`, `'E'`) |
| `Core.Prompt.Create(key, label, group, hold)` | `group:addPrompt(key, label, holdTime)` |
| `Core.Prompt.ShowGroup(group, title)` en boucle | `group:display()` une seule fois |
| `Core.Prompt.IsCompleted(prompt)` | `jo.promptNui.isCompleted(group, key)` |
| Rendu natif RDR3 | Rendu NUI (iframe jo_libs) |
