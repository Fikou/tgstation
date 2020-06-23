//Vending NPC's, they are vendors that seem a bit more human, might be useful for mapping/admin events
/obj/machinery/vending/npc
	name = "Vending NPC"
	desc = "Come buy some!"
	circuit = null
	tiltable = FALSE
	payment_department = NO_FREEBIES
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	integrity_failure = 0
	light_power = 0
	light_range = 0
	verb_say = "says"
	verb_ask = "asks"
	verb_exclaim = "exclaims"
	speech_span = null
	age_restrictions = FALSE //hey kid, wanna buy some?
	use_power = NO_POWER_USE
	onstation_override = TRUE
	vending_sound = 'sound/effects/cashregister.ogg'
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "faceless"
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND
	layer = MOB_LAYER
	///Corpse spawned when vendor is deconstructed (MURDERED)
	var/corpse = /obj/effect/mob_spawn/human/corpse
	///Phrases used when you talk to the NPC
	var/list/lore = list("Hello! I am the test NPC.",
						"Man, shut the fuck up."
						)
	///List of items able to be sold to the npc
	var/list/wanted_items = list()

/obj/machinery/vending/npc/Initialize()
	. = ..()
	QDEL_NULL(wires)
	QDEL_NULL(coin)
	QDEL_NULL(bill)
	QDEL_NULL(Radio)

/obj/machinery/vending/npc/attackby(obj/item/I, mob/user, params)
	return

/obj/machinery/vending/npc/crowbar_act(mob/living/user, obj/item/I)
	return

/obj/machinery/vending/npc/wrench_act(mob/living/user, obj/item/I)
	return

/obj/machinery/vending/npc/screwdriver_act(mob/living/user, obj/item/I)
	return

/obj/machinery/vending/npc/deconstruct(disassembled = TRUE)
	if(corpse)
		new corpse(src)
	qdel(src)

/obj/machinery/vending/npc/loadingAttempt(obj/item/I, mob/user)
	return

/obj/machinery/vending/npc/emag_act(mob/user)
	return

/obj/machinery/vending/npc/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(istype(AM, /obj/item))
		return
	..()

/obj/machinery/vending/npc/interact(mob/user)
	face_atom(user)
	var/list/npc_options = list(
		"Buy" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_buy"),
		"Sell" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_sell"),
		"Talk" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_talk")
		)
	var/npc_result = show_radial_menu(user, src, npc_options, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user))
		return FALSE
	switch(npc_result)
		if("Buy")
			return ui_interact(user)
		if("Sell")
			return try_sell(user)
		if("Talk")
			return deep_lore(user)
	face_atom(user)
	return FALSE

/obj/machinery/vending/npc/ui_act(action, params)
	. = ..()
	face_atom(usr)

/obj/machinery/vending/npc/proc/check_menu(mob/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/machinery/vending/npc/proc/try_sell(mob/user)
	var/obj/item/activehanditem = user.get_active_held_item()
	var/obj/item/inactivehanditem = user.get_inactive_held_item()
	if(!(sell_item(user, activehanditem)||sell_item(user, inactivehanditem)))
		say("Sorry, I'm not a fan of anything you're showing me. Give me something better and we'll talk.")

/obj/machinery/vending/npc/proc/deep_lore(mob/user)
	say(pick(lore))


/obj/machinery/vending/npc/proc/sell_item(mob/user, selling)
	var/obj/item/sellitem = selling
	if(is_type_in_list(sellitem, wanted_items))
		say("Hey, you've got an item that interests me, I'd like to buy that [sellitem], I'll give you [wanted_items[sellitem.type]] cash for it, deal?")
		var/list/npc_options = list(
			"Yes" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_yes"),
			"No" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_no")
			)
		var/npc_result = show_radial_menu(user, src, npc_options, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
		if(!check_menu(user))
			return FALSE
		if(npc_result != "Yes")
			say("What a shame, tell me if you changed your mind.")
			return FALSE
		say("Pleasure doing business with you.")
		if(istype(sellitem, /obj/item/stack))
			var/obj/item/stack/stackoverflow = sellitem
			generate_cash(wanted_items[stackoverflow.type] * stackoverflow.amount, user)
			stackoverflow.use(stackoverflow.amount)
			return TRUE
		generate_cash(wanted_items[sellitem.type], user)
		return TRUE
	return FALSE

/obj/machinery/vending/npc/proc/generate_cash(value, mob/user)
	var/obj/item/holochip/chip = new /obj/item/holochip(src, value)
	user.put_in_hands(chip)

/obj/machinery/vending/npc/mrbones
	name = "Mr. Bones"
	desc = "The ride never ends!"
	verb_say = "rattles"
	vending_sound = 'sound/voice/hiss2.ogg'
	speech_span = SPAN_SANS
	default_price = 500
	extra_price = 1000
	products = list(/obj/item/clothing/head/helmet/skull = 1,
					/obj/item/clothing/mask/bandana/skull = 1,
					/obj/item/reagent_containers/food/snacks/sugarcookie/spookyskull = 5,
					/obj/item/instrument/trombone/spectral = 1,
					/obj/item/shovel/serrated = 1
					)
	product_ads = "Why's there so little traffic, is this a skeleton crew?;You should buy like there's no to-marrow!"
	vend_reply = "Bone appetit!"
	icon_state = "mrbones"
	gender = MALE
	corpse = /obj/effect/decal/remains
	lore = list("Hello, I am Mr. Bones!",
				"The ride never ends!",
				"I'd really like a refreshing carton of milk!",
				"I'm willing to play big prices for BONES! Need materials to make merch, eh?"
				)
	wanted_items = list(/obj/item/reagent_containers/food/condiment/milk = 1000,
						/obj/item/stack/sheet/bone = 420)
