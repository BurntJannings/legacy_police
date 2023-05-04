ConfigJail = {}


ConfigJail.JailSettings = {
     MaxJailDistance = 600,    -- Max Distance before more time added if using triggered
     IncreaseSentence = false, -- False breaking out lets player escape, true they get jailed longer
     IncreaseTime = 2,         -- amount of minutes extra to jail if using Config.IncreaseSentence
     BreakoutDistance = 500,   --Max Distance before breakout started
     UpdateJailTime = 30000,
     --How many MS you want to update jail db timer, making it so if they relog the time will be saved every so often
     --Can do 60000 * # of minutes even, IE, I get jailed for 10 minutes the timer updates every 5 minutes, I leave 7 minutes in come back and have 5 minutes left
}

ConfigJail.jailchores = {
     { x = 3343.25, y = -692.97, z = 43.84 },
}

ConfigJail.Jails = {
     sisika = {
          entrance = {
               x = 3359.64, y = -668.57, z = 45.78 --Sisika
          },
          exit = {
               x = 2670.49, y = -1545.06, z = 45.97
          }
     },
     blackwater = {
          entrance = {
               x = -766.87, y = -1262.36, z = 44.02
          },
          exit = {
               x = -755.13, y = -1269.58, z = 44.02
          }
     },
     valentine = {
          entrance = {
               x = -273.05, y = 810.97, z = 119.37
          },
          exit = {
               x = -276.76, y = 815.19, z = 119.21
          }
     },
     armadillo = {
          entrance = {
               x = -3619.05, y = -2600.14, z = -13.34
          },
          exit = {
               x = -3629.63, y = -2606.69, z = -13.73
          }
     },
     tumbleweed = {
          entrance = {
               x = -5528.43, y = -2926.27, z = -1.36
          },
          exit = {
               x = -5525.88, y = -2930.76, z = -2.01
          }
     },
     strawberry = {
          entrance = {
               x = -1810.91, y = -351.38, z = 161.43
          },
          exit = {
               x = -1806.98, y = -353.38, z = 164.15
          }
     },
     rhodes = {
          entrance = {
               x = 1356.05, y = -1301.87, z = 77.76
          },
          exit = {
               x = 1356.59, y = -1297.34, z = 76.81
          }
     },
     stdenis = {
          entrance = {
               x = 2502.75, y = -1310.78, z = 48.95
          },
          exit = {
               x = 2490.69, y = -1315.26, z = 48.87
          }
     },
     annesburg = {
          entrance = {
               x = 2901.57, y = 1310.95, z = 44.93
          },
          exit = {
               x = 2911.99, y = 1307.32, z = 44.66
          }
     }
}
