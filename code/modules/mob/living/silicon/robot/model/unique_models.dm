/obj/item/robot_model/clown
	name = "Clown"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/toy/crayon/rainbow,
		/obj/item/instrument/bikehorn,
		/obj/item/stamp/clown,
		/obj/item/bikehorn,
		/obj/item/bikehorn/airhorn,
		/obj/item/paint/anycolor/cyborg,
		/obj/item/soap/nanotrasen/cyborg,
		/obj/item/pneumatic_cannon/pie/selfcharge/cyborg,
		/obj/item/razor, //killbait material
		/obj/item/lipstick/purple,
		/obj/item/reagent_containers/spray/waterflower/cyborg,
		/obj/item/borg/cyborghug/peacekeeper,
		/obj/item/borg/lollipop,
		/obj/item/picket_sign/cyborg,
		/obj/item/reagent_containers/borghypo/clown,
		/obj/item/extinguisher/mini,
	)
	emag_modules = list(
		/obj/item/reagent_containers/borghypo/clown/hacked,
		/obj/item/reagent_containers/spray/waterflower/cyborg/hacked,
	)
	model_select_icon = "service"
	cyborg_base_icon = "clown"
	hat_offset = -2

/obj/item/robot_model/clown/respawn_consumable(mob/living/silicon/robot/cyborg, coeff = 1)
	. = ..()
	var/obj/item/soap/nanotrasen/cyborg/soap = locate(/obj/item/soap/nanotrasen/cyborg) in basic_modules
	if(!soap)
		return
	if(soap.uses < initial(soap.uses))
		soap.uses += ROUND_UP(initial(soap.uses) / 100) * coeff


/obj/item/robot_model/kiltborg
	name = "Highlander"
	basic_modules = list(
		/obj/item/claymore/highlander/robot,
		/obj/item/pinpointer/nuke,
	)
	model_select_icon = "kilt"
	cyborg_base_icon = "kilt"
	hat_offset = -2
	model_traits = list(TRAIT_PUSHIMMUNE)
	breakable_modules = FALSE
	locked_transform = FALSE //GO GO QUICKLY AND SLAUGHTER THEM ALL

/obj/item/robot_model/kiltborg/be_transformed_to(obj/item/robot_model/old_model)
	. = ..()
	if(!.)
		return
	robot.faction -= FACTION_SILICON
	qdel(robot.radio)
	robot.radio = new /obj/item/radio/borg/syndicate(robot)
	robot.scrambledcodes = TRUE
	robot.maxHealth = 50 //DIE IN THREE HITS, LIKE A REAL SCOT
	robot.break_cyborg_slot(3) //YOU ONLY HAVE TWO ITEMS ANYWAY
	var/obj/item/pinpointer/nuke/diskyfinder = locate(/obj/item/pinpointer/nuke) in basic_modules
	diskyfinder.attack_self(robot)

/obj/item/robot_model/kiltborg/do_transform_delay() //AUTO-EQUIPPING THESE TOOLS ANY EARLIER CAUSES RUNTIMES OH YEAH
	. = ..()
	robot.equip_module_to_slot(locate(/obj/item/claymore/highlander/robot) in basic_modules, 1)
	robot.equip_module_to_slot(locate(/obj/item/pinpointer/nuke) in basic_modules, 2)
	robot.place_on_head(new /obj/item/clothing/head/beret/highlander(robot)) //THE ONLY PART MORE IMPORTANT THAN THE SWORD IS THE HAT
	ADD_TRAIT(robot.hat, TRAIT_NODROP, HIGHLANDER_TRAIT)

/obj/item/robot_model/kiltborg/Destroy()
	robot.faction |= FACTION_SILICON
	return ..()
