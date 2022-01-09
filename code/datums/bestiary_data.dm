/datum/bestiary_data
	///Ckey of this achievement data's owner
	var/owner_ckey
	/// List of all entries by the amount of kills.
	var/list/killcount = list()

/datum/bestiary_data/New(ckey)
	owner_ckey = ckey
	load_killcount()

/datum/bestiary_data/ui_state(mob/user)
	return GLOB.always_state

/datum/bestiary_data/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/bestiary),
		get_asset_datum(/datum/asset/spritesheet/bestiarymobs)
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
		bestiary_data["loot"] = GLOB.bestiary_entries[bestiary_entry]["loot"]
		bestiary_info += list(bestiary_data)
	.["bestiary_info"] = bestiary_info

/datum/bestiary_data/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Bestiary")
		ui.open()

/datum/bestiary_data/proc/check_kills()
	for(var/bestiary_entry in GLOB.bestiary_entries)
		if(!killcount[bestiary_entry])
			return
	var/client/bestiary_holder = GLOB.directory[owner_ckey]
	bestiary_holder.give_award(/datum/award/achievement/misc/full_bestiary, bestiary_holder.mob)

/datum/bestiary_data/proc/load_killcount()
	var/list/killcount_entries = strings("bestiary.json", "killcount", "data/npc_saves")
	for(var/killcount_entry in killcount_entries)


/datum/bestiary_data/proc/save_killcount()
	var/path = "data/player_saves/[owner_ckey[1]]/[owner_ckey]/bestiary.sav"
	var/savefile/F = new /savefile(path)
	for(var/bestiary_entry in killcount)
		WRITE_FILE(F[bestiary_entry], killcount[bestiary_entry])

/client/verb/viewbestiary()
	set category = "OOC"
	set name = "View Bestiary"
	set desc = "View your Bestiary."

	player_details.bestiary.ui_interact(usr)
