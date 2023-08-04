
/obj/item/robot_model/janitor
	name = "Janitor"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/screwdriver/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/stack/tile/iron/base/cyborg,
		/obj/item/soap/nanotrasen/cyborg,
		/obj/item/storage/bag/trash/cyborg,
		/obj/item/melee/flyswatter,
		/obj/item/extinguisher/mini,
		/obj/item/mop/cyborg,
		/obj/item/reagent_containers/cup/bucket,
		/obj/item/paint/paint_remover,
		/obj/item/lightreplacer/cyborg,
		/obj/item/holosign_creator,
		/obj/item/reagent_containers/spray/cyborg_drying,
		/obj/item/wirebrush,
	)
	radio_channels = list(RADIO_CHANNEL_SERVICE)
	emag_modules = list(
		/obj/item/reagent_containers/spray/cyborg_lube,
	)
	cyborg_base_icon = "janitor"
	model_select_icon = "janitor"
	hat_offset = -5
	/// Weakref to the wash toggle action we own
	var/datum/weakref/wash_toggle_ref

/obj/item/robot_model/janitor/be_transformed_to(obj/item/robot_model/old_model, forced = FALSE)
	. = ..()
	if(!.)
		return
	var/datum/action/wash_toggle = new /datum/action/toggle_buffer(loc)
	wash_toggle.Grant(loc)
	wash_toggle_ref = WEAKREF(wash_toggle)

/obj/item/robot_model/janitor/Destroy()
	QDEL_NULL(wash_toggle_ref)
	return ..()

/datum/action/toggle_buffer
	name = "Activate Auto-Wash"
	desc = "Trade speed and water for a clean floor."
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "activate_wash"
	var/static/datum/callback/allow_buffer_activate
	var/block_buffer_change	= FALSE
	var/buffer_on = FALSE
	///The bucket we draw water from
	var/datum/weakref/bucket_ref
	///Our looping sound
	var/datum/looping_sound/wash/wash_audio
	///Toggle cooldown to prevent sound spam
	COOLDOWN_DECLARE(toggle_cooldown)

/datum/action/toggle_buffer/New(Target)
	if(!allow_buffer_activate)
		allow_buffer_activate = CALLBACK(src, PROC_REF(allow_buffer_activate))
	return ..()

/datum/action/toggle_buffer/Destroy()
	if(buffer_on)
		turn_off_wash()
	QDEL_NULL(wash_audio)
	return ..()

/datum/action/toggle_buffer/Grant(mob/M)
	. = ..()
	wash_audio = new(owner)

/datum/action/toggle_buffer/IsAvailable(feedback = FALSE)
	if(!iscyborg(owner))
		return FALSE
	return ..()

/datum/action/toggle_buffer/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	var/mob/living/silicon/robot/robot_owner = owner

	block_buffer_change = DOING_INTERACTION(owner, "auto_wash_toggle")
	if(block_buffer_change)
		return FALSE

	var/obj/item/reagent_containers/cup/bucket/our_bucket = locate(/obj/item/reagent_containers/cup/bucket) in robot_owner.model.modules
	bucket_ref = WEAKREF(our_bucket)

	if(!buffer_on)
		if(!COOLDOWN_FINISHED(src, toggle_cooldown))
			robot_owner.balloon_alert(robot_owner, "auto-wash refreshing, please hold...")
			return FALSE
		COOLDOWN_START(src, toggle_cooldown, 4 SECONDS)
		if(!allow_buffer_activate())
			return FALSE

		robot_owner.balloon_alert(robot_owner, "activating auto-wash...")
		// Start the sound. it'll just last the 4 seconds it takes for us to rev up
		wash_audio.start()
		// We're just gonna shake the borg a bit. Not a ton, but just enough that it feels like the audio makes sense
		var/base_x = robot_owner.base_pixel_x
		var/base_y = robot_owner.base_pixel_y
		animate(robot_owner, pixel_x = base_x, pixel_y = base_y, time = 1, loop = -1)
		for(var/i in 1 to 17) //Startup rumble
			var/x_offset = base_x + rand(-1, 1)
			var/y_offset = base_y + rand(-1, 1)
			animate(pixel_x = x_offset, pixel_y = y_offset, time = 1)

		if(!do_after(robot_owner, 4 SECONDS, interaction_key = "auto_wash_toggle", extra_checks = allow_buffer_activate))
			wash_audio.stop() // Coward
			animate(robot_owner, pixel_x = base_x, pixel_y = base_y, time = 1)
			return FALSE
	else
		if(!COOLDOWN_FINISHED(src, toggle_cooldown))
			robot_owner.balloon_alert(robot_owner, "auto-wash deactivating, please hold...")
			return FALSE
		robot_owner.balloon_alert(robot_owner, "de-activating auto-wash...")

	toggle_wash()

/// Toggle our wash mode
/datum/action/toggle_buffer/proc/toggle_wash()
	if(buffer_on)
		deactivate_wash()
	else
		activate_wash()

/// Activate the buffer, comes with a nice animation that loops while it's on
/datum/action/toggle_buffer/proc/activate_wash()
	var/mob/living/silicon/robot/robot_owner = owner
	buffer_on = TRUE
	// Slow em down a bunch
	robot_owner.add_movespeed_modifier(/datum/movespeed_modifier/auto_wash)
	RegisterSignal(robot_owner, COMSIG_MOVABLE_MOVED, PROC_REF(clean))
	//This is basically just about adding a shake to the borg, effect should look ilke an engine's running
	var/base_x = robot_owner.base_pixel_x
	var/base_y = robot_owner.base_pixel_y
	robot_owner.pixel_x = base_x + rand(-7, 7)
	robot_owner.pixel_y = base_y + rand(-7, 7)
	//Larger shake with more changes to start out, feels like "Revving"
	animate(robot_owner, pixel_x = base_x, pixel_y = base_y, time = 1, loop = -1)
	for(var/i in 1 to 100)
		var/x_offset = base_x + rand(-2, 2)
		var/y_offset = base_y + rand(-2, 2)
		animate(pixel_x = x_offset, pixel_y = y_offset, time = 1)
	if(!wash_audio.is_active())
		wash_audio.start()
	clean()
	build_all_button_icons()

/// Start the process of disabling the buffer. Plays some effects, waits a bit, then finishes
/datum/action/toggle_buffer/proc/deactivate_wash()
	var/mob/living/silicon/robot/robot_owner = owner
	var/time_left = timeleft(wash_audio.timer_id) // We delay by the timer of our wash cause well, we want to hear the ramp down
	var/finished_by = time_left + 2.6 SECONDS
	// Need to ensure that people don't spawn the deactivate button
	COOLDOWN_START(src, toggle_cooldown, finished_by)
	// Diable the cleaning, we're revving down
	UnregisterSignal(robot_owner, COMSIG_MOVABLE_MOVED)
	// Do the rumble animation till we're all finished
	var/base_x = robot_owner.base_pixel_x
	var/base_y = robot_owner.base_pixel_y
	animate(robot_owner, pixel_x = base_x, pixel_y = base_y, time = 1)
	for(var/i in 1 to finished_by - 0.1 SECONDS) //We rumble until we're finished making noise
		var/x_offset = base_x + rand(-1, 1)
		var/y_offset = base_y + rand(-1, 1)
		animate(pixel_x = x_offset, pixel_y = y_offset, time = 1)
	// Reset our animations
	animate(pixel_x = base_x, pixel_y = base_y, time = 2)
	addtimer(CALLBACK(wash_audio, TYPE_PROC_REF(/datum/looping_sound, stop)), time_left)
	addtimer(CALLBACK(src, PROC_REF(turn_off_wash)), finished_by)

/// Called by [deactivate_wash] on a timer to allow noises and animation to play out.
/// Finally disables the buffer. Doesn't do everything mind, just the stuff that we wanted to delay
/datum/action/toggle_buffer/proc/turn_off_wash()
	var/mob/living/silicon/robot/robot_owner = owner
	buffer_on = FALSE
	robot_owner.remove_movespeed_modifier(/datum/movespeed_modifier/auto_wash)
	build_all_button_icons()

/// Should we keep trying to activate our buffer, or did you fuck it up somehow
/datum/action/toggle_buffer/proc/allow_buffer_activate()
	var/mob/living/silicon/robot/robot_owner = owner
	if(block_buffer_change)
		robot_owner.balloon_alert(robot_owner, "activation cancelled!")
		return FALSE

	var/obj/item/reagent_containers/cup/bucket/our_bucket = bucket_ref?.resolve()
	if(!buffer_on && our_bucket?.reagents?.total_volume < 0.1)
		robot_owner.balloon_alert(robot_owner, "bucket is empty!")
		return FALSE
	return TRUE

/// Call this to attempt to actually clean the turf underneath us
/datum/action/toggle_buffer/proc/clean()
	SIGNAL_HANDLER
	var/mob/living/silicon/robot/robot_owner = owner

	var/obj/item/reagent_containers/cup/bucket/our_bucket = bucket_ref?.resolve()
	var/datum/reagents/reagents = our_bucket?.reagents

	if(!reagents || reagents.total_volume < 0.1)
		robot_owner.balloon_alert(robot_owner, "bucket is empty, de-activating...")
		deactivate_wash()
		return

	var/turf/our_turf = get_turf(robot_owner)

	if(reagents.has_chemical_flag(REAGENT_CLEANS, 1))
		our_turf.wash(CLEAN_SCRUB)

	reagents.expose(our_turf, TOUCH, min(1, 10 / reagents.total_volume))
	// We use more water doing this then mopping
	reagents.remove_any(2) //reaction() doesn't use up the reagents

/datum/action/toggle_buffer/update_button_name(atom/movable/screen/movable/action_button/current_button, force)
	if(buffer_on)
		name = "De-Activate Auto-Wash"
	else
		name = "Activate Auto-Wash"
	return ..()

/datum/action/toggle_buffer/apply_button_icon(atom/movable/screen/movable/action_button/current_button, force)
	if(buffer_on)
		button_icon_state = "deactivate_wash"
	else
		button_icon_state = "activate_wash"
	return ..()

/obj/item/reagent_containers/spray/cyborg_drying
	name = "drying agent spray"
	color = "#A000A0"
	list_reagents = list(/datum/reagent/drying_agent = 250)

/obj/item/reagent_containers/spray/cyborg_lube
	name = "lube spray"
	list_reagents = list(/datum/reagent/lube = 250)

/obj/item/robot_model/janitor/respawn_consumable(mob/living/silicon/robot/cyborg, coeff = 1)
	..()
	var/obj/item/lightreplacer/light_replacer = locate(/obj/item/lightreplacer) in basic_modules
	if(light_replacer)
		for(var/charge in 1 to coeff)
			light_replacer.Charge(cyborg)

	var/obj/item/reagent_containers/spray/cyborg_drying/drying_agent = locate(/obj/item/reagent_containers/spray/cyborg_drying) in basic_modules
	if(drying_agent)
		drying_agent.reagents.add_reagent(/datum/reagent/drying_agent, 5 * coeff)

	var/obj/item/reagent_containers/spray/cyborg_lube/lube = locate(/obj/item/reagent_containers/spray/cyborg_lube) in emag_modules
	if(lube)
		lube.reagents.add_reagent(/datum/reagent/lube, 2 * coeff)

	var/obj/item/soap/nanotrasen/cyborg/soap = locate(/obj/item/soap/nanotrasen/cyborg) in basic_modules
	if(!soap)
		return
	if(soap.uses < initial(soap.uses))
		soap.uses += ROUND_UP(initial(soap.uses) / 100) * coeff
