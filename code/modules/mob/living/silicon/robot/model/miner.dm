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
	var/obj/item/storage/bag/ore/ore_bag

/obj/item/robot_model/miner/be_transformed_to(obj/item/robot_model/old_model, forced)
	. = ..()
	if(!.)
		return
	set_bag(/obj/item/storage/bag/ore)

/obj/item/robot_model/miner/Destroy()
	QDEL_NULL(ore_bag)
	return ..()

/obj/item/robot_model/miner/add_sensors()
	robot.sight_mode |= BORGMESON
	robot.update_sight()

/obj/item/robot_model/miner/remove_sensors()
	robot.sight_mode &= ~BORGMESON
	robot.update_sight()

/obj/item/robot_model/miner/proc/set_bag(obj/item/storage/bag/ore/bag_type)
	var/obj/item/old_bag = ore_bag
	ore_bag = new bag_type(src)
	ore_bag.atom_storage.rustle_sound = 'sound/weapons/gun/general/mag_bullet_insert.ogg' //more robot sound
	if(old_bag)
		old_bag.atom_storage.remove_all(ore_bag)
		qdel(old_bag)
	ore_bag.RegisterSignal(robot, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/obj/item/storage/bag/ore, pickup_ores))
	ore_bag.add_item_action(/datum/action/item_action/drop_ore)
	ore_bag.atom_storage.update_actions()
	for(var/datum/action/action as anything in ore_bag.actions)
		action.Grant(robot)

/datum/action/item_action/drop_ore
	name = "Drop Ore"
	desc = "Drop your internal ore storage onto the ground."
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"
