/datum/team/swarmers
	name = "Swarmer Consciousness"

/datum/antagonist/swarmer
	name = "Swarmer"
	job_rank = ROLE_ALIEN
	show_to_ghosts = TRUE
	show_in_antagpanel = FALSE
	prevent_roundtype_conversion = FALSE
	var/datum/team/swarmers/swarmer_team

/datum/antagonist/swarmer/create_team(datum/team/team)
	if(team)
		swarmer_team = team
		objectives |= swarmer_team.objectives
	else
		swarmer_team = new

/datum/antagonist/swarmer/get_team()
	return swarmer_team

/datum/antagonist/swarmer/greet()
	to_chat(owner, "<span class='bold'>SWARMER CONSTRUCTION COMPLETED.  OPERATOR NOTES:\n\
		- CONSUME RESOURCES TO CONSTRUCT TRAPS, BARRIERS, AND FOLLOWER DRONES\n\
		- BIOLOGICAL RESOURCES WILL BE HARVESTED AT A LATER DATE, DO NOT HARM THEM\n\
		- FOLLOWER DRONES WILL FOLLOW YOU AUTOMATCIALLY UNLESS THEY POSSESS A TARGET.  WHILE DRONES CANNOT ASSIST IN RESOURCE HARVESTING, THEY CAN PROTECT YOU FROM THREATS\n\
		- LCTRL + ATTACKING AN ORGANIC WILL ALOW YOU TO REMOVE SAID ORGANIC FROM THE AREA\n\
		- YOU AND YOUR DRONES HAVE A STUN EFFECT ON MELEE.  YOU ARE ALSO ARMED WITH A DISABLER PROJECTILE, USE THESE TO PREVENT ORGANICS FROM HALTING YOUR PROGRESS\n\
		- YOU CAN SACRIFICE YOUR RESOURCES TO THE BEACON TO BECOME A GUARDIAN, LOSING YOUR OFFENSIVE CAPABILITIES BUT GAINING DEFENSIVE ONES\n\
		GLORY TO !*# $*#^</span>")
	owner.announce_objectives()
