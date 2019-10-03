/obj/item/organ/brain/mami
	name = "\improper Machine-Man Interface"
	desc = "A piece of juicy machinery found in a person's head. Positronic brain not included."
	icon_state = "mami"
	organ_flags = ORGAN_SYNTHETIC
	w_class = WEIGHT_CLASS_NORMAL
	var/obj/item/radio/radio = null //Let's give it a radio.
	var/obj/item/mmi/posibrain/brane = null

/obj/item/organ/brain/mami/update_icon()
	if(!brane)
		icon_state = "mami"
	else
		icon_state = "mami-occupied"

/obj/item/organ/brain/mami/Initialize()
	. = ..()
	radio = new(src) //Spawns a radio inside the MMI.
	radio.broadcasting = FALSE //researching radio mmis turned the robofabs into radios because this didnt start as 0.

/obj/item/organ/brain/mami/attackby(obj/item/O, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if(istype(O, /obj/item/mmi/posibrain)) //Time to stick a brain in it --NEO
		var/obj/item/mmi/posibrain/newbrain = O
		if(brane)
			to_chat(user, "<span class='warning'>There's already a posibrain in the MaMI!</span>")
			return
		if(!newbrain.brainmob)
			to_chat(user, "<span class='warning'>Error. Posibrain not activated!</span>")
			return

		if(!user.transferItemToLoc(O, src))
			return
		var/mob/living/brain/B = newbrain.brainmob
		if(!B.key)
			B.notify_ghost_cloning("Someone has put your brain in a MaMI!", source = src)
		user.visible_message("<span class='notice'>[user] sticks \a [newbrain] into [src].</span>", "<span class='notice'>[src]'s indicator light turn on as you insert [newbrain].</span>")

		brainmob = newbrain.brainmob
		newbrain.brainmob = null
		brainmob.forceMove(src)
		brainmob.container = src
		GLOB.dead_mob_list -= brainmob
		GLOB.alive_mob_list += brainmob
		brainmob.reset_perspective()
		brane = newbrain

		name = "[initial(name)]: [brainmob.real_name]"
		update_icon()
		
		to_chat(brainmob, <b>You are a positronic brain in control of an organ, brought into existence aboard Space Station 13.\n\
		As a synthetic intelligence, you answer to all crewmembers and the AI.\n\
		Remember, the purpose of your existence is to serve the crew and the station. Above all else, do no harm.</b>)
		
		log_game("[key_name(user)] has put the posibrain of [key_name(brainmob)] into a MaMI at [AREACOORD(src)]")

	else if(brainmob)
		O.attack(brainmob, user) //Oh noooeeeee
	else
		return ..()

/obj/item/organ/brain/mami/transfer_identity(mob/living/L)
	..()
	brainmob.name = initial(brainmob.name)
	brainmob.real_name = initial(brainmob.real_name)
	name = "[initial(name)]: [brainmob.real_name]"

/obj/item/organ/brain/mami/attack_self(mob/user)
	if(!brane)
		radio.on = !radio.on
		to_chat(user, "<span class='notice'>You toggle [src]'s radio system [radio.on==1 ? "on" : "off"].</span>")
	else
		eject_brain(user)
		update_icon()
		name = initial(name)
		to_chat(user, "<span class='notice'>You unlock and upend [src], dropping the posibrain onto the floor.</span>")

/obj/item/organ/brain/mami/deconstruct(disassembled = TRUE)
	if(brane)
		eject_brain()
	qdel(src)

/obj/item/organ/brain/mami/speshal_message()
	. += "<span class='notice'>There is a switch to toggle the radio system [radio.on ? "off" : "on"].[brane ? " It is currently being covered by [brane]." : null]</span>"
	if(brainmob)
		var/mob/living/brain/B = brainmob
		if(!B.key || !B.mind || B.stat == DEAD)
			. += "<span class='warning'>The MaMI indicates the posibrain is completely unresponsive.</span>"

		else if(!B.client)
			. += "<span class='warning'>The MaMI indicates the posibrain is currently inactive; it might change.</span>"

		else
			. += "<span class='notice'>The MaMI indicates the posibrain is active.</span>"

/obj/item/organ/brain/mami/relaymove(mob/user)
	return //so that the MaMI won't get a warning about not being able to move if it tries to move

/obj/item/organ/brain/mami/Destroy()
	if(radio)
		qdel(radio)
		radio = null
	return ..()

/obj/item/organ/brain/mami/proc/eject_brain(mob/user)
	brainmob.container = null //Reset brainmob mami var.
	brainmob.forceMove(brane) //Throw mob into brain.
	brainmob.reset_perspective() //so the brainmob follows the brain organ instead of the mmi. And to update our vision
	GLOB.alive_mob_list -= brainmob //Get outta here
	GLOB.dead_mob_list |= brainmob
	brane.brainmob = brainmob //Set the brain to use the brainmob
	log_game("[key_name(user)] has ejected the posibrain of [key_name(brainmob)] from a MaMI at [AREACOORD(src)]")
	brainmob = null //Set mmi brainmob var to null
	if(user)
		user.put_in_hands(brane) //puts brain in the user's hand or otherwise drops it on the user's turf
	else
		brane.forceMove(get_turf(src))
	brane = null //No more brain in here
