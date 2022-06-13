/datum/autowiki/modsuit
	page = "Template:Autowiki/Content/MODsuit"

/datum/autowiki/modsuit/generate()
	var/output = ""
	var/mob/living/carbon/human/human = new /mob/living/carbon/human/dummy/consistent()
	for(var/datum/mod_theme/mod as anything in typesof(/datum/mod_theme))
		var/filename = SANITIZE_FILENAME(escape_value(format_text(mod.name)))
		var/obj/item/mod/control/modsuit = new /obj/item/mod/control(null, mod.type, null, new /obj/item/mod/core/infinite())
		human.equip_to_slot_if_possible(modsuit, modsuit.slot_flags, qdel_on_fail = FALSE, disable_warning = TRUE)
		modsuit.quick_activation()
		output += include_template("Autowiki/MODsuitTheme", list(
			"icon" = escape_value(filename),
			"name" = escape_value(capitalize(format_text(mod.name))),
			"cell_drain" = mod.charge_drain,
			"complexity" = mod.complexity_max,
			"skins" = format_skin_list(mod.skins, mod.default_skin, human, modsuit),
			"modules" = format_module_list(mod.inbuilt_modules),
		))
		upload_icon(getFlatIcon(human, no_anim = TRUE), filename)
		qdel(modsuit)
	return output

/datum/autowiki/modsuit/proc/format_skin_list(list/skin_list, default_skin, mob/wearer, obj/item/mod/control/modsuit)
	var/output = ""
	for(var/skin in skin_list)
		if(skin == default_skin)
			continue
		for(var/obj/item/part as anything in modsuit.mod_parts)
			modsuit.seal_part(part, seal = FALSE)
		modsuit.finish_activation(on = FALSE)
		modsuit.set_mod_skin(skin)
		modsuit.quick_activation()
		var/filename = SANITIZE_FILENAME(escape_value(format_text(skin)))
		output += include_template("Autowiki/MODsuitThemeSkin", list(
			"name" = escape_value(capitalize(format_text(skin))),
			"icon" = escape_value(filename),
		))
		upload_icon(getFlatIcon(wearer, no_anim = TRUE), filename)
	return output

/datum/autowiki/modsuit/proc/format_module_list(list/module_list)
	var/output = ""
	for(var/obj/item/mod/module/module as anything in module_list)
		var/filename = SANITIZE_FILENAME(escape_value(format_text(module.name)))
		output += include_template("Autowiki/MODsuitThemeModule", list(
			"name" = escape_value(capitalize(format_text(module.name))),
			"icon" = escape_value(filename),
		))
		upload_icon(icon(module.icon, module.icon_state), filename)
	return output
