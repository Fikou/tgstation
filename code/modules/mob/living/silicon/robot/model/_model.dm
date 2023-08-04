/**
 * # robot_model
 *
 * Definition of /obj/item/robot_model, which defines behavior for each model.
 * Deals with the creation and deletion of modules (tools).
 * Assigns modules and traits to a borg with a specific model selected.
 *
 **/
/obj/item/robot_model
	name = "Default"
	icon = 'icons/obj/assemblies/module.dmi'
	icon_state = "std_mod"
	w_class = WEIGHT_CLASS_GIGANTIC
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	flags_1 = CONDUCT_1
	///Host of this model
	var/mob/living/silicon/robot/robot
	///Icon of the module selection screen
	var/model_select_icon = "nomod"
	///Produces the icon for the borg and, if no special_light_key is set, the lights
	var/cyborg_base_icon = "robot"
	///If we want specific lights, use this instead of copying lights in the dmi
	var/special_light_key
	///Holds all the usable modules (tools)
	var/list/modules = list()
	///Paths of modules to be created when the model is created
	var/list/basic_modules = list()
	///Paths of modules to be created on emagging
	var/list/emag_modules = list()
	///Modules not inherent to the robot configuration
	var/list/added_modules = list()
	///Storage types of the model
	var/list/storages = list()
	///List of traits that will be applied to the mob if this model is used.
	var/list/model_traits = null
	///List of radio channels added to the cyborg
	var/list/radio_channels = list()
	///Whether the borg loses tool slots with damage.
	var/breakable_modules = TRUE
	///Whether swapping to this configuration should lockcharge the borg
	var/locked_transform = TRUE
	///Can we be ridden
	var/allow_riding = TRUE
	///Whether the borg can stuff itself into disposals
	var/canDispose = FALSE
	///The y offset of  the hat put on
	var/hat_offset = -3
	///The x offsets of a person riding the borg
	var/list/ride_offset_x = list("north" = 0, "south" = 0, "east" = -6, "west" = 6)
	///The y offsets of a person riding the borg
	var/list/ride_offset_y = list("north" = 4, "south" = 4, "east" = 3, "west" = 3)
	///List of skins the borg can be reskinned to, optional
	var/list/borg_skins

/obj/item/robot_model/Initialize(mapload)
	. = ..()
	for(var/path in basic_modules)
		var/obj/item/new_module = new path(src)
		basic_modules += new_module
		basic_modules -= path
	for(var/path in emag_modules)
		var/obj/item/new_module = new path(src)
		emag_modules += new_module
		emag_modules -= path

/obj/item/robot_model/Destroy()
	basic_modules.Cut()
	emag_modules.Cut()
	modules.Cut()
	added_modules.Cut()
	storages.Cut()
	return ..()

/obj/item/robot_model/proc/add_sensors()
	return

/obj/item/robot_model/proc/remove_sensors()
	return

/obj/item/robot_model/proc/get_usable_modules()
	. = modules.Copy()

/obj/item/robot_model/proc/get_inactive_modules()
	. = list()
	var/mob/living/silicon/robot/cyborg = loc
	for(var/module in get_usable_modules())
		if(!(module in cyborg.held_items))
			. += module

/obj/item/robot_model/proc/add_module(obj/item/added_module, nonstandard, requires_rebuild)
	if(isstack(added_module))
		var/obj/item/stack/sheet_module = added_module
		if(ispath(sheet_module.source, /datum/robot_energy_storage))
			sheet_module.source = get_or_create_estorage(sheet_module.source)

		if(istype(sheet_module.source))
			sheet_module.cost = max(sheet_module.cost, 1) // Must not cost 0 to prevent div/0 errors.
			sheet_module.is_cyborg = TRUE

	if(added_module.loc != src)
		added_module.forceMove(src)
	modules += added_module
	ADD_TRAIT(added_module, TRAIT_NODROP, CYBORG_ITEM_TRAIT)
	added_module.mouse_opacity = MOUSE_OPACITY_OPAQUE
	if(nonstandard)
		added_modules += added_module
	if(requires_rebuild)
		rebuild_modules()
	return added_module

/obj/item/robot_model/proc/remove_module(obj/item/removed_module, delete_after)
	basic_modules -= removed_module
	modules -= removed_module
	emag_modules -= removed_module
	added_modules -= removed_module
	rebuild_modules()
	if(delete_after)
		qdel(removed_module)

/obj/item/robot_model/proc/rebuild_modules() //builds the usable module list from the modules we have
	var/mob/living/silicon/robot/cyborg = loc
	if (!istype(cyborg))
		return
	var/list/held_modules = cyborg.held_items.Copy()
	var/active_module = cyborg.module_active
	cyborg.drop_all_held_items()
	modules = list()
	for(var/obj/item/module in basic_modules)
		add_module(module, FALSE, FALSE)
	if(cyborg.emagged)
		for(var/obj/item/module in emag_modules)
			add_module(module, FALSE, FALSE)
	for(var/obj/item/module in added_modules)
		add_module(module, FALSE, FALSE)
	for(var/module in held_modules)
		if(module)
			cyborg.equip_module_to_slot(module, held_modules.Find(module))
	if(active_module)
		cyborg.select_module(held_modules.Find(active_module))
	if(cyborg.hud_used)
		cyborg.hud_used.update_robot_modules_display()

/obj/item/robot_model/proc/respawn_consumable(mob/living/silicon/robot/cyborg, coeff = 1)
	SHOULD_CALL_PARENT(TRUE)

	for(var/datum/robot_energy_storage/storage_datum in storages)
		if(storage_datum.renewable == FALSE)
			continue
		storage_datum.energy = min(storage_datum.max_energy, storage_datum.energy + coeff * storage_datum.recharge_rate)

	for(var/obj/item/module in get_usable_modules())
		if(istype(module, /obj/item/assembly/flash))
			var/obj/item/assembly/flash/flash = module
			flash.times_used = 0
			flash.burnt_out = FALSE
			flash.update_appearance()
		else if(istype(module, /obj/item/melee/baton/security))
			var/obj/item/melee/baton/security/baton = module
			baton.cell?.charge = baton.cell.maxcharge
		else if(istype(module, /obj/item/gun/energy))
			var/obj/item/gun/energy/gun = module
			if(!gun.chambered)
				gun.recharge_newshot() //try to reload a new shot.

	cyborg.toner = cyborg.tonermax

/**
 * Refills consumables that require materials, rather than being given for free.
 *
 * Pulls from the charger's silo connection, or fails otherwise.
 */
/obj/item/robot_model/proc/restock_consumable()
	if(!robot)
		return //This means the model hasn't been chosen yet, and avoids a runtime. Anyway, there's nothing to restock yet.
	var/obj/machinery/recharge_station/charger = robot.loc
	if(!istype(charger))
		return

	var/datum/component/material_container/mat_container = charger.materials.mat_container
	if(!mat_container || charger.materials.on_hold())
		charger.sendmats = FALSE
		return

	for(var/datum/robot_energy_storage/material/storage_datum in storages)
		if(storage_datum.renewable == TRUE) //Skipping renewables, already handled in respawn_consumable()
			continue
		if(storage_datum.max_energy == storage_datum.energy) //Skipping full
			continue
		var/restock_divisor = 8 - charger.repairs //Piggybacking here to avoid part checks every cycle. Repair tiers are 0 through 3, so this value will be 8 through 5. Lower means quicker restocking.

		var/to_stock = min(storage_datum.max_energy / restock_divisor, storage_datum.max_energy - storage_datum.energy, mat_container.get_material_amount(storage_datum.mat_type))
		if(!to_stock) //Nothing for us in the silo
			continue

		storage_datum.energy += mat_container.use_amount_mat(to_stock, storage_datum.mat_type)
		charger.balloon_alert(robot, "+ [to_stock]u [initial(storage_datum.mat_type.name)]")
		charger.materials.silo_log(charger, "resupplied", -1, "units", list(GET_MATERIAL_REF(storage_datum.mat_type) = to_stock))
		playsound(charger, 'sound/weapons/gun/general/mag_bullet_insert.ogg', 50, vary = FALSE)
		return
	charger.balloon_alert(robot, "restock process complete")
	charger.sendmats = FALSE



/obj/item/robot_model/proc/get_or_create_estorage(storage_type)
	return (locate(storage_type) in storages) || new storage_type(src)

/obj/item/robot_model/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_CONTENTS)
		return
	for(var/obj/module in modules)
		module.emp_act(severity)
	..()

/obj/item/robot_model/proc/transform_to(new_config_type, forced = FALSE)
	var/mob/living/silicon/robot/cyborg = loc
	var/obj/item/robot_model/new_model = new new_config_type(cyborg)
	new_model.robot = cyborg
	if(!new_model.be_transformed_to(src, forced))
		qdel(new_model)
		return
	cyborg.model = new_model
	cyborg.update_module_innate()
	if(cyborg.sensors_on)
		new_model.add_sensors()
	new_model.rebuild_modules()
	cyborg.radio.recalculateChannels()
	cyborg.set_modularInterface_theme()
	cyborg.diag_hud_set_health()
	cyborg.diag_hud_set_status()
	cyborg.diag_hud_set_borgcell()
	cyborg.diag_hud_set_aishell()
	log_silicon("CYBORG: [key_name(cyborg)] has transformed into the [new_model] model.")

	INVOKE_ASYNC(new_model, PROC_REF(do_transform_animation))
	qdel(src)
	return new_model

/obj/item/robot_model/proc/be_transformed_to(obj/item/robot_model/old_model, forced = FALSE)
	if(islist(borg_skins) && !forced)
		var/mob/living/silicon/robot/cyborg = loc
		var/list/reskin_icons = list()
		for(var/skin in borg_skins)
			var/list/details = borg_skins[skin]
			reskin_icons[skin] = image(icon = details[SKIN_ICON] || 'icons/mob/silicon/robots.dmi', icon_state = details[SKIN_ICON_STATE])
		var/borg_skin = show_radial_menu(cyborg, cyborg, reskin_icons, custom_check = CALLBACK(src, PROC_REF(check_menu), cyborg, old_model), radius = 38, require_near = TRUE)
		if(!borg_skin)
			return FALSE
		var/list/details = borg_skins[borg_skin]
		if(!isnull(details[SKIN_ICON_STATE]))
			cyborg_base_icon = details[SKIN_ICON_STATE]
		if(!isnull(details[SKIN_ICON]))
			cyborg.icon = details[SKIN_ICON]
		if(!isnull(details[SKIN_PIXEL_X]))
			cyborg.base_pixel_x = details[SKIN_PIXEL_X]
		if(!isnull(details[SKIN_PIXEL_Y]))
			cyborg.base_pixel_y = details[SKIN_PIXEL_Y]
		if(!isnull(details[SKIN_LIGHT_KEY]))
			special_light_key = details[SKIN_LIGHT_KEY]
		if(!isnull(details[SKIN_HAT_OFFSET]))
			hat_offset = details[SKIN_HAT_OFFSET]
		if(!isnull(details[SKIN_TRAITS]))
			model_traits += details[SKIN_TRAITS]
	for(var/i in old_model.added_modules)
		added_modules += i
		old_model.added_modules -= i
	return TRUE

/obj/item/robot_model/proc/do_transform_animation()
	var/mob/living/silicon/robot/cyborg = loc
	if(cyborg.hat)
		cyborg.hat.forceMove(drop_location())

	cyborg.cut_overlays()
	cyborg.setDir(SOUTH)
	do_transform_delay()

/obj/item/robot_model/proc/do_transform_delay()
	var/mob/living/silicon/robot/cyborg = loc
	sleep(0.1 SECONDS)
	flick("[cyborg_base_icon]_transform", cyborg)
	cyborg.notransform = TRUE
	if(locked_transform)
		cyborg.ai_lockdown = TRUE
		cyborg.SetLockdown(TRUE)
		cyborg.set_anchored(TRUE)
	cyborg.logevent("Chassis model has been set to [name].")
	sleep(0.1 SECONDS)
	for(var/i in 1 to 4)
		playsound(cyborg, pick('sound/items/drill_use.ogg', 'sound/items/jaws_cut.ogg', 'sound/items/jaws_pry.ogg', 'sound/items/welder.ogg', 'sound/items/ratchet.ogg'), 80, TRUE, -1)
		sleep(0.7 SECONDS)
	cyborg.SetLockdown(FALSE)
	cyborg.ai_lockdown = FALSE
	cyborg.setDir(SOUTH)
	cyborg.set_anchored(FALSE)
	cyborg.notransform = FALSE
	cyborg.updatehealth()
	cyborg.update_icons()
	cyborg.notify_ai(AI_NOTIFICATION_NEW_MODEL)
	if(cyborg.hud_used)
		cyborg.hud_used.update_robot_modules_display()
	SSblackbox.record_feedback("tally", "cyborg_modules", 1, cyborg.model)

/**
 * Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The cyborg mob interacting with the menu
 * * old_model The old cyborg's model
 */
/obj/item/robot_model/proc/check_menu(mob/living/silicon/robot/user, obj/item/robot_model/old_model)
	if(!istype(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	if(user.model != old_model)
		return FALSE
	return TRUE


// ------------------------------------------ Storages
/datum/robot_energy_storage
	var/name = "Generic energy storage"
	var/max_energy = 30000
	var/recharge_rate = 1000
	var/energy
	///Whether this resource should refill from the aether inside a charging station.
	var/renewable = TRUE

/datum/robot_energy_storage/New(obj/item/robot_model/model)
	energy = max_energy
	if(model)
		model.storages |= src
		RegisterSignal(model.robot, COMSIG_MOB_GET_STATUS_TAB_ITEMS, PROC_REF(get_status_tab_item))
		RegisterSignal(model, COMSIG_QDELETING, PROC_REF(unregister_from_model))

/datum/robot_energy_storage/proc/unregister_from_model(obj/item/robot_model/model)
	SIGNAL_HANDLER
	if(model)
		model.storages -= src
		UnregisterSignal(model.robot, COMSIG_MOB_GET_STATUS_TAB_ITEMS)

/datum/robot_energy_storage/proc/get_status_tab_item(mob/living/silicon/robot/source, list/items)
	SIGNAL_HANDLER
	items += "[name]: [energy]/[max_energy]"

/datum/robot_energy_storage/proc/use_charge(amount)
	if (energy >= amount)
		energy -= amount
		if (energy == 0)
			return TRUE
		return TRUE
	else
		return FALSE

/datum/robot_energy_storage/proc/add_charge(amount)
	energy = min(energy + amount, max_energy)

/datum/robot_energy_storage/material
	name = "generic material storage"
	renewable = FALSE
	///The type of materials we should pull when restocking
	var/datum/material/mat_type

/datum/robot_energy_storage/material/New(obj/item/robot_model/model)
	max_energy = 60 * SHEET_MATERIAL_AMOUNT
	return ..()

/datum/robot_energy_storage/material/iron
	name = "Iron Synthesizer"
	mat_type = /datum/material/iron

/datum/robot_energy_storage/material/glass
	name = "Glass Synthesizer"
	mat_type = /datum/material/glass

/datum/robot_energy_storage/wire
	max_energy = 50
	recharge_rate = 2
	name = "Wire Synthesizer"

/datum/robot_energy_storage/medical
	max_energy = 2500
	recharge_rate = 250
	name = "Medical Synthesizer"

/datum/robot_energy_storage/beacon
	max_energy = 30
	recharge_rate = 1
	name = "Marker Beacon Storage"

/datum/robot_energy_storage/pipe_cleaner
	max_energy = 50
	recharge_rate = 2
	name = "Pipe Cleaner Synthesizer"
