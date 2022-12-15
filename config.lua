Config = {}

OffDutyJobs = {
    'offpolice',
    'offmarshal',
    'offlawmen',
    'offsheriffrhodes',

}

OnDutyJobs = {
    'police',
    'marshal',
    'lawmen',
    'sheriffrhodes',

}

Config.synsociety = false -- newline


Config.Guncabinets = {
{x = -279.1195, y = 805.1283, z = 118.4004 }, --Val
{ x = -1814.174, y = -355.3881, z = 163.6477 }, --Straw
{ x = -5526.067, y = -2928.221, z = -1.467515 },--Tumble
{ x = -3625.914, y = -2601.108, z = -13.314 },--Armadillo
{ x = -764.8386, y = -1273.058, z = 43.04159 },--Blackwater
{ x = 2494.58, y = -1304.277, z = 47.97145 },--StDenis
{ x = 1361.76, y= -1306.12, z= 76.75977 },--Rhodes
}

Config.MaxJailDistance = 600 -- Max Distance before more time added if using triggered
Config.IncreaseSentence = false -- False breaking out lets player escape, true they get jailed longer
Config.IncreaseTime = 2 -- amount of minutes extra to jail if using Config.IncreaseSentence
Config.MaxCops = 1000 -- Max Cops that script can register
Config.BreakoutDistance = 500 --Max Distance before breakout started

 --How many MS you want to update jail db timer, making it so if they relog the time will be saved every so often
 Config.UpdateJailTime = 30000--Can do 60000 * # of minutes even, IE, I get jailed for 5 minutes the timer updates every minute, I leave 2 minutes in come back and have 3 minutes left      

Config.minigame = true -- use syn minigame in Community Service
Config.communityservicetimer = 10 --amount of seconds player has to return to location
Config.communityservicedistance = 25 -- distance before warning to return to community service area
Config.leftserviceamount = 2 -- minutes to jail player if the escape service


Config.ondutycommand = "goonduty" -- Go on duty Command
Config.offdutycommand = "gooffduty" --Go off duty Command
Config.openpolicemenu = "menu" -- Open Police Menu Command
Config.menuname = "Law Menu" -- Menu Name
Config.badgename = "Law Badge" -- Law Badge

                              
Config.Prompt = "Open Cabinet"

Config.RevolverName1 = "Lemat Revolver" -- Revolver Label Name
Config.RevolverSpawnName1 = "WEAPON_REVOLVER_LEMAT"--Revolver Spawn Name
Config.RevolverName2 = "Navy Revolver" -- Revolver Label Name
Config.RevolverSpawnName2 = "WEAPON_REVOLVER_NAVY"--Revolver Spawn Name
Config.RepeaterName = "Evans Repeater" -- Repeater Label Name
Config.RepeaterSpawnName = "WEAPON_REPEATER_EVANS" -- Repeater Spawn Name
Config.RifleName = "Bolt Action" -- Repeater Label Name
Config.RifleSpawnName = "WEAPON_RIFLE_BOLTACTION" -- Repeater Spawn Name
Config.ShotgunName = "Pump Shotgun" -- Repeater Label Name
Config.ShotgunSpawnName = "WEAPON_SHOTGUN_PUMP" -- Repeater Spawn Name
Config.KnifeName = "Knife" -- Repeater Label Name
Config.KnifeSpawnName = "WEAPON_MELEE_KNIFE" -- Repeater Spawn Name
Config.LassoName = "Lasso" -- Repeater Label Name
Config.LassoSpawnName = "WEAPON_LASSO" -- Repeater Spawn Name

Config.RevolverAmmoType = "ammorevolvernormal" --Revolver Ammo Hash
Config.RepeaterAmmoType = "ammorepeaternormal" -- Repeater Ammo Hash
Config.RifleAmmoType = "ammoriflenormal" -- Repeater Ammo Hash
Config.ShotgunAmmoType = "ammoshotgunnormal" -- Repeater Ammo Hash



Config.ExitFromSisika = { ["x"] = 2670.49, ["y"] = -1545.06, ["z"] = 45.97 } -- Where to get let out from Sisika

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

Config.Jails = {
     sisika = {
          entrance = {
               x = 3359.64, y = -668.57, z = 45.78  --Sisika
               },
               exit ={
                    x = 2670.49, y = -1545.06, z = 45.97
               }
     },
     blackwater = {
          entrance = {
               x = -766.87, y = -1262.36, z = 44.02
               },
               exit= {
                    x = -755.13, y = -1269.58, z = 44.02
               }
     },
     valentine = {
          entrance = {
               x = -273.05, y = 810.97, z = 119.37 
          },
               exit= {
                    x = -276.76, y = 815.19, z = 119.21
               }
     },
     armadillo = {
          entrance = {
               x = -3619.05, y = -2600.14, z = -13.34
          },
               exit= {
                    x = -3629.63, y = -2606.69, z = -13.73
               }
     },
     tumbleweed = {
          entrance = {
               x = -5528.43, y = -2926.27, z = -1.36
          },
               exit= {
                    x = -5525.88, y = -2930.76, z = -2.01
               }
     },
     strawberry = {
          entrance = {
               x = -1810.91, y = -351.38, z = 161.43
          },
               exit= {
                    x = -1806.98, y = -353.38, z = 164.15
               }
     },
     rhodes = {
          entrance = {
               x = 1356.05, y = -1301.87, z = 77.76
          },
               exit= {
                    x = 1356.59, y = -1297.34, z = 76.81
               }
     },
     stdenis = {
          entrance = {
               x = 2502.75, y = -1310.78, z = 48.95
          },
               exit= {
                    x = 2490.69, y = -1315.26, z = 48.87
               }
     },
     annesburg = {
          entrance = {
               x = 2901.57, y = 1310.95, z = 44.93
          },
               exit= {
                    x = 2911.99, y = 1307.32, z = 44.66
               }
     }


}
