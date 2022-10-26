Config = {}

OffDutyJobs = {
    'offpolice',
    'offmarshal',
    'offlawmen',
    'offsheriffrhodes',

}

Marshal_Jobs = {
    'police',
    'marshal',
    'lawmen',
    'sheriffrhodes',

}

Config.Guncabinets = {
{x = -279.1195, y = 805.1283, z = 118.4004 }, --Val
{ x = -1814.174, y = -355.3881, z = 163.6477 }, --Straw
{ x = -5526.067, y = -2928.221, z = -1.467515 },--Tumble
{ x = -3625.914, y = -2601.108, z = -13.314 },--Armadillo
{ x = -764.8386, y = -1273.058, z = 43.04159 },--Blackwater
{ x = -2494.58, y = -1304.277, z = 47.97145 },--StDenis
{ x = 1361.76, y= -1306.12, z= 76.75977 },--Rhodes
}

Config.MaxJailDistance = 600 -- Max Distance before more time added if using triggered
Config.IncreaseSentence = false -- False breaking out lets player escape, true they get jailed longer
Config.IncreaseTime = 2 -- amount of minutes extra to jail if using Config.IncreaseSentence
Config.MaxCops = 1000 -- Max Cops that script can register
Config.BreakoutDistance = 500 --Max Distance before breakout started

Config.minigame = true -- use syn minigame in Community Service
Config.communityservicetimer = 10 --amount of seconds player has to return to location
Config.communityservicedistance = 25 -- distance before warning to return to community service area
Config.leftserviceamount = 2 -- minutes to jail player if the escape service


Config.ondutycommand = "goonduty" -- Go on duty Command
Config.offdutycommand = "gooffduty" --Go off duty Command
Config.openpolicemenu = "menu" -- Open Police Menu Command


Config.RevolverName = "Lemat Revolver" -- Revolver Label Name
Config.RevolverSpawnName = "WEAPON_REVOLVER_LEMAT"--Revolver Spawn Name
Config.RevolverAmmoType = "AMMO_REVOLVER" --Revolver Ammo Hash
Config.RevolverAmmoAmount = 60 --Revolver ammo amount
Config.RepeaterName = "Evans Repeater" -- Repeater Label Name
Config.RepeaterSpawnName = "WEAPON_REPEATER_EVANS" -- Repeater Spawn Name
Config.RepeaterAmmoType = "AMMO_REPEATER" -- Repeater Ammo Hash
Config.RepeaterAmmoAmount = 60 -- Repeater ammo amount

                             --How many MS you want to update jail db timer, making it so if they relog the time will be saved every so often
Config.UpdateJailTime = 30000--Can do 60000 * # of minutes even, IE, I get jailed for 5 minutes the timer updates every minute, I leave 2 minutes in
                             --Come back and have 3 minutes left      
                              
                              
Config.Prompt = "Open Cabinet"

Config.ExitFromSiska = { ["x"] = 2670.49, ["y"] = -1545.06, ["z"] = 45.97 } -- Where to get let out from Siska

Config.jailchores = {

    {x = 3343.25, y = -692.97, z = 43.84},

}

--Community Service chore currently is construction
Config.construction = {

    {x = -838.37, y = -1273.13, z = 43.53},
    {x = -832.66, y = -1273.21, z = 43.58},
    {x = -828.88, y = -1268.5, z = 43.63},
    {x = -826.92, y = -1277.46, z = 43.61},
    

}

Config.Siska = {
     x = 3359.64, y = -668.57, z = 45.78  --Siska
}

Config.Blackwater = {
     x = 3359.64, y = -668.57, z = 45.78 
}

Config.Valentine = {
    x = -273.05, y = 810.97, z = 119.37 
}

Config.Armadillo = {
     x = 3359.64, y = -668.57, z = 45.78 
}

Config.Tumbleweed = {
     x = 3359.64, y = -668.57, z = 45.78 
}

Config.Strawberry = {
     x = 3359.64, y = -668.57, z = 45.78 
}

Config.Rhodes = {
     x = 3359.64, y = -668.57, z = 45.78 
}

Config.StDenis = {
     x = 3359.64, y = -668.57, z = 45.78 
}

Config.Annesburg = {
     x = 3359.64, y = -668.57, z = 45.78 
}
