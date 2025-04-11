exports["es_extended"]:getSharedObject()
RegisterServerEvent('pw_give:request')
AddEventHandler('pw_give:request', function(playerID, thing, count)
    local src = source 
    if src == 0 then
        print('Chyba: Příkaz byl spuštěn z konzole!')
        return
    end

    local allowedGroups = {'admin', 'staff', 'trial'}

    local playerGroup = xPlayer.getGroup()
    local isAllowed = false
    for _, group in ipairs(allowedGroups) do
        if playerGroup == group then
            isAllowed = true
            break
        end
    end
    
    if not isAllowed then
        TriggerClientEvent('pw_give:notifyWithErrorSound', src, {
            title = 'Chyba',
            description = 'Nemáš oprávnění k tomuto příkazu!',
            type = 'error'
        })
        return
    end

    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then
        print("Hráč s ID " .. src .. " není dostupný!")
        return
    end



    playerID = tonumber(playerID)
    count = tonumber(count)
    if not playerID or not count then
        TriggerClientEvent('pw_give:notifyWithErrorSound', src, {
            title = 'Chyba',
            description = 'Špatný formát ID nebo počtu!',
            type = 'error'
        })
        return
    end

    -- Zkontrolujeme cílového hráče
    local xTarget = ESX.GetPlayerFromId(playerID)
    if not xTarget then
        TriggerClientEvent('pw_give:notifyWithErrorSound', src, {
            title = 'Chyba',
            description = 'Hráč s ID ' .. playerID .. ' nebyl nalezen!',
            type = 'error'
        })
        return
    end

    -- Kontrola platnosti počtu
    if count < 1 then
        TriggerClientEvent('pw_give:notifyWithErrorSound', src, {
            title = 'Chyba',
            description = 'Počet musí být větší než 0!',
            type = 'error'
        })
        return
    end


    local itemData = exports.ox_inventory:Items(thing)
    if not itemData then
        TriggerClientEvent('pw_give:notifyWithErrorSound', src, {
            title = 'Chyba',
            description = 'Item ' .. thing .. ' neexistuje!',
            type = 'error'
        })
        return
    end

    -- Získání Steam jmen
    local srcSteamName = GetPlayerName(src) or "Není Steam jméno"
    local targetSteamName = GetPlayerName(playerID) or "Není Steam jméno"

 
    local srcLicense = xPlayer.identifier or "Není licence"
    local targetLicense = xTarget.identifier or "Není licence"


    if exports.ox_inventory:CanCarryItem(playerID, thing, count) then
        exports.ox_inventory:AddItem(playerID, thing, count)
        

        TriggerClientEvent('pw_give:showNotification', src, {
            title = 'Úspěšně givnuto',
            description = 'Hráči ' .. targetSteamName .. ' bylo dáno ' .. count .. 'x ' .. thing .. '!',
            type = 'success'
        })

        TriggerClientEvent('pw_give:showNotification', playerID, {
            title = 'Dostal jsi item',
            description = 'Bylo ti dáno ' .. count .. 'x ' .. thing .. ' od ' .. srcSteamName .. '!',
            type = 'success'
        })

        -- Discord log
        local logMessage = string.format(
            "**Odesílatel:** %s (ID: %d) \n**License:** %s\n\n**Cíl:** %s (ID: %d)\n**License:** %s\n\n**Item:** %s\n**Počet:** %d",
            srcSteamName,
            src,
            srcLicense,
            targetSteamName, -- Opraveno z srcSteamName
            playerID,
            targetLicense,
            thing,
            count
        )
        exports['pw_logs']:sendToDiscord(
            "DISCORD WEBHOOK URL",
            "Give Item",
            logMessage,
            65280 -- Zelená barva
        )
    else
        TriggerClientEvent('pw_give:notifyWithErrorSound', src, {
            title = 'Chyba',
            description = 'Hráč ' .. targetSteamName .. ' nemá místo v inventáři!',
            type = 'error'
        })
    end
end)