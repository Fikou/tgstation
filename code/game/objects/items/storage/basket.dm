/obj/item/storage/basket
	name = "basket"
	desc = "Handwoven basket."
	icon_state = "basket"
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = FLAMMABLE

/obj/item/storage/basket/ComponentInitialize()
	. = ..()
	storage.max_w_class = WEIGHT_CLASS_NORMAL
	storage.max_combined_w_class = 21
