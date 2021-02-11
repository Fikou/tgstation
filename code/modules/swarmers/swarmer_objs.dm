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
	layer = MASSIVE_OBJ_LAYER
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
	addtimer(VARSET_CALLBACK(src, processing, FALSE), 4.12 SECONDS)
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

/obj/structure/swarmer/trap/Crossed(atom/movable/AM)
	if(isliving(AM))
		var/mob/living/living_crosser = AM
		if(!istype(living_crosser, /mob/living/simple_animal/hostile/swarmer))
			playsound(loc,'sound/effects/snap.ogg',50, TRUE, -1)
			living_crosser.electrocute_act(100, src, TRUE, flags = SHOCK_NOGLOVES|SHOCK_ILLUSION)
			if(iscyborg(living_crosser))
				living_crosser.Paralyze(100)
			qdel(src)
	return ..()

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

/obj/structure/swarmer/tower

/obj/structure/swarmer/turret
	name = "swarmer turret"
	desc = "A quickly assembled energy turret, it shoots disabler beams in cardinal directions and then in diagonal ones."
	icon_state = "turret"
	density = TRUE
	var/diagonal = TRUE
	var/cooldown_time = 1 SECONDS
	COOLDOWN_DECLARE(cooldown_timer)

/obj/structure/swarmer/turret/Initialize(mapload)
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
	flick("[diagonal ? "turret_diagonal" : "turret_cardinal"]", src)
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
