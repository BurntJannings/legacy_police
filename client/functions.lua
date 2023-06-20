local IsSearching = false

VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)

VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
end)

function HandcuffPlayer() --Handcuff player function
    MenuData.CloseAll()
    Inmenu = false
    local closestPlayer, closestDistance = GetClosestPlayer()
    local targetplayerid = GetPlayerServerId(closestPlayer)
    local isDead = IsEntityDead(PlayerPedId())

    if closestDistance <= 3.0 then
        if not isDead then
            TriggerServerEvent('lawmen:handcuff', targetplayerid)
            if not IsSearching then
                IsSearching = true
                --CuffPlayer(closestPlayer)
            elseif IsSearching then
                IsSearching = false
            end
        end
    else
        VORPcore.NotifyBottomRight(_U('notcloseenough'), 4000)
    end
end

function GetClosestPlayer() -- Get closest player function
    local players, closestDistance, closestPlayer = GetActivePlayers(), -1, -1
    local playerPed, playerId = PlayerPedId(), PlayerId()
    local coords, usePlayerPed = coords, false

    if coords then
        coords = vector3(coords.x, coords.y, coords.z)
    else
        usePlayerPed = true
        coords = GetEntityCoords(playerPed)
    end

    for i = 1, #players, 1 do
        local tgt = GetPlayerPed(players[i])

        if not usePlayerPed or (usePlayerPed and players[i] ~= playerId) then
            local targetCoords = GetEntityCoords(tgt)
            local distance = #(coords - targetCoords)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = players[i]
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end

function CuffPlayer(closestPlayer) -- Prompt and code to access Gun Cabinets
    while true do
        local playercoords = GetEntityCoords(PlayerPedId())
        local tgtcoords = GetEntityCoords(GetPlayerPed(closestPlayer))
        local distance = #(playercoords - tgtcoords)
        local isDead = IsEntityDead(PlayerPedId())
        Wait(5)
        if distance <= 1.5 then
            if not isDead then
                if IsSearching then
                    if not Inmenu then
                        if not InWagon then
                            local item_name = CreateVarString(10, 'LITERAL_STRING', _U('searchplayer'))
                            PromptSetActiveGroupThisFrame(prompt2, item_name)
                        end
                    end
                end
            end
        end
        if PromptHasHoldModeCompleted(Search) then
            TriggerServerEvent('lawmen:grabdata', GetPlayerServerId(closestPlayer))
            Wait(200)
            if Takenmoney then
                SearchMenu(Takenmoney)
            end
        end
    end
end

function DrawTxt(text, x, y, w, h, enableShadow, col1, col2, col3, a, centre) -- Draw text function
    local str = CreateVarString(10, "LITERAL_STRING", text)
    SetTextScale(w, h)
    SetTextColor(math.floor(col1), math.floor(col2), math.floor(col3), math.floor(a))
    SetTextCentre(centre)
    if enableShadow then SetTextDropshadow(1, 0, 0, 0, 255) end
    Citizen.InvokeNative(0xADA9255D, 1);
    DisplayText(str, x, y)
end

function CreateVarString(p0, p1, variadic) -- Create variable string function
    return Citizen.InvokeNative(0xFA925AC00EB830B9, p0, p1, variadic, Citizen.ResultAsLong())
end

function CheckTable(table, element) --Job checking table
    for k, v in pairs(table) do
        if v == element then
            return true
        end
    end
    return false
end

function GetPlayers() -- Get players function
    local players = {}
    for i = 0, 256 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, GetPlayerServerId(i))
        end
    end
    return players
end

function PutInOutVehicle()
    local closestPlayer, closestDistance = GetClosestPlayer()
    local iscuffed = Citizen.InvokeNative(0x74E559B3BC910685, closestPlayer)
    print(iscuffed)
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        TriggerServerEvent('lawmen:GetPlayerWagonID', GetPlayerServerId(closestPlayer))
    else
        VORPcore.NotifyBottomRight(_U('notcloseenough'), 4000)
        return
    end
end

function GetClosestVehicle(coords)
    local ped = PlayerPedId()
    local objects = GetGamePool('CVehicle')
    local closestDistance = -1
    local closestObject = -1
    if coords then
    else
        coords = GetEntityCoords(ped)
    end
    for i = 1, #objects, 1 do
        local objectCoords = GetEntityCoords(objects[i])
        local distance = #(objectCoords - coords)
        if closestDistance == -1 or closestDistance > distance then
            closestObject = objects[i]
            closestDistance = distance
        end
    end
    return closestObject, closestDistance
end

function DrawText3D(x, y, z, text)
    local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)
    local px,py,pz=table.unpack(GetGameplayCamCoord())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    if onScreen then
        SetTextScale(0.30, 0.30)
        SetTextFontForCurrentCommand(1)
        SetTextColor(255, 255, 255, 215)
        SetTextCentre(1)
        DisplayText(str,_x,_y)
        local factor = (string.len(text)) / 225
        DrawSprite("feeds", "hud_menu_4a", _x, _y+0.0125,0.015+ factor, 0.03, 0.1, 35, 35, 35, 190, 0)
    end
end