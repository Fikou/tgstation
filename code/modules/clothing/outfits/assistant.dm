//Random assistant outfits, for fun.

/datum/outfit/job/assistant/barber
	name = "Assistant (Barber)"
	id_trim = /datum/id_trim/job/assistant/barber
	uniform = /obj/item/clothing/under/suit/sl
	suit = /obj/item/clothing/suit/toggle/suspenders/black
	shoes = /obj/item/clothing/shoes/laceup
	l_pocket = /obj/item/razor
	r_pocket = /obj/item/barber_spray
	backpack_contents = list(/obj/item/reagent_containers/glass/bottle/barbers_aid = 1, /obj/item/reagent_containers/glass/bottle/baldium = 1)

/datum/id_trim/job/assistant/barber
	assignment = "Barber"

/datum/outfit/job/assistant/waiter
	name = "Assistant (Waiter)"
	id_trim = /datum/id_trim/job/assistant/waiter
	uniform = /obj/item/clothing/under/suit/waiter
	shoes = /obj/item/clothing/shoes/laceup
	belt = /obj/item/storage/bag/tray
	l_pocket = /obj/item/reagent_containers/food/condiment/saltshaker
	r_pocket = /obj/item/reagent_containers/food/condiment/peppermill
	backpack_contents = list(/obj/item/pda = 1)

/datum/id_trim/job/assistant/waiter
	assignment = "Waiter"
	full_access = list(ACCESS_BAR, ACCESS_KITCHEN)

/datum/outfit/job/assistant/mailman
	name = "Assistant (Mailman)"
	id_trim = /datum/id_trim/job/assistant/mailman
	head = /obj/item/clothing/head/mailman
	uniform = /obj/item/clothing/under/misc/mailman
	shoes = /obj/item/clothing/shoes/sneakers/brown
	belt = /obj/item/pda
	l_pocket = /obj/item/dest_tagger
	r_pocket = /obj/item/sales_tagger
	backpack_contents = list(/obj/item/paper_bin = 1, /obj/item/pen/fountain = 1, /obj/item/stack/package_wrap = 1, /obj/item/stack/wrapping_paper = 1)

/datum/id_trim/job/assistant/mailman
	assignment = "Mailman"
	full_access = list(ACCESS_MAILSORTING, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MAILSORTING)

/datum/outfit/job/assistant/gardener
	name = "Assistant (Gardener)"
	id_trim = /datum/id_trim/job/assistant/gardener
	uniform = /obj/item/clothing/under/misc/pj/blue
	suit = /obj/item/clothing/suit/apron/waders
	shoes = /obj/item/clothing/shoes/workboots
	belt = /obj/item/pda
	l_pocket = /obj/item/hatchet/wooden
	r_pocket = /obj/item/shovel/spade
	backpack_contents = list(/obj/item/cultivator/rake = 1, /obj/item/plant_analyzer = 1)

/datum/id_trim/job/assistant/gardener
	assignment = "Gardener"
	full_access = list(ACCESS_HYDROPONICS)

/datum/outfit/job/assistant/firefighter
	name = "Assistant (Firefighter)"
	id_trim = /datum/id_trim/job/assistant/firefighter
	head = /obj/item/clothing/head/hardhat/red/masked
	suit = /obj/item/clothing/suit/fire/foldable
	uniform = /obj/item/clothing/under/rank/engineering/engineer/hazard
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/crowbar/red
	r_pocket = /obj/item/reagent_containers/food/drinks/coffee
	skillchips = list(/obj/item/skillchip/quickercarry)
	backpack_contents = list(/obj/item/grenade/chem_grenade/smart_metal_foam = 1, /obj/item/stack/rods/twentyfive = 1, /obj/item/stack/tile/iron/loaded = 1, /obj/item/extinguisher = 1, /obj/item/stack/medical/ointment = 1)

/datum/id_trim/job/assistant/firefighter
	assignment = "Firefighter"

/datum/outfit/job/assistant/tourist
	name = "Assistant (Tourist)"
	id_trim = /datum/id_trim/job/assistant/tourist
	suit = /obj/item/clothing/suit/hawaiian
	uniform = /obj/item/clothing/under/pants/white
	shoes = /obj/item/clothing/shoes/sandal
	neck = /obj/item/camera

/datum/id_trim/job/assistant/tourist
	assignment = "Tourist"
	full_access = list()

/datum/outfit/job/assistant/influencer
	name = "Assistant (Influencer)"
	id_trim = /datum/id_trim/job/assistant/influencer
	uniform = /obj/item/clothing/under/costume/swagoutfit
	shoes = /obj/item/clothing/shoes/swagshoes
	r_pocket = /obj/item/droppod_beacon/camera
	l_pocket = /obj/item/instrument/piano_synth/headphones/spacepods

/datum/id_trim/job/assistant/influencer
	assignment = "Influencer"
	full_access = list()
