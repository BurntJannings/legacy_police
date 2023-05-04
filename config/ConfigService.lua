ConfigService = {}



ConfigService.CommunityServiceSettings = {
     minigame = true,               -- use syn minigame in Community Service
     communityservicetimer = 10,    --amount of seconds player has to return to location
     communityservicedistance = 25, -- distance before warning to return to community service area
     leftserviceamount = 2,         -- minutes to jail player if the escape service
}

--Community Service is currently in blackwater, if to far from it will send to jail, you manually transport
ConfigService.construction = {
     { x = -838.37, y = -1273.13, z = 43.53 },
     { x = -832.66, y = -1273.21, z = 43.58 },
     { x = -828.88, y = -1268.5,  z = 43.63 },
     { x = -826.92, y = -1277.46, z = 43.61 },
}
