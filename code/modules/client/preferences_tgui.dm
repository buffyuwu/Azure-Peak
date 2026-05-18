/client/verb/open_character_prefs_new()
	set name = "Character Preferences (New)"
	set category = "OOC"
	prefs.ui_interact(usr)

// add assets here to use them in the front end
/proc/get_preferences_assets(mob/user)
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

	return list(
		"real_name" = real_name,
		"nickname" = nickname,
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
		"flavortext" = flavortext || "",
		"headshot_link" = headshot_link || assets["headshot_background.png"],
		"ooc_notes" = ooc_notes || "",
		"voice_color" = sanitize_hexcolor(voice_color, 6, 1),
		"voice_pitch" = voice_pitch,
		"highlight_color" = sanitize_hexcolor(highlight_color, 6, 1),
		"extra_language" = lang_display,
		"race_bonus" = race_bonus || "None",
		"song_artist" = song_artist || "",
		"song_title" = song_title || "",
		"ooc_extra" = ooc_extra || "",
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
	if(.)
		save_character()
		SStgui.update_uis(src)
