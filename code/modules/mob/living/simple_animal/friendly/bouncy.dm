/mob/living/simple_animal/bouncy_ball
	name = "bouncy ball"
	maxHealth = 50
	health = 50
	desc = "A floaty ball filled with air...Let's hope it doesn't come this way"
	gender = NEUTER
	icon = 'icons/mob/bouncyball.dmi'
	icon_state = "bouncyball"
	icon_living = "bouncyball"
	///Override so it uses datum ai
	can_have_ai = FALSE
	AIStatus = AI_OFF
	del_on_death = TRUE
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

/mob/living/simple_animal/bouncy_ball/Initialize(mapload)
	. = ..()
	setDir(pick(GLOB.alldirs)) //Pick a bounce direction


/mob/living/simple_animal/bouncy_ball/setDir(newdir)
	. = ..()
	walk(src, newdir, 1 SECONDS)

/mob/living/simple_animal/bouncy_ball/Bump(atom/A)
	. = ..()
	var/atom/throw_target = get_edge_target_turf(A, dir)
	if(isliving(A) && !istype(A, type))
		var/mob/living/yeeted_living = A
		yeeted_living.throw_at(throw_target, rand(1,3), 3)

	var/face_direction = get_dir(A, src)
	var/face_angle = dir2angle(face_direction)
	var/incidence_s = GET_ANGLE_OF_INCIDENCE(face_angle, (dir2angle(dir) + 180))
	var/new_angle_s = SIMPLIFY_DEGREES(face_angle + incidence_s)
	setDir(angle2dir(new_angle_s))
