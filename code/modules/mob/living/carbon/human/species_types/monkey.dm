/datum/species/monkey
	name = "Monkey"
	id = "monkey"
	say_mod = "chimpers"
	attack_verb = "bite"
	attack_sound = 'sound/weapons/bite.ogg'
	miss_sound = 'sound/weapons/bite.ogg'
	mutant_organs = list(/obj/item/organ/tail/monkey)
	mutant_bodyparts = list("tail_monkey")
	default_features = list("tail_monkey" = "Monkey")
	species_traits = list(HAS_FLESH,HAS_BONE,NO_UNDERWEAR,LIPS,NOEYESPRITES)
	inherent_traits = list(TRAIT_MONKEYLIKE)
	no_equip = list(ITEM_SLOT_EARS, ITEM_SLOT_EYES, ITEM_SLOT_OCLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET, ITEM_SLOT_ICLOTHING, ITEM_SLOT_SUITSTORE)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	liked_food = MEAT | FRUIT
	limbs_id = "monkey"
	sexes = FALSE
	punchstunthreshold = 11 // no stun punches
	species_language_holder = /datum/language_holder/monkey

/datum/species/monkey/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.ventcrawler = VENTCRAWLER_NUDE
	C.pass_flags |= PASSTABLE
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(!H.dna.features["tail_monkey"] || H.dna.features["tail_monkey"] == "None")
			H.dna.features["tail_monkey"] = "Monkey"
			handle_mutant_bodyparts(H)

/datum/species/monkey/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.ventcrawler = initial(C.ventcrawler)
	C.pass_flags = initial(C.pass_flags)
