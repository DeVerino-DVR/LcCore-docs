# Camera API

API pour gerer les cameras scriptees RDR2.

## Fonctions

```lua
local cam = Core.Camera.Create(pos, rot, fov)     -- Cree une camera
Core.Camera.Destroy(cam)                           -- Detruit une camera
Core.Camera.SetActive(cam, render)                 -- Active + RenderScriptCams
Core.Camera.StopRendering()                        -- Arrete le rendu script
Core.Camera.Interp(from, to, duration, easeIn, easeOut)  -- Interpolation
Core.Camera.InterpWait(from, to, duration)         -- Interpolation + Wait
Core.Camera.SetFocus(cam, dist)                    -- Distance de focus
Core.Camera.SetMotionBlur(cam, strength)           -- Motion blur
Core.Camera.Shake(cam, shakeType, amplitude)       -- Tremblement
Core.Camera.PlayPostFX(name)                       -- Effet post-process
Core.Camera.StopPostFX(name)                       -- Arrete un effet
```

## Exemple

```lua
local cam = Core.Camera.Create(
    vector3(-562.15, -3776.22, 239.11),
    vector3(-4.71, 0.0, -93.14),
    45.0
)
Core.Camera.SetActive(cam)
Core.Camera.SetFocus(cam, 4.0)
Core.Camera.Shake(cam, 'HAND_SHAKE', 0.04)

-- Plus tard
Core.Camera.Destroy(cam)
Core.Camera.StopRendering()
```
