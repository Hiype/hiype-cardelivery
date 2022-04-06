-- For other languages, translate these strings
blipName = "Car delivery"
NoSpawnLocationInConfigFile = "No spawn locations in config file, quitting the job"
KeepTheCar_JobIsCancelled = "Keep the car, job is canceled"
VehicleHasBeenDestroyed_JobIsCancelled = "The vehicle was destroyed! Job has been canceled."
JobQuit = "Car delivery job has been quit"
JobInProgress = "Car delivery job is in progress"
JobNotStarted = "Car delivery job is not active"
JobStarted = "Car delivery job started"
StartJob = "Press E to start a job"
QuitJob = "Press E to quit the job"
CarModelLoadingTimeout = "Car model loading has timed out, check if model names of your cars are correct"
text_adminXPEditDescription = "(Admin) Edit car delivery rank"
text_adminXPEditCommand = "cardeliveryxp"
text_option = "Option"
text_optionHelp = "Option type (add, reduce, set)"
text_add = "add"
text_reduce = "reduce"
text_set = "set"
text_number = "Number"
text_level = "Level"
text_levelUp = "Level up"
text_levelLost = "Level lost"
text_numberHelp = "Number of change"
text_noSuchParameter = "No such parameter"
text_notEveryArgumentWasEntered = "Not every argument was entered"
text_getXpCommand = "deliveryxp"
text_getXpDescription = "Shows your car delivery xp"
text_added = "Added"
text_xpToCarDeliveryRank = "xp to car delivery rank"
text_cooldown = "Cooldown"
text_secondsLeft = "seconds left"


KeepTheCar = "In the next " .. choiceTimer .. " seconds, press U to keep the car and leave the job"
SubtractedXP = tostring(rankPenalty) .. " XP subtracted from car delivery rank"

function text_GoFindCar(spawns, level, vehicleChoice, spawnLocation)
    return "Go find a ~g~" .. vehicles[level][vehicleChoice].name .. "~w~ somewhere around ~g~" .. spawns[spawnLocation].name .. "~w~!"
end

function text_GoFindParkedCar(spawns, level, vehicleChoice, spawnLocation)
    return "Go find a parked ~g~" .. vehicles[level][vehicleChoice].name .. "~w~ at ~g~" .. spawns[spawnLocation].name .. "~w~!"
end

function text_vehicleStolen(vehicleChoice, level)
    return vehicles[level][vehicleChoice].name .. " robbery in progress"
end