-- For other languages, translate these strings
blipName = "Car delivery"
NoSpawnLocationInConfigFile = "No spawn locations in config file, quitting the job"
KeepTheCar_JobIsCancelled = "Keep the car, job is canceled"
VehicleHasBeenDestroyed_JobIsCancelled = "The vehicle was destroyed! Job has been canceled."
JobQuit = "Car delivery job has been quit"
JobStarted = "Car delivery job started"
StartJob = "Press E to start a job"
QuitJob = "Press E to quit the job"

KeepTheCar = "In the next " .. choiceTimer .. " seconds, press U to keep the car and leave the job"
SubtractedXP = tostring(rankPenalty) .. " XP subtracted from car delivery rank"

function text_GoFindCar(spawns, vehicleChoice, spawnLocation)
    return "Go find a " .. vehicles[vehicleChoice].name .. " somewhere around " .. spawns[spawnLocation].name .. "!"
end

function text_GoFindParkedCar(spawns, vehicleChoice, spawnLocation)
    return "Go find a parked " .. vehicles[vehicleChoice].name .. " at " .. spawns[spawnLocation].name .. "!"
end