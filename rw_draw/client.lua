---------------------------------------------------
---[https://discord.gg/B23yY3UMut] -- SUPPROT
---[MIT License]
---[Copyright (c) 2023 RoyaleWind]
---------------------------------------------------
---[SETTINGS]
---------------------------------------------------
local debug = true ---[PRINTS]
local RENDER = 500 ---[RENDER DISTANCE]
local EDIT = 4 ---[EDIT DISTANCE]
-- local Dialog = "rw_dialog" ---[IF YOU HAVE RW_DIALOG USE RW DIALOG] [https://forum.cfx.re/t/rw-dialog/5088577]
local Dialog = "dialog" 
---------------------------------------------------
---[LOCALS NEED IT FOR THE RW_DRAW]
---------------------------------------------------
local REGISTRY = {}
local R_INT = 0
local tpm1 = {}
local tpm2 = {}
local draw = false
local cache = {}
local cache_int = 0
local devmode = false
local poster = false 
---------------------------------------------------
---[SETUP]
---------------------------------------------------
Citizen.CreateThread(function()
   TriggerServerEvent('rw_draw:GetData')
end)
---------------------------------------------------
---[CREATE A NEW CANVAS]
---------------------------------------------------
RegisterCommand("poster", function(source, args, rawCommand)
    if poster then return end
    poster = true 
    tpm1 = getray("[1] TOP LEFT")
    if tpm1 == nil then clmsg("CANCELED") poster = false return end
    Citizen.Wait(1000)
    draw = true
    tpm2 = getray("[2] BOTOM DOWN")
    draw = false
    if tpm2 == nil then clmsg("CANCELED") poster = false return end

    local key = randomString(4)
    ---[STAFF INPOUT]
    local data = exports[Dialog]:Create("ENTER URL", 'HTPS')
    local url = data.value
    if url == nil then clmsg("CANCELED") poster = false return end

    local data = exports[Dialog]:Create("TX NAME", 'not use the same name')
    local name = data.value
    if name == nil then clmsg("CANCELED")  poster = false return end

    local data = exports[Dialog]:Create("width of url", 'only numbers pls')
    local width = tonumber(data.value)
    if width == nil then clmsg("CANCELED") poster = false return end

    local data = exports[Dialog]:Create("height of url", 'only numbers pls')
    local height = tonumber(data.value)
    if height == nil then clmsg("CANCELED") poster = false return end
    ---------------------------------------------------
    name = key.."_"..name
    cache_int = R_INT + 1
    cache[cache_int] = {}
    cache[cache_int].url = url
    cache[cache_int].width = width
    cache[cache_int].height = height
    cache[cache_int].dtexname = name.."_d"
    cache[cache_int].texname = name

    local topLeft = tpm1
    local bottomRight = tpm2
    local bottomLeft = vector3(topLeft.x,topLeft.y,bottomRight.z)
    local topright = vector3(bottomRight.x,bottomRight.y,topLeft.z)
    cache[cache_int].pos = topLeft
    cache[cache_int].tl = topLeft
    cache[cache_int].tr = topright
    cache[cache_int].bl = bottomLeft
    cache[cache_int].br = bottomRight
    TriggerServerEvent("rw_draw:regnew",cache[cache_int])
    clmsg("YOU CREATED A NEW POSTER")
    poster = false 
    -- NewInit(cache[cache_int])
    -- DevUi()
end, false)
---------------------------------------------------
---[FILL REGISTRY]
---------------------------------------------------
function Initialize(data)
    local data = data
    for i, v in pairs(data) do
        R_INT = R_INT + 1
        REGISTRY[R_INT] = {}
        REGISTRY[R_INT] = data[i]
        REG_CANVAS(R_INT)
    end
end

function NewInit(data)
    local data = data
    R_INT = R_INT + 1
    REGISTRY[R_INT] = {}
    REGISTRY[R_INT] = data
    REG_CANVAS(R_INT)
end
---------------------------------------------------
---[REGISTER NEW CANVAS]
---------------------------------------------------
function REG_CANVAS(key)
    local url = REGISTRY[key].url
    local width = REGISTRY[key].width
    local height = REGISTRY[key].height
    local texuredicname = REGISTRY[key].dtexname
    local textureName = REGISTRY[key].texname
    ---[LOCALS]
    local textureDict = CreateRuntimeTxd(texuredicname) 
    local duiObj = CreateDui(url, width, height)
    REGISTRY[key].duiObj = duiObj
    local dui = GetDuiHandle(duiObj)
    local tx = CreateRuntimeTextureFromDuiHandle(textureDict, textureName, dui)

    ---[INITIALIZE]
    InitializePoster(key)
end

function InitializePoster(key)
    Citizen.CreateThread(function()
        clmsg("[PSOTER]:"..key..":STARTED")
        local topLeft = REGISTRY[key].tl
        local topright = REGISTRY[key].tr
        local bottomLeft = REGISTRY[key].bl
        local bottomRight = REGISTRY[key].br
        local texuredicname = REGISTRY[key].dtexname
        local textureName = REGISTRY[key].texname
        -----
        local time = 0
        while REGISTRY[key] ~= nil do
            local ped = GetPlayerPed(-1)
            local playerCoords = GetEntityCoords(ped)
            if IsPlayerNear(playerCoords,REGISTRY[key].pos,RENDER) then 
                time = 0
                DrawSpritePoly(bottomRight.x, bottomRight.y, bottomRight.z, topright.x, topright.y, topright.z, topLeft.x, topLeft.y, topLeft.z, 255, 255, 255, 255, texuredicname, textureName,
                1.0, 1.0, 1.0,
                1.0, 0.0, 1.0,
                0.0, 0.0, 1.0)
               DrawSpritePoly(topLeft.x, topLeft.y, topLeft.z, bottomLeft.x, bottomLeft.y, bottomLeft.z, bottomRight.x, bottomRight.y, bottomRight.z, 255, 255, 255, 255, texuredicname, textureName,
                0.0, 0.0, 1.0,
                0.0, 1.0, 1.0,
                1.0, 1.0)  
            else 
                time = 1000
            end
            Citizen.Wait(time)
        end
        clmsg("[PSOTER]:"..key..":ENDED")
    end)
end
---------------------------------------------------
---[RESET-REMOVE-UPDATE]
---------------------------------------------------
function UpdateImage(texname,url)
    for i, v in pairs(REGISTRY) do
        local name = texname
        if v.texname == name then 
            local duiobj = v.duiObj
            REGISTRY[i].url = url
            SetDuiUrl(duiobj,url)
            clmsg("CANVAS UPDATED ID:"..name)
        end
    end
end

function Remove(texname)
    for i, v in pairs(REGISTRY) do
        local name = v.texname
        if v.texname == name then 
            local duiobj = v.duiObj
            DestroyDui(duiobj)
            REGISTRY[i] = nil
            clmsg("CANVAS DELETED ID:"..name)
        end
    end
end

function RESET()
    for i, v in pairs(REGISTRY) do
        local duiobj = v.duiObj
        DestroyDui(duiobj)
    end
end

function DevMode(state)
    devmode = state
    if devmode then 
        DevUi()
    end
end
---------------------------------------------------
---[UTILS]
---------------------------------------------------
function clmsg(data) 
    if debug then 
        print(data)
    end
end

function IsPlayerNear(playerCoords, vector, distance)
    -- print(json.encode( playerCoords))
    -- print(json.encode( vector))

    local playerDistance = GetDistanceBetweenCoords(playerCoords,vector,true)
    return playerDistance <= distance 
end

function RotationToDirection(rotation)
	local adjustedRotation =
	{
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction =
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination =
	{
		x = cameraCoord.x + direction.x * distance,
		y = cameraCoord.y + direction.y * distance,
		z = cameraCoord.z + direction.z * distance
	}
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
	return b, c, e
end

function Draw2DText(content, font, colour, scale, x, y)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(colour[1],colour[2],colour[3], 255)
    SetTextEntry("STRING")
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    AddTextComponentString(content)
    DrawText(x, y)
end

function getray(id)
    local run = true
    while run do
            local Wait = 5
            local color = {r = 0, g = 255, b = 0, a = 200}
            local position = GetEntityCoords(PlayerPedId())
            local hit, coords, entity = RayCastGamePlayCamera(1000.0)
            Draw2DText('Raycast Coords: ' .. coords.x .. ' ' ..  coords.y .. ' ' .. coords.z, 4, {255, 255, 255}, 0.4, 0.55, 0.650)
            Draw2DText('Press ~g~E ~w~to POSITION : '..id, 4, {255, 255, 255}, 0.4, 0.55, 0.650 + 0.025)
            Draw2DText('Press ~r~DEL ~w~to CANCEL ', 4, {255, 255, 255}, 0.4, 0.55, 0.650 + 0.050)
            DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, color.r, color.g, color.b, color.a, false, true, 2, nil, nil, false)
            if draw then 
                local topLeft = tpm1
                local bottomRight = coords
                local bottomLeft = vector3(topLeft.x,topLeft.y,bottomRight.z)
                local topright = vector3(bottomRight.x,bottomRight.y,topLeft.z)

                DrawMarker(28, topLeft.x, topLeft.y, topLeft.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, color.r, color.g, color.b, color.a, false, true, 2, nil, nil, false)

                DrawPoly(bottomRight,topright,topLeft,0,0,255,200)
                DrawPoly(topLeft,bottomLeft,bottomRight,0,0,255,200)
            end
            if IsControlJustReleased(0, 38) then
                run = false
                return(coords)
            end
            if IsControlJustReleased(0, 178) then ---[DEL CANCEL]
                run = false
                return(nil)
            end
        Citizen.Wait(Wait)
	end
end

function DevUi()
    Citizen.CreateThread(function()
        clmsg("[DEVMODE] ON")
        local time = 0
        local found = false
        while devmode do 
            local ped = GetPlayerPed(-1)
            local playerCoords = GetEntityCoords(ped)
            for i, v in pairs(REGISTRY) do
                if IsPlayerNear(playerCoords,v.pos,EDIT) then 
                    DrawMarker(28, v.pos.x, v.pos.y, v.pos.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, 0, 255, 0, 255, false, true, 2, nil, nil, false)
                    Draw2DText('Press ~r~ DEL ~w~to DELETE : ', 4, {255, 255, 255}, 0.4, 0.55, 0.600)
                    Draw2DText('Press ~g~ E ~w~to EDIT : ', 4, {255, 255, 255}, 0.4, 0.55, 0.620)
                    if IsControlJustReleased(0, 51) then ---[E EDIT]
                        local data = exports[Dialog]:Create("NEW URL", 'ENTER HTTPS')
                        local amount = data.value
                        if amount then
                            TriggerServerEvent("rw_draw:UpdateImage",v.texname,amount)
                            time = 1000
                        end 
                    end
                    if IsControlJustReleased(0, 178) then ---[DEL DELETE]
                        if exports[Dialog]:Decision("ARE YOU SURE YOU WONT TO DELETE", 'THIS CANVAS', '', 'YES', 'NO').action == 'submit' then
                            TriggerServerEvent("rw_draw:Remove",v.texname)
                            time = 1000
                        else
                            clmsg('[CANCLED ACTION TO DELETE]')
                        end 
                    end
                end
            end
            Citizen.Wait(time)
            if time ~= 0 then 
                time = 0
            end
        end
        clmsg("[DEVMODE] OFF")
    end)
end

function randomString(length)
    local chars = {}
    for i = 1, length do
      chars[i] = string.char(math.random(65, 90))
    end
    return table.concat(chars)
end
---------------------------------------------------
---[EVENTS]
---------------------------------------------------
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    RESET()
end)
RegisterNetEvent('rw_draw:Initialize', Initialize) ---[data]
RegisterNetEvent('rw_draw:NewInit', NewInit) ---[data]
RegisterNetEvent('rw_draw:Remove', Remove)  ---[texname]
RegisterNetEvent('rw_draw:UpdateImage', UpdateImage) ---[texname,url]
RegisterNetEvent('rw_draw:DevMode', DevMode) ---[state]