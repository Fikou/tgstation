/datum/species/monkey
	name = "Monkey"
	id = "monkey"
	say_mod = "chimpers"
	attack_verb = "bite"
	attack_sound = 'sound/weapons/bite.ogg'
	miss_sound = 'sound/weapons/bite.ogg'
	mutant_organs = list(/obj/item/organ/tail/monkey)
	mutant_bodyparts = list("tail_monkey" = "Monkey")
	skinned_type = /obj/item/stack/sheet/animalhide/monkey
	meat = /obj/item/food/meat/slab/monkey
	species_traits = list(HAS_FLESH,HAS_BONE,NO_UNDERWEAR,LIPS,NOEYESPRITES,NOBLOODOVERLAY)
	inherent_traits = list(TRAIT_MONKEYLIKE)
	no_equip = list(ITEM_SLOT_EARS, ITEM_SLOT_EYES, ITEM_SLOT_OCLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET, ITEM_SLOT_ICLOTHING, ITEM_SLOT_SUITSTORE)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	liked_food = MEAT | FRUIT
	limbs_id = "monkey"
	husk_limb_icon = "monkeyhusk"
	damage_overlay_type = "monkey"
	deathanim = "m"
	sexes = FALSE
	punchdamagelow = 1
	punchdamagehigh = 3
	punchstunthreshold = 4 // no stun punches
	species_language_holder = /datum/language_holder/monkey

/datum/species/monkey/random_name(gender,unique,lastname)
	var/randname = "monkey ([rand(1,999)])"

	return randname

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
