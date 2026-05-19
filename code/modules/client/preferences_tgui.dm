/client/verb/open_character_prefs_new()
	set name = "Character Preferences (New)"
	set category = "OOC"
	prefs.ui_interact(usr)

// add assets here to use them in the front end
/datum/preferences/proc/get_preferences_assets(mob/user)
	var/static/list/asset_files = list(
		"headshot_background.png" = file("icons/tgui/headshot_background.png"),
	)
	var/list/urls = list()
	for(var/asset_name in asset_files)
		if(!SSassets.cache[asset_name])
			SSassets.transport.register_asset(asset_name, asset_files[asset_name])
		SSassets.transport.send_assets(user, asset_name)
		urls[asset_name] = SSassets.transport.get_asset_url(asset_name)
	return urls

/datum/preferences/proc/generate_sprite_preview(mob/user)
	var/dummy_key = "pref_preview_[REF(src)]"
	var/mob/living/carbon/human/dummy/body = generate_or_wait_for_human_dummy(dummy_key)

	copy_to(body, icon_updates = TRUE, roundstart_checks = FALSE, character_setup = TRUE)

	if(length(gear_list))
		for(var/item_name in gear_list)
			var/datum/loadout_item/LI = GLOB.loadout_items_by_name[item_name]
			if(!LI || !LI.path)
				continue
			var/obj/item/I = new LI.path(body)
			if(I)
				body.equip_to_appropriate_slot(I)
	else if(topjob)
		var/datum/job/J = SSjob.GetJob(topjob)
		if(J)
			J.equip(body, TRUE, FALSE)

	body.setDir(SOUTH)
	body.update_inv_hands(TRUE)
	body.update_inv_belt(TRUE)
	body.update_inv_back(TRUE)
	body.update_inv_head(TRUE)

	var/icon/flat = getFlatIcon(body)
	unset_busy_human_dummy(dummy_key)

	if(!flat)
		return null

	var/asset_name = "char_sprite_[REF(src)].png"
	SSassets.transport.unregister_asset(asset_name)
	SSassets.transport.register_asset(asset_name, flat)
	SSassets.transport.send_assets(user, asset_name)
	return SSassets.transport.get_asset_url(asset_name)

/proc/get_tgui_themes()
	var/static/list/themes = list(
		"azure_default" = "Ascendant",
		"azure_ascendant" = "New Ascendant",
		"azure_green" = "Oaken",
		"azure_lane" = "Noccite",
		"azure_purple" = "Raneshen",
		"azure_gilbranze" = "Gilbranze",
		"azure_psydonic" = "Psydonic",
		"azure_lingyue" = "Lingyue",
		"trey_liam" = "Trey Liam"
	)
	return themes

// Get the display name of the current TGUI theme
/datum/preferences/proc/get_tgui_theme_display_name()
	var/list/themes = get_tgui_themes()
	return themes[tgui_theme] || tgui_theme

// Open the theme picker with live preview
/datum/preferences/proc/setTguiStyle(mob/user)
	var/datum/theme_picker/picker = new(user)
	picker.ui_interact(user)

/datum/preferences/ui_state(mob/user)
	return GLOB.always_state

/datum/preferences/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PreferencesMenu", "Character Preferences", 900, 700)
		ui.autoupdate = FALSE
		ui.open()

/datum/preferences/ui_data(mob/user)
	var/list/assets = get_preferences_assets(user)
	var/body_type
	if(gender == MALE)
		body_type = "Masculine"
	else
		body_type = "Feminine"

	var/list/voice_pack_keys = list()
	for(var/key in GLOB.voice_packs_list)
		voice_pack_keys += key

	var/lang_display = "None"
	if(ispath(extra_language, /datum/language))
		var/datum/language/lang_ref = extra_language
		lang_display = initial(lang_ref.name)

	var/list/charflaws_data = list()
	for(var/i = 1 to length(charflaws))
		var/datum/charflaw/cf = charflaws[i]
		if(!cf)
			continue
		charflaws_data += list(list("name" = "[cf]", "index" = i))
	var/has_averse = FALSE
	for(var/datum/charflaw/cf in charflaws)
		if(istype(cf, /datum/charflaw/averse))
			has_averse = TRUE
			break
	var/combat_music_name = "Default"
	if(combat_music)
		combat_music_name = combat_music.shortname ? combat_music.shortname : combat_music.name

	var/examine_theme_display = "None (Use Viewer's)"
	if(examine_theme)
		var/list/et_theme_list = get_tgui_themes()
		examine_theme_display = et_theme_list[examine_theme] || examine_theme
	var/has_skin_tones = pref_species.use_skintones
	var/has_mutant_colors = (MUTCOLORS in pref_species.species_traits) || (MUTCOLORS_PARTSONLY in pref_species.species_traits)

	var/list/special_roles_data = list()
	for(var/role in GLOB.special_roles_rogue)
		special_roles_data += list(list("name" = role, "enabled" = (role in be_special)))

	return list(
		"character_sprite" = generate_sprite_preview(user),
		"real_name" = html_decode(real_name),
		"nickname" = html_decode(nickname),
		"pronouns" = pronouns,
		"pronouns_options" = GLOB.pronouns_list.Copy(),
		"titles_pref" = titles_pref,
		"titles_options" = list(TITLES_M, TITLES_F),
		"clothes_pref" = clothes_pref,
		"clothes_options" = list(CLOTHES_M, CLOTHES_F),
		"voice_type" = voice_type,
		"voice_type_options" = GLOB.voice_types_list.Copy(),
		"voice_pack" = voice_pack,
		"voice_pack_options" = voice_pack_keys,
		"body_type" = body_type,
		"body_type_options" = list("Masculine", "Feminine"),
		"age" = age,
		"age_options" = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD),
		"species" = pref_species ? pref_species.base_name : "Unknown",
		"subspecies" = pref_species ? pref_species.sub_name : "None",
		"statpack" = statpack ? statpack.name : "None",
		"statpack_virtuous" = (statpack?.virtuous ? TRUE : FALSE),
		"origin" = (virtue_origin && !istype(virtue_origin, /datum/virtue/none)) ? "[virtue_origin]" : "None",
		"virtue" = virtue ? "[virtue]" : "None",
		"virtuetwo" = virtuetwo ? "[virtuetwo]" : "None",
		"charflaw" = length(charflaws) ? charflaws.Join(", ") : "None",
		"faith" = (selected_patron?.associated_faith && GLOB.faithlist[selected_patron.associated_faith]) ? GLOB.faithlist[selected_patron.associated_faith] : "None",
		"patron" = selected_patron ? selected_patron.name : "None",
		"domhand" = domhand,
		"flavortext" = html_decode(flavortext || ""),
		"headshot_link" = headshot_link || assets["headshot_background.png"],
		"ooc_notes" = html_decode(ooc_notes || ""),
		"voice_color" = sanitize_hexcolor(voice_color, 6, 1),
		"voice_pitch" = voice_pitch,
		"highlight_color" = sanitize_hexcolor(highlight_color, 6, 1),
		"extra_language" = lang_display,
		"race_bonus" = race_bonus || "None",
		"song_artist" = html_decode(song_artist || ""),
		"song_title" = html_decode(song_title || ""),
		"ooc_extra" = ooc_extra || "",
		"charflaws_list" = charflaws_data,
		"max_vices" = MAX_VICES,
		"has_averse" = has_averse,
		"averse_faction" = averse_chosen_faction || "Inquisition",
		"combat_music" = combat_music_name,
		"dnr_pref" = dnr_pref,
		// Body column
		"body_size" = round(features["body_size"] * 100),
		"has_skin_tones" = has_skin_tones,
		"skin_tone" = skin_tone || "Unknown",
		"examine_theme" = examine_theme_display,
		"update_mutant_colors" = update_mutant_colors,
		"has_mutant_colors" = has_mutant_colors,
		"mutant_color1" = sanitize_hexcolor(features["mcolor"] || "000000", 6, 1),
		"mutant_color2" = sanitize_hexcolor(features["mcolor2"] || "000000", 6, 1),
		"mutant_color3" = sanitize_hexcolor(features["mcolor3"] || "000000", 6, 1),
		// Game settings
		"tgui_theme" = get_tgui_theme_display_name(),
		"ambientocclusion" = ambientocclusion,
		"windowflashing" = windowflashing,
		"clientfps" = clientfps,
		"special_roles" = special_roles_data,
	)

/datum/preferences/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	switch(action)
		if("set_name")
			real_name = sanitize(params["value"])
			. = TRUE
		if("set_nickname")
			nickname = sanitize(params["value"])
			. = TRUE
		if("randomize_name")
			real_name = pref_species.random_name(gender, TRUE)
			. = TRUE
		if("set_pronouns")
			if(!(params["value"] in GLOB.pronouns_list))
				return
			pronouns = params["value"]
			. = TRUE
		if("set_titles")
			if(!(params["value"] in list(TITLES_M, TITLES_F)))
				return
			titles_pref = params["value"]
			. = TRUE
		if("set_clothes")
			if(!(params["value"] in list(CLOTHES_M, CLOTHES_F)))
				return
			clothes_pref = params["value"]
			. = TRUE
		if("set_voice_type")
			if(!(params["value"] in GLOB.voice_types_list))
				return
			voice_type = params["value"]
			. = TRUE
		if("set_voice_pack")
			if(!(params["value"] in GLOB.voice_packs_list))
				return
			voice_pack = params["value"]
			. = TRUE
		if("set_body_type")
			switch(params["value"])
				if("Masculine")
					gender = MALE
				else
					gender = FEMALE
			. = TRUE
		if("set_age")
			if(!(params["value"] in list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD)))
				return
			age = params["value"]
			. = TRUE
		if("set_domhand")
			domhand = (text2num(params["value"]) == 1) ? 1 : 2
			. = TRUE
		if("set_flavortext")
			flavortext = sanitize(params["value"])
			. = TRUE
		if("set_species")
			var/list/species = list()
			for(var/A in GLOB.roundstart_races)
				var/datum/species/race = GLOB.species_list[A]
				race = new race()
				if(!ui.user.client)
					continue
				if(race.patreon_req > ui.user.client.patreonlevel())
					continue
				if(race.is_subrace)
					continue
				if(race.base_name == pref_species.base_name)
					continue
				species[race.base_name] = race
			species = sortList(species)
			var/result = tgui_input_list(ui.user, "By what shape are you bound?", "RACE", species)
			if(result)
				set_new_race(species[result], ui.user)
				. = TRUE
		if("set_subspecies")
			var/list/species = list()
			for(var/A in GLOB.roundstart_races)
				var/datum/species/race = GLOB.species_list[A]
				race = new race()
				if(!ui.user.client)
					continue
				if(race.base_name != pref_species.base_name)
					continue
				if(race.sub_name == pref_species.sub_name)
					continue
				species[race.sub_name] = race
			var/result = tgui_input_list(ui.user, "By what shape are you bound?", "SUBRACE", species)
			if(result)
				set_new_race(species[result], ui.user)
				. = TRUE
		if("set_statpack")
			var/list/statpacks_available = list()
			var/list/statpack_descriptions = list()
			for(var/path as anything in GLOB.statpacks)
				var/datum/statpack/sp = GLOB.statpacks[path]
				if(!sp.name)
					continue
				if(length(sp.stat_array))
					statpack_descriptions[sp.name] = sp.generate_modifier_string()
				statpacks_available[sp.name] = sp
			statpacks_available = sort_list(statpacks_available)
			var/result = tgui_input_list(ui.user, "How shall your strengths manifest?", "STATPACK", statpacks_available, statpack, descriptions = statpack_descriptions)
			if(result)
				statpack = statpacks_available[result]
				. = TRUE
		if("set_origin")
			var/list/origin_choices = list()
			for(var/path as anything in GLOB.virtues)
				var/datum/virtue/V = GLOB.virtues[path]
				if(!V.name || V.name == virtue_origin.name)
					continue
				if(!istype(V, /datum/virtue/origin))
					continue
				if(V.restricted && (pref_species.type in V.races))
					continue
				if(istype(V, /datum/virtue/origin/racial) && !(pref_species.type in V.races))
					continue
				origin_choices[V.name] = V
			var/result = tgui_input_list(ui.user, "From where do you come?", "ORIGINS", origin_choices)
			if(result)
				virtue_origin = origin_choices[result]
				. = TRUE
		if("set_virtue")
			var/list/virtue_choices = list()
			for(var/path as anything in GLOB.virtues)
				var/datum/virtue/V = GLOB.virtues[path]
				if(!V.name)
					continue
				if((V.name == virtue.name || V.name == virtuetwo.name) && !istype(V, /datum/virtue/none) && !V.stackable)
					continue
				if(istype(V, /datum/virtue/origin) || V.unlisted)
					continue
				if(istype(V, /datum/virtue/heretic) && !istype(selected_patron, /datum/patron/inhumen))
					continue
				if(V.restricted && (pref_species.type in V.races))
					continue
				if(V.virtuous_only && !statpack.virtuous)
					continue
				virtue_choices[V.name] = V
			virtue_choices = sort_list(virtue_choices)
			var/result = tgui_input_list(ui.user, "What strength shall you wield?", "VIRTUES", virtue_choices)
			if(result)
				var/datum/virtue/chosen = virtue_choices[result]
				virtue = new chosen.type
				. = TRUE
		if("set_virtuetwo")
			var/list/virtue_choices = list()
			for(var/path as anything in GLOB.virtues)
				var/datum/virtue/V = GLOB.virtues[path]
				if(!V.name)
					continue
				if((V.name == virtue.name || V.name == virtuetwo.name) && !istype(V, /datum/virtue/none) && !V.stackable)
					continue
				if(istype(V, /datum/virtue/origin) || V.unlisted)
					continue
				if(istype(V, /datum/virtue/heretic) && !istype(selected_patron, /datum/patron/inhumen))
					continue
				if(V.restricted && (pref_species.type in V.races))
					continue
				virtue_choices[V.name] = V
			virtue_choices = sort_list(virtue_choices)
			var/result = tgui_input_list(ui.user, "What strength shall you wield?", "VIRTUES", virtue_choices)
			if(result)
				var/datum/virtue/chosen_two = virtue_choices[result]
				virtuetwo = new chosen_two.type
				. = TRUE
		if("set_charflaw")
			for(var/datum/charflaw/_existing in charflaws)
				if(istype(_existing, /datum/charflaw/noflaw))
					charflaws.Remove(_existing)
					break
			if(length(charflaws) >= MAX_VICES)
				to_chat(ui.user, "I can't be any more flawed.")
				return
			var/list/char_flaws = GLOB.character_flaws.Copy()
			for(var/key in char_flaws)
				if(char_flaws[key] == /datum/charflaw/noflaw)
					char_flaws.Remove(key)
				else
					var/cf_type = char_flaws[key]
					var/datum/charflaw/character_flaw = new cf_type()
					if(length(character_flaw.restricted_species) && (pref_species.type in character_flaw.restricted_species))
						char_flaws.Remove(key)
			for(var/datum/charflaw/character_flaw in charflaws)
				for(var/key in char_flaws)
					if(char_flaws[key] == character_flaw.type && !istype(character_flaw, /datum/charflaw/randflaw))
						char_flaws.Remove(key)
						break
			var/result = tgui_input_list(ui.user, "What burden will you bear?", "VICES", char_flaws)
			if(result)
				var/cf_type = char_flaws[result]
				var/datum/charflaw/character_flaw = new cf_type()
				charflaws.Add(character_flaw)
				. = TRUE
		if("set_faith")
			var/list/faiths_named = list()
			for(var/path as anything in GLOB.preference_faiths)
				var/datum/faith/faith = GLOB.faithlist[path]
				if(!faith.name)
					continue
				faiths_named[faith.name] = faith
			var/result = tgui_input_list(ui.user, "The world rots. Which truth you bear?", "FAITH", faiths_named)
			if(result)
				var/datum/faith/chosen_faith = faiths_named[result]
				selected_patron = GLOB.patronlist[chosen_faith.godhead] || GLOB.patronlist[pick(GLOB.patrons_by_faith[result])]
				. = TRUE
		if("set_patron")
			var/list/patrons_named = list()
			for(var/path as anything in GLOB.patrons_by_faith[selected_patron?.associated_faith || initial(default_patron.associated_faith)])
				var/datum/patron/patron = GLOB.patronlist[path]
				if(!patron.name)
					continue
				patrons_named[patron.name] = patron
			var/result = tgui_input_list(ui.user, "The first amongst many.", "PATRON", patrons_named)
			if(result)
				selected_patron = patrons_named[result]
				. = TRUE
		if("set_ooc_notes")
			var/new_notes = params["value"]
			if(new_notes == "")
				ooc_notes = null
				ooc_notes_cached = null
			else
				ooc_notes = new_notes
				ooc_notes_cached = parsemarkdown_basic(html_encode(ooc_notes), hyperlink = TRUE)
			. = TRUE
		if("set_voice_color")
			var/new_voice = input(ui.user, "Choose your character's voice color:", "Voice Color", "#[voice_color]") as color|null
			if(new_voice)
				if(color_hex2num(new_voice) >= 230)
					voice_color = sanitize_hexcolor(new_voice)
					. = TRUE
				else
					to_chat(ui.user, "<font color='red'>This voice color is too dark for mortals.</font>")
		if("set_voice_pitch")
			var/new_pitch = tgui_input_number(ui.user, "Choose your voice pitch ([MIN_VOICE_PITCH] to [MAX_VOICE_PITCH], lower is deeper):", "Voice Pitch", voice_pitch, MAX_VOICE_PITCH, MIN_VOICE_PITCH, round_value = FALSE)
			if(new_pitch)
				if(new_pitch >= MIN_VOICE_PITCH && new_pitch <= MAX_VOICE_PITCH)
					voice_pitch = new_pitch
					. = TRUE
				else
					to_chat(ui.user, "<font color='red'>Value must be between [MIN_VOICE_PITCH] and [MAX_VOICE_PITCH].</font>")
		if("set_voice_pitch_direct")
			var/new_pitch = params["value"]
			new_pitch = text2num(new_pitch)
			if(new_pitch >= MIN_VOICE_PITCH && new_pitch <= MAX_VOICE_PITCH)
				voice_pitch = new_pitch
				. = TRUE
		if("set_highlight_color")
			var/new_color = input(ui.user, "Choose your nickname highlight color:", "Nickname Color", highlight_color) as color|null
			if(new_color)
				highlight_color = sanitize_hexcolor(new_color)
				. = TRUE
		if("set_extra_language")
			var/static/list/selectable_languages = list(
				/datum/language/elvish,
				/datum/language/dwarvish,
				/datum/language/orcish,
				/datum/language/hellspeak,
				/datum/language/draconic,
				/datum/language/celestial,
				/datum/language/raneshi,
				/datum/language/grenzelhoftian,
				/datum/language/kazengunese,
				/datum/language/lingyuese,
				/datum/language/etruscan,
				/datum/language/gronnic,
				/datum/language/otavan,
				/datum/language/aavnic,
			)
			var/list/lang_choices = list("None")
			for(var/language in selectable_languages)
				if(language in pref_species.languages)
					continue
				var/datum/language/a_language = new language()
				lang_choices[a_language.name] = language
			var/result = tgui_input_list(ui.user, "Choose your free language:", "FREE LANGUAGE", lang_choices)
			if(result)
				if(result == "None")
					extra_language = "None"
				else
					extra_language = lang_choices[result]
				. = TRUE
		if("set_race_bonus")
			if(length(pref_species.custom_selection))
				var/result = tgui_input_list(ui.user, "What has fate blessed your race with?", "BONUS", pref_species.custom_selection)
				if(result)
					race_bonus = result
					. = TRUE
		if("set_song_url")
			to_chat(ui.user, span_notice("Add a direct link to an mp3 from a suitable host (catbox, etc) to embed in your flavor text."))
			to_chat(ui.user, "<font color='red'>Abuse of this will get you banned.</font>")
			var/new_url = tgui_input_text(ui.user, "Input song URL (https, hosts: discord, catbox):", "Song URL", ooc_extra, encode = FALSE)
			if(new_url != null)
				if(new_url == "")
					ooc_extra = null
					. = TRUE
				else
					var/static/list/valid_ext = list("mp3")
					if(valid_headshot_link(ui.user, new_url, FALSE, valid_ext))
						ooc_extra = new_url
						log_game("[ui.user] has set their Song URL to '[ooc_extra]'.")
						. = TRUE
		if("set_song_artist")
			song_artist = sanitize(params["value"])
			. = TRUE
		if("set_song_title")
			song_title = sanitize(params["value"])
			. = TRUE
		if("remove_charflaw")
			var/rem_index = text2num(params["index"])
			if(rem_index >= 1 && rem_index <= length(charflaws))
				charflaws.Remove(charflaws[rem_index])
				. = TRUE
		if("set_averse_faction")
			var/choice = tgui_input_list(ui.user, "Who do you loathe?", "AVERSION", GLOB.averse_factions)
			if(choice)
				averse_chosen_faction = choice
				. = TRUE
		if("set_combat_music")
			var/track_select = tgui_input_list(ui.user, "To you, the Signal sounds like:", "COMBAT MUSIC", GLOB.cmode_tracks_by_name, combat_music?.name)
			if(track_select)
				combat_music = GLOB.cmode_tracks_by_name[track_select]
				. = TRUE
		if("toggle_dnr")
			dnr_pref = !dnr_pref
			. = TRUE
		if("open_familiar_prefs")
			familiar_prefs.fam_show_ui()
		if("set_headshot")
			to_chat(ui.user, span_notice("Please use a SFW head and shoulder image. Direct image links only."))
			var/new_link = tgui_input_text(ui.user, "Input headshot link (https, hosts: gyazo, discord, lensdump, imgbox, catbox):", "Headshot", headshot_link, encode = FALSE)
			if(new_link != null)
				if(new_link == "")
					headshot_link = null
					. = TRUE
				else if(valid_headshot_link(ui.user, new_link))
					headshot_link = new_link
					log_game("[ui.user] has set their Headshot to '[headshot_link]'.")
					. = TRUE
		if("set_body_size")
			var/new_size = tgui_input_number(ui.user, "Choose your sprite size ([BODY_SIZE_MIN*100]%-[BODY_SIZE_MAX*100]%):", "Sprite Scale", features["body_size"]*100, BODY_SIZE_MAX*100, BODY_SIZE_MIN*100)
			if(new_size)
				features["body_size"] = clamp(new_size * 0.01, BODY_SIZE_MIN, BODY_SIZE_MAX)
				. = TRUE
		if("set_skin_tone")
			var/list/tone_list = pref_species.get_skin_list()
			if(istype(virtue, /datum/virtue/combat/rotcured) || istype(virtuetwo, /datum/virtue/combat/rotcured))
				tone_list["Rotten"] = SKIN_COLOR_ROT
			var/picked_tone = tgui_input_list(ui.user, "Choose your character's skin tone:", "SKINTONE", tone_list)
			if(picked_tone)
				skin_tone = tone_list[picked_tone]
				features["mcolor"] = sanitize_hexcolor(skin_tone)
				try_update_mutant_colors()
				. = TRUE
		if("set_examine_theme")
			var/list/et_themes = get_tgui_themes()
			var/list/et_choices = list("None (Use Viewer's)")
			for(var/theme_key in et_themes)
				if(theme_key == "trey_liam")
					continue
				et_choices += et_themes[theme_key]
			var/et_current = examine_theme ? (et_themes[examine_theme] || examine_theme) : "None (Use Viewer's)"
			var/et_picked = tgui_input_list(ui.user, "Choose your examine theme:", "EXAMINE THEME", et_choices, et_current)
			if(et_picked != null)
				if(et_picked == "None (Use Viewer's)")
					examine_theme = null
				else
					for(var/theme_key in et_themes)
						if(et_themes[theme_key] == et_picked)
							examine_theme = theme_key
							break
				. = TRUE
		if("toggle_update_mutant_colors")
			update_mutant_colors = !update_mutant_colors
			. = TRUE
		if("set_mutant_color1")
			var/new_col1 = input(ui.user, "Choose mutant color #1:", "Mutant Color", "#" + features["mcolor"]) as color|null
			if(new_col1)
				features["mcolor"] = sanitize_hexcolor(new_col1)
				try_update_mutant_colors()
				. = TRUE
		if("set_mutant_color2")
			var/new_col2 = input(ui.user, "Choose mutant color #2:", "Mutant Color", "#" + features["mcolor2"]) as color|null
			if(new_col2)
				features["mcolor2"] = sanitize_hexcolor(new_col2)
				try_update_mutant_colors()
				. = TRUE
		if("set_mutant_color3")
			var/new_col3 = input(ui.user, "Choose mutant color #3:", "Mutant Color", "#" + features["mcolor3"]) as color|null
			if(new_col3)
				features["mcolor3"] = sanitize_hexcolor(new_col3)
				try_update_mutant_colors()
				. = TRUE
		if("open_features")
			ShowCustomizers(ui.user)
		if("open_markings")
			ShowMarkings(ui.user)
		if("open_descriptors")
			show_descriptors_ui(ui.user)
		if("set_tgui_theme")
			setTguiStyle(ui.user)
		if("toggle_ambientocclusion")
			ambientocclusion = !ambientocclusion
			. = TRUE
		if("toggle_windowflashing")
			windowflashing = !windowflashing
			. = TRUE
		if("set_fps")
			var/new_fps = tgui_input_number(ui.user, "Choose your FPS (0 to sync with server, 75 recommended):", "FPS", clientfps, 244, 0)
			if(new_fps != null)
				clientfps = clamp(new_fps, 0, 100)
				. = TRUE
		if("toggle_special_role")
			var/role_name = params["role"]
			if(role_name in GLOB.special_roles_rogue)
				if(role_name in be_special)
					be_special -= role_name
				else
					be_special += role_name
				. = TRUE
	if(.)
		save_character()
		SStgui.update_uis(src)
