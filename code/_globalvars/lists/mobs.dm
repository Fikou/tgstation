GLOBAL_LIST_EMPTY(clients) //all clients
GLOBAL_LIST_EMPTY(admins) //all clients whom are admins
GLOBAL_PROTECT(admins)
GLOBAL_LIST_EMPTY(deadmins) //all ckeys who have used the de-admin verb.

GLOBAL_LIST_EMPTY(directory) //all ckeys with associated client
GLOBAL_LIST_EMPTY(stealthminID) //reference list with IDs that store ckeys, for stealthmins

GLOBAL_LIST_INIT(dangerous_turfs, typecacheof(list(
	/turf/open/lava,
	/turf/open/chasm,
	/turf/open/space,
	/turf/open/openspace)))


//Since it didn't really belong in any other category, I'm putting this here
//This is for procs to replace all the goddamn 'in world's that are chilling around the code

GLOBAL_LIST_EMPTY(player_list) //all mobs **with clients attached**.
GLOBAL_LIST_EMPTY(keyloop_list) //as above but can be limited to boost performance
GLOBAL_LIST_EMPTY(mob_list) //all mobs, including clientless
GLOBAL_LIST_EMPTY(mob_directory) //mob_id -> mob
GLOBAL_LIST_EMPTY(alive_mob_list) //all alive mobs, including clientless. Excludes /mob/dead/new_player
GLOBAL_LIST_EMPTY(suicided_mob_list) //contains a list of all mobs that suicided, including their associated ghosts.
GLOBAL_LIST_EMPTY(drones_list)
GLOBAL_LIST_EMPTY(dead_mob_list) //all dead mobs, including clientless. Excludes /mob/dead/new_player
GLOBAL_LIST_EMPTY(joined_player_list) //all ckeys that have joined the game at round-start or as a latejoin.
GLOBAL_LIST_EMPTY(new_player_list) //all /mob/dead/new_player, in theory all should have clients and those that don't are in the process of spawning and get deleted when done.
GLOBAL_LIST_EMPTY(pre_setup_antags) //minds that have been picked as antag by the gamemode. removed as antag datums are set.
GLOBAL_LIST_EMPTY(silicon_mobs) //all silicon mobs
GLOBAL_LIST_EMPTY(mob_living_list) //all instances of /mob/living and subtypes
GLOBAL_LIST_EMPTY(carbon_list) //all instances of /mob/living/carbon and subtypes, notably does not contain brains or simple animals
GLOBAL_LIST_EMPTY(human_list) //all instances of /mob/living/carbon/human and subtypes
GLOBAL_LIST_EMPTY(ai_list)
GLOBAL_LIST_EMPTY(pai_list)
GLOBAL_LIST_EMPTY(available_ai_shells)
GLOBAL_LIST_INIT(simple_animals, list(list(),list(),list(),list())) // One for each AI_* status define
GLOBAL_LIST_EMPTY(spidermobs) //all sentient spider mobs
GLOBAL_LIST_EMPTY(bots_list)
GLOBAL_LIST_EMPTY(aiEyes)
GLOBAL_LIST_EMPTY(suit_sensors_list) //all people with suit sensors on

/// All alive mobs with clients.
GLOBAL_LIST_EMPTY(alive_player_list)

/// All dead mobs with clients. Does not include observers.
GLOBAL_LIST_EMPTY(dead_player_list)

/// All alive antags with clients.
GLOBAL_LIST_EMPTY(current_living_antags)

/// All observers with clients that joined as observers.
GLOBAL_LIST_EMPTY(current_observers_list)

///underages who have been reported to security for trying to buy things they shouldn't, so they can't spam
GLOBAL_LIST_EMPTY(narcd_underages)

GLOBAL_LIST_EMPTY(language_datum_instances)
GLOBAL_LIST_EMPTY(all_languages)

GLOBAL_LIST_EMPTY(sentient_disease_instances)

GLOBAL_LIST_EMPTY(latejoin_ai_cores)

GLOBAL_LIST_EMPTY(mob_config_movespeed_type_lookup)

GLOBAL_LIST_EMPTY(emote_list)

GLOBAL_LIST_INIT(construct_radial_images, list(
	CONSTRUCT_JUGGERNAUT = image(icon = 'icons/mob/cult.dmi', icon_state = "juggernaut"),
	CONSTRUCT_WRAITH = image(icon = 'icons/mob/cult.dmi', icon_state = "wraith"),
	CONSTRUCT_ARTIFICER = image(icon = 'icons/mob/cult.dmi', icon_state = "artificer")
))

GLOBAL_LIST_INIT(bestiary_entries, generate_bestiary_entries())

/proc/update_config_movespeed_type_lookup(update_mobs = TRUE)
	var/list/mob_types = list()
	var/list/entry_value = CONFIG_GET(keyed_list/multiplicative_movespeed)
	for(var/path in entry_value)
		var/value = entry_value[path]
		if(!value)
			continue
		for(var/subpath in typesof(path))
			mob_types[subpath] = value
	GLOB.mob_config_movespeed_type_lookup = mob_types
	if(update_mobs)
		update_mob_config_movespeeds()

/proc/update_mob_config_movespeeds()
	for(var/i in GLOB.mob_list)
		var/mob/M = i
		M.update_config_movespeed()

/proc/init_emote_list()
	. = list()
	for(var/path in subtypesof(/datum/emote))
		var/datum/emote/E = new path()
		if(E.key)
			if(!.[E.key])
				.[E.key] = list(E)
			else
				.[E.key] += E
		else if(E.message) //Assuming all non-base emotes have this
			stack_trace("Keyless emote: [E.type]")

		if(E.key_third_person) //This one is optional
			if(!.[E.key_third_person])
				.[E.key_third_person] = list(E)
			else
				.[E.key_third_person] |= E

/proc/generate_bestiary_entries()
	var/list/bestiary_entries = list()
	for(var/path in sortTim(subtypesof(/mob/living), /proc/cmp_typepaths_asc))
		var/mob/living/mob = path
		if(!initial(mob.bestiary_id) || !initial(mob.bestiary_description))
			continue
		if(bestiary_entries[initial(mob.bestiary_id)])
			continue
		mob = new mob() // yea this sucks but byond doesnt support initial with lists
		var/list/loot = list()
		loot |= mob.butcher_results
		loot |= mob.guaranteed_butcher_results
		if(isanimal(mob))
			var/mob/living/simple_animal/simplemob = mob
			loot |= simplemob.loot
		if(ismegafauna(mob))
			var/mob/living/simple_animal/hostile/megafauna/megafauna = mob
			loot |= megafauna.crusher_loot
		if(istype(mob, /mob/living/simple_animal/hostile/asteroid))
			var/mob/living/simple_animal/hostile/asteroid/asteroidmob = mob
			loot |= asteroidmob.crusher_loot
		var/list/loot_names = list()
		for(var/loot_path in loot)
			if(ispath(loot_path, /obj/structure/closet))
				var/obj/structure/closet/loot_container = new loot_path()
				loot_container.PopulateContents()
				for(var/atom/treasure in loot_container)
					loot_names |= treasure.name
				qdel(loot_container)
				continue
			else if(!ispath(loot_path) || ispath(loot_path, /obj/effect))
				continue
			var/atom/loot_atom = loot_path
			loot_names += initial(loot_atom.name)
		bestiary_entries[mob.bestiary_id] = list(
			"name" = mob.name,
			"desc" = mob.bestiary_description,
			"icon" = mob.icon_state,
			"health" = mob.maxHealth,
			"loot" = loot_names,
		)
		qdel(mob)
	return sortTim(bestiary_entries, cmp = /proc/cmp_bestiary_health_asc, associative = TRUE)
