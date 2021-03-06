//Random assistant outfits, for fun.

/datum/outfit/job/assistant/barber
	name = "Assistant (Barber)"
	id_trim = /datum/id_trim/job/assistant/barber
	uniform = /obj/item/clothing/under/suit/sl
	belt = /obj/item/clothing/suit/toggle/suspenders/gray
	shoes = /obj/item/clothing/shoes/laceup
	l_pocket = /obj/item/pda
	r_pocket = /obj/item/razor

/datum/id_trim/job/assistant/barber
	assignment = "Barber"

/datum/outfit/job/assistant/waiter
	name = "Assistant (Waiter)"
	id_trim = /datum/id_trim/job/assistant/barber
	uniform = /obj/item/clothing/under/suit/black
	accessory = /obj/item/clothing/accessory/waistcoat
	shoes = /obj/item/clothing/shoes/laceup

/datum/id_trim/job/assistant/waiter
	assignment = "Waiter"
	full_access = list(ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_KITCHEN)
