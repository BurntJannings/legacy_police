local IsHandcuffed, Autotele, Jailed, InWagon, display, badgeactive, dragStatus = false, true, false, false, false, false, {}
local playerJob, JailID, currentCheck, jaillocation, Open, Search, searchid
Choreamount = _U('none')
Takenmoney, PoliceOnDuty = nil, nil

dragStatus.isDragged = false

local prompt2 = GetRandomIntInRange(0, 0xffffff)
local prompt = GetRandomIntInRange(0, 0xffffff)

CreateThread(function()
    local str = _U('opencabinet')
    Open = PromptRegisterBegin()
    PromptSetControlAction(Open, 0xCEFD9220)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(Open, str)
    PromptSetEnabled(Open, true)
    PromptSetVisible(Open, true)
    PromptSetHoldMode(Open, true, 2000)
    PromptSetGroup(Open, prompt)
    PromptRegisterEnd(Open)

    local str = _U('search')
    Search = PromptRegisterBegin()
    PromptSetControlAction(Search, 0xC7B5340A)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(Search, str)
    PromptSetEnabled(Search, true)
    PromptSetVisible(Search, true)
    PromptSetHoldMode(Search, true, 2000)
    PromptSetGroup(Search, prompt2)
    PromptRegisterEnd(Search)
end)

CreateThread(function() -- In jail chores to reduce time in jail
    while true do
        Wait(5)
        if Jailed then
            local doingchore = false
            for k, v in pairs(ConfigJail.jailchores) do
                local blip = N_0x554d9d53f696d002(1664425300, v.x, v.y, v.z)
                SetBlipSprite(blip, 28148096, 1)
                Citizen.InvokeNative(0x9CB1A1623062F402, blip, _U('jailchoreblip'))
                local coords = GetEntityCoords(PlayerPedId())
                local currentCheck = Vdist2(coords.x, coords.y, coords.z, v.x, v.y, v.z)
                if currentCheck < 5 then
                    DrawTxt(_U('presstodotask'), 0.42, 0.90, 0.4, 0.4, true, 255, 255, 255, 255, false)
                    if IsControlJustReleased(0, 0xCEFD9220) and doingchore == false then
                        TaskStartScenarioInPlace(PlayerPedId(), GetHashKey('WORLD_HUMAN_BROOM_WORKING'), 10000, true,
                            false, false, false)
                        Wait(10000)
                        ClearPedTasksImmediately(PlayerPedId())
                        SetCurrentPedWeapon(PlayerPedId(), GetHashKey('WEAPON_UNARMED'), true) -- unarm player
                        Jail_time = Jail_time - 10
                        Wait(10000)
                    end
                end
            end
        else
            Wait(500)
        end
    end
end)

CreateThread(function() -- In jail chores to reduce time in jail
    while true do
        Wait(5)
        local playercoords = GetEntityCoords(PlayerPedId())
        if Jailed then
            if JailID == "sk" then
                local Jailedcoords = GetEntityCoords(PlayerPedId())
                local currentCheck = GetDistanceBetweenCoords(Jailedcoords.x, Jailedcoords.y, Jailedcoords.z,
                    ConfigJail.Jails.sisika.entrance.x, ConfigJail.Jails.sisika.entrance.y,
                    ConfigJail.Jails.sisika.entrance.z,
                    true)
                if currentCheck > 420 then
                    TriggerEvent("lawmen:breakout")
                end
            else
                local Jailedcoords = GetEntityCoords(PlayerPedId())
                local currentCheck2 = GetDistanceBetweenCoords(playercoords.x, playercoords.y, playercoords.z,
                    Jailedcoords.x, Jailedcoords.y, Jailedcoords.z, true)
                if currentCheck2 > 15 then
                    TriggerEvent("lawmen:breakout")
                end
            end
        else
            Wait(500)
        end
    end
end)

CreateThread(function() -- Community Service Logic, including animations minigame difficulty and more
    while true do
        Wait(5)
        local coords = GetEntityCoords(PlayerPedId())
        if Serviced then
            if not Serviceblip then
                Serviceblip = N_0x554d9d53f696d002(1664425300, Pos.x, Pos.y, Pos.z)
                SetBlipSprite(Serviceblip, 28148096, 1)
                Citizen.InvokeNative(0x9CB1A1623062F402, Serviceblip, _U('jailchoreblip'))
            end

            currentCheck = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, Pos.x, Pos.y, Pos.z, true)
            if currentCheck < 1 then
                DrawTxt(_U('presstodotask'), 0.38, 0.90, 0.4, 0.4, true, 255, 255, 255, 255, false)
                if IsControlJustReleased(0, 0xCEFD9220) then
                    if ConfigService.CommunityServiceSettings.minigame then
                        local test = exports["syn_minigame"]:taskBar(3000, 7) -- difficulty,skillGapSent
                        if test == 100 then
                            local ped = PlayerPedId()
                            if IsPedMale(ped) then
                                TaskStartScenarioInPlace(PlayerPedId(),
                                    GetHashKey('PROP_HUMAN_REPAIR_WAGON_WHEEL_ON_SMALL'), 10000, true, false, false,
                                    false)
                            else
                                TaskStartScenarioInPlace(PlayerPedId(), GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), 10000,
                                    true, false, false, false)
                            end
                            Wait(12000)
                            Choreamount = Choreamount - 1
                            TriggerServerEvent("lawmen:updateservice")
                        else
                            VORPcore.NotifyBottomRight(_U('taskfailed'), 4000)
                        end
                    else
                        TaskStartScenarioInPlace(PlayerPedId(), GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), 10000, true,
                            false, false, false)
                        Wait(10000)
                        SetCurrentPedWeapon(PlayerPedId(), GetHashKey('WEAPON_UNARMED'), true) -- unarm player
                    end
                end
            end

            for k, v in pairs(ConfigService.construction) do
                local coords = GetEntityCoords(PlayerPedId())
                if GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) >
                    ConfigService.CommunityServiceSettings.communityservicedistance then
                    Brokedistance = true
                else
                    Brokedistance = false
                end
            end
        else
            Wait(200)
        end

        if Choreamount and Choreamount == 0 then
            TriggerServerEvent("lawmen:endservice")
            Serviced = false
            RemoveBlip(Serviceblip)
            Serviceblip = nil
            VORPcore.NotifyBottomRight(_U('servicecomplete'), 4000)
            break
        end
    end
end)

RegisterNetEvent("lawmen:ServicePlayer") -- Assigns Chore amount and picks random coord for construcion
AddEventHandler("lawmen:ServicePlayer", function(chore, amount)
    Serviced = true
    Choreamount = amount
    Pos = ConfigService.construction[math.random(1, #ConfigService.construction)]
end)

CreateThread(function() -- Prompt and code to access Gun Cabinets
    while true do
        Wait(5)
        local coords = GetEntityCoords(PlayerPedId())
        local isDead = IsEntityDead(PlayerPedId())
        for k, v in pairs(ConfigCabinets.Guncabinets) do
            if GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 1.5 and not Inmenu then
                if not isDead then
                    local item_name = CreateVarString(10, 'LITERAL_STRING', _U('opencabinet'))
                    PromptSetActiveGroupThisFrame(prompt, item_name)

                    if PromptHasHoldModeCompleted(Open) then
                        TriggerServerEvent("lawmen:PlayerJob") -- run client side check before check for distance. no need to run code that is not meant for the client its optimized this way
                        Wait(200)
                        if CheckTable(OnDutyJobs, playerJob) then
                            Inmenu = true
                            CabinetMenu()
                        end
                    end
                end
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(5)
        if InWagon then
            SetRelationshipBetweenGroups(1, `PLAYER`, `PLAYER`)
        else
            Wait(500)
        end
    end
end)

RegisterNetEvent('lawmen:PlayerInWagon') --Put in Vehicle logic, not in use currently
AddEventHandler('lawmen:PlayerInWagon', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local closestWagon = GetClosestVehicle(coords)
    local vehicle = IsPedInVehicle(ped, closestWagon, 0)
    if ped ~= nil then
        if not vehicle then
            SetPedIntoVehicle(ped, closestWagon, -2)
            Wait(500)
            InWagon = true
        else
            TaskLeaveVehicle(ped, closestWagon, 16)
            Wait(5000)
            InWagon = false
        end
    end
end)

CreateThread(function()
    while true do
        Wait(5)
        if InWagon then
            DisableControlAction(1, 0xFEFAB9B4, true)
            DisableControlAction(1, 0xE31C6A41, true)
            DisableControlAction(1, 0x4CC0E2FE, true)
        else
            Wait(500)
        end
    end
end)

RegisterNetEvent('lawmen:StartSearch', function()
    local closestPlayer, closestDistance = GetClosestPlayer()
    searchid = GetPlayerServerId(closestPlayer)
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        TriggerServerEvent("lawmen:ReloadInventory", searchid)
        TriggerEvent("vorp_inventory:OpenstealInventory", _U('inventorytitle'), searchid)
    end
end)

RegisterNetEvent('lawmen:GetSearch')
AddEventHandler('lawmen:GetSearch', function(obj)
    TriggerServerEvent('lawmen:TakeFrom', obj, searchid)
end)

RegisterNetEvent("lawmen:PlayerJob") -- Job check event
AddEventHandler("lawmen:PlayerJob", function(Job)
    playerJob = Job
end)

RegisterNetEvent("lawmen:senddata") -- Job check event
AddEventHandler("lawmen:senddata", function(playermoney)
    Takenmoney = playermoney
end)

RegisterNetEvent("lawmen:breakout") -- Event for breaking out
AddEventHandler("lawmen:breakout", function()
    local coords = GetEntityCoords(PlayerPedId())
    local local_player = PlayerId()
    TriggerServerEvent('lawmen:jailbreak')
    TriggerServerEvent('lawmen:policenotify', coords)
    VORPcore.NotifyBottomRight(_U('jailbreak'), 4000)
    Jailed = false
    Jail_time = 0
    SetPlayerInvincible(local_player, false)
end)

RegisterNetEvent("vorp:SelectedCharacter") -- Event for checking jail and job on character select
AddEventHandler("vorp:SelectedCharacter", function(charid)
    TriggerServerEvent("lawmen:check_jail")
    Wait(200)
    TriggerServerEvent("lawmen:gooffdutysv")
    TriggerServerEvent("judicial:gooffdutysv")
end)

RegisterNetEvent("lawmen:onduty")
AddEventHandler("lawmen:onduty", function(duty)
    if not duty then
        PoliceOnDuty = false
        if ConfigMain.synsociety then
            TriggerServerEvent('lawmen:synsociety', false)
            ExecuteCommand('refreshjob')
        end
    else
        PoliceOnDuty = true
        if ConfigMain.synsociety then
            TriggerServerEvent('lawmen:synsociety', true)
            ExecuteCommand('refreshjob')
        end
    end
end)

Badge = nil
Badgex, Badgey, Badgez = 0.17, -0.19, -0.25
BadgeCoords = nil
MaleboneIndex = 458
FemaleboneIndex = 500
Rotationz = 30.0


--Badges
RegisterNetEvent("legacy_police:badgeon")
AddEventHandler("legacy_police:badgeon", function(playerjob, jobgrade)
    Wait(60)
    local ped = PlayerPedId()

    if not badgeactive then
        badgeactive = true
        Wait(5)

        if playerjob == "police" and jobgrade ~= 6 then
            if IsPedMale(ped) then
                Badge = CreateObject(GetHashKey("s_badgedeputy01x"), Badgex, Badgey, Badgez + 0.2, true, false, false)
                AttachEntityToEntity(Badge, ped, MaleboneIndex, Badgex, Badgey, Badgez, -15.0, 0.0, Rotationz, true, true,
                    false, true, 1, true)
                BadgeCoords = GetEntityCoords(Badge)
            else
                Badge = CreateObject(GetHashKey("s_badgedeputy01x"), Badgex, Badgey, Badgez + 0.2, true, false, false)
                AttachEntityToEntity(Badge, ped, FemaleboneIndex, Badgex, Badgey, Badgez, -15.0, 0.0, 30.0, false,
                    true,
                    false,
                    true, 1,
                    true)
                BadgeCoords = GetEntityCoords(Badge)
            end
        elseif playerjob == "police" and jobgrade == 6 then
            --Sheriff

            if IsPedMale(ped) then
                Badge = CreateObject(GetHashKey("s_badgesherif01x"), Badgex, Badgey, Badgez + 0.2, true, false, false)
                AttachEntityToEntity(Badge, ped, MaleboneIndex, 0.17, -0.19, -0.25, -12.5, 0.0, 30.0, false, true,
                    false,
                    true, 1,
                    true)
                BadgeCoords = GetEntityCoords(Badge)
            else
                Badge = CreateObject(GetHashKey("s_badgesherif01x"), Badgex, Badgey, Badgez + 0.2, true, false, false)
                AttachEntityToEntity(Badge, ped, FemaleboneIndex, 0.17, -0.19, -0.25, -12.5, 0.0, 30.0, false, true,
                    false,
                    true, 1,
                    true)
                BadgeCoords = GetEntityCoords(Badge)
            end

            --Rangers
        elseif playerjob == "marshal" and jobgrade ~= nil then
            if IsPedMale(ped) then
                Badge = CreateObject(GetHashKey("s_badgeusmarshal01x"), Badgex, Badgey, Badgez + 0.2, true, false,
                    false)
                AttachEntityToEntity(Badge, ped, MaleboneIndex, 0.17, -0.19, -0.25, -12.5, 0.0, 30.0, false, true,
                    false,
                    true, 1,
                    true)
                BadgeCoords = GetEntityCoords(Badge)
            else
                Badge = CreateObject(GetHashKey("s_badgeusmarshal01x"), Badgex, Badgey, Badgez + 0.2, true, false,
                    false)
                AttachEntityToEntity(Badge, ped, FemaleboneIndex, 0.17, -0.19, -0.25, -12.5, 0.0, 30.0, false, true,
                    false,
                    true, 1,
                    true)
                BadgeCoords = GetEntityCoords(Badge)
            end
        end

        VORPcore.NotifyBottomRight(_U('badgeon'), 4000)
    else
        DeleteObject(Badge)
        badgeactive = false
        VORPcore.NotifyBottomRight(_U('badgeoff'), 4000)
    end
end)

RegisterNetEvent("lawmen:goonduty") -- Go on duty event
AddEventHandler("lawmen:goonduty", function()
    if PoliceOnDuty then
        VORPcore.NotifyBottomRight(_U('onduty'), 4000)
    else
        TriggerServerEvent('lawmen:goondutysv', GetPlayers())
    end
end)

RegisterCommand(ConfigMain.ondutycommand, function() -- on duty command
    TriggerEvent('lawmen:goonduty')
end)
RegisterCommand(ConfigMain.adjustbadgecommand,
    function()
        local ped = PlayerPedId()
        -- on duty command
        local PromptGroup = VORPutils.Prompts:SetupPromptGroup()                                 --Setup Prompt Group
        local firstprompt = PromptGroup:RegisterPrompt("Up", 0x6319DB71, 1, 1, true, 'click')    --Register your first prompt
        local secondprompt = PromptGroup:RegisterPrompt("Down", 0x05CA7C52, 1, 1, true, 'click') --Register your first prompt
        local thirdprompt = PromptGroup:RegisterPrompt("Left", 0x20190AB4, 1, 1, true, 'click')  --Register your first prompt
        local fourthprompt = PromptGroup:RegisterPrompt("Right", 0xC97792B7, 1, 1, true, 'click')
        local fifthprompt = PromptGroup:RegisterPrompt("In", 0xE6F612E4, 1, 1, true, 'click')    --Register your first prompt
        local sixthprompt = PromptGroup:RegisterPrompt("Out", 0x1CE6D9EB, 1, 1, true, 'click')
        local seventhprompt = PromptGroup:RegisterPrompt("Rotate Left", 0xAE69478F, 1, 1, true, 'click')
        local eighthprompt = PromptGroup:RegisterPrompt("Rotate Right", 0x8F9F9E58, 1, 1, true, 'click')

        if PoliceOnDuty and badgeactive then
            if not display then
                display = true
                --Register your first promp
                while true do
                    Wait(5)

                    if display and badgeactive then
                        if IsPedMale(ped) then
                            AttachEntityToEntity(Badge, ped, MaleboneIndex, Badgex, Badgey, Badgez, -15.0, 0.0, Rotationz,
                                true, true, false, true, 1, true)
                        else
                            AttachEntityToEntity(Badge, ped, FemaleboneIndex, Badgex, Badgey, Badgez, -15.0, 0.0,
                                Rotationz,
                                true, true, false, true, 1, true)
                        end
                        PromptGroup:ShowGroup("Move your badge") --Show your prompt group
                        if firstprompt:HasCompleted() then
                            Badgez = Badgez + 0.01
                        end
                        if secondprompt:HasCompleted() then
                            Badgez = Badgez - 0.01
                        end
                        if thirdprompt:HasCompleted() then
                            Badgex = Badgex + 0.01
                        end
                        if fourthprompt:HasCompleted() then
                            Badgex = Badgex - 0.01
                        end
                        if fifthprompt:HasCompleted() then
                            Badgey = Badgey + 0.01
                        end
                        if sixthprompt:HasCompleted() then
                            Badgey = Badgey - 0.01
                        end
                        if seventhprompt:HasCompleted() then
                            Rotationz = Rotationz + 2.0
                        end
                        if eighthprompt:HasCompleted() then
                            Rotationz = Rotationz - 2.0
                        end
                    end
                end
            else
                display = false
                firstprompt:TogglePrompt(false)
                secondprompt:TogglePrompt(false)
                thirdprompt:TogglePrompt(false)
                fourthprompt:TogglePrompt(false)
                fifthprompt:TogglePrompt(false)
                sixthprompt:TogglePrompt(false)
                seventhprompt:TogglePrompt(false)
                eighthprompt:TogglePrompt(false)
            end
        end
    end)

RegisterNetEvent("lawmen:gooffduty") -- Go off duty event
AddEventHandler("lawmen:gooffduty", function()
    TriggerServerEvent("lawmen:gooffdutysv")
end)

RegisterCommand(ConfigMain.offdutycommand, function() -- Go off duty command
    TriggerEvent('lawmen:gooffduty')
end)

RegisterCommand(ConfigMain.openpolicemenu, function()
    if PoliceOnDuty and not IsEntityDead(PlayerPedId()) then
        OpenPoliceMenu()
    else
        return
    end
end)

-- Disable player actions when handcuffed
CreateThread(function()
    while true do
        Citizen.Wait(5)
        if IsHandcuffed then
            DisableControlAction(0, 0xB2F377E8, true) -- Attack
            DisableControlAction(0, 0xC1989F95, true) -- Attack 2
            DisableControlAction(0, 0x07CE1E61, true) -- Melee Attack 1
            DisableControlAction(0, 0xF84FA74F, true) -- MOUSE2
            DisableControlAction(0, 0xCEE12B50, true) -- MOUSE3
            DisableControlAction(0, 0x8FFC75D6, true) -- Shift
            DisableControlAction(0, 0xD9D0E1C0, true) -- SPACE
            DisableControlAction(0, 0xF3830D8E, true) -- J
            DisableControlAction(0, 0x80F28E95, true) -- L
            DisableControlAction(0, 0xDB096B85, true) -- CTRL
            DisableControlAction(0, 0xE30CD707, true) -- R
        elseif IsHandcuffed and IsPedDeadOrDying(PlayerPedId()) then
            ClearPedSecondaryTask(PlayerPedId())
            SetEnableHandcuffs(PlayerPedId(), false)
            DisablePlayerFiring(PlayerPedId(), false)
            SetPedCanPlayGestureAnims(PlayerPedId(), true)
            Wait(500)
        else
            Wait(500)
        end
    end
end)

CreateThread(function() -- Logic for dragging person cuffed
    local wasDragged
    while true do
        Citizen.Wait(5)
        local playerPed = PlayerPedId()
        if IsHandcuffed and dragStatus.isDragged then
            local targetPed = GetPlayerPed(GetPlayerFromServerId(dragStatus.CopId))
            if DoesEntityExist(targetPed) and IsPedOnFoot(targetPed) and not IsPedDeadOrDying(targetPed, true) then
                if not wasDragged then
                    AttachEntityToEntity(playerPed, targetPed, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false
                    , false, 2, true)
                    wasDragged = true
                else
                    Citizen.Wait(1000)
                end
            else
                wasDragged = false
                dragStatus.isDragged = false
                DetachEntity(playerPed, true, false)
            end
        elseif wasDragged then
            wasDragged = false
            DetachEntity(playerPed, true, false)
        else
            Wait(500)
        end
    end
end)

RegisterNetEvent('lawmen:drag') -- Event to register dragging
AddEventHandler('lawmen:drag', function(copId)
    if IsHandcuffed then
        dragStatus.isDragged = not dragStatus.isDragged
        dragStatus.CopId = copId
    end
end)

RegisterNetEvent("lawmen:JailPlayer") -- Jailing player event
AddEventHandler("lawmen:JailPlayer", function(time, Location)
    local ped = PlayerPedId()
    local time_minutes = math.floor(time / 60)
    JailID = Location
    Serviced = false
    if not Jailed then
        if Autotele then
            DoScreenFadeOut(500)
            Citizen.Wait(600)
            if JailID == "sk" then
                SetEntityCoords(ped, ConfigJail.Jails.sisika.entrance.x, ConfigJail.Jails.sisika.entrance.y,
                    ConfigJail.Jails.sisika.entrance.z)
            elseif JailID == "bw" then
                SetEntityCoords(ped, ConfigJail.Jails.blackwater.entrance.x, ConfigJail.Jails.blackwater.entrance.y,
                    ConfigJail.Jails.blackwater.entrance.z)
            elseif JailID == "st" then
                SetEntityCoords(ped, ConfigJail.Jails.strawberry.entrance.x, ConfigJail.Jails.strawberry.entrance.y,
                    ConfigJail.Jails.strawberry.entrance.z)
            elseif JailID == "val" then
                SetEntityCoords(ped, ConfigJail.Jails.valentine.entrance.x, ConfigJail.Jails.valentine.entrance.y,
                    ConfigJail.Jails.valentine.entrance.z)
            elseif JailID == "ar" then
                SetEntityCoords(ped, ConfigJail.Jails.armadillo.entrance.x, ConfigJail.Jails.armadillo.entrance.y,
                    ConfigJail.Jails.armadillo.entrance.z)
            elseif JailID == "tu" then
                SetEntityCoords(ped, ConfigJail.Jails.tumbleweed.entrance.x, ConfigJail.Jails.tumbleweed.entrance.y,
                    ConfigJail.Jails.tumbleweed.entrance.z)
            elseif JailID == "rh" then
                SetEntityCoords(ped, ConfigJail.Jails.rhodes.entrance.x, ConfigJail.Jails.rhodes.entrance.y,
                    ConfigJail.Jails.rhodes.entrance.z)
            elseif JailID == "sd" then
                SetEntityCoords(ped, ConfigJail.Jails.stdenis.entrance.x, ConfigJail.Jails.stdenis.entrance.y,
                    ConfigJail.Jails.stdenis.entrance.z)
            elseif JailID == "an" then
                SetEntityCoords(ped, ConfigJail.Jails.annesburg.entrance.x, ConfigJail.Jails.annesburg.entrance.y,
                    ConfigJail.Jails.annesburg.entrance.z)
            end
            FreezeEntityPosition(ped, true)
            Jail_time = time
            Jailed = true
            RemoveAllPedWeapons(ped, true)
            DoScreenFadeIn(500)
            Citizen.Wait(600)
            VORPcore.NotifyBottomRight(_U('imprisoned') .. time_minutes .. _U('minutes'), 4000)
            FreezeEntityPosition(ped, false)
            TriggerEvent("lawmen:wear_prison", ped)
            Wait(500)
        else
            Jail_time = time
            Jailed = true
            Citizen.Wait(600)
            RemoveAllPedWeapons(ped, true)
            VORPcore.NotifyBottomRight(_U('imprisoned') .. time_minutes .. _U('minutes'), 4000)
            TriggerEvent("lawmen:wear_prison", ped)
        end
    end
end)

RegisterNetEvent("lawmen:wear_prison") -- Wear prison outfit event
AddEventHandler("lawmen:wear_prison", function()
    local ped = PlayerPedId()
    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, 0x9925C067, true, true, true)
    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, 0x485EE834, true, true, true)
    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, 0x18729F39, true, true, true)
    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, 0x3107499B, true, true, true)
    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, 0x3C1A74CD, true, true, true)
    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, 0x3F1F01E5, true, true, true)
    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, 0x3F7F3587, true, true, true)
    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, 0x49C89D9B, true, true, true)
    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, 0x4A73515C, true, true, true)
    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, 0x514ADCEA, true, true, true)
    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, 0x5FC29285, true, true, true)
    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, 0x79D7DF96, true, true, true)
    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, 0x7A96FACA, true, true, true)
    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, 0x877A2CF7, true, true, true)
    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, 0x9B2C8B89, true, true, true)
    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, 0xA6D134C6, true, true, true)
    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, 0xE06D30CE, true, true, true)
    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, 0x662AC34, true, true, true)
    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, 0xAF14310B, true, true, true)
    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, 0x72E6EF74, true, true, true)
    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, 0xEABE0032, true, true, true)
    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, 0x2026C46D, true, true, true)

    if IsPedMale(ped) then
        Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, 0x5BA76CCF, true, true, true)
        Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, 0x216612F0, true, true, true)
        Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, 0x1CCEE58D, true, true, true)
    else
        Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, 0x6AB27695, true, true, true)
        Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, 0x75BC0CF5, true, true, true)
        Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, 0x14683CDF, true, true, true)
    end
    RemoveAllPedWeapons(ped, true, true)
end)

RegisterNetEvent("lawmen:UnjailPlayer") -- Unjail player event
AddEventHandler("lawmen:UnjailPlayer", function(jaillocation)
    local local_ped = PlayerPedId()
    local local_player = PlayerId()
    JailID = jaillocation
    ExecuteCommand('rc')
    VORPcore.NotifyBottomRight(_U('released'), 4000)
    Jailed = false
    Jail_time = 0
    if Autotele then
        if JailID == "sk" then
            SetEntityCoords(local_ped, ConfigJail.Jails.sisika.exit.x, ConfigJail.Jails.sisika.exit.y,
                ConfigJail.Jails.sisika.exit
                .z)
        elseif JailID == "bw" then
            SetEntityCoords(local_ped, ConfigJail.Jails.blackwater.exit.x, ConfigJail.Jails.blackwater.exit.y,
                ConfigJail.Jails.blackwater.exit.z)
        elseif JailID == "st" then
            SetEntityCoords(local_ped, ConfigJail.Jails.strawberry.exit.x, ConfigJail.Jails.strawberry.exit.y,
                ConfigJail.Jails.strawberry.exit.z)
        elseif JailID == "val" then
            SetEntityCoords(local_ped, ConfigJail.Jails.valentine.exit.x, ConfigJail.Jails.valentine.exit.y,
                ConfigJail.Jails.valentine.exit.z)
        elseif JailID == "ar" then
            SetEntityCoords(local_ped, ConfigJail.Jails.armadillo.exit.x, ConfigJail.Jails.armadillo.exit.y,
                ConfigJail.Jails.armadillo.exit.z)
        elseif JailID == "tu" then
            SetEntityCoords(local_ped, ConfigJail.Jails.tumbleweed.exit.x, ConfigJail.Jails.tumbleweed.exit.y,
                ConfigJail.Jails.tumbleweed.exit.z)
        elseif JailID == "rh" then
            SetEntityCoords(local_ped, ConfigJail.Jails.rhodes.exit.x, ConfigJail.Jails.rhodes.exit.y,
                ConfigJail.Jails.rhodes.exit
                .z)
        elseif JailID == "sd" then
            SetEntityCoords(local_ped, ConfigJail.Jails.stdenis.exit.x, ConfigJail.Jails.stdenis.exit.y,
                ConfigJail.Jails.stdenis.exit.z)
        elseif JailID == "an" then
            SetEntityCoords(local_ped, ConfigJail.Jails.annesburg.exit.x, ConfigJail.Jails.annesburg.exit.y,
                ConfigJail.Jails.annesburg.exit.z)
        end
        SetPlayerInvincible(local_player, false)
    else
        SetPlayerInvincible(local_player, false)
    end
end)

CreateThread(function() --Display timer when in jail logic
    while true do
        Wait(5)
        if Jailed then
            DrawTxt(_U('imprisoned') .. Jail_time .. _U('jailseconds'), 0.38, 0.95, 0.4, 0.4, true, 255, 0, 0, 255, false)
        else
            Wait(200)
        end
    end
end)

RegisterNetEvent("lawmen:cuffs") --Cuffing player event
AddEventHandler("lawmen:cuffs", function()
    HandcuffPlayer()
end)

RegisterNetEvent("lawmen:lockpick") -- Lockpicking handcuffs event
AddEventHandler("lawmen:lockpick", function()
    local closestPlayer, closestDistance = GetClosestPlayer()
    local isDead = IsEntityDead(PlayerPedId())

    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        local chance = math.random(1, 100)
        if not isDead then
            if chance < 85 then
                local anim = "mini_games@story@mud5@cracksafe_look_at_dial@med_r@ped"
                local idle = "base_idle"
                local lr = "left_to_right"
                local rl = "right_to_left"
                RequestAnimDict(anim)
                while not HasAnimDictLoaded(anim) do
                    Wait(50)
                end

                TaskPlayAnim(PlayerPedId(), anim, idle, 8.0, -8.0, -1, 32, 0, false, false, false)
                Wait(1250)
                TaskPlayAnim(PlayerPedId(), anim, lr, 8.0, -8.0, -1, 32, 0, false, false, false)
                Wait(325)
                TaskPlayAnim(PlayerPedId(), anim, idle, 8.0, -8.0, -1, 32, 0, false, false, false)
                Wait(1250)
                TaskPlayAnim(PlayerPedId(), anim, rl, 8.0, -8.0, -1, 32, 0, false, false, false)
                Wait(325)
                repeat
                    TriggerEvent("lawmen:lockpick")
                until (chance)
            end
            if chance >= 85 then
                local breakChance = math.random(1, 10)
                print("breakChance", breakChance)
                if breakChance < 3 then
                    TriggerServerEvent("lawmen:lockpick:break")
                else
                    local anim = "mini_games@story@mud5@cracksafe_look_at_dial@small_r@ped"
                    local open = "open"
                    RequestAnimDict(anim)
                    while not HasAnimDictLoaded(anim) do
                        Wait(50)
                    end
                    TaskPlayAnim(PlayerPedId(), anim, open, 8.0, -8.0, -1, 32, 0, false, false, false)
                    Citizen.Wait(1250)
                    TriggerServerEvent('lawmen:lockpicksv', GetPlayerServerId(closestPlayer))
                end
            end
        end
    else
        VORPcore.NotifyBottomRight(_U('notcloseenough'), 4000)
        return
    end
end)

CreateThread(function() -- Added time if over max distance/count down until unJailed logic
    while true do
        if Jailed then
            local local_player = PlayerId()
            if not GetPlayerInvincible(local_player) then
                SetPlayerInvincible(local_player, true)
            end
            if Jail_time < 1 then
                local player_server_id = GetPlayerServerId(PlayerId())
                TriggerServerEvent("lawmen:finishedjail", player_server_id, jaillocation)
            else
                Jail_time = Jail_time - 1
            end
            Wait(1000)
        end
        Wait(0)
    end
end)

CreateThread(function() -- Added time if over max distance/count down until unJailed logic
    while true do
        Wait(5)
        if Jailed then
            Wait(ConfigJail.JailSettings.UpdateJailTime)
            TriggerServerEvent("lawmen:taketime")
        else
            Wait(500)
        end
    end
end)

RegisterNetEvent('lawmen:handcuff', function()
    local playerPed = PlayerPedId()
    if not IsHandcuffed then
        IsHandcuffed = true
        SetEnableHandcuffs(playerPed, true)
        Citizen.InvokeNative(0x7981037A96E7D174, playerPed)                --Cuff Ped Native
        DisablePlayerFiring(playerPed, true)
        SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true) -- unarm player
        SetPedCanPlayGestureAnims(playerPed, false)
    else
        IsHandcuffed = false
        ClearPedSecondaryTask(playerPed)
        SetEnableHandcuffs(playerPed, false)
        Citizen.InvokeNative(0x67406F2C8F87FC4F, playerPed) --Uncuff Ped Native
        DisablePlayerFiring(playerPed, false)
        SetPedCanPlayGestureAnims(playerPed, true)
    end
end)

RegisterNetEvent('lawmen:lockpicked') -- Successful lockpick event
AddEventHandler('lawmen:lockpicked', function()
    local playerPed = PlayerPedId()
    ClearPedSecondaryTask(playerPed)
    SetEnableHandcuffs(playerPed, false)
    DisablePlayerFiring(playerPed, false)
    SetPedCanPlayGestureAnims(playerPed, true)
    IsHandcuffed = false
end)

CreateThread(function() -- Timer for leaving community service logic, which jails player
    while true do
        Wait(5)
        local gametime = GetGameTimer()
        local seconds = ConfigService.CommunityServiceSettings
            .communityservicetimer -- max time (seconds) you want to set
        local printtime = seconds
        while Brokedistance do
            Wait(5)
            if printtime > 0 then
                local diftime = GetGameTimer() - gametime
                printtime = math.floor(seconds - (diftime / 1000))
                DrawTxt(_U('youhave') .. printtime .. _U('secondsremaining'), 0.50, 0.95, 0.6, 0.6, true, 255, 255, 255,
                    255, true, 10000)
            else
                Citizen.Wait(1000)
                Brokedistance = false
                Serviced = false
                Autotele = true
                Location = "sk"
                local player_server_id = GetPlayerServerId(PlayerId())
                TriggerServerEvent('lawmen:JailPlayer', tonumber(player_server_id),
                    tonumber(ConfigService.CommunityServiceSettings.leftserviceamount), JailID)
                TriggerServerEvent('lawmen:Jailedservice', source)
            end
        end
    end
end)

RegisterNetEvent("lawmen:witness", function(coords)
    VORPcore.NotifyLeft(_U('crimereported'), _U('jailbreakalert'), "generic_textures", "star", 6000)
    local blip = Citizen.InvokeNative(0x45F13B7E0A15C880, -1282792512, coords.x, coords.y, coords.z, 20.0)
    Wait(60000) --Time till notify blips dispears, 1 min
    RemoveBlip(blip)
end)

AddEventHandler('onResourceStop', function(resource) -- on resource restart remove Serviceblips
    if resource == GetCurrentResourceName() then
        RemoveBlip(Serviceblip)
        Choreamount = _U('none')
    end
end)

------ This will create a commissary at sisika ------
CreateThread(function()
    if ConfigJail.Jails.sisika.Commisary.enable then
        while true do
            Wait(5)
            local pl = GetEntityCoords(PlayerPedId())
            local dist = GetDistanceBetweenCoords(pl.x, pl.y, pl.z, ConfigJail.Jails.sisika.Commisary.coords.x, ConfigJail.Jails.sisika.Commisary.coords.y, ConfigJail.Jails.sisika.Commisary.coords.z, true)
            if dist < 5 then
                DrawText3D(ConfigJail.Jails.sisika.Commisary.coords.x, ConfigJail.Jails.sisika.Commisary.coords.y, ConfigJail.Jails.sisika.Commisary.coords.z, _U('sisika_commisary'))
                if IsControlJustReleased(0, 0x760A9C6F) then
                    TriggerServerEvent('legacy_police:CommisaryAddItem')
                end
            elseif dist > 200 then
                Wait(2000)
            end
        end
    end
end)