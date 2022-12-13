local VORP_INV = exports.vorp_inventory:vorp_inventoryApi()
local webhook = ""
local VORPcore = {}

TriggerEvent("getCore",function(core)
    VORPcore = core
end)


function CheckTable(table, element)
    for k, v in pairs(table) do
        if v == element then
            return true
        end
    end
    return false
end

RegisterServerEvent("lawmen:goondutysv") -- Go on duty, add cop count, restrict based off Max cop count event
AddEventHandler("lawmen:goondutysv", function(ptable)
        local _source = source
        local player = VORPcore.getUser(_source).getUsedCharacter
        local job = player.job
        local grade = player.jobGrade
        local playername = player.firstname.. ' ' ..player.lastname
    if CheckTable(OffDutyJobs,job) then

            if job == OffDutyJobs[1] then
                player.setJob(OnDutyJobs[1], grade)
                VORPcore.NotifyBottomRight(_source,"You are now on Duty",4000)			
            elseif OffDutyJobs[2] then
                player.setJob(OnDutyJobs[2], grade)
                VORPcore.NotifyBottomRight(_source,"You are now on Duty",4000)	
            elseif OffDutyJobs[3] then
                player.setJob(OnDutyJobs[3], grade)
                VORPcore.NotifyBottomRight(_source,"You are now on Duty",4000)	
            elseif OffDutyJobs[4] then
                player.setJob(OnDutyJobs[4], grade)
                VORPcore.NotifyBottomRight(_source,"You are now on Duty",4000)	
            elseif OffDutyJobs[5] then
                player.setJob(OnDutyJobs[5], grade)
                VORPcore.NotifyBottomRight(_source,"You are now on Duty",4000)	
            elseif OffDutyJobs[6] then
                player.setJob(OnDutyJobs[6], grade)
                VORPcore.NotifyBottomRight(_source,"You are now on Duty",4000)	
            elseif OffDutyJobs[7] then
                player.setJob(OnDutyJobs[7], grade)
                VORPcore.NotifyBottomRight(_source,"You are now on Duty",4000)	
            elseif OffDutyJobs[8] then
                player.setJob(OnDutyJobs[8], grade)
                VORPcore.NotifyBottomRight(_source,"You are now on Duty",4000)	
            elseif OffDutyJobs[9] then
                player.setJob(OnDutyJobs[9], grade)
                VORPcore.NotifyBottomRight(_source,"You are now on Duty",4000)	
            elseif OffDutyJobs[10] then
                player.setJob(OnDutyJobs[10], grade)
                VORPcore.NotifyBottomRight(_source,"You are now on Duty",4000)	
            end

    else
    VORPcore.NotifyBottomRight(_source,"You do not have the right job",4000)	
    end

    TriggerClientEvent("lawmen:onduty", _source, true)

end)

RegisterServerEvent("lawmen:synsociety", function(status)
    local _source = source
    local player = VORPcore.getUser(_source).getUsedCharacter
    local job = player.job
    print(job)
    exports["syn_society"]:SetPlayerDuty(_source,job,status,nil) 
end)

RegisterServerEvent("lawmen:gooffdutysv") -- Go off duty event
AddEventHandler("lawmen:gooffdutysv", function()
    local _source = source
    local player = VORPcore.getUser(_source).getUsedCharacter
    local job = player.job
    local grade = player.jobGrade
    local playername = player.firstname.. ' ' ..player.lastname
    for k,v in pairs(OnDutyJobs) do
        if v == job then
            player.setJob('off'..job, grade)
            local message = playername.. " Went Off Duty as off"..job.. ' ' ..grade
            TriggerEvent('Log', webhook, "Police Duty", message, 255)
		VORPcore.NotifyBottomRight(_source,"You are now Off Duty",4000)
            TriggerClientEvent("lawmen:offdutycl", _source, false)
        end
        TriggerClientEvent("lawmen:onduty", _source, false)
    end
end)

RegisterServerEvent('lawmen:FinePlayer') --Fine a player event, this is the one that removes right from pockets
AddEventHandler('lawmen:FinePlayer', function(player, amount)
    local _source = source
    local User = VORPcore.getUser(player)
    local Police = VORPcore.getUser(_source)
    local Target = User.getUsedCharacter
    local pCharacter = Police.getUsedCharacter
    local fine = tonumber(amount)
    print("fine", fine)

    for i,v in pairs(Marshal_Jobs) do
        if v == pCharacter.job then
            pJob = v
            local Society_Account = pJob
            if pCharacter.job == Society_Account then
                if Target.money < fine then
                    Target.removeCurrency(0, Target.money)
                    exports.ghmattimysql:executeSync('UPDATE society_ledger SET ledger = ledger + @fine WHERE job = @job', { fine = Target.money, job = Society_Account})
                else
                    Target.removeCurrency(0, fine)
                    exports.ghmattimysql:executeSync('UPDATE society_ledger SET ledger = ledger + @fine WHERE job = @job', { fine = fine, job = Society_Account })
                end
		VORPcore.NotifyBottomRight(_source,'You fined '..Target.firstname..' '..Target.lastname..' $'..amount,4000)
		VORPcore.NotifyBottomRight(player,'You received a fine of $'..fine,4000)
            end
        end
    end
end)

RegisterServerEvent('lawmen:JailPlayer') --Jail player event
AddEventHandler('lawmen:JailPlayer', function(player, amount, loc)
    local _source = source
    local user_name = GetPlayerName(player)
    local User = VORPcore.getUser(player)
    local CharInfo = User.getUsedCharacter
    local steam_id = CharInfo.identifier
    local Character = CharInfo.charIdentifier
    -- TIME
    local time_m = tostring(amount)
    local amount = amount * 60
    local timestamp = getTime() + amount

    exports.ghmattimysql:execute("INSERT INTO jail (identifier, characterid, name, time, time_s, jaillocation) VALUES (@identifier, @characterid, @name, @timestamp, @time, @jaillocation)", {["@identifier"] = steam_id, ["@characterid"] = Character, ["@name"] = user_name, ["@timestamp"] = timestamp, ["@time"] = amount, ["@jaillocation"] = loc})
            TriggerClientEvent("lawmen:JailPlayer",player, amount,loc)
end)

RegisterServerEvent('lawmen:CommunityService')--Start community Service event
AddEventHandler('lawmen:CommunityService', function(player, chore,amount)
    local _source = source
    local user_name = GetPlayerName(player)
    local User = VORPcore.getUser(player)
    local CharInfo = User.getUsedCharacter
    local steam_id = CharInfo.identifier
    local Character = CharInfo.charIdentifier

    exports.ghmattimysql:execute("INSERT INTO communityservice (identifier, characterid, name, communityservice, servicecount) VALUES (@identifier, @characterid, @name, @communityservice, @servicecount)", {["@identifier"] = steam_id, ["@characterid"] = Character, ["@name"] = user_name, ["@communityservice"] = chore, ["@servicecount"] = amount})

            TriggerClientEvent("lawmen:ServicePlayer", player, chore, amount)
		VORPcore.NotifyBottomRight(player,'You have been given Community Service',4000)

    
end)

RegisterServerEvent("lawmen:unjail") --Unjail event
AddEventHandler("lawmen:unjail", function(target_id,loc)
    local _source = source
    local User = VORPcore.getUser(target_id)
    local CharInfo = User.getUsedCharacter
    local steam_id = CharInfo.identifier
    local Character = CharInfo.charIdentifier
    exports.ghmattimysql:execute("SELECT * FROM `jail` WHERE characterid = @characterid", {["@characterid"] = Character}, function(result)

        if result[1] then
            local loc = result[1]["jaillocation"]
            TriggerClientEvent("lawmen:UnjailPlayer", target_id,loc)   
        end
    end)
    exports.ghmattimysql:execute("DELETE FROM jail WHERE identifier = @identifier AND characterid = @characterid", {["@identifier"] = steam_id, ["@characterid"] = Character})

end)

RegisterServerEvent('lawmen:GetID') -- Get id event currently not used
AddEventHandler('lawmen:GetID', function(player)
    local _source = tonumber(source)

    local User = VORPcore.getUser(player)
    local Target = User.getUsedCharacter

    TriggerClientEvent("vorp:TipRight", _source, 'Name: '..Target.firstname..' '..Target.lastname, 10000)
    TriggerClientEvent("vorp:TipRight", _source, 'Job: '..Target.job, 10000)
end)

RegisterServerEvent('lawmen:getVehicleInfo') --Get vehicle/horse owner event not currently used
AddEventHandler('lawmen:getVehicleInfo', function(player, mount)
    local _source = tonumber(source)

    local User = VORPcore.getUser(player)
    local Character = User.getUsedCharacter

    exports.ghmattimysql:execute("SELECT * FROM `horses` WHERE charidentifier=@identifier", {identifier=Character.charIdentifier}, function(result)
        local found = false
        if result[1] then
            for i,v in pairs(result) do
                if GetHashKey(v.modelname) == mount then
                    found = true
                    TriggerClientEvent("vorp:TipRight", _source, 'Vehicle/Horse Owned By: '..Character.firstname..' '..Character.lastname, 10000)
                end
            end
        end
        if not found then
            TriggerClientEvent("vorp:TipRight", _source, "Vehicle/Horse not owned by anyone", 10000)
        end
    end)
end)

RegisterServerEvent('lawmen:handcuff') --Handcuff Player Evnet
AddEventHandler('lawmen:handcuff', function(player)
    TriggerClientEvent('lawmen:handcuff', player)
end)

RegisterServerEvent('lawmen:lockpicksv') --Lockpick Handcuff event
AddEventHandler('lawmen:lockpicksv', function(player)
    local _source = source
    local chance = math.random(1,100)
    local user = VORPcore.getUser(_source).getUsedCharacter
    if chance < 5 then
        VORP_INV.subItem(_source, 'lockpick', 1)
	VORPcore.NotifyBottomRight(_source,"~pa~"..user.firstname.." "..user.lastname.."~q~: Gosh Darnit! My Lockpick broke!",4000)
    else
        TriggerClientEvent('lawmen:lockpicked', player)
    end
end)

RegisterServerEvent("lawmen:putinoutvehicle")-- Take out vehicle event not currently used
AddEventHandler("lawmen:putinoutvehicle", function(player)
    TriggerClientEvent('lawmen:putinoutvehicle', player)
end)

RegisterServerEvent('lawmen:drag')--Drag Event
AddEventHandler('lawmen:drag', function(target)
    local _source = source
    local user = VORPcore.getUser(_source).getUsedCharacter
    for i,v in pairs(Marshal_Jobs) do
        if user.job == v then
            TriggerClientEvent('lawmen:drag', target, _source)
        else
            print(('lawmen: %s attempted to drag a player (is not police)!'):format(GetPlayerName(_source)))
        end
    end
end)


RegisterServerEvent("lawmen:updateservice")--Update chore amount when chore is completed event
AddEventHandler("lawmen:updateservice", function()
    local _source = source

    Citizen.Wait(2000)

    local User = VORPcore.getUser(_source)
    local CharInfo = User.getUsedCharacter
    local steam_id = CharInfo.identifier

    local Character = CharInfo.charIdentifier

    exports.ghmattimysql:execute("SELECT * FROM communityservice WHERE identifier = @identifier AND characterid = @characterid", {["@identifier"] = steam_id, ["@characterid"] = Character}, function(result)

        if result[1] ~= nil then
            local count = result[1]["servicecount"]
            local identifier = result[1]["identifier"]
            local charid = result[1]["characterid"]
            exports.ghmattimysql:execute("UPDATE communityservice SET servicecount = @count WHERE identifier = @identifier AND characterid = @characterid", {["@identifier"] = identifier, ["@characterid"] = charid, ["@count"] = count - 1})
        end
    end)
end)

RegisterNetEvent("lawmen:endservice")-- Finished Community Service Event
AddEventHandler("lawmen:endservice", function()
    local _source = source

    local User = VORPcore.getUser(_source)
    local CharInfo = User.getUsedCharacter
    local steam_id = CharInfo.identifier

    local Character = CharInfo.charIdentifier
    exports.ghmattimysql:execute("DELETE FROM communityservice WHERE identifier = @identifier AND characterid = @characterid", {["@identifier"] = steam_id, ["@characterid"] = Character}, function(result)
        if result[1] ~= nil then
      VORPcore.NotifyBottomRight(_source,"You have completed Community Service, straighten up",4000)

        end
    end)
end)

RegisterNetEvent("lawmen:jailedservice") --Jailed from breaking community service event
AddEventHandler("lawmen:jailedservice", function()
    local _source = source

    local User = VORPcore.getUser(_source)
    local CharInfo = User.getUsedCharacter
    local steam_id = CharInfo.identifier

    local Character = CharInfo.charIdentifier
    exports.ghmattimysql:execute("DELETE FROM communityservice WHERE identifier = @identifier AND characterid = @characterid", {["@identifier"] = steam_id, ["@characterid"] = Character}, function(result)
        if result[1] ~= nil then
       VORPcore.NotifyBottomRight(_source,"You have been jailed for breaking Community Service, straighten up",4000)
        end
    end)
end)


RegisterServerEvent("lawmen:check_jail") --Check if jailed when selecting character event
AddEventHandler("lawmen:check_jail", function()
    local _source = source

    Citizen.Wait(2000)

    local User = VORPcore.getUser(_source)
    local CharInfo = User.getUsedCharacter
    local steam_id = CharInfo.identifier

    local Character = CharInfo.charIdentifier

    exports.ghmattimysql:execute("SELECT * FROM jail WHERE identifier = @identifier AND characterid = @characterid", {["@identifier"] = steam_id, ["@characterid"] = Character}, function(result)

        if result[1] ~= nil then
            local time = result[1]["time_s"]
            local identifier = result[1]["identifier"]
            exports.ghmattimysql:execute("UPDATE jail SET time = @time WHERE identifier = @identifier", {["@time"] = getTime() + time, ["@identifier"] = identifier})
            time = tonumber(time)
            TriggerClientEvent("lawmen:JailPlayer", _source, time)
            TriggerEvent("police_job:wear_prison", _source)
        end
    end)
end)

RegisterNetEvent("lawmen:jailbreak")--Jail break event, deletes time in jail
AddEventHandler("lawmen:jailbreak", function()
    local _source = source
    print('it worked?')
    Citizen.Wait(1000)

    local User = VORPcore.getUser(_source)
    local CharInfo = User.getUsedCharacter
    local steam_id = CharInfo.identifier

    local Character = CharInfo.charIdentifier

    exports.ghmattimysql:execute("DELETE FROM jail WHERE identifier = @identifier AND characterid = @characterid", {["@identifier"] = steam_id, ["@characterid"] = Character}, function(result)
        if result[1] ~= nil then
        print('jail broke')
            
        end
    end)
end)

RegisterServerEvent("lawmen:taketime")--Updates timer of how long left in jail defined by player
AddEventHandler("lawmen:taketime", function()
    local _source = source

    local User = VORPcore.getUser(_source)
    local CharInfo = User.getUsedCharacter
    local steam_id = CharInfo.identifier

    local Character = CharInfo.charIdentifier

    exports.ghmattimysql:execute("SELECT * FROM jail WHERE identifier = @identifier AND characterid = @characterid", {["@identifier"] = steam_id, ["@characterid"] = Character}, function(result)

        if result[1] ~= nil then
            local time = result[1]["time_s"]
            local newtime = time - 30
            local identifier = result[1]["identifier"]
            exports.ghmattimysql:execute("UPDATE jail SET time_s = @time WHERE identifier = @identifier", {["@time"] = newtime, ["@identifier"] = identifier})
        end
    end)
end)

RegisterServerEvent("lawmen:guncabinet")-- Adds weapon from gun cabinet
AddEventHandler("lawmen:guncabinet", function(weapon, ammoList, compList)
    local _source = source
    VORP_INV.createWeapon(_source, weapon, ammoList, compList)
end)

RegisterServerEvent("lawmen:addammo")-- Adds weapon from gun cabinet
AddEventHandler("lawmen:addammo", function(ammotype)
    local _source = source
	VORP_INV.addItem(_source, ammotype, 1)
end)

function getTime () -- GEt time function
    return os.time(os.date("!*t"))
end

RegisterServerEvent('lawmen:lockpick:break')--Lockpick broke event
AddEventHandler('lawmen:lockpick:break', function()
    local _source = source
	local user = VORPcore.getUser(_source).getUsedCharacter
	VORP_INV.subItem(_source, "lockpick", 1)
	VORPcore.NotifyBottomRight(_source, "Gosh Darnit!, My Lockpick broke!",4000)
end)

VORP_INV.RegisterUsableItem("lockpick", function(data)--Lockpick usable
    VORP_INV.CloseInv(data.source)
    TriggerClientEvent("lawmen:lockpick", data.source)
end)

VORP_INV.RegisterUsableItem("handcuffs", function(data)--Handcuffs usable
    VORP_INV.CloseInv(data.source)
    TriggerClientEvent("lawmen:cuffs", data.source)
end)

function CheckTable(table, element)
    for k, v in pairs(table) do
        if v == element then
            return true
        end
    end
    return false
end

RegisterServerEvent("lawmen:policenotify")
AddEventHandler("lawmen:policenotify", function(players, coords)
    local _source = source -- id 
    local Character = VorpCore.getUser(_source).getUsedCharacter
    local job = Character.job -- player job

        if CheckTable(Marshal_Jobs,job) then -- if job exist in table then pass

				TriggerClientEvent("witness", m, coords)

        end

end)

RegisterCommand("fine", function(source, args, rawCommand)
local _source = source -- player source
local Character = VORPcore.getUser(_source).getUsedCharacter
    local target = args[1]
    local fine = args[2]
    if Character.group == "admin" then
        TriggerEvent("lawmen:FinePlayer", tonumber(target), tonumber(fine))
    end
end)

RegisterCommand("jail", function(source, args, rawCommand)
   local _source = source -- player source
local Character = VORPcore.getUser(_source).getUsedCharacter
    local target = args[1]
    local jailtime = args[2]
    local jailid = args[3]
    if Character.group == "admin" then
        TriggerEvent('lawmen:JailPlayer', tonumber(target), tonumber(jailtime), jailid)
    else
        TriggerEvent("vorp:TipRight", "Not on duty", 2000)
    end
end)

RegisterCommand('unjail', function(source, args, rawCommand)
	local _source = source -- player source
local Character = VORPcore.getUser(_source).getUsedCharacter
    local target = args[1]
    if Character.group == "admin" then
        TriggerEvent("lawmen:unjail", tonumber(target))
    end
end)

RegisterServerEvent('legacy_police:PlayerJob')
AddEventHandler('legacy_police:PlayerJob', function()
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local CharacterJob = Character.job


    TriggerClientEvent('legacy_police:PlayerJob', _source, CharacterJob)

end)
