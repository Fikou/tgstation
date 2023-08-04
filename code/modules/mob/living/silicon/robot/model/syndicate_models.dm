
/obj/item/robot_model/syndicate
	name = "Syndicate Assault"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/melee/energy/sword/cyborg,
		/obj/item/gun/energy/printer,
		/obj/item/gun/ballistic/revolver/grenadelauncher/cyborg,
		/obj/item/card/emag,
		/obj/item/crowbar/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/pinpointer/syndicate_cyborg,
	)
	cyborg_base_icon = "synd_sec"
	model_select_icon = "malf"
	model_traits = list(TRAIT_PUSHIMMUNE)
	hat_offset = 3

/obj/item/robot_model/syndicate/be_transformed_to(obj/item/robot_model/old_model, forced)
	. = ..()
	if(!.)
		return
	robot.faction -= FACTION_SILICON //ai turrets

/obj/item/robot_model/syndicate/Destroy()
	robot.faction |= FACTION_SILICON
	return ..()

/obj/item/robot_model/syndicate_medical
	name = "Syndicate Medical"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/reagent_containers/borghypo/syndicate,
		/obj/item/shockpaddles/syndicate/cyborg,
		/obj/item/healthanalyzer,
		/obj/item/surgical_drapes,
		/obj/item/retractor,
		/obj/item/hemostat,
		/obj/item/cautery,
		/obj/item/surgicaldrill,
		/obj/item/scalpel,
		/obj/item/melee/energy/sword/cyborg/saw,
		/obj/item/bonesetter,
		/obj/item/blood_filter,
		/obj/item/roller/robo,
		/obj/item/crowbar/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/pinpointer/syndicate_cyborg,
		/obj/item/stack/medical/gauze,
		/obj/item/stack/medical/bone_gel,
		/obj/item/gun/medbeam,
		/obj/item/borg/apparatus/organ_storage,
	)
	cyborg_base_icon = "synd_medical"
	model_select_icon = "malf"
	model_traits = list(TRAIT_PUSHIMMUNE)
	hat_offset = 3

/obj/item/robot_model/syndicate_medical/be_transformed_to(obj/item/robot_model/old_model, forced)
	. = ..()
	if(!.)
		return
	robot.faction -= FACTION_SILICON //ai turrets

/obj/item/robot_model/syndicate_medical/Destroy()
	robot.faction |= FACTION_SILICON
	return ..()

/obj/item/robot_model/saboteur
	name = "Syndicate Saboteur"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/sight/thermal,
		/obj/item/construction/rcd/borg/syndicate,
		/obj/item/pipe_dispenser,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/extinguisher,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/screwdriver/nuke,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/analyzer,
		/obj/item/multitool/cyborg,
		/obj/item/stack/sheet/iron,
		/obj/item/stack/sheet/glass,
		/obj/item/borg/apparatus/sheet_manipulator,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/iron/base/cyborg,
		/obj/item/dest_tagger/borg,
		/obj/item/stack/cable_coil,
		/obj/item/pinpointer/syndicate_cyborg,
		/obj/item/borg_chameleon,
		/obj/item/card/emag,
	)
	cyborg_base_icon = "synd_engi"
	model_select_icon = "malf"
	model_traits = list(TRAIT_PUSHIMMUNE, TRAIT_NEGATES_GRAVITY)
	hat_offset = -4
	canDispose = TRUE
