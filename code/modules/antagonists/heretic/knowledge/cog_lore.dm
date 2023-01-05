/datum/heretic_knowledge/cog_start
	name = "Coggers"
	desc = "fix"
	gain_text = "this"
	next_knowledge = list(
		/datum/heretic_knowledge/limited_amount/starting/base_cog,
	)
	priority = MAX_KNOWLEDGE_PRIORITY - 3
	cost = 0
	route = COG_PATH
	/// Tracker of cultists sacrificed, which is needed for other cog knowledges
	var/cultist_sacrifices = 0

/datum/heretic_knowledge/cog_start/New()
	. = ..()
	banned_knowledge = subtypesof(/datum/heretic_knowledge/limited_amount/starting) - next_knowledge

/datum/heretic_knowledge/cog_start/on_research(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	for(var/knowledge as anything in our_heretic.researched_knowledge)
		var/datum/heretic_knowledge/knowledge_datum = our_heretic.researched_knowledge[knowledge]
		if(knowledge_datum.route == PATH_START || knowledge_datum.route == PATH_COG)
			continue
		if(istype(knowledge_datum, /datum/heretic_knowledge/limited_amount))
			var/datum/heretic_knowledge/limited_amount/item_creator = knowledge_datum
			for(var/datum/weakref/ref as anything in item_creator.created_items)
				var/atom/created_item = ref.resolve()
				qdel(created_item)
		knowledge_datum.on_lose()
		our_heretic.researched_knowledge -= knowledge_datum
		our_heretic.banned_knowledge -= knowledge_datum.banned_knowledge
		our_heretic.researchable_knowledge -= knowledge_datum.next_knowledge

/datum/heretic_knowledge/limited_amount/starting/base_cog
	name = "cogwerks"
	desc = "goonstation"
	gain_text = "my favorite mapper"
	next_knowledge = list()
	required_atoms = list(
		/obj/item/knife = 1,
		/obj/item/stack/sheet/bronze = 2,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/cog)
	route = PATH_COG


