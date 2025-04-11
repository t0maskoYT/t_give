CreateThread(function()
    RegisterCommand('give', function()
        local input = lib.inputDialog('GIVE ITEM', {
            { type = 'number', label = 'ID hráče', placeholder = '1', required = true },
            { type = 'input', label = 'Item', placeholder = 'burger', required = true },
            { type = 'number', label = 'Počet', placeholder = '1', required = true },
        })
    
        if not input then
            return -- Pokud hráč zavře dialog, nic se nepošle
        end
    
        local playerID = input[1]
        local thing = input[2]
        local count = input[3]
    
        -- Pokud je vše OK, pošleme data na server
        TriggerServerEvent('pw_give:request', playerID, thing, count)
    end, false)
    
    RegisterNetEvent('pw_give:notifyWithErrorSound')
    AddEventHandler('pw_give:notifyWithErrorSound', function(data)
        lib.notify({
            title = data.title,
            description = data.description,
            type = data.type
        })
        PlaySoundFrontend(-1, "ERROR", "HUD_AMMO_SHOP_SOUNDSET", 1)
    end)

    RegisterNetEvent('pw_give:showNotification')
    AddEventHandler('pw_give:showNotification', function(data)
        lib.notify({
            title = data.title,
            description = data.description,
            type = data.type
        })
    end)
end)