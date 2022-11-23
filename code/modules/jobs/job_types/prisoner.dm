/datum/job/prisoner
	title = JOB_PRISONER
	description = "Keep yourself occupied in permabrig."
	department_head = list("The Security Team")
	faction = FACTION_STATION
	total_positions = 0
	spawn_positions = 2
	supervisors = "the security team"
	selection_color = "#ffe1c3"
	exp_granted_type = EXP_TYPE_CREW
	paycheck = PAYCHECK_LOWER
	job_tag = "PRISONER"

	outfit = /datum/outfit/job/prisoner
	plasmaman_outfit = /datum/outfit/plasmaman/prisoner

	display_order = JOB_DISPLAY_ORDER_PRISONER
	department_for_prefs = /datum/job_department/security

	exclusive_mail_goodies = TRUE
	mail_goodies = list (
		/obj/effect/spawner/random/contraband/prison = 1
	)

	family_heirlooms = list(/obj/item/pen/blue)
	rpg_title = "Defeated Miniboss"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/job/prisoner/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	if(!ishuman(spawned))
		return
	var/crime_name = player_client?.prefs?.read_preference(/datum/preference/choiced/prisoner_crime)
	if(!crime_name)
		return
	if(crime_name == "Random")
		crime_name = pick(assoc_to_keys(GLOB.prisoner_crimes))
	var/datum/data/record/target_record = find_record("name", spawned.real_name, GLOB.data_core.security)
	var/crime_desc = GLOB.prisoner_crimes[crime_name]
	target_record.fields["criminal"] = "Incarcerated"
	var/datum/data/crime/past_crime = GLOB.data_core.createCrimeEntry(crime_name, crime_desc, "Central Command", "Indefinite.")
	GLOB.data_core.addCrime(target_record.fields["id"], past_crime)
	to_chat(spawned, span_warning("You are imprisoned for \"[crime_name]\"."))

/datum/outfit/job/prisoner
	name = "Prisoner"
	jobtype = /datum/job/prisoner

	id = /obj/item/card/id/advanced/prisoner
	id_trim = /datum/id_trim/job/prisoner
	uniform = /obj/item/clothing/under/rank/prisoner
	belt = null
	ears = null
	shoes = /obj/item/clothing/shoes/sneakers/orange

/datum/outfit/job/prisoner/pre_equip(mob/living/carbon/human/H)
	..()
	if(prob(1)) // D BOYYYYSSSSS
		head = /obj/item/clothing/head/beanie/black/dboy

/datum/outfit/job/prisoner/post_equip(mob/living/carbon/human/new_prisoner, visualsOnly)
	. = ..()
	if(!length(SSpersistence.prison_tattoos_to_use) || visualsOnly)
		return
	var/obj/item/bodypart/tatted_limb = pick(new_prisoner.bodyparts)
	var/list/tattoo = pick(SSpersistence.prison_tattoos_to_use)
	tatted_limb.AddComponent(/datum/component/tattoo, tattoo["story"])
	SSpersistence.prison_tattoos_to_use -= tattoo
