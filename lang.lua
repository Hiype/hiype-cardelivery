local Translations = {
    error = {
        job_quit = "Car delivery job has been quit",
        job_in_progress = "Car delivery job is in progress",
        job_not_active = "Car delivery job is not active",
        car_model_timeout = "Model loading has timed out, check if model names of your cars are correct",
        no_spawn_in_config = "No spawn locations in config file, quitting the job",
        metadata_not_set_up = "Metadata not setup correctly",
        vehicle_destroyed = "The vehicle was destroyed! Job has been canceled",
        rank_lost = "Rank lost!",
        not_enough_cops = "Not enough cops in the server!",
        cops_cant_start_job = "Cops can't start the job!"
    },
    info = {
        start_job = "[E] Steal some cars",
        end_job = "[E] End job",
        end_job2 = "Quit job",
        start_job2 = "Start job",
        blip_name = "Vehicle delivery",
        rank = "Rank %i",
        rank_up = "Rank up!",
        message_name = "Thug",
        message_subject = "Car job",
        message_text = "Go steal %s at %s",
        robbery_in_progress = "%s robbery in progress",
        keep_car = "[U] Keep vehicle",
        keep_car_job_cancelled = "Keep the car, job is cancelled",
        xp_subtracted = "%i XP subtracted from your rank",
        cooldown_left = "Cooldown: %i seconds left"
    },
    commands = {
        edit_add = "add",
        edit_reduce = "reduce",
        edit_set = "set",
        edit_call = "cdedit",
        edit_description = "(Restricted) Edit car delivery rank",
        edit_option_name = "Option",
        edit_option_help = "Option type (add, reduce, set)",
        edit_number_name = "Number",
        edit_number_help = "Value to change xp by",
        status_call = "cdxp",
        status_description = "Displays current car delivery rank",
        no_such_parameter = "No such parameter",
        not_enough_parameters = "Not enough parameters entered",
    },
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})