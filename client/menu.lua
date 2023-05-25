local chore = _U('none')
local Tele = _U('vartrue')
local timeinjail = 0
Playerid = 0
local fineamount = 0
local jailname = _U('none')

local VORPcore = {}

TriggerEvent("getCore", function(core)
    VORPcore = core
end)

PlayerIDInput = {
    -- Player ID input
    type = "enableinput",                                               -- don't touch
    inputType = "input",                                                -- input type
    button = _U('inputconfirm'),                                        -- button name
    placeholder = _U('playerid'),                                       -- placeholder name
    style = "block",                                                    -- don't touch
    attributes = {
        inputHeader = _U('playerid'),                                   -- header
        type = "number",                                                -- inputype text, number,date,textarea ETC
        pattern = "[0-9]",                                              --  only numbers "[0-9]" | for letters only "[A-Za-z]+"
        title = _U('numberonly'),                                       -- if input doesnt match show this message
        style = "border-radius: 10px; background-color: ; border:none;" -- style
    }
}

FineAmount = {
    -- Fine Amount input
    type = "enableinput",                                               -- don't touch
    inputType = "input",                                                -- input type
    button = _U('inputconfirm'),                                        -- button name
    placeholder = _U('fineamount'),                                     -- placeholder name
    style = "block",                                                    -- don't touch
    attributes = {
        inputHeader = _U('fineamount'),                                 -- header
        type = "number",                                                -- inputype text, number,date,textarea ETC
        pattern = "[0-9]",                                              --  only numbers "[0-9]" | for letters only "[A-Za-z]+"
        title = _U('numberonly'),                                       -- if input doesnt match show this message
        style = "border-radius: 10px; background-color: ; border:none;" -- style
    }
}

JailTime = {
    -- Jail time input
    type = "enableinput",                                               -- don't touch
    inputType = "input",                                                -- input type
    button = _U('inputconfirm'),                                        -- button name
    placeholder = _U('jailamount'),                                     -- placeholder name
    style = "block",                                                    -- don't touch
    attributes = {
        inputHeader = _U('jailamount'),                                 -- header
        type = "number",                                                -- inputype text, number,date,textarea ETC
        pattern = "[0-9]",                                              --  only numbers "[0-9]" | for letters only "[A-Za-z]+"
        title = _U('numberonly'),                                       -- if input doesnt match show this message
        style = "border-radius: 10px; background-color: ; border:none;" -- style
    }
}

MenuData = {}
TriggerEvent("menuapi:getData", function(call)
    MenuData = call
end)

function OpenPoliceMenu() -- Base Police Menu Logic
    Inmenu = true
    MenuData.CloseAll()
    local elements = {
        { label = _U('togglebadge'),     value = 'star' },
        { label = _U('idmenu'),          value = 'idmenu' },
        { label = _U('cufftoggle'),      value = 'cuff' },
        { label = _U('escort'),          value = 'escort' },
        { label = _U('putinoutvehicle'), value = 'vehicle' },
        { label = _U('fineplayer'),      value = 'fine' },
        { label = _U('jailplayer'),      value = 'jail' },
        { label = _U('serviceplayer'),   value = 'community' },
    }
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title    = _U('lawmenu'),
            align    = 'top-left',
            elements = elements,
        },
        function(data, menu)
            if (data.current.value == 'star') then
                TriggerServerEvent('legacy_police:checkjob')
            elseif (data.current.value == 'cuff') then
                local closestPlayer, closestDistance = GetClosestPlayer()
                if closestPlayer ~= -1 and closestDistance <= 3.0 then
                    HandcuffPlayer()
                else
                    VORPcore.NotifyBottomRight(_U('notcloseenough'), 4000)
                end
            elseif (data.current.value == 'escort') then
                local closestPlayer, closestDistance = GetClosestPlayer()
                if closestPlayer ~= -1 and closestDistance <= 3.0 then
                    TriggerServerEvent('lawmen:drag', GetPlayerServerId(closestPlayer))
                else
                    VORPcore.NotifyBottomRight(_U('notcloseenough'), 4000)
                end
            elseif (data.current.value == 'fine') then
                OpenFineMenu()
            elseif (data.current.value == 'vehicle') then
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                local closestWagon, distance = GetClosestVehicle(coords)
                if closestWagon ~= -1 and distance <= 5.0 then
                    PutInOutVehicle()
                else
                    VORPcore.NotifyBottomRight(_U('notcloseenoughtowagon'), 4000)
                end
            elseif (data.current.value == 'jail') then
                OpenJailMenu()
            elseif (data.current.value == 'idmenu') then
                OpenIDMenu()
            elseif (data.current.value == 'community') then
                OpenCommunityMenu()
            end
        end,
        function(data, menu)
            Inmenu = false
            menu.close()
        end)
end

function OpenJailMenu() -- Jail menu logic
    MenuData.CloseAll()
    local elements = {
        { label = _U('playerid') .. "<span style='margin-left:10px; color: Red;'>" .. Playerid .. '</span>', value = 'id' },
        {
            label = _U('jailamount') .. "<span style='margin-left:10px; color: Red;'>" .. timeinjail .. '</span>',
            value = 'time'
        },
        {
            label = _U('Autotele') .. Tele,
            value =
            'auto',
            desc =
                _U('Autoteledesc')
        },
        {
            label = _U('jaillocaiton') .. jailname,
            value =
            'loc'
        },
        {
            label = _U('jail'),
            value =
            'jail',
            desc =
                _U('jaildesc')
        },
        {
            label = _U('unjail'),
            value =
            'unjail',
            desc =
                _U('unjail')
        },

    }
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title    = _U('jailmenu'),
            align    = 'top-left',
            elements = elements,
            lastmenu = "OpenPoliceMenu"
        },
        function(data, menu)
            if data.current == "backup" then
                _G[data.trigger]()
            elseif (data.current.value == 'id') then
                TriggerEvent("vorpinputs:advancedInput", json.encode(PlayerIDInput), function(result)
                    local amount = tonumber(result)
                    if amount > 0 and amount then -- make sure its not empty or nil
                        Playerid = amount
                        menu.close()
                        OpenJailMenu()
                    else
                        print("it's empty?") --notify
                    end
                end)
            elseif (data.current.value == 'time') then
                TriggerEvent("vorpinputs:advancedInput", json.encode(JailTime), function(result)
                    local amount = result
                    if result ~= "" and result then -- make sure its not empty or nil
                        timeinjail = amount
                        menu.close()
                        OpenJailMenu()
                    else
                        print("it's empty?") --notify
                    end
                end)
            elseif (data.current.value == 'jail') then
                Wait(500)
                if JailID == nil then
                    JailID = 'sk'
                end
                TriggerServerEvent('lawmen:JailPlayer', tonumber(Playerid), tonumber(timeinjail), JailID)
            elseif (data.current.value == 'auto') then
                if Autotele == false then
                    Autotele = true
                    Tele = _U('vartrue')
                    menu.close()
                    OpenJailMenu()
                else
                    Autotele = false
                    Tele = _U('varfalse')
                    menu.close()
                    OpenJailMenu()
                end
            elseif (data.current.value == 'loc') then
                OpenSubJailMenu()
            elseif (data.current.value == 'unjail') then
                TriggerServerEvent('lawmen:unjailed', Playerid, JailID)
            end
        end,
        function(data, menu)
            menu.close()
        end)
end

function OpenSubJailMenu() -- Choosing Jail menu logic
    MenuData.CloseAll()
    local elements = {
        { label = _U('valjail'), value = "val" },
        { label = _U('bwjail'),  value = 'bw' },
        { label = _U('sdjail'),  value = "sd" },
        { label = _U('rhjail'),  value = "rh" },
        { label = _U('stjail'),  value = "st" },
        { label = _U('arjail'),  value = "ar" },
        { label = _U('tujail'),  value = "tu" },
        { label = _U('anjail'),  value = "an" },
        { label = _U('sisika'),  value = "sk" },
    }
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title    = _U('jailmenu'),
            align    = 'top-left',
            elements = elements,
            lastmenu = "OpenJailMenu"
        },
        function(data, menu)
            if data.current == "backup" then
                _G[data.trigger]()
            elseif data.current.value then
                jailname = data.current.label
                JailID = data.current.value
                menu.close()
                OpenJailMenu()
            end
        end,
        function(data, menu)
            menu.close()
        end)
end

function OpenFineMenu() -- Fine Menu logic
    MenuData.CloseAll()
    local elements = {
        { label = _U('playerid') .. "<span style='margin-left:10px; color: Red;'>" .. Playerid .. '</span>', value = 'id' },
        {
            label = _U('fineamount') .. "<span style='margin-left:10px; color: Red;'>" .. fineamount .. '</span>',
            value = 'amount'
        },
        {
            label = _U('bill'),
            value =
            'bill',
            desc =
                _U('billdesc')
        },
        {
            label = _U('fine'),
            value =
            'fine',
            desc =
                _U('finedesc')
        },
    }
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title    = "Fine Menu",
            subtext  = "Actions",
            align    = 'top-left',
            elements = elements,
            lastmenu = "OpenPoliceMenu"
        },
        function(data, menu)
            if data.current == "backup" then
                _G[data.trigger]()
            elseif (data.current.value == 'id') then
                TriggerEvent("vorpinputs:advancedInput", json.encode(PlayerIDInput), function(result)
                    local amount = result
                    if result ~= "" and result then -- make sure its not empty or nil
                        Playerid = amount
                        menu.close()
                        OpenFineMenu()
                    else
                        print("it's empty?") --notify
                    end
                end)
            elseif (data.current.value == 'amount') then
                TriggerEvent("vorpinputs:advancedInput", json.encode(FineAmount), function(result)
                    local amount = result
                    if result ~= "" and result then -- make sure its not empty or nil
                        fineamount = amount
                        menu.close()
                        OpenFineMenu()
                    else
                        print("it's empty?") --notify
                    end
                end)
            elseif (data.current.value == 'bill') then
                TriggerServerEvent("syn_society:bill", tonumber(fineamount), tonumber(Playerid)) -- playerid
            elseif (data.current.value == 'fine') then
                TriggerServerEvent("lawmen:FinePlayer", tonumber(Playerid), tonumber(fineamount))
            end
        end,
        function(data, menu)
            menu.close()
        end)
end

function OpenChoreTypeMenu() -- Set chore menu logic
    MenuData.CloseAll()
    local elements = {
        { label = _U('choretype'), value = 'cont' },
    }
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title    = _U('servicemenu'),
            align    = 'top-left',
            elements = elements,
            lastmenu = "OpenPoliceMenu"
        },
        function(data, menu)
            if data.current == "backup" then
                _G[data.trigger]()
            elseif data.current.label then
                chore = data.current.label
                menu.close()
                OpenCommunityMenu()
            end
        end,
        function(data, menu)
            menu.close()
        end)
end

function OpenCommunityMenu() -- Community service menu logic
    MenuData.CloseAll()
    local elements = {
        { label = _U('playerid') .. "<span style='margin-left:10px; color: Red;'>" .. Playerid .. '</span>', value = 'id' },
        {
            label = _U('choosechore') .. chore,
            value =
            'chore'
        },
        {
            label = _U('amountofchores') .. "<span style='margin-left:10px; color: Red;'>" .. Choreamount .. '</span>',
            value = 'amount'
        },
        {
            label = _U('giveservice'),
            value =
            'service'
        },
    }
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title    = _U('servicemenu'),
            align    = 'top-left',
            elements = elements,
            lastmenu = "OpenPoliceMenu"
        },
        function(data, menu)
            if data.current == "backup" then
                _G[data.trigger]()
            elseif (data.current.value == 'id') then
                TriggerEvent("vorpinputs:advancedInput", json.encode(PlayerIDInput), function(result)
                    local amount = result
                    if result ~= "" and result then -- make sure its not empty or nil
                        Playerid = amount
                        menu.close()
                        OpenCommunityMenu()
                    else
                        print("it's empty?") --notify
                    end
                end)
            elseif (data.current.value == 'amount') then
                TriggerEvent("vorpinputs:advancedInput", json.encode(FineAmount), function(result)
                    local amount = result
                    if result ~= "" and result then -- make sure its not empty or nil
                        Choreamount = amount
                        menu.close()
                        OpenCommunityMenu()
                    else
                        print("it's empty?") --notify
                    end
                end)
            elseif (data.current.value == 'chore') then
                OpenChoreTypeMenu()
            elseif (data.current.value == 'service') then
                TriggerServerEvent("lawmen:CommunityService", tonumber(Playerid), chore, tonumber(Choreamount))
            end
        end,
        function(data, menu)
            menu.close()
        end)
end

function CloseMenu()
    Inmenu = false
    MenuData.CloseAll()
end

function BadgeMenu(Badge) -- Choosing Jail menu logic
    MenuData.CloseAll()
    local elements = {
        { label = _U('up'),    value = "up" },
        { label = _U('down'),  value = "down" },
        { label = _U('left'),  value = "left" },
        { label = _U('right'), value = 'right' },

    }
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title    = 'Move Badge',
            align    = 'top-left',
            elements = elements,
            lastmenu = "OpenPoliceMenu"
        },
        function(data, menu)
            if data.current == "backup" then
                _G[data.trigger]()
            elseif data.current.value == "up" then
                Badgez = Badgez + 1
                print(Badgez)
                Badge = CreateObject(GetHashKey("s_badgedeputy01x"), Badgex, Badgey, Badgez, true, false, false)
                AttachEntityToEntity(Badge, ped, MaleboneIndex, Badgex, Badgey, Badgez, -12.5, 0.0, 30.0, true, true,
                    false, true, 1, true)
            elseif data.current.value == "down" then
                Badgez = Badgez - 1
                print(Badgez)
                AttachEntityToEntity(Badge, ped, MaleboneIndex, Badgex, Badgey, Badgez, -12.5, 0.0, 30.0, false, true,
                    false,
                    true, 1,
                    true)
            elseif data.current.value == "left" then
                Badgex = Badgex + 1
            elseif data.current.value == "right" then
                Badgex = Badgex - 1
            end
        end,
        function(data, menu)
            CloseMenu()
        end)
end

function WeaponMenu() -- Choosing Jail menu logic
    MenuData.CloseAll()
    local elements = {
        { label = ConfigCabinets.WeaponsandAmmo.RevolverName1, value = "revolver1" },
        { label = ConfigCabinets.WeaponsandAmmo.KnifeName,     value = "knife" },
        { label = ConfigCabinets.WeaponsandAmmo.LassoName,     value = "lasso" },
        { label = ConfigCabinets.WeaponsandAmmo.RepeaterName,  value = 'repeater' },


    }
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title    = _U('grabweapons'),
            align    = 'top-left',
            elements = elements,
            lastmenu = "CabinetMenu"
        },
        function(data, menu)
            if data.current == "backup" then
                _G[data.trigger]()
            elseif data.current.value == "revolver1" then
                TriggerServerEvent("lawmen:guncabinet", ConfigCabinets.WeaponsandAmmo.RevolverSpawnName1)
                CloseMenu()
            elseif data.current.value == "knife" then
                TriggerServerEvent("lawmen:guncabinet", ConfigCabinets.WeaponsandAmmo.KnifeSpawnName)
                CloseMenu()
            elseif data.current.value == "lasso" then
                TriggerServerEvent("lawmen:guncabinet", ConfigCabinets.WeaponsandAmmo.LassoSpawnName)
                CloseMenu()
            elseif data.current.value == "revolver2" then
                TriggerServerEvent("lawmen:guncabinet", ConfigCabinets.WeaponsandAmmo.RevolverSpawnName2)
                CloseMenu()
            elseif data.current.value == "shotgun" then
                TriggerServerEvent("lawmen:guncabinet", ConfigCabinets.WeaponsandAmmo.ShotgunSpawnName)
                CloseMenu()
            elseif data.current.value == "rifle" then
                TriggerServerEvent("lawmen:guncabinet", ConfigCabinets.WeaponsandAmmo.RifleSpawnName)
                CloseMenu()
            elseif data.current.value == "repeater" then
                TriggerServerEvent("lawmen:guncabinet", ConfigCabinets.WeaponsandAmmo.RepeaterSpawnName)
                CloseMenu()
            end
        end,
        function(data, menu)
            CloseMenu()
        end)
end

function AmmoMenu() -- Choosing Jail menu logic
    MenuData.CloseAll()
    local elements = {
        { label = ConfigCabinets.WeaponsandAmmo.RevolverAmmoType, value = "ammo1", desc = "Grab your ammo" },
        { label = ConfigCabinets.WeaponsandAmmo.RepeaterAmmoType, value = "ammo4", desc = "Grab your ammo" },
    }
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title    = _U('grabammo'),
            align    = 'top-left',
            elements = elements,
            lastmenu = "CabinetMenu"
        },
        function(data, menu)
            if data.current == "backup" then
                _G[data.trigger]()
            elseif data.current.value == "ammo1" then
                local ammotype = ConfigCabinets.WeaponsandAmmo.RevolverAmmoType
                TriggerServerEvent("lawmen:addammo", ammotype)
                Inmenu = false
                menu.close()
            elseif data.current.value == "ammo2" then
                local ammotype = ConfigCabinets.WeaponsandAmmo.RifleAmmoType
                TriggerServerEvent("lawmen:addammo", ammotype)
                Inmenu = false
                menu.close()
            elseif data.current.value == "ammo3" then
                local ammotype = ConfigCabinets.WeaponsandAmmo.ShotgunAmmoType
                TriggerServerEvent("lawmen:addammo", ammotype)
                Inmenu = false
                menu.close()
            elseif data.current.value == "ammo4" then
                local ammotype = ConfigCabinets.WeaponsandAmmo.RepeaterAmmoType
                TriggerServerEvent("lawmen:addammo", ammotype)
                Inmenu = false
                menu.close()
            end
        end,
        function(data, menu)
            Inmenu = false
            menu.close()
        end)
end

function CabinetMenu() -- Set chore menu logic
    MenuData.CloseAll()
    local elements = {
        { label = _U('grabammo'),    value = 'ammo' },
        { label = _U('grabweapons'), value = 'wep' },

    }
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title    = _U('Cabinet'),
            align    = 'top-left',
            elements = elements,
        },
        function(data, menu)
            if data.current == "backup" then
                _G[data.trigger]()
            elseif data.current.value == "ammo" then
                AmmoMenu()
            elseif data.current.value == "wep" then
                WeaponMenu()
            end
        end,
        function(data, menu)
            menu.close()
            Inmenu = false
        end)
end

function OpenIDMenu() -- Set chore menu logic
    MenuData.CloseAll()
    local elements = {
        { label = _U('citizenid'), value = 'getid' },
    }
    if ConfigMain.CheckHorse then
        table.insert(elements, { label = _U('horseowner'), value = 'getowner', desc = _U('horseownerdesc') })
    end
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title    = _U('idmenu'),
            align    = 'bottom-left',
            elements = elements,
            lastmenu = "OpenPoliceMenu"
        },
        function(data, menu)
            if data.current == "backup" then
                _G[data.trigger]()
            elseif data.current.value == "getid" then
                local closestPlayer, closestDistance = GetClosestPlayer()
                if closestPlayer ~= -1 and closestDistance <= 3.0 then
                    TriggerServerEvent('lawmen:GetID', GetPlayerServerId(closestPlayer))
                end
            elseif data.current.value == "getowner" then
                local closestPlayer, closestDistance = GetClosestPlayer()
                if closestPlayer ~= -1 and closestDistance <= 3.0 then
                    local mount = GetMount(PlayerPedId())
                    TriggerServerEvent('lawmen:getVehicleInfo', GetPlayerServerId(closestPlayer), GetEntityModel(mount))
                else
                    local mount = GetMount(PlayerPedId())
                    local id = GetPlayerServerId(GetPlayerIndex())
                    TriggerServerEvent('lawmen:getVehicleInfo', id, GetEntityModel(mount))
                end
            end
        end,
        function(data, menu)
            CloseMenu()
        end)
end

function SearchMenu(takenmoney) -- Set chore menu logic
    MenuData.CloseAll()
    Inmenu = true
    local elements = {
        { label = _U('playermoney') .. takenmoney, value = 'Money' },
        { label = _U('checkitems'),                value = 'Items' },

    }
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title    = "Search Menu",
            align    = 'top-left',
            elements = elements
        },
        function(data, menu)
            if data.current == "backup" then
                _G[data.trigger]()
            elseif data.current.value == "Items" then
                TriggerEvent('lawmen:StartSearch')
            end
        end,
        function(data, menu)
            menu.close()
            Inmenu = false
        end)
end
