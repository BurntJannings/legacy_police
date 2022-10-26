local isHandcuffed = false
local defaultVehicle = -1
local playerJob
local isDead = IsPedDeadOrDying(PlayerPedId())
local star = false
local timeinjail = 0
local playerid = 0
local fineamount = 0
local jailname = "None"
local jailid = "sk"
local tele = "true"
local autotele = true
local chore = "None"
local choreamount = "None"
local currentCheck
local notinjail = false

policeOnDuty = nil

local dragStatus = {}
dragStatus.isDragged = false

local jailed = false

local prompt = GetRandomIntInRange(0, 0xffffff)

function OpenCabinet()
    Citizen.CreateThread(function()
        local str = Config.Prompt
        Open = PromptRegisterBegin()
        PromptSetControlAction(Open, 0xC7B5340A)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(Open, str)
        PromptSetEnabled(Open, true)
        PromptSetVisible(Open, true)
        PromptSetHoldMode(Open, true)
        PromptSetGroup(Open, prompt)
        PromptRegisterEnd(Open)
    end)
end

local VORPcore = {}

TriggerEvent("getCore", function(core)
    VORPcore = core
end)

Citizen.CreateThread(function() -- In jail chores to reduce time in jail
    while true do
        Wait(10)
        if jailed then 
            doingchore = false
            for k,v in pairs(Config.jailchores) do 
            local blip = N_0x554d9d53f696d002(1664425300,v.x,v.y,v.z)
            SetBlipSprite(blip, 28148096, 1)
            Citizen.InvokeNative(0x9CB1A1623062F402, blip, "Jail Chore")
            local coords = GetEntityCoords(PlayerPedId())
            local currentCheck = Vdist2(coords.x, coords.y, coords.z, v.x,v.y,v.z)
            local broom = Vdist2(GetHashKey("p_broom01x"), coords.x, coords.y, coords.z)
            if currentCheck < 3 then 
                DrawTxt('Press E to clean the courtyard', 0.38, 0.90, 0.4, 0.4, true, 255, 255, 255, 255, false)
                if IsControlJustReleased(0, 0xCEFD9220) and doingchore == false then
                    TaskStartScenarioInPlace(PlayerPedId(), GetHashKey('WORLD_HUMAN_BROOM_WORKING'), 10000, true, false, false, false)
                    Wait(10000)
                    ClearPedTasksImmediately(PlayerPedId())
                    SetCurrentPedWeapon(PlayerPedId(), GetHashKey('WEAPON_UNARMED'), true) -- unarm player
                    jail_time = jail_time - 10
                    Wait(10000)
                end
            end
        end
        end
    end
end)


Citizen.CreateThread(function() -- Community Service Logic, including animations minigame difficulty and more
    while true do
        Wait(10)
        local coords = GetEntityCoords(PlayerPedId())
        if serviced then
            if not serviceblip then  
            serviceblip = N_0x554d9d53f696d002(1664425300,pos.x,pos.y,pos.z)
            SetBlipSprite(serviceblip, 28148096, 1)
            Citizen.InvokeNative(0x9CB1A1623062F402, serviceblip, "Community Service")
            end
                   currentCheck = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, pos.x,pos.y,pos.z, true)
                    if currentCheck < 1 then 
                            DrawTxt('Press E to clean the courtyard', 0.38, 0.90, 0.4, 0.4, true, 255, 255, 255, 255, false)
                        if IsControlJustReleased(0, 0xCEFD9220) then
                                if Config.minigame then
                                    local test = exports["syn_minigame"]:taskBar(3000,7) -- difficulty,skillGapSent
                                    if test == 100 then 
                                        ped = PlayerPedId()
                                        if IsPedMale(ped) then     
                                        TaskStartScenarioInPlace(PlayerPedId(), GetHashKey('PROP_HUMAN_REPAIR_WAGON_WHEEL_ON_SMALL'), 10000, true, false, false, false)
                                        else 
                                        TaskStartScenarioInPlace(PlayerPedId(), GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), 10000, true, false, false, false)
                                        end
                                        Wait(12000)
                                        choreamount = choreamount - 1
                                        TriggerServerEvent("lawmen:updateservice")
                                    else
					VORPcore.NotifyBottomRight("You failed",4000)
                                    end
                                else
                                    TaskStartScenarioInPlace(PlayerPedId(), GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), 10000, true, false, false, false)
                                    Wait(10000)
                                    SetCurrentPedWeapon(PlayerPedId(), GetHashKey('WEAPON_UNARMED'), true) -- unarm player
                                end
                                
                        end
                    end
        end

        if choreamount and choreamount == 0 then
            TriggerServerEvent("lawmen:endservice")
            serviced = false
            RemoveBlip(serviceblip) 
            serviceblip = nil  
		VORPcore.NotifyBottomRight("You have completed Community Service, straighten up",4000)
            break
        end

    end


end)

RegisterNetEvent("lawmen:ServicePlayer") -- Assigns Chore amount and picks random coord for construcion
AddEventHandler("lawmen:ServicePlayer", function(chore,amount) 
        serviced = true
        choreamount = amount
        print(amount)
        pos = Config.construction[math.random(1, #Config.construction)]
        print(pos.x,pos.y,pos.z)
end)

 Citizen.CreateThread(function() -- Registers breakout of Community Service Area 
    while true do
        Wait(10)
        if serviced then 
            for k,v in pairs(Config.construction) do 
                local coords = GetEntityCoords(PlayerPedId())
                if GetDistanceBetweenCoords(coords, v.x,v.y,v.z, true) > Config.communityservicedistance then 
                    brokedistance = true
                else 
                    brokedistance = false
                end
             end
        end
    end
end)

Citizen.CreateThread(function() -- Update Jail Timer Logic 
    while true do
        Wait(10)
        if jailed then 
            Wait(Config.UpdateJailTime)
            TriggerServerEvent("lawmen:taketime")
        end
    end
end)

--[[Citizen.CreateThread(function() -- Distance check for Jail break started
    while true do
        Wait(10)
        if jailed then 
            local coords = GetEntityCoords(PlayerPedId())
            local currentCheck = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, 3325.59, -614.74, 44.11, false)
            if currentCheck > Config.BreakoutDistance then 
                TriggerEvent("lawmen:breakout")
            end
        end
    end
end)]]

Citizen.CreateThread(function() -- Prompt and code to access Gun Cabinets
    while true do
        Wait(0)
        local coords = GetEntityCoords(PlayerPedId())
        for k, v in pairs(Config.Guncabinets) do

            if GetDistanceBetweenCoords(coords,v.x, v.y, v.z, true) < 1.5 then
                OpenCabinet()
                local item_name = CreateVarString(10, 'LITERAL_STRING', Config.Prompt)
                PromptSetActiveGroupThisFrame(prompt, item_name)
                    if IsControlJustReleased(0, 0xC7B5340A) then	          
                    EquipmentMenu()
                    end

            end
        end

    end
end)

--Start of Menu Code

Playerid = { -- Player ID input
    type = "enableinput", -- don't touch
    inputType = "input", -- input type
    button = "Confirm", -- button name
    placeholder = "Enter Player ID", -- placeholder name
    style = "block", -- don't touch
    attributes = {
        inputHeader = "Player ID", -- header
        type = "number", -- inputype text, number,date,textarea ETC
        pattern = "[0-9]", --  only numbers "[0-9]" | for letters only "[A-Za-z]+" 
        title = "numbers only", -- if input doesnt match show this message
        style = "border-radius: 10px; background-color: ; border:none;"-- style 
    }
}

FineAmount = { -- Fine Amount input
    type = "enableinput", -- don't touch
    inputType = "input", -- input type
    button = "Confirm", -- button name
    placeholder = "Enter Fine Amount", -- placeholder name
    style = "block", -- don't touch
    attributes = {
        inputHeader = "Fine Amount", -- header
        type = "number", -- inputype text, number,date,textarea ETC
        pattern = "[0-9]", --  only numbers "[0-9]" | for letters only "[A-Za-z]+" 
        title = "numbers only", -- if input doesnt match show this message
        style = "border-radius: 10px; background-color: ; border:none;"-- style 
    }
}

JailTime = { -- Jail time input
    type = "enableinput", -- don't touch
    inputType = "input", -- input type
    button = "Confirm", -- button name
    placeholder = "Enter Jail Time", -- placeholder name
    style = "block", -- don't touch
    attributes = {
        inputHeader = "Jail Time", -- header
        type = "number", -- inputype text, number,date,textarea ETC
        pattern = "[0-9]", --  only numbers "[0-9]" | for letters only "[A-Za-z]+" 
        title = "numbers only", -- if input doesnt match show this message
        style = "border-radius: 10px; background-color: ; border:none;"-- style 
    }
}

MenuData = {}
TriggerEvent("menuapi:getData",function(call)
    MenuData = call
end)

function openPolicemenu() -- Base Police Menu Logic
	MenuData.CloseAll()
	local elements = {
		{label = "Sheriff Star", value = 'star' , desc = "Put On Your Star"},
		{label = "Cuff/Uncuff Citizen", value = 'cuff' , desc = "Cuff a Citizen"},
		{label = "Escort", value = 'escort' , desc = "Escort a Citizen"},
        {label = "Fine Menu", value = 'fine' , desc = "Fine a Citizen"},
        {label = "Jail Menu", value = 'jail' , desc = "Jail a Citizen"},
        {label = "Community Service Menu", value = 'community' , desc = "Community Service a Citizen"},
	}
   MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
	{
		title    = "Sheriff Menu",
		subtext    = "Actions",
		align    = 'top-left',
		elements = elements,
	},
	function(data, menu)
		if (data.current.value == 'star') then 
            if star == false then
			    if not IsPedMale(ped) then
                    Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(),  0x1FC12C9C, true, true, true)
                    Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, false)
                else
                    Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), 0xDB4C451D, true, false, true)
                    Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, false)
                end
		VORPcore.NotifyBottomRight("You have put on your star",4000)		
                star = true
            else
                if not IsPedMale(ped) then
                    Citizen.InvokeNative(0x0D7FFA1B2F69ED82, PlayerPedId(),  0x1FC12C9C, 0, 0)
                    Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, false)
                else
                    Citizen.InvokeNative(0x0D7FFA1B2F69ED82, PlayerPedId(), 0xDB4C451D, 0, 0)
                    Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, false)
                end
		VORPcore.NotifyBottomRight("You took your star off",4000)
                star = false
            end

        elseif (data.current.value == 'cuff') then
            HandcuffPlayer()

        elseif (data.current.value == 'escort') then
            local closestPlayer, closestDistance = GetClosestPlayer()
            if closestPlayer ~= -1 and closestDistance <= 3.0 then
                TriggerServerEvent('lawmen:drag', GetPlayerServerId(closestPlayer))
            else
		VORPcore.NotifyBottomRight("Not close enough",4000)	
            
            end

        elseif (data.current.value == 'fine') then
            OpenFineMenu()

        elseif (data.current.value == 'jail') then
            OpenJailMenu()		

    elseif (data.current.value == 'community') then
        OpenCommunityMenu()
    end

    
	end,
	function(data, menu)
		menu.close()
	end)
end

function OpenJailMenu() -- Jail menu logic
	MenuData.CloseAll()
	local elements = {
		{label = "ID # : " .. "<span style='margin-left:10px; color: Red;'>" .. playerid .. '</span>', value = 'id' , desc = "This is the citizens ID: "..playerid },
		{label = "Amount of Time :" .. "<span style='margin-left:10px; color: Red;'>" .. timeinjail .. '</span>' , value = 'time' , desc = "This is how many minutes in jail: "..timeinjail },
        {label = "Auto Tele: " ..tele , value = 'auto' , desc = "Should the Citizen be taken away or manually transport" },
        {label = "Jail Location: " ..jailname, value = 'loc' , desc = "Jail Location to use" },
        {label = "Jail", value = 'jail' , desc = "If Auto Jail is false then you must transport the Citizen if not locals will do it" },
        {label = "Unjail", value = 'unjail' , desc = "Unjail a Citizen" },

	}
   MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
	{
		title    = "Jail Menu",
		subtext    = "Actions",
		align    = 'top-left',
		elements = elements,
        lastmenu = "openPolicemenu"
	},
	function(data, menu)
        if data.current == "backup" then
            _G[data.trigger]()
         
		elseif (data.current.value == 'id') then 
            
            TriggerEvent("vorpinputs:advancedInput", json.encode(Playerid), function(result)
                local amount = result
                if result ~= "" and result then -- make sure its not empty or nil
                    playerid = amount
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
            TriggerServerEvent('lawmen:JailPlayer', tonumber(playerid), tonumber(timeinjail), jailid)

        elseif (data.current.value == 'auto') then
            if autotele == false then
                autotele = true
                tele = "True"
                menu.close()
                OpenJailMenu()
            else
                autotele = false
                tele = "False"
                menu.close()
                OpenJailMenu()
            end

        elseif (data.current.value == 'loc') then
            OpenSubJailMenu()

        elseif (data.current.value == 'unjail') then
            
            TriggerServerEvent('lawmen:unjail', playerid)

        end
	end,
	function(data, menu)
		menu.close()
	end)
end

function OpenSubJailMenu() -- Choosing Jail menu logic
	MenuData.CloseAll()
	local elements = {
		{label = "Valentine Sheriff Office", value = "val" , desc = "Jail Citizen to Valentine Sheriff Office in a Cell" },
        {label = "Blackwater Sheriff Office", value = 'bw' , desc = "Jail Citizen to Blackwater Sheriff Office in a Cell" },
		{label = "Saint Denis Sheriff Office", value = "sd" , desc = "Jail Citizen to Saint Denis Sheriff Office in a Cell" },
		{label = "Rhodes Sheriff Office", value = "rh" , desc = "Jail Citizen to Rhodes Sheriff Office in a Cell" },
		{label = "Strawberry Sheriff Office", value = "st" , desc = "Jail Citizen to Strawberry Sheriff Office in a Cell" },
        {label = "Armadillo Sheriff Office", value = "ar" , desc = "Jail Citizen to Armadillo Sheriff Office in a Cell" },
		{label = "Tumbleweed Sheriff Office", value = "tu" , desc = "Jail Citizen to Tumbleweed Sheriff Office in a Cell" },
		{label = "Annesburg Sheriff Office", value = "an" , desc = "Jail Citizen to Annesburg Sheriff Office in a Cell" },
        {label = "Siska Prison", value = "sk" , desc = "Jail Citizen to Siska Prison" },


	}
   MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
	{
		title    = "Jail Menu",
		subtext    = "Choose Jail",
		align    = 'top-left',
		elements = elements,
        lastmenu = "OpenJailMenu"
	},
	function(data, menu)
        if data.current == "backup" then
            _G[data.trigger]()
        
    elseif data.current.value then 
        jailname = data.current.label
        jailid = data.current.value
            print(jailname)
            print(jailid)
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
		{label = "ID # : " .. "<span style='margin-left:10px; color: Red;'>" .. playerid .. '</span>', value = 'id' , desc = "This is the citizens ID: "..playerid },		
        {label = "Amount of Fine :" .. "<span style='margin-left:10px; color: Red;'>" .. fineamount .. '</span>' , value = 'amount' , desc = "This is the amount of the fine: "..timeinjail },
        {label = "Bill (Society)", value = 'bill' , desc = "Bill the Citizen, allowing them to pay back later, to the society" },
        {label = "Fine (Non Society)", value = 'fine' , desc = "Fine the Citizen, Takes the cash from the citizen at the moment, even putting them negative" },
	}
   MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
	{
		title    = "Fine Menu",
		subtext    = "Actions",
		align    = 'top-left',
		elements = elements,
        lastmenu = "openPolicemenu"
	},
	function(data, menu)
        if data.current == "backup" then
            _G[data.trigger]()
        
    elseif (data.current.value == 'id') then 
            
            TriggerEvent("vorpinputs:advancedInput", json.encode(Playerid), function(result)
                local amount = result
                if result ~= "" and result then -- make sure its not empty or nil
                    playerid = amount
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
            TriggerServerEvent("syn_society:bill", tonumber(fineamount), tonumber(playerid)) -- playerid

        elseif (data.current.value == 'fine') then
            print(playerid)
            print(fineamount)
            TriggerServerEvent("lawmen:FinePlayer", tonumber(playerid), tonumber(fineamount))
    end
	end,
	function(data, menu)
		menu.close()
	end)
end

function OpenCommunityMenu() -- Community service menu logic
    print(chore)
	MenuData.CloseAll()
	local elements = {
		{label = "ID # : " .. "<span style='margin-left:10px; color: Red;'>" .. playerid .. '</span>', value = 'id' , desc = "This is the citizens ID: "..playerid },		
        {label = "Chore: " ..chore, value = 'chore' , desc = "Chore Type" },
        {label = "Amount of Chores :" .. "<span style='margin-left:10px; color: Red;'>" .. choreamount .. '</span>' , value = 'amount' , desc = "This is the amount of chores to do: "..choreamount },
        {label = "Service", value = 'service' , desc = "Give the Citizen Community Service" },
	}
   MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
	{
		title    = "Community Service Menu",
		subtext    = "Actions",
		align    = 'top-left',
		elements = elements,
        lastmenu = "openPolicemenu"
	},
	function(data, menu)
        if data.current == "backup" then
            _G[data.trigger]()
        
    elseif (data.current.value == 'id') then 
            
            TriggerEvent("vorpinputs:advancedInput", json.encode(Playerid), function(result)
                local amount = result
                if result ~= "" and result then -- make sure its not empty or nil
                    playerid = amount
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
                    choreamount = amount
                    menu.close()
                    OpenCommunityMenu()
                else
                    print("it's empty?") --notify
                end
            end)

        elseif (data.current.value == 'chore') then
            OpenChoreTypeMenu()
        elseif (data.current.value == 'service') then
            TriggerServerEvent("lawmen:CommunityService", tonumber(playerid), chore, tonumber(choreamount))
       
        end
	end,
	function(data, menu)
		menu.close()
	end)
end

function OpenChoreTypeMenu() -- Set chore menu logic
	MenuData.CloseAll()
	local elements = {
        {label = "Construction", value = 'cont' , desc = "Construction " },
	}
   MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
	{
		title    = "Chore Menu",
		subtext    = "Actions",
		align    = 'top-left',
		elements = elements,
        lastmenu = "openPolicemenu"
	},
	function(data, menu)
        if data.current == "backup" then
            _G[data.trigger]()
        
    elseif data.current.label then 
           chore = data.current.label 
           print(chore)
           menu.close()
           OpenCommunityMenu()
    end
	end,
	function(data, menu)
		menu.close()
	end)
end


function EquipmentMenu() -- Choosing Jail menu logic
	MenuData.CloseAll()
	local elements = {
		{label = Config.RevolverName, value = "revolver" , desc = "Grab a basic Revolver" },
        {label = Config.RepeaterName, value = 'repeater' , desc = "Grab a basic Repeater" },

	}
   MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
	{
		title    = "Equipment Menu",
		subtext    = "Get Your Gear",
		align    = 'top-left',
		elements = elements,
	},
	function(data, menu)
        if data.current == "backup" then
            _G[data.trigger]()
        
    elseif data.current.value == "revolver" then 
        local ammo = {[Config.RevolverAmmoType] = Config.RevolverAmmoAmount}
        local comps = {['nothing'] = 0}
        TriggerServerEvent("lawmen:guncabinet", Config.RevolverSpawnName, ammo, comps)
        menu.close()

    elseif data.current.value == "repeater" then 
        local ammo = {[Config.RepeaterAmmoType] = Config.RepeaterAmmoAmount}
        local comps = {['nothing'] = 0}
        TriggerServerEvent("lawmen:guncabinet", Config.RepeaterSpawnName, ammo, comps)
        menu.close()
        end
	end,
	function(data, menu)
		menu.close()
	end)
end

RegisterNetEvent("lawmen:breakout") -- Event for breaking out
AddEventHandler("lawmen:breakout", function()
    local local_ped = PlayerPedId()
    local local_player = PlayerId()
    TriggerServerEvent('lawmen:jailbreak')
	VORPcore.NotifyBottomRight("You have been broken out from prison. Now Run!",4000)	
    jailed = false
    jail_time = 0
    SetPlayerInvincible(local_player, false)

end)

RegisterNetEvent("vorp:SelectedCharacter") -- Event for checking jail and job on character select
AddEventHandler("vorp:SelectedCharacter", function(charid)
    TriggerServerEvent("police:checkjob")
    TriggerServerEvent("lawmen:check_jail")
end)

RegisterNetEvent("lawmen:onduty")
AddEventHandler("lawmen:onduty", function(duty)
    if not duty then
        policeOnDuty = false
    else
        policeOnDuty = true
    end
end)

RegisterNetEvent("lawmen:goonduty") -- Go on duty event
AddEventHandler("lawmen:goonduty", function()
    if policeOnDuty then
	VORPcore.NotifyBottomRight("You are already on Duty",4000)		
    else
        TriggerServerEvent('lawmen:goondutysv', GetPlayers())
    end
end)

RegisterCommand(Config.ondutycommand, function() -- on duty command
    TriggerEvent('lawmen:goonduty')
end)

RegisterNetEvent("lawmen:gooffduty") -- Go off duty event
AddEventHandler("lawmen:gooffduty", function()
    TriggerServerEvent("lawmen:gooffdutysv")
end)

RegisterCommand(Config.offdutycommand, function() -- Go off duty command
    TriggerEvent('lawmen:gooffduty')
end)

RegisterCommand(Config.openpolicemenu, function()
    if is policeOnDuty and not isDead then
        openPolicemenu()
    else
        return
    end
end)


RegisterNetEvent("lawmen:guncabinet")
AddEventHandler("lawmen:guncabinet", function()
    WarMenu.OpenMenu("marshal_weapons")
end)



-- Disable player actions when handcuffed
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if isHandcuffed then
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
        elseif isHandcuffed and IsPedDeadOrDying(PlayerPedId()) then
            isHandcuffed = false
            ClearPedSecondaryTask(PlayerPedId())
            SetEnableHandcuffs(PlayerPedId(), false)
            DisablePlayerFiring(PlayerPedId(), false)
            SetPedCanPlayGestureAnims(PlayerPedId(), true)
            
			Citizen.Wait(500)
		end
	end
end)

function GetPlayers() -- Get players function
    local players = {}

    for i = 0, 256 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, GetPlayerServerId(i))
        end
    end
    
    return players
end

Citizen.CreateThread(function() -- Logic for dragging person cuffed
    local wasDragged

    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        if isHandcuffed and dragStatus.isDragged then
            local targetPed = GetPlayerPed(GetPlayerFromServerId(dragStatus.CopId))

            if DoesEntityExist(targetPed) and IsPedOnFoot(targetPed) and not IsPedDeadOrDying(targetPed, true) then
                if not wasDragged then
                    AttachEntityToEntity(playerPed, targetPed, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
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
            Citizen.Wait(500)
        end
    end
end)

RegisterNetEvent('lawmen:drag') -- Event to register dragging
AddEventHandler('lawmen:drag', function(copId)
    if isHandcuffed then
        dragStatus.isDragged = not dragStatus.isDragged
        dragStatus.CopId = copId
    end
end)

RegisterNetEvent("lawmen:JailPlayer") -- Jailing player event
AddEventHandler("lawmen:JailPlayer", function(time)
    local ped = PlayerPedId()
    local time_minutes = math.floor(time/60)
    serviced = false
print(autotele)
        if not jailed then
            if autotele then
            DoScreenFadeOut(500)
            Citizen.Wait(600)
            if jailid == "sk" then
               local coords = Config.Siska
                SetEntityCoords(ped, coords.x, coords.y, coords.z)                      
            elseif jailid == "bw" then
                local coords = Config.Blackwater
                SetEntityCoords(ped, coords.x, coords.y, coords.z)
            elseif jailid == "st" then
                local coords = Config.Strawberry
                SetEntityCoords(ped, coords.x, coords.y, coords.z)
            elseif jailid == "val" then
                coords = Config.Valentine
                SetEntityCoords(ped, coords.x, coords.y, coords.z)
            elseif jailid == "ar" then
                local coords = Config.Armadillo
                SetEntityCoords(ped, coords.x, coords.y, coords.z)
            elseif jailid == "tu" then
                local coords = Config.Tumbleweed
                SetEntityCoords(ped, coords.x, coords.y, coords.z)
            elseif jailid == "rh" then
                local coords = Config.Rhodes
                SetEntityCoords(ped, coords.x, coords.y, coords.z)
            elseif jailid == "sd" then
                local coords = Config.StDenis
                SetEntityCoords(ped, coords.x, coords.y, coords.z)
            elseif jailid == "an" then
                local coords = Config.Annesburg
                SetEntityCoords(ped, coords.x, coords.y, coords.z)
            end

            FreezeEntityPosition(ped, true)
            jail_time = time
            jailed = true
            RemoveAllPedWeapons(ped, true)

            DoScreenFadeIn(500)
            Citizen.Wait(600)
		VORPcore.NotifyBottomRight("~pa~Police~q~: You have been imprisoned for '..time_minutes..' minutes",4000)
            FreezeEntityPosition(ped, false)
            TriggerEvent("police_job:wear_prison", ped)
            else 
                jail_time = time
                jailed = true
                Citizen.Wait(600)
                RemoveAllPedWeapons(ped, true)
		VORPcore.NotifyBottomRight("~pa~Police~q~: You have been imprisoned for '..time_minutes..' minutes",4000)
                TriggerEvent("police_job:wear_prison", ped)
            end
        end
end)

RegisterNetEvent("police_job:wear_prison") -- Wear prison outfit event
AddEventHandler("police_job:wear_prison", function()

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
AddEventHandler("lawmen:UnjailPlayer", function()
    local local_ped = PlayerPedId()
    local local_player = PlayerId()
    ExecuteCommand('rc')
VORPcore.NotifyBottomRight("~pa~Police~q~: You have been released from prison. Now straighten up and fly right!",4000)
    jailed = false
    jail_time = 0
    if autotele then
    SetEntityCoords(local_ped, Config.ExitFromSiska.x, Config.ExitFromSiska.y, Config.ExitFromSiska.z)
    SetPlayerInvincible(local_player, false)
    else 
        SetPlayerInvincible(local_player, false)
    end
end)

Citizen.CreateThread(function() --Display timer when in jail logic
    while true do
        Wait(0)
        if jailed then
            DrawTxt('Imprisoned: '..jail_time ..' seconds remaining', 0.38, 0.95, 0.4, 0.4, true, 255, 0, 0, 255, false)
        end

    end
end)

RegisterNetEvent('lawmen:putinoutvehicle') --Put in Vehicle logic, not in use currently
AddEventHandler('lawmen:putinoutvehicle', function()
    local ped = PlayerPedId()
    if IsPedSittingInAnyVehicle(ped) then
        local vehicle = GetVehiclePedIsIn(ped, false)
        TaskLeaveVehicle(ped, vehicle, 16)
    else
        local coords = GetEntityCoords(ped)
        local vehicle = GetVehicleCoords(coords)
        local seats = 1
        while seats <= 6 do
            if Citizen.InvokeNative(0xE052C1B1CAA4ECE4, vehicle, seats) then
                Citizen.InvokeNative(0xF75B0D629E1C063D, ped, vehicle, seats)
                break
            end
                if seats == 7 then
                    break
                end
            seats = seats + 1
        end
    end
end)

RegisterNetEvent("lawmen:cuffs") --Cuffing player event
AddEventHandler("lawmen:cuffs", function()
    HandcuffPlayer() 
end)

RegisterNetEvent("lawmen:lockpick")-- Lockpicking handcuffs event
AddEventHandler("lawmen:lockpick", function()
    local closestPlayer, closestDistance = GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        local chance = math.random(1,100)
        print("chance", chance)
        if not isDead then
            if chance < 85 then
                local ped = PlayerPedId()
                local anim = "mini_games@story@mud5@cracksafe_look_at_dial@med_r@ped"
                local idle = "base_idle"
                local lr = "left_to_right"
                local rl = "right_to_left"
                RequestAnimDict(anim)
                while not HasAnimDictLoaded(anim) do
                    Citizen.Wait(50)
                end
                
                TaskPlayAnim(PlayerPedId(), anim, idle, 8.0, -8.0, -1, 32, 0, false, false, false)
                Citizen.Wait(1250)
                TaskPlayAnim(PlayerPedId(), anim, lr, 8.0, -8.0, -1, 32, 0, false, false, false)
                Citizen.Wait(325)
                TaskPlayAnim(PlayerPedId(), anim, idle, 8.0, -8.0, -1, 32, 0, false, false, false)
                Citizen.Wait(1250)
                TaskPlayAnim(PlayerPedId(), anim, rl, 8.0, -8.0, -1, 32, 0, false, false, false)
                Citizen.Wait(325)
                repeat
                    TriggerEvent("lawmen:lockpick")
                until(chance)
            end
            if chance >= 85 then
                local breakChance = math.random(1,10)
                print("breakChance", breakChance)
                if breakChance < 3 then
                    TriggerServerEvent("lawmen:lockpick:break")
                else
                    local ped = PlayerPedId()
                    local anim = "mini_games@story@mud5@cracksafe_look_at_dial@small_r@ped"
                    local open = "open"
                    RequestAnimDict(anim)
                    while not HasAnimDictLoaded(anim) do
                        Citizen.Wait(50)
                    end
                    TaskPlayAnim(PlayerPedId(), anim, open, 8.0, -8.0, -1, 32, 0, false, false, false)
                    Citizen.Wait(1250)
                    TriggerServerEvent('lawmen:lockpicksv', GetPlayerServerId(closestPlayer))
                end
            end
        end
    else
	VORPcore.NotifyBottomRight("No Player Nearby",4000)
        return
    end
    
end)

function DrawTxt(text, x, y, w, h, enableShadow, col1, col2, col3, a, centre) -- Draw text function
    local str = CreateVarString(10, "LITERAL_STRING", text)
    SetTextScale(w, h)
    SetTextColor(math.floor(col1), math.floor(col2), math.floor(col3), math.floor(a))
	SetTextCentre(centre)
    if enableShadow then SetTextDropshadow(1, 0, 0, 0, 255) end
	Citizen.InvokeNative(0xADA9255D, 1);
    DisplayText(str, x, y)
end

function DrawText3D(x, y, z, text) -- Draw text 3d function
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

function CreateVarString(p0, p1, variadic) -- Create variable string function
    return Citizen.InvokeNative(0xFA925AC00EB830B9, p0, p1, variadic, Citizen.ResultAsLong())
end

Citizen.CreateThread(function() -- Added time if over max distance/count down until unjailed logic
    while true do
        if jailed then
            local ped = PlayerPedId()
            local local_player = PlayerId()
            local player_coords = GetEntityCoords(ped, true)

            if not GetPlayerInvincible(local_player) then
                SetPlayerInvincible(local_player, true)
            end
            if jail_time < 1 then
                local player_server_id = GetPlayerServerId(PlayerId())
                TriggerServerEvent("lawmen:unjail", player_server_id)
            else

                jail_time = jail_time - 1

            end
            Citizen.Wait(1000)
        end
        Citizen.Wait(0)
    end
end)


function PutInOutVehicle() --Not fuctioning currently
    local closestPlayer, closestDistance = GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        TriggerServerEvent('lawmen:putinoutvehicle', GetPlayerServerId(closestPlayer))
    else
	VORPcore.NotifyBottomRight("No Player Nearby",4000)	
        return
    end
end

function CheckID() --Not functioning currently
    local player = tonumber(onscreenKeyboard('PLAYER_ID'))
    if not tonumber(player) then
        TriggerEvent("vorp:TipRight", "Invalid Player ID", 10000)
        return
    elseif not NetworkIsPlayerActive(GetPlayerFromServerId(player)) then
        TriggerEvent("vorp:TipRight", "Player Not Online", 10000)
        return
    end

    TriggerServerEvent('lawmen:GetID', tonumber(player))
end

function HandcuffPlayer() --Handcuff player function
    local closestPlayer, closestDistance = GetClosestPlayer()

    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        TriggerServerEvent('lawmen:handcuff', GetPlayerServerId(closestPlayer))
    else
	VORPcore.NotifyBottomRight("No Player Nearby",4000)
        return
    end
end

function getvehicle() -- get vehicle info function
    local closestPlayer, closestDistance = GetClosestPlayer()
TriggerServerEvent('lawmen:getVehicleInfo', closestPlayer,GetMount(closestPlayer))
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
    
    for i=1, #players, 1 do
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

RegisterNetEvent('lawmen:handcuff') --Handcuff event
AddEventHandler('lawmen:handcuff', function()
	isHandcuffed = not isHandcuffed
	local playerPed = PlayerPedId()

	Citizen.CreateThread(function()
		if isHandcuffed then
			SetEnableHandcuffs(playerPed, true)
			DisablePlayerFiring(playerPed, true)
			SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true) -- unarm player
			SetPedCanPlayGestureAnims(playerPed, false)
        else
            ClearPedSecondaryTask(playerPed)
            SetEnableHandcuffs(playerPed, false)
            DisablePlayerFiring(playerPed, false)
            SetPedCanPlayGestureAnims(playerPed, true)
		end
	end)
end)

RegisterNetEvent('lawmen:lockpicked') -- Successful lockpick event
AddEventHandler('lawmen:lockpicked', function()
    local playerPed = PlayerPedId()
    ClearPedSecondaryTask(playerPed)
    SetEnableHandcuffs(playerPed, false)
    DisablePlayerFiring(playerPed, false)
    SetPedCanPlayGestureAnims(playerPed, true)
    isHandcuffed = false
end)

function lockpick() -- Lockpicking function
    local ped = PlayerPedId()
    local anim = "mini_games@story@mud5@cracksafe_look_at_dial@med_r@ped"
    local idle = "base_idle"
    local lr = "left_to_right"
    local rl = "right_to_left"
    RequestAnimDict(anim)
    while not HasAnimDictLoaded(anim) do
        Citizen.Wait(50)
    end
    
    TaskPlayAnim(PlayerPedId(), anim, idle, 8.0, -8.0, -1, 32, 0, false, false, false)
    Citizen.Wait(1250)
    TaskPlayAnim(PlayerPedId(), anim, lr, 8.0, -8.0, -1, 32, 0, false, false, false)
    Citizen.Wait(325)
    TaskPlayAnim(PlayerPedId(), anim, idle, 8.0, -8.0, -1, 32, 0, false, false, false)
    Citizen.Wait(1250)
    TaskPlayAnim(PlayerPedId(), anim, rl, 8.0, -8.0, -1, 32, 0, false, false, false)
    Citizen.Wait(325)
end

Citizen.CreateThread(function() -- Timer for leaving community service logic, which jails player
   while true do
        Wait(0)
            local player = PlayerPedId()
            gametime = GetGameTimer()
            seconds = Config.communityservicetimer -- max time (seconds) you want to set
            printtime = seconds
            while brokedistance do
            Wait(0)
                local playerCoords = GetEntityCoords(PlayerPedId())       
                    if printtime > 0 then
                        diftime = GetGameTimer() - gametime
                        printtime = math.floor(seconds - (diftime/1000))
                        DrawTxt("You have  " .. printtime .. " seconds remaining to return before being jailed", 0.50, 0.95, 0.6, 0.6, true, 255, 255, 255, 255, true,10000)
                    else
                        Citizen.Wait(1000)
                        brokedistance = false
                        serviced = false
                        autotele = true
                        loc = "sk"
                        local player_server_id = GetPlayerServerId(PlayerId())
                        TriggerServerEvent('lawmen:JailPlayer', tonumber(player_server_id), tonumber(Config.leftserviceamount), jailid)
                        TriggerServerEvent('lawmen:jailedservice',source)
                        print("Brokedistance is false")
                    end
        end   
    end
end)

RegisterNetEvent("lawmen:witness")
AddEventHandler("lawmen:witness", function(coords)
	local player = PlayerPedId()
	local coord = GetEntityCoords(player)
			TriggerEvent("vorp:NotifyLeft", "Crime Reported", "A Jail Break has been reported", "generic_textures", "star", 6000)
			local blip = Citizen.InvokeNative(0x45f13b7e0a15c880, -1282792512, coords.x, coords.y, coords.z, 20.0)
			Wait(60000)--Time till notify blips dispears, 1 min
		RemoveBlip(blip)
end)

AddEventHandler('onResourceStop', function(resource) -- on resource restart remove serviceblips
	if resource == GetCurrentResourceName() then
     RemoveBlip(serviceblip)
     choreamount = "None"
	end
end)
