-- LcCore Client Module - Menu API
-- Ouvre des menus RDR2 depuis le Lua.
--
-- Usage:
--   LcCore.Menu.Open({
--       title = 'Mon Menu',
--       subtitle = 'Options',
--       items = {
--           { label = 'Option 1', rightLabel = 'Info' },
--           { label = 'Option 2', values = {'Choix A', 'Choix B'}, defaultIndex = 1 },
--           { label = 'Checkbox', checked = false },
--           { label = 'Separateur', type = 'separator' },
--           { label = 'Avec description', description = 'Description en bas' },
--           { label = 'Desactive', disabled = true },
--           { label = 'Saisie texte', type = 'text' },
--       },
--       position = 'top-left', -- top-left | top-right | bottom-left | bottom-right
--       maxVisibleItems = 11,
--       canClose = true,
--   }, function(selected, scrollIndex)
--       print('Selectionne:', selected, scrollIndex)
--   end, function()
--       print('Menu ferme')
--   end)

LcCore.Menu = {}

local activeCallback = nil
local activeCloseCallback = nil

---@param options table
---@param onSelect function? -- function(index, scrollIndex)
---@param onClose function?
function LcCore.Menu.Open(options, onSelect, onClose)
    activeCallback = onSelect
    activeCloseCallback = onClose

    SendNUIMessage({
        action = 'openMenu',
        title = options.title or 'Menu',
        subtitle = options.subtitle,
        items = options.items or {},
        position = options.position or 'top-left',
        maxVisibleItems = options.maxVisibleItems or 11,
        canClose = options.canClose ~= false,
    })
    SetNuiFocus(true, true)
end

function LcCore.Menu.Close()
    SendNUIMessage({ action = 'closeMenu' })
    SetNuiFocus(false, false)
    if activeCloseCallback then
        activeCloseCallback()
    end
    activeCallback = nil
    activeCloseCallback = nil
end

RegisterNUICallback('confirmSelected', function(data, cb)
    if activeCallback then
        activeCallback(data[1], data[2])
    end
    cb('ok')
end)

RegisterNUICallback('closeMenu', function(_, cb)
    SetNuiFocus(false, false)
    if activeCloseCallback then
        activeCloseCallback()
    end
    activeCallback = nil
    activeCloseCallback = nil
    cb('ok')
end)

RegisterNUICallback('changeChecked', function(data, cb)
    -- data[1] = index, data[2] = checked state
    TriggerEvent('lc:menu:checkChanged', data[1], data[2])
    cb('ok')
end)

RegisterNUICallback('changeIndex', function(data, cb)
    -- data[1] = index, data[2] = scroll index
    TriggerEvent('lc:menu:indexChanged', data[1], data[2])
    cb('ok')
end)
