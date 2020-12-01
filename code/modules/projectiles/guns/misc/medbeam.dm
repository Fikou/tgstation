/obj/item/gun/medbeam
	name = "Medical Beamgun"
	desc = "Don't cross the streams!"
	icon = 'icons/obj/chronos.dmi'
	icon_state = "chronogun"
	inhand_icon_state = "chronogun"
	w_class = WEIGHT_CLASS_NORMAL

	var/mob/living/current_target
	var/last_check = 0
	var/check_delay = 10 //Check los as often as possible, max resolution is SSobj tick though
	var/max_range = 8
	var/active = FALSE
	var/datum/beam/current_beam = null
	var/mounted = FALSE //Denotes if this is a handheld or mounted version
	var/beam_icon = "medbeam"

	weapon_weight = WEAPON_MEDIUM

/obj/item/gun/medbeam/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/gun/medbeam/Destroy(mob/user)
	STOP_PROCESSING(SSobj, src)
	LoseTarget(user)
	return ..()

/obj/item/gun/medbeam/dropped(mob/user)
	..()
	LoseTarget(user)

/obj/item/gun/medbeam/equipped(mob/user)
	..()
	LoseTarget(user)

/obj/item/gun/medbeam/proc/LoseTarget(atom/user)
	if(active)
		qdel(current_beam)
		current_beam = null
		active = FALSE
		on_beam_release(current_target, user)
	current_target = null

/obj/item/gun/medbeam/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(isliving(user))
		add_fingerprint(user)

	if(current_target)
		if(target == current_target)
			LoseTarget(user)
			return
		LoseTarget(user)
	if(!isliving(target))
		return
	current_target = target
	active = TRUE
	current_beam = new(user,current_target,time=6000,beam_icon_state=beam_icon,btype=/obj/effect/ebeam/medical)
	INVOKE_ASYNC(current_beam, /datum/beam.proc/Start)
	on_beam_hit(target, user)

	SSblackbox.record_feedback("tally", "gun_fired", 1, type)

/obj/item/gun/medbeam/process(deltatime)
	var/source = loc
	if(!mounted && !isliving(source))
		LoseTarget(source)
		return
	if(!current_target || current_target.stat == DEAD)
		LoseTarget(source)
		return
	if(get_dist(source, current_target)>max_range || !los_check(source, current_target))
		LoseTarget(source)
		if(isliving(source))
			to_chat(source, "<span class='warning'>You lose control of the beam!</span>")
		return
	if(current_target)
		on_beam_tick(current_target)

/obj/item/gun/medbeam/proc/los_check(atom/movable/user, mob/target)
	var/turf/user_turf = user.loc
	if(mounted)
		user_turf = get_turf(user)
	else if(!istype(user_turf))
		return FALSE
	var/obj/dummy = new(user_turf)
	dummy.pass_flags |= PASSTABLE|PASSGLASS|PASSGRILLE //Grille/Glass so it can be used through common windows
	for(var/turf/turf in getline(user_turf,target))
		if(mounted && turf == user_turf)
			continue //Mechs are dense and thus fail the check
		if(turf.density)
			qdel(dummy)
			return FALSE
		for(var/atom/movable/AM in turf)
			if(!AM.CanPass(dummy,turf,1))
				qdel(dummy)
				return FALSE
		for(var/obj/effect/ebeam/medical/B in turf)// Don't cross the str-beams!
			if(B.owner.origin != current_beam.origin)
				explosion(B.loc,0,3,5,8)
				qdel(dummy)
				return FALSE
	qdel(dummy)
	return TRUE

/obj/item/gun/medbeam/proc/on_beam_hit(mob/living/target, atom/user)
	return

/obj/item/gun/medbeam/proc/on_beam_tick(mob/living/target)
	if(target.health != target.maxHealth)
		new /obj/effect/temp_visual/heal(get_turf(target), "#80F5FF")
	target.adjustBruteLoss(-4)
	target.adjustFireLoss(-4)
	target.adjustToxLoss(-1)
	target.adjustOxyLoss(-1)

/obj/item/gun/medbeam/proc/on_beam_release(mob/living/target, atom/user)
	return

/obj/effect/ebeam/medical
	name = "medical beam"

//////////////////////////////Mech Version///////////////////////////////
/obj/item/gun/medbeam/mech
	mounted = TRUE

/obj/item/gun/medbeam/mech/Initialize()
	. = ..()
	STOP_PROCESSING(SSobj, src) //Mech mediguns do not process until installed, and are controlled by the holder obj

//////////////////////////////Red ERT Version////////////////////////////

/obj/item/gun/medbeam/mega
	name = "Experimental Medical Beamgun"
	desc = "This experimental beamgun has a highly advanced \"Mëgacharge\" function that lets the target and user become invincible for a short while. Does not work on nonhuman lifeforms. Don't cross the streams!"
	pin = /obj/item/firing_pin/implant/mindshield
	var/texture_icon_state = "megacharge"
	var/texture
	var/eyeoverlay
	var/megacharge_active = FALSE
	var/megacharge = 0
	var/chargepertick = 3
	var/dischargepertick = -5

/obj/item/gun/medbeam/mega/Initialize()
	. = ..()
	texture = mutable_appearance(icon, texture_icon_state, -3)
	eyeoverlay = mutable_appearance('icons/effects/genetics.dmi', "lasereyes", -2)

/obj/item/gun/medbeam/mega/attack_self(mob/user)
	if(megacharge_active)
		user.visible_message("<span class='warning'>[src] buzzes. It's already on!")
		return
	if(megacharge < 100)
		user.visible_message("<span class='warning'>[src] buzzes. It's not fully charged!")
		return
	LoseTarget(user)
	megacharge_active = TRUE
	icon_state = "[initial(icon_state)]3"
	beam_icon = "sm_arc_supercharged"
	playsound(src, 'sound/machines/defib_zap.ogg', 70, FALSE)

/obj/item/gun/medbeam/mega/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Mëgacharge is [megacharge]% filled.</span>"

/obj/item/gun/medbeam/mega/on_beam_hit(mob/living/target, atom/user)
	if(megacharge_active)
		playsound(src, 'sound/machines/defib_zap.ogg', 50, FALSE)
		var/list/mobs_affected = list()
		mobs_affected += target
		if(isliving(user))
			mobs_affected += user
		for(var/m in mobs_affected)
			var/mob/living/charged = m
			if(ishuman(charged))
				var/mob/living/carbon/human/hooman = charged
				hooman.physiology.damage_resistance += 200
				hooman.add_stun_absorption("megacharge", INFINITY, 5)
				if(texture_icon_state)
					hooman.add_overlay(texture)
				hooman.add_overlay(eyeoverlay)
			else
				LoseTarget(user)
				charged.visible_message("<span class='warning'>[src] buzzes and shuts off. It can't Mëgacharge nonhuman lifeforms!")
				playsound(src, 'sound/machines/defib_failed.ogg', 70, FALSE)
				return

/obj/item/gun/medbeam/mega/on_beam_release(mob/living/target, atom/user)
	if(megacharge_active)
		var/list/mobs_affected = list()
		if(target && !QDELETED(target))
			mobs_affected += target
		if(isliving(user))
			mobs_affected += user
		for(var/m in mobs_affected)
			var/mob/living/charged = m
			if(ishuman(charged))
				var/mob/living/carbon/human/hooman = charged
				hooman.physiology.damage_resistance -= 200
				if(islist(hooman.stun_absorption) && hooman.stun_absorption["megacharge"])
					hooman.stun_absorption -= "megacharge"
				if(texture_icon_state)
					hooman.cut_overlay(texture)
				hooman.cut_overlay(eyeoverlay)

/obj/item/gun/medbeam/mega/process(deltatime)
	. = ..()
	if(megacharge > 0)
		update_megacharge(TRUE, dischargepertick * deltatime)

/obj/item/gun/medbeam/mega/on_beam_tick(mob/living/target)
	if(!megacharge_active)
		. = ..()
	if(megacharge < 100)
		update_megacharge(FALSE, chargepertick)

/obj/item/gun/medbeam/mega/proc/update_megacharge(when_charged, amount)
	if((when_charged && megacharge_active) || (!when_charged && !megacharge_active))
		megacharge = clamp(megacharge + amount, 0, 100)
		if(megacharge == 100)
			icon_state = "[initial(icon_state)]2"
			playsound(src, 'sound/machines/defib_ready.ogg', 70, FALSE)
		if(megacharge == 0)
			icon_state = initial(icon_state)
			beam_icon = initial(beam_icon)
			LoseTarget(loc)
			megacharge_active = FALSE
			playsound(src, 'sound/machines/defib_success.ogg', 70, FALSE)
