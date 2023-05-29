---------------------------------------------------
---[https://discord.gg/B23yY3UMut] -- SUPPROT
---[MIT License]
---[Copyright (c) 2023 RoyaleWind]
---------------------------------------------------
local Table = {}
local MASTER = {}
local M_INT = 0
---------------------------------------------------
---[SETUP]
---------------------------------------------------
Citizen.CreateThread(function()
    Table = load()
    if Table ~= nil then 
        for i, v in pairs(Table) do
            M_INT = M_INT + 1
            MASTER[M_INT] = {}
            MASTER[M_INT] = Table[i]
            ---[FIXING VECTORS BECOUSE JSON BREAKS IT]
            MASTER[M_INT].tl = vector3(MASTER[M_INT].tl.x,MASTER[M_INT].tl.y,MASTER[M_INT].tl.z)
            MASTER[M_INT].tr = vector3(MASTER[M_INT].tr.x,MASTER[M_INT].tr.y,MASTER[M_INT].tr.z)
            MASTER[M_INT].bl = vector3(MASTER[M_INT].bl.x,MASTER[M_INT].bl.y,MASTER[M_INT].bl.z)
            MASTER[M_INT].br = vector3(MASTER[M_INT].br.x,MASTER[M_INT].br.y,MASTER[M_INT].br.z)
            MASTER[M_INT].pos = vector3(MASTER[M_INT].pos.x,MASTER[M_INT].pos.y,MASTER[M_INT].pos.z)

        end
    else
        save()
    end
end)
---------------------------------------------------
---[PLAYER]
---------------------------------------------------
RegisterNetEvent('rw_draw:GetData')
AddEventHandler('rw_draw:GetData', function()
    local player = source
    while MASTER == nil do 
        Citizen.Wait(1000)
    end
    TriggerClientEvent('rw_draw:Initialize',player,MASTER)
end)

RegisterNetEvent('rw_draw:UpdateImage')
AddEventHandler('rw_draw:UpdateImage', function(texname,url)
    local player = source
    if perms(player) then
        for i, v in pairs(MASTER) do
            if texname == v.texname then
                MASTER[i].url = url
                UpdateImage(i)
            end
        end
    end
end)

RegisterNetEvent('rw_draw:Remove')
AddEventHandler('rw_draw:Remove', function(texname)
    local player = source
    if perms(player) then
        for i, v in pairs(MASTER) do
            if texname == v.texname then
                Remove(i)
            end
        end
    end
end)

RegisterNetEvent('rw_draw:regnew')
AddEventHandler('rw_draw:regnew', function(data)
    local player = source
    if perms(player) then
        M_INT = M_INT + 1
        MASTER[M_INT] = data
        update(M_INT)
    end
end)

RegisterCommand("draw_dev", function(source, args, rawCommand)
    if args[1] ~= nil then
        local send = false
        local tmp = args[1]
        if tmp == "on" then 
            send = true
        else
            send = false
        end
        player = source
        if perms(player) and send ~= nil then 
            TriggerClientEvent('rw_draw:DevMode',-1,send)
        end
    end
end, false)
---------------------------------------------------
---[FUNCTIONS]
---------------------------------------------------
function update(id)
    TriggerClientEvent('rw_draw:NewInit',-1,MASTER[id])
    save()
end

function UpdateImage(id)
    TriggerClientEvent('rw_draw:UpdateImage',-1,MASTER[id].texname,MASTER[id].url)
    save()
end

function Remove(id)
    TriggerClientEvent('rw_draw:Remove',-1,MASTER[id].texname)
    MASTER[i] = nil
    save()
end
---------------------------------------------------
---[UTILS]
---------------------------------------------------
function perms(id) ---[ADD YOUR PERMISION SYSTEM]
    return true
end

function playerloaded(id)
    DoesEntityExist(GetPlayerPed(id))
end

function load()
    local loadFile= LoadResourceFile(GetCurrentResourceName(), "./data.json")
    return (json.decode(loadFile))
end

function save()
    SaveResourceFile(GetCurrentResourceName(), "data.json", json.encode(MASTER), -1)
end
