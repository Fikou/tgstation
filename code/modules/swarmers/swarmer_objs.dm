/obj/structure/swarmer //Default swarmer effect object visual feedback
	name = "swarmer ui"
	desc = null
	gender = NEUTER
	icon = 'icons/mob/swarmer.dmi'
	icon_state = "ui_light"
	layer = MOB_LAYER
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	light_color = LIGHT_COLOR_CYAN
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	max_integrity = 30
	anchored = TRUE

/obj/structure/swarmer/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/weapons/egloves.ogg', 80, TRUE)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/swarmer/emp_act()
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	qdel(src)

/**
 * # Swarmer Beacon
 *
 * Beacon which creates sentient player swarmers.
 *
 * The beacon which creates sentient player swarmers during the swarmer event.  Spawns in maint on xeno locations, and can create a player swarmer once every 30 seconds.
 * The beacon cannot be damaged by swarmers, and must be destroyed to prevent the spawning of further player-controlled swarmers.
 * Holds a swarmer within itself during the 30 seconds before releasing it and allowing for another swarmer to be spawned in.
 */

/obj/structure/swarmer_beacon
	name = "swarmer beacon"
	desc = "A machine that prints swarmers."
	icon = 'icons/mob/swarmer.dmi'
	icon_state = "swarmer_console"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 50, BIO = 100, RAD = 100, FIRE = 100, ACID = 100)
	max_integrity = 500
	plane = MASSIVE_OBJ_PLANE
	light_color = LIGHT_COLOR_CYAN
	light_range = 10
	anchored = TRUE
	density = FALSE
	///Team antag role for swarmers
	var/datum/team/swarmers/swarmers
	///Whether or not a swarmer is currently being created by this beacon or the beacon is currently being created
	var/processing = TRUE
	///Global material storage
	var/resources = 0

/obj/structure/swarmer_beacon/Initialize()
	. = ..()
	flick("swarmer_console_full_boot", src)
	addtimer(VARSET_CALLBACK(src, processing, FALSE), 5 SECONDS)
	AddElement(/datum/element/point_of_interest)
	swarmers = new /datum/team/swarmers()
	var/datum/objective/swarmer/material_objective = new
	material_objective.gen_objective(src)
	material_objective.team = swarmers
	swarmers.objectives += material_objective
	var/datum/objective/protect_object/protect_objective = new
	protect_objective.set_target(src)
	protect_objective.team = swarmers
	swarmers.objectives += protect_objective

/obj/structure/swarmer_beacon/attack_ghost(mob/user)
	. = ..()
	if(processing)
		to_chat(user, "<b>The beacon is currently processing. Try again later.</b>")
		return
	var/swarm_ask = alert("Become a swarmer?", "Do you wish to consume the station?", "Yes", "No")
	if(swarm_ask == "No" || QDELETED(src) || QDELETED(user) || processing)
		return
	que_swarmer(user, /mob/living/simple_animal/hostile/swarmer, FALSE)

/**
 * Interaction when a ghost interacts with a swarmer beacon
 *
 * Called when a ghost interacts with a swarmer beacon, allowing them to become a swarmer
 * Arguments:
 * * user - A reference to the ghost interacting with the beacon
 */
/obj/structure/swarmer_beacon/proc/que_swarmer(mob/user, mob/living/simple_animal/hostile/swarmer/swarmer_type, reconstructing = FALSE)
	var/mob/living/simple_animal/hostile/swarmer/newswarmer = new swarmer_type(src)
	if(reconstructing)
		user.mind.transfer_to(newswarmer)
	else
		newswarmer.key = user.key
	newswarmer.origin_beacon = src
	addtimer(CALLBACK(src, .proc/release_swarmer, newswarmer), (LAZYLEN(swarmers.members) * 2 SECONDS) + 5 SECONDS)
	to_chat(newswarmer, "<span class='boldannounce'>SWARMER [reconstructing ? "RECONSTRUCTION" : "CONSTRUCTION"] INITIALIZED.</span>")
	playsound(src, 'sound/items/rped.ogg', 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	processing = TRUE
	return TRUE

/**
 * Releases a swarmer from the beacon and tells it what to do
 *
 * Occcurs 5 + (alive swarmers made from beacon * 2) seconds after a ghost becomes a swarmer.  The beacon releases it, tells it what to do, and opens itself up to spawn in a new swarmer.
 * Arguments:
 * * swarmer - The swarmer being released and told what to do
 */
/obj/structure/swarmer_beacon/proc/release_swarmer(mob/swarmer)
	playsound(src, 'sound/items/deconstruct.ogg', 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	swarmer.forceMove(get_turf(src))
	if(!swarmer.mind.has_antag_datum(/datum/antagonist/swarmer))
		swarmer.mind.add_antag_datum(/datum/antagonist/swarmer, swarmers)
	processing = FALSE

/obj/structure/swarmer/trap
	name = "swarmer trap"
	desc = "A quickly assembled trap that electrifies living beings and overwhelms machine sensors. Will not retain its form if damaged enough."
	icon_state = "trap"
	max_integrity = 10
	density = FALSE

/obj/structure/swarmer/trap/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, src, loc_connections)

/obj/structure/swarmer/trap/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(isliving(AM))
		var/mob/living/living_crosser = AM
		if(!istype(living_crosser, /mob/living/simple_animal/hostile/swarmer))
			playsound(loc,'sound/effects/snap.ogg',50, TRUE, 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			living_crosser.electrocute_act(100, src, TRUE, flags = SHOCK_NOGLOVES|SHOCK_ILLUSION)
			if(iscyborg(living_crosser))
				living_crosser.Paralyze(100)
			qdel(src)

/obj/structure/swarmer/blockade
	name = "swarmer blockade"
	desc = "A quickly assembled energy blockade. Will not retain its form if damaged enough, but disabler beams and swarmers pass right through."
	icon_state = "barricade"
	max_integrity = 50
	density = TRUE

/obj/structure/swarmer/blockade/CanAllowThrough(atom/movable/O)
	. = ..()
	if(isswarmer(O) || istype(O, /obj/projectile/beam/disabler))
		return TRUE

/obj/structure/swarmer/field_generator
	name = "swarmer field generator"
	desc = "A quickly assembled energy generator, it creates rechargeable blockades on its sides."
	icon_state = "generator"
	max_integrity = 75
	density = TRUE
	var/cooldown_time = 5 SECONDS
	var/obj/structure/swarmer/blockade/blockade_right
	var/obj/structure/swarmer/blockade/blockade_left

/obj/structure/swarmer/field_generator/Initialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation, ROTATION_ALTCLICK|ROTATION_CLOCKWISE, CALLBACK(src, .proc/can_user_rotate), CALLBACK(src, .proc/can_be_rotated), CALLBACK(src,.proc/after_rotation))
	recalculate_barriers(TRUE, TRUE)

/obj/structure/swarmer/field_generator/Destroy()
	..()
	QDEL_NULL(blockade_right)
	QDEL_NULL(blockade_left)

/obj/structure/swarmer/field_generator/proc/can_user_rotate(mob/living/simple_animal/hostile/swarmer/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY))
		return FALSE
	return TRUE

/obj/structure/swarmer/field_generator/proc/can_be_rotated()
	for(var/turf/torf in orange(1,src))
		return !torf.is_blocked_turf(TRUE, src, list(blockade_right, blockade_left))

/obj/structure/swarmer/field_generator/proc/after_rotation(mob/user)
	to_chat(user,"<span class='notice'>You rotate [src].</span>")
	recalculate_barriers()

/obj/structure/swarmer/field_generator/proc/recalculate_barriers(create_right = FALSE, create_left = FALSE)
	for(var/turf/torf in orange(1,get_turf(src)))
		if(torf.is_blocked_turf(TRUE, src, list(blockade_right, blockade_left)))
			return
	if(!blockade_right)
		if(create_right)
			blockade_right = new /obj/structure/swarmer/blockade(get_step(src, turn(dir, 90)))
			RegisterSignal(blockade_right, COMSIG_PARENT_QDELETING, .proc/remove_blockade, blockade_right)
	else
		blockade_right.forceMove(get_step(src, turn(dir, 90)))
	if(!blockade_left)
		if(create_left)
			blockade_left = new /obj/structure/swarmer/blockade(get_step(src, turn(dir, -90)))
			RegisterSignal(blockade_left, COMSIG_PARENT_QDELETING, .proc/remove_blockade, blockade_left)
	else
		blockade_left.forceMove(get_step(src, turn(dir, -90)))
	playsound(src,'sound/weapons/resonator_fire.ogg',100,TRUE,SHORT_RANGE_SOUND_EXTRARANGE)

/obj/structure/swarmer/field_generator/proc/remove_blockade(obj/structure/swarmer/blockade/blockade)
	if(blockade == blockade_right)
		addtimer(CALLBACK(src, .proc/recalculate_barriers, TRUE, FALSE), cooldown_time)
		blockade_right = null
	if(blockade == blockade_left)
		addtimer(CALLBACK(src, .proc/recalculate_barriers, FALSE, TRUE), cooldown_time)
		blockade_left = null

/obj/structure/swarmer/tower
	name = "swarmer tower"
	desc = "A quickly assembled tower, it summons drones that orbit it until they find a target."
	icon_state = "tower"
	max_integrity = 50
	density = TRUE
	var/list/dronelist = list()
	var/drone_limit = 4
	var/cooldown_time = 10 SECONDS
	COOLDOWN_DECLARE(cooldown_timer)

/obj/structure/swarmer/tower/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/swarmer/tower/process(delta_time)
	if(COOLDOWN_FINISHED(src, cooldown_timer) && dronelist.len < drone_limit)
		fabricate_swarmer()

/obj/structure/swarmer/tower/proc/fabricate_swarmer()
	playsound(src, 'sound/magic/summonitems_generic.ogg', 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	COOLDOWN_START(src, cooldown_timer, cooldown_time)
	var/turf/spawn_turf
	for(var/turf/torf in orange(1,get_turf(src)))
		if(torf.is_blocked_turf(FALSE, src))
			continue
		spawn_turf = torf
		break
	if(!spawn_turf)
		return
	var/mob/newswarmer = new /mob/living/simple_animal/hostile/swarmer/drone/melee(spawn_turf)
	dronelist += newswarmer

/obj/structure/swarmer/turret
	name = "swarmer turret"
	desc = "A quickly assembled energy turret, it shoots disabler beams in cardinal directions and then in diagonal ones."
	icon_state = "turret_cardinal"
	density = TRUE
	var/diagonal = TRUE
	var/cooldown_time = 1 SECONDS
	COOLDOWN_DECLARE(cooldown_timer)

/obj/structure/swarmer/turret/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/structure/swarmer/turret/process(delta_time)
	if(COOLDOWN_FINISHED(src, cooldown_timer))
		prepare_to_shoot()

/obj/structure/swarmer/turret/proc/prepare_to_shoot()
	var/list/shot_dirs
	if(diagonal)
		shot_dirs = GLOB.diagonals
	else
		shot_dirs = GLOB.cardinals
	for(var/dir in shot_dirs)
		var/turf/target = get_step(src, dir)
		shoot_projectile(target)
	diagonal = !diagonal
	icon_state = "turret_[diagonal ? "diagonal" : "cardinal"]"
	flick("[diagonal ? "turret_diagonal_anim" : "turret_cardinal_anim"]", src)
	playsound(src, 'sound/weapons/taser2.ogg', 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	COOLDOWN_START(src, cooldown_timer, cooldown_time)

/obj/structure/swarmer/turret/proc/shoot_projectile(turf/marker)
	if(!marker || marker == loc)
		return
	var/obj/projectile/P = new /obj/projectile/beam/disabler/swarmer(get_turf(src))
	P.preparePixelProjectile(marker, src)
	P.fired_from = src
	P.firer = src
	P.fire()

/obj/effect/temp_visual/swarmer //temporary swarmer visual feedback objects
	icon = 'icons/mob/swarmer.dmi'
	layer = BELOW_MOB_LAYER

/obj/effect/temp_visual/swarmer/disintegration
	icon_state = "disintegrate"
	duration = 1 SECONDS

/obj/effect/temp_visual/swarmer/disintegration/Initialize()
	. = ..()
	playsound(loc, "sparks", 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/obj/effect/temp_visual/swarmer/dismantle
	icon_state = "dismantle"
	duration = 2.5 SECONDS

/obj/effect/temp_visual/swarmer/integrate
	icon_state = "integrate"
	duration = 0.5 SECONDS
