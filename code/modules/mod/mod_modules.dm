/obj/item/mod/module
	name = "MOD module"
	icon_state = "module"
	/// If it can be removed
	var/removable = TRUE
	/// If it's passive, active or usable
	var/selectable = MOD_PASSIVE
	/// Is the module active
	var/active = FALSE
	/// How much space it takes up in the MOD
	var/complexity = 0
	/// Power use when idle
	var/idle_power_use = 0
	/// Power use when used
	var/active_power_use = 0
	/// Linked MODsuit
	var/obj/item/mod/control/mod
	/// Whitelist of MOD themes that can use it
	var/list/mod_blacklist = list()

/obj/item/mod/module/Destroy()
	..()
	if(mod)
		mod.uninstall(src)

/obj/item/mod/module/proc/on_install()
	return

/obj/item/mod/module/proc/on_uninstall()
	return

/obj/item/mod/module/storage
	name = "MOD storage module"
	desc = "A module using nanotechnology to fit a storage inside of the MOD."
	complexity = 5
	var/datum/component/storage/concrete/storage
	var/max_w_class = WEIGHT_CLASS_SMALL
	var/max_combined_w_class = 14
	var/max_items = 7

/obj/item/mod/module/storage/antag
	name = "MOD syndicate storage module"
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 21
	max_items = 21

/obj/item/mod/module/storage/antag/wiz
	name = "MOD enchanted storage module"

/obj/item/mod/module/storage/Initialize()
	. = ..()
	storage = AddComponent(/datum/component/storage/concrete)
	storage.max_w_class = max_w_class
	storage.max_combined_w_class = max_combined_w_class
	storage.max_items = max_items

/obj/item/mod/module/storage/on_install()
	var/datum/component/storage/modstorage = mod.AddComponent(/datum/component/storage, storage)
	modstorage.max_w_class = max_w_class
	modstorage.max_combined_w_class = max_combined_w_class
	modstorage.max_items = max_items

/obj/item/mod/module/storage/on_uninstall()
	var/datum/component/storage/modstorage = mod.GetComponent(/datum/component/storage)
	modstorage.RemoveComponent()

///ATTENTION: THIS DOES NOT WORK YET. This is something you should look at if you want to unfuck something
/obj/item/mod/module/flashlight
	name = "MOD flashlight booster"
	desc = "A module that adds a shoulder mounted flashlight onto your MOD suit once installed."
	complexity = 3
	selectable = MOD_USABLE
	var/datum/action/item_action/toggle_helmet_flashlight/headlights

/obj/item/mod/module/flashlight/on_install()
	mod.light_range = 4
	mod.light_power = 1
	mod.light_on = FALSE
	if(mod?.helmet)
		headlights = new(mod.helmet)

/obj/item/mod/module/flashlight/on_uninstall()
	mod.light_range -= 4
	mod.light_power -= 1
	mod.light_on = FALSE

/obj/item/mod/module/speed
	name = "MOD motorized actuators"
	desc = "Kinetic accelerators built into the MODsuit's legs to reduce slowdown when worn."
	complexity = 8


/obj/item/mod/module/speed/on_install()
	mod.slowdown = round(mod.slowdown / 2)

/obj/item/mod/module/speed/on_uninstall()
	mod.slowdown = initial(mod.slowdown)

/obj/item/modpaint
	name = "MOD paint kit"
	desc = "This kit will repaint your MOD suit back to it's default grey."
	icon = 'icons/obj/mod.dmi'
	icon_state = "paintkit"
	///This is what the MOD suit's theme will be set to. Only use themes we have sprites for!
	var/style = "standard"

/obj/item/modpaint/engineering
	desc = "This kit will repaint your MOD suit to bright engineering orange."
	style = "engineering"
