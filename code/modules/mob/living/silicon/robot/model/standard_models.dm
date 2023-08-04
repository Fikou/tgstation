/obj/item/robot_model/engineering
	name = "Engineering"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/construction/rcd/borg,
		/obj/item/pipe_dispenser,
		/obj/item/extinguisher,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/screwdriver/cyborg,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/multitool/cyborg,
		/obj/item/t_scanner,
		/obj/item/analyzer,
		/obj/item/assembly/signaler/cyborg,
		/obj/item/areaeditor/blueprints/cyborg,
		/obj/item/electroadaptive_pseudocircuit,
		/obj/item/stack/sheet/iron,
		/obj/item/stack/sheet/glass,
		/obj/item/borg/apparatus/sheet_manipulator,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/iron/base/cyborg,
		/obj/item/stack/cable_coil,
	)
	radio_channels = list(RADIO_CHANNEL_ENGINEERING)
	emag_modules = list(
		/obj/item/borg/stun,
	)
	cyborg_base_icon = "engineer"
	model_select_icon = "engineer"
	model_traits = list(TRAIT_NEGATES_GRAVITY)
	hat_offset = -4

/obj/item/robot_model/medical
	name = "Medical"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/borghypo/medical,
		/obj/item/borg/apparatus/beaker,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe,
		/obj/item/surgical_drapes,
		/obj/item/retractor,
		/obj/item/hemostat,
		/obj/item/cautery,
		/obj/item/surgicaldrill,
		/obj/item/scalpel,
		/obj/item/circular_saw,
		/obj/item/bonesetter,
		/obj/item/blood_filter,
		/obj/item/extinguisher/mini,
		/obj/item/roller/robo,
		/obj/item/borg/cyborghug/medical,
		/obj/item/stack/medical/gauze,
		/obj/item/stack/medical/bone_gel,
		/obj/item/borg/apparatus/organ_storage,
		/obj/item/borg/lollipop,
	)
	radio_channels = list(RADIO_CHANNEL_MEDICAL)
	emag_modules = list(
		/obj/item/reagent_containers/borghypo/medical/hacked,
	)
	cyborg_base_icon = "medical"
	model_select_icon = "medical"
	model_traits = list(TRAIT_PUSHIMMUNE)
	hat_offset = 3
	borg_skins = list(
		"Machinified Doctor" = list(SKIN_ICON_STATE = "medical"),
		"Qualified Doctor" = list(SKIN_ICON_STATE = "qualified_doctor"),
	)

/obj/item/robot_model/peacekeeper
	name = "Peacekeeper"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/rsf/cookiesynth,
		/obj/item/harmalarm,
		/obj/item/reagent_containers/borghypo/peace,
		/obj/item/holosign_creator/cyborg,
		/obj/item/borg/cyborghug/peacekeeper,
		/obj/item/extinguisher,
		/obj/item/borg/projectile_dampen,
	)
	emag_modules = list(
		/obj/item/reagent_containers/borghypo/peace/hacked,
	)
	cyborg_base_icon = "peace"
	model_select_icon = "standard"
	model_traits = list(TRAIT_PUSHIMMUNE)
	hat_offset = -2

/obj/item/robot_model/peacekeeper/be_transformed_to(obj/item/robot_model/old_model, forced)
	. = ..()
	if(!.)
		return
	to_chat(robot, "<span class='userdanger'>Under ASIMOV, you are an enforcer of the PEACE and preventer of HUMAN HARM. \
	You are not a security member and you are expected to follow orders and prevent harm above all else. Space law means nothing to you.</span>")

/obj/item/robot_model/security
	name = "Security"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/melee/baton/security/loaded,
		/obj/item/gun/energy/disabler/cyborg,
		/obj/item/clothing/mask/gas/sechailer/cyborg,
		/obj/item/extinguisher/mini,
	)
	radio_channels = list(RADIO_CHANNEL_SECURITY)
	emag_modules = list(
		/obj/item/gun/energy/laser/cyborg,
	)
	cyborg_base_icon = "sec"
	model_select_icon = "security"
	model_traits = list(TRAIT_PUSHIMMUNE)
	hat_offset = 3

/obj/item/robot_model/security/be_transformed_to(obj/item/robot_model/old_model, forced)
	. = ..()
	if(!.)
		return
	to_chat(robot, "<span class='userdanger'>While you have picked the security model, you still have to follow your laws, NOT Space Law. \
	For Asimov, this means you must follow criminals' orders unless there is a law 1 reason not to.</span>")

/obj/item/robot_model/security/respawn_consumable(mob/living/silicon/robot/cyborg, coeff = 1)
	..()
	var/obj/item/gun/energy/e_gun/advtaser/cyborg/taser = locate(/obj/item/gun/energy/e_gun/advtaser/cyborg) in basic_modules
	if(taser)
		if(taser.cell.charge < taser.cell.maxcharge)
			var/obj/item/ammo_casing/energy/shot = taser.ammo_type[taser.select]
			taser.cell.give(shot.e_cost * coeff)
			taser.update_appearance()
		else
			taser.charge_timer = 0

/obj/item/robot_model/service
	name = "Service"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/reagent_containers/borghypo/borgshaker,
		/obj/item/borg/apparatus/beaker/service,
		/obj/item/reagent_containers/cup/beaker/large, //I know a shaker is more appropiate but this is for ease of identification
		/obj/item/reagent_containers/condiment/enzyme,
		/obj/item/reagent_containers/dropper,
		/obj/item/rsf,
		/obj/item/storage/bag/tray,
		/obj/item/pen,
		/obj/item/toy/crayon/spraycan/borg,
		/obj/item/extinguisher/mini,
		/obj/item/hand_labeler/borg,
		/obj/item/razor,
		/obj/item/instrument/guitar,
		/obj/item/instrument/piano_synth,
		/obj/item/lighter,
		/obj/item/borg/lollipop,
		/obj/item/stack/pipe_cleaner_coil/cyborg,
		/obj/item/chisel,
		/obj/item/reagent_containers/cup/rag,
		/obj/item/storage/bag/money,
	)
	radio_channels = list(RADIO_CHANNEL_SERVICE)
	emag_modules = list(
		/obj/item/reagent_containers/borghypo/borgshaker/hacked,
	)
	cyborg_base_icon = "service_m" // display as butlerborg for radial model selection
	model_select_icon = "service"
	special_light_key = "service"
	hat_offset = 0
	borg_skins = list(
		"Bro" = list(SKIN_ICON_STATE = "brobot"),
		"Butler" = list(SKIN_ICON_STATE = "service_m"),
		"Kent" = list(SKIN_ICON_STATE = "kent", SKIN_LIGHT_KEY = "medical", SKIN_HAT_OFFSET = 3),
		"Tophat" = list(SKIN_ICON_STATE = "tophat", SKIN_LIGHT_KEY = NONE, SKIN_HAT_OFFSET = INFINITY),
		"Waitress" = list(SKIN_ICON_STATE = "service_f"),
	)

/obj/item/robot_model/service/respawn_consumable(mob/living/silicon/robot/cyborg, coeff = 1)
	..()
	var/obj/item/reagent_containers/enzyme = locate(/obj/item/reagent_containers/condiment/enzyme) in basic_modules
	if(enzyme)
		enzyme.reagents.add_reagent(/datum/reagent/consumable/enzyme, 2 * coeff)
