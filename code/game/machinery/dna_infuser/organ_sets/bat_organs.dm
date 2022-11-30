
#define BAT_ORGAN_COLOR "#271f23"
#define BAT_SCLERA_COLOR "#270000"
#define BAT_PUPIL_COLOR "#be1919"

#define BAT_COLORS BAT_ORGAN_COLOR + BAT_SCLERA_COLOR + BAT_PUPIL_COLOR

/datum/status_effect/organ_set_bonus/bat
	organs_needed = 4
	bonus_activate_text = span_notice("Bat DNA is deeply infused with you! You've learned how to propel yourself through space!")
	bonus_deactivate_text = span_notice("Your DNA is once again mostly yours, and so fades your ability to space-swim...")

/datum/status_effect/organ_set_bonus/bat/enable_bonus()
	. = ..()

/datum/status_effect/organ_set_bonus/bat/disable_bonus()
	. = ..()

/obj/item/organ/internal/ears/bat
	name = "bat ears"
	desc = "Bat DNA infused into what was once some normal ears."
	damage_multiplier = 1.5

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "ears"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = BAT_COLORS

/obj/item/organ/internal/ears/bat/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "seems very sensitive to sounds.")
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/bat)

/obj/item/organ/internal/ears/bat/Insert(mob/living/carbon/inserted_into, special, drop_if_replaced, no_id_transfer)
	. = ..()
	inserted_into.AddComponent(/datum/component/echolocation, echo_group = "bat")

/obj/item/organ/internal/ears/bat/Remove(mob/living/carbon/removed_from, special, no_id_transfer)
	. = ..()
	qdel(removed_from.GetComponent(/datum/component/echolocation))

/obj/item/organ/internal/tongue/bat
	name = "bat jaws"
	desc = "Bat DNA infused into what was once some normal teeth."
	actions_types = list(/datum/action/item_action/organ_action/bat_drain)

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "tongue"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = BAT_COLORS
	/// How much do we drain?
	var/drain_amount = 50
	/// How much time is between drains?
	var/cooldown_time = 3 SECONDS
	/// Cooldown between drains
	COOLDOWN_DECLARE(drain_cooldown)

/obj/item/organ/internal/tongue/bat/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "has shiny, elongated fangs.")
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/bat)

/datum/action/item_action/organ_action/bat_drain
	name = "Drain Victim"
	desc = "Leech blood from any carbon victim you are passively grabbing."

/obj/item/organ/internal/tongue/bat/ui_action_click(mob/user, actiontype)
	. = ..()
	if(!iscarbon(user))
		return
	var/mob/living/carbon/carbon_owner = user
	if(!COOLDOWN_FINISHED(src, drain_cooldown))
		to_chat(carbon_owner, span_warning("You just drained blood, wait a few seconds!"))
		return
	if(!carbon_owner.pulling || !iscarbon(carbon_owner.pulling))
		return
	var/mob/living/carbon/victim = carbon_owner.pulling
	if(carbon_owner.blood_volume >= BLOOD_VOLUME_MAXIMUM)
		to_chat(carbon_owner, span_warning("You're already full!"))
		return
	if(victim.stat == DEAD)
		to_chat(carbon_owner, span_warning("You need a living victim!"))
		return
	if(!victim.blood_volume || (victim.dna && ((NOBLOOD in victim.dna.species.species_traits) || victim.dna.species.exotic_blood)))
		to_chat(carbon_owner, span_warning("[victim] doesn't have blood!"))
		return
	COOLDOWN_START(src, drain_cooldown, cooldown_time)
	if(victim.can_block_magic(MAGIC_RESISTANCE_HOLY, charge_cost = 0))
		victim.show_message(span_warning("[carbon_owner] tries to bite you, but stops before touching you!"))
		to_chat(carbon_owner, span_warning("[victim] is blessed! You stop just in time to avoid catching fire."))
		return
	if(victim.has_reagent(/datum/reagent/consumable/garlic))
		victim.show_message(span_warning("[carbon_owner] tries to bite you, but recoils in disgust!"))
		to_chat(carbon_owner, span_warning("[victim] reeks of garlic! you can't bring yourself to drain such tainted blood."))
		return
	if(!do_after(carbon_owner, 3 SECONDS, target = victim))
		return
	var/blood_volume_difference = BLOOD_VOLUME_MAXIMUM - carbon_owner.blood_volume //How much capacity we have left to absorb blood
	var/drained_blood = min(victim.blood_volume, drain_amount, blood_volume_difference)
	victim.show_message(span_danger("[carbon_owner] is draining your blood!"))
	to_chat(carbon_owner, span_notice("You drain some blood!"))
	playsound(carbon_owner, 'sound/items/drink.ogg', 30, TRUE, -2)
	victim.blood_volume = clamp(victim.blood_volume - drained_blood, 0, BLOOD_VOLUME_MAXIMUM)
	carbon_owner.blood_volume = clamp(carbon_owner.blood_volume + drained_blood, 0, BLOOD_VOLUME_MAXIMUM)
	if(!victim.blood_volume)
		to_chat(carbon_owner, span_notice("You finish off [victim]'s blood supply."))


#undef BAT_ORGAN_COLOR
#undef BAT_SCLERA_COLOR
#undef BAT_PUPIL_COLOR

#undef BAT_COLORS
