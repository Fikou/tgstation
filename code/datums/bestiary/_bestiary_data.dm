/datum/bestiary_data
	var/list/killcount = list()

/datum/bestiary_data/ui_state(mob/user)
	return GLOB.always_state

/datum/bestiary_data/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/bestiary),
	)

/datum/bestiary_data/ui_static_data(mob/user)
	. = ..()
	var/list/bestiary_info = list()
	for(var/bestiary_entry in GLOB.bestiary_entries)
		var/list/bestiary_data = list()
		bestiary_data["name"] = GLOB.bestiary_entries[bestiary_entry]["name"]
		bestiary_data["desc"] = bestiary_entry
		bestiary_data["icon"] = GLOB.bestiary_entries[bestiary_entry]["icon"]
		bestiary_data["kills"] = killcount[bestiary_entry] || 0
		bestiary_info += list(bestiary_data)
	.["bestiary_info"] = bestiary_info

/datum/bestiary_data/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Bestiary")
		ui.open()

/client/verb/viewbestiary()
	set category = "OOC"
	set name = "View Bestiary"
	set desc = "View your Bestiary."

	player_details.bestiary.ui_interact(usr)
