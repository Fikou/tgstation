/obj/item/robot_model/miner
	name = "Miner"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/reagent_containers/borghypo/miner,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/pickaxe/drill/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/weldingtool/mini,
		/obj/item/extinguisher,
		/obj/item/storage/bag/sheetsnatcher/borg,
		/obj/item/borg/pheromone_spray,
		/obj/item/gps/cyborg,
		/obj/item/stack/marker_beacon,
	)
	radio_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_SUPPLY)
	emag_modules = list(
		/obj/item/borg/stun,
	)
	cyborg_base_icon = "miner"
	model_select_icon = "miner"
	hat_offset = 0
	borg_skins = list(
		"Asteroid Miner" = list(SKIN_ICON_STATE = "minerOLD"),
		"Spider Miner" = list(SKIN_ICON_STATE = "spidermin"),
		"Lavaland Miner" = list(SKIN_ICON_STATE = "miner"),
	)
	/// Reference to the internal ore bag.
	var/datum/weakref/ore_bag
	/// Weakref to the dive action we own.
	var/datum/weakref/dive_action

/obj/item/robot_model/miner/be_transformed_to(obj/item/robot_model/old_model, forced)
	. = ..()
	if(!.)
		return
	set_bag(/obj/item/storage/bag/ore)
	var/datum/action/dive = new /datum/action/miner_dive(robot)
	dive.Grant(robot)
	dive_action = WEAKREF(dive)

/obj/item/robot_model/miner/Destroy()
	QDEL_NULL(ore_bag)
	QDEL_NULL(dive_action)
	return ..()

/obj/item/robot_model/miner/add_sensors()
	robot.sight_mode |= BORGMESON
	robot.update_sight()

/obj/item/robot_model/miner/remove_sensors()
	robot.sight_mode &= ~BORGMESON
	robot.update_sight()

/obj/item/robot_model/miner/proc/set_bag(obj/item/storage/bag/ore/bag_type)
	var/obj/item/old_bag = ore_bag?.resolve()
	var/obj/item/new_bag = new bag_type(src)
	new_bag.atom_storage.rustle_sound = 'sound/weapons/gun/general/mag_bullet_insert.ogg' //more robot sound
	if(old_bag)
		old_bag.atom_storage.remove_all(new_bag)
		qdel(ore_bag)
	new_bag.RegisterSignal(robot, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/obj/item/storage/bag/ore, pickup_ores))
	new_bag.add_item_action(/datum/action/item_action/drop_ore)
	new_bag.atom_storage.update_actions()
	for(var/datum/action/action as anything in new_bag.actions)
		action.Grant(robot)
	ore_bag = WEAKREF(new_bag)

/datum/action/item_action/drop_ore
	name = "Drop Ore"
	desc = "Drop your internal ore storage onto the ground."
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"

/datum/action/miner_dive
	name = "Dive Underground"
	desc = "Dive to the most peaceful place on this hellscape."
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "activate_wash"
	/// Are we currently in the dive state?
	var/diving = FALSE

/datum/action/miner_dive/IsAvailable(feedback = FALSE)
	if(!iscyborg(owner))
		return FALSE
	var/mob/living/borg_owner = owner
	var/health_percent = borg_owner.health/borg_owner.maxHealth
	if(health_percent <= -0.5) //similar to equipment breaking, your actions can break too
		if(feedback)
			borg_owner.balloon_alert(borg_owner, "chassis too damaged!")
		return FALSE
	return ..()

/datum/action/miner_dive/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	var/mob/living/silicon/robot/robot_owner = owner
	if(diving)
		robot_owner.forceMove(robot_owner.loc.loc)
	else
		robot_owner.forceMove(new /obj/effect/dummy/phased_mob(get_turf(robot_owner)))
