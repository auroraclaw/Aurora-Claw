//Stand-in until this is made more lore-friendly.
/datum/species/xenos
	name = "Xenomorph"
	name_plural = "Xenomorphs"

	default_language = "Xenomorph"
	language = "Hivemind"
	unarmed_types = list(/datum/unarmed_attack/claws/strong, /datum/unarmed_attack/bite/strong)
	hud_type = /datum/hud_data/alien
	rarity_value = 10

	has_fine_manipulation = 0
	siemens_coefficient = 0
	gluttonous = TRUE
	mouth_size = 15	// Should be larger than any human-type.
	allowed_eat_types = TYPE_ORGANIC | TYPE_SYNTHETIC | TYPE_HUMANOID
	mob_size = 14
	fall_mod = 0
	grab_mod = 4

	has_limbs = list(
		"chest" =  list("path" = /obj/item/organ/external/chest/unbreakable),
		"groin" =  list("path" = /obj/item/organ/external/groin/unbreakable),
		"head" =   list("path" = /obj/item/organ/external/head/unbreakable),
		"l_arm" =  list("path" = /obj/item/organ/external/arm/unbreakable),
		"r_arm" =  list("path" = /obj/item/organ/external/arm/right/unbreakable),
		"l_leg" =  list("path" = /obj/item/organ/external/leg/unbreakable),
		"r_leg" =  list("path" = /obj/item/organ/external/leg/right/unbreakable),
		"l_hand" = list("path" = /obj/item/organ/external/hand/unbreakable),
		"r_hand" = list("path" = /obj/item/organ/external/hand/right/unbreakable),
		"l_foot" = list("path" = /obj/item/organ/external/foot/unbreakable),
		"r_foot" = list("path" = /obj/item/organ/external/foot/right/unbreakable)
		)

	eyes = "blank_eyes"

	stamina = 175
	sprint_speed_factor = 2
	sprint_cost_factor = 0.80
	stamina_recovery = 5
	natural_climbing = 1
	climb_coeff = 0.1

	virus_immune = 1

	brute_mod = 0.25 // Hardened carapace.
	burn_mod = 1.75    // Weak to fire.

	warning_low_pressure = 50
	hazard_low_pressure = -1

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	flags =  NO_BREATHE | NO_SCAN | NO_PAIN | NO_SLIP | NO_POISON | NO_EMBED
	spawn_flags = IS_RESTRICTED

	reagent_tag = IS_XENOS

	blood_color = "#05EE05"
	flesh_color = "#282846"
	gibbed_anim = "gibbed-a"
	dusted_anim = "dust-a"
	death_message = "lets out a waning guttural screech, green blood bubbling from its maw."
	death_sound = 'sound/voice/hiss6.ogg'

	speech_sounds = list('sound/voice/hiss1.ogg','sound/voice/hiss2.ogg','sound/voice/hiss3.ogg','sound/voice/hiss4.ogg')
	speech_chance = 100

	breath_type = null
	poison_type = null

	vision_flags = DEFAULT_SIGHT | SEE_MOBS

	darksight = 8

	has_organ = list(
		"heart" =           /obj/item/organ/heart,
		"brain" =           /obj/item/organ/brain/xeno,
		"plasma vessel" =   /obj/item/organ/xenos/plasmavessel,
		"hive node" =       /obj/item/organ/xenos/hivenode,
		"nutrient channel" = /obj/item/organ/diona/nutrients
		)

	bump_flag = ALIEN
	swap_flags = ~HEAVY
	push_flags = (~HEAVY) ^ ROBOT

	move_trail = /obj/effect/decal/cleanable/blood/tracks/claw

	max_nutrition_factor = -1

	max_hydration_factor = -1

	var/alien_number = 0
	var/caste_name = "creature" // Used to update alien name.
	var/weeds_heal_rate = 1     // Health regen on weeds.
	var/weeds_plasma_rate = 5   // Plasma regen on weeds.

/datum/species/xenos/get_bodytype()
	return "Xenomorph"

/datum/species/xenos/get_random_name()
	return "alien [caste_name] ([alien_number])"

/datum/species/xenos/can_understand(var/mob/other)

	if(istype(other,/mob/living/carbon/alien/larva))
		return 1

	return 0

/datum/species/xenos/tap(var/mob/living/carbon/human/H,var/mob/living/target)
	H.visible_message("<span class='notice'>[H] caresses [target] with its scythe-like arm.</span>", \
					"<span class='notice'>You caress [target] with your scythe-like arm.</span>")

/datum/species/xenos/handle_post_spawn(var/mob/living/carbon/human/H)

	if(H.mind)
		H.mind.assigned_role = "Alien"
		H.mind.special_role = "Alien"

	alien_number++ //Keep track of how many aliens we've had so far.
	H.real_name = "alien [caste_name] ([alien_number])"
	H.name = H.real_name

	..()

/datum/species/xenos/handle_environment_special(var/mob/living/carbon/human/H)

	var/turf/T = H.loc
	if(!T) return
	var/datum/gas_mixture/environment = T.return_air()
	if(!environment) return

	if(environment.gas["phoron"] > 0 || locate(/obj/structure/alien/weeds) in T)
		if(!regenerate(H))
			var/obj/item/organ/xenos/plasmavessel/P = H.internal_organs_by_name["plasma vessel"]
			P.stored_plasma += weeds_plasma_rate
			P.stored_plasma = min(max(P.stored_plasma,0),P.max_plasma)
	..()

/datum/species/xenos/proc/regenerate(var/mob/living/carbon/human/H)
	var/heal_rate = weeds_heal_rate
	var/mend_prob = 10
	if (!H.resting)
		heal_rate = weeds_heal_rate / 3
		mend_prob = 1

	//first heal damages
	if (H.getBruteLoss() || H.getFireLoss() || H.getOxyLoss() || H.getToxLoss())
		H.adjustBruteLoss(-heal_rate)
		H.adjustFireLoss(-heal_rate)
		H.adjustOxyLoss(-heal_rate)
		H.adjustToxLoss(-heal_rate)
		if (prob(5))
			to_chat(H, "<span class='alium'>You feel a soothing sensation come over you...</span>")
		return 1

	//next internal organs
	for(var/obj/item/organ/I in H.internal_organs)
		if(I.damage > 0)
			I.damage = max(I.damage - heal_rate, 0)
			if (prob(5))
				to_chat(H, "<span class='alium'>You feel a soothing sensation within your [I.parent_organ]...</span>")
			return 1

	//next mend broken bones, approx 10 ticks each
	for(var/obj/item/organ/external/E in H.bad_external_organs)
		if (E.status & ORGAN_BROKEN)
			if (prob(mend_prob))
				if (E.mend_fracture())
					to_chat(H, "<span class='alium'>You feel something mend itself inside your [E.name].</span>")
			return 1

	return 0

/datum/species/xenos/drone
	name = "Xenomorph Drone"
	caste_name = "drone"
	weeds_plasma_rate = 15
	slowdown = 1
	tail = "xenos_drone_tail"
	rarity_value = 5

	icobase = 'icons/mob/human_races/xenos/r_xenos_drone.dmi'
	deform =  'icons/mob/human_races/xenos/r_xenos_drone.dmi'

	has_organ = list(
		"heart" =           /obj/item/organ/heart,
		"brain" =           /obj/item/organ/brain/xeno,
		"plasma vessel" =   /obj/item/organ/xenos/plasmavessel/queen,
		"acid gland" =      /obj/item/organ/xenos/acidgland,
		"hive node" =       /obj/item/organ/xenos/hivenode,
		"resin spinner" =   /obj/item/organ/xenos/resinspinner,
		"nutrient channel" = /obj/item/organ/diona/nutrients
		)

	inherent_verbs = list(
		/mob/living/proc/ventcrawl,
		/mob/living/proc/devour,
		/mob/living/carbon/human/proc/regurgitate,
		/mob/living/carbon/human/proc/plant,
		/mob/living/carbon/human/proc/transfer_plasma,
		/mob/living/carbon/human/proc/evolve,
		/mob/living/carbon/human/proc/resin,
		/mob/living/carbon/human/proc/corrosive_acid,
		/mob/living/carbon/human/proc/darkness_eyes
		)

/datum/species/xenos/drone/handle_post_spawn(var/mob/living/carbon/human/H)

	var/mob/living/carbon/human/A = H
	if(!istype(A))
		return ..()
	..()

/datum/species/xenos/hunter

	name = "Xenomorph Hunter"
	weeds_plasma_rate = 5
	caste_name = "hunter"
	slowdown = -2
	total_health = 150
	tail = "xenos_hunter_tail"

	icobase = 'icons/mob/human_races/xenos/r_xenos_hunter.dmi'
	deform =  'icons/mob/human_races/xenos/r_xenos_hunter.dmi'

	has_organ = list(
		"heart" =           /obj/item/organ/heart,
		"brain" =           /obj/item/organ/brain/xeno,
		"plasma vessel" =   /obj/item/organ/xenos/plasmavessel/hunter,
		"hive node" =       /obj/item/organ/xenos/hivenode,
		"nutrient channel" = /obj/item/organ/diona/nutrients
		)

	stamina = 200
	sprint_speed_factor = 2.25
	sprint_cost_factor = 1
	stamina_recovery = 4

	inherent_verbs = list(
		/mob/living/proc/ventcrawl,
		/mob/living/carbon/human/proc/tackle,
		/mob/living/carbon/human/proc/gut,
		/mob/living/carbon/human/proc/leap,
		/mob/living/carbon/human/proc/psychic_whisper,
		/mob/living/proc/devour,
		/mob/living/carbon/human/proc/regurgitate,
		/mob/living/carbon/human/proc/darkness_eyes
		)

/datum/species/xenos/sentinel
	name = "Xenomorph Sentinel"
	weeds_plasma_rate = 10
	caste_name = "sentinel"
	slowdown = 0
	total_health = 125
	tail = "xenos_sentinel_tail"

	icobase = 'icons/mob/human_races/xenos/r_xenos_sentinel.dmi'
	deform =  'icons/mob/human_races/xenos/r_xenos_sentinel.dmi'

	has_organ = list(
		"heart" =           /obj/item/organ/heart,
		"brain" =           /obj/item/organ/brain/xeno,
		"plasma vessel" =   /obj/item/organ/xenos/plasmavessel/sentinel,
		"acid gland" =      /obj/item/organ/xenos/acidgland,
		"hive node" =       /obj/item/organ/xenos/hivenode,
		"nutrient channel" = /obj/item/organ/diona/nutrients
		)

	inherent_verbs = list(
		/mob/living/proc/ventcrawl,
		/mob/living/carbon/human/proc/tackle,
		/mob/living/proc/devour,
		/mob/living/carbon/human/proc/regurgitate,
		/mob/living/carbon/human/proc/transfer_plasma,
		/mob/living/carbon/human/proc/corrosive_acid,
		/mob/living/carbon/human/proc/neurotoxin,
		/mob/living/carbon/human/proc/darkness_eyes
		)

/datum/species/xenos/queen

	name = "Xenomorph Queen"
	total_health = 250
	weeds_heal_rate = 5
	weeds_plasma_rate = 20
	caste_name = "queen"
	slowdown = 4
	tail = "xenos_queen_tail"
	rarity_value = 10

	icobase = 'icons/mob/human_races/xenos/r_xenos_queen.dmi'
	deform =  'icons/mob/human_races/xenos/r_xenos_queen.dmi'

	has_organ = list(
		"heart" =           /obj/item/organ/heart,
		"brain" =           /obj/item/organ/brain/xeno,
		"egg sac" =         /obj/item/organ/xenos/eggsac,
		"plasma vessel" =   /obj/item/organ/xenos/plasmavessel/queen,
		"acid gland" =      /obj/item/organ/xenos/acidgland,
		"hive node" =       /obj/item/organ/xenos/hivenode,
		"resin spinner" =   /obj/item/organ/xenos/resinspinner,
		"nutrient channel" = /obj/item/organ/diona/nutrients
		)

	inherent_verbs = list(
		/mob/living/proc/ventcrawl,
		/mob/living/carbon/human/proc/psychic_whisper,
		/mob/living/proc/devour,
		/mob/living/carbon/human/proc/regurgitate,
		/mob/living/carbon/human/proc/lay_egg,
		/mob/living/carbon/human/proc/plant,
		/mob/living/carbon/human/proc/transfer_plasma,
		/mob/living/carbon/human/proc/corrosive_acid,
		/mob/living/carbon/human/proc/neurotoxin,
		/mob/living/carbon/human/proc/gut,
		/mob/living/carbon/human/proc/resin,
		/mob/living/carbon/human/proc/darkness_eyes
		)

/datum/species/xenos/queen/handle_login_special(var/mob/living/carbon/human/H)
	..()
	// Make sure only one official queen exists at any point.
	if(!alien_queen_exists(1,H))
		H.real_name = "alien queen ([alien_number])"
		H.name = H.real_name
	else
		H.real_name = "alien princess ([alien_number])"
		H.name = H.real_name

/datum/hud_data/alien

	icon = 'icons/mob/screen/alien.dmi'
	has_a_intent =  1
	has_m_intent =  1
	has_warnings =  1
	has_hands =     1
	has_drop =      1
	has_throw =     1
	has_resist =    1
	has_pressure =  0
	has_nutrition = 0
	has_hydration = 0
	has_bodytemp =  0
	has_internals = 0

	gear = list(
		"o_clothing" =   list("loc" = ui_belt,      "name" = "Suit",         "slot" = slot_wear_suit, "state" = "equip",  "dir" = SOUTH),
		"head" =         list("loc" = ui_id,        "name" = "Hat",          "slot" = slot_head,      "state" = "hair"),
		"storage1" =     list("loc" = ui_storage1,  "name" = "Left Pocket",  "slot" = slot_l_store,   "state" = "pocket"),
		"storage2" =     list("loc" = ui_storage2,  "name" = "Right Pocket", "slot" = slot_r_store,   "state" = "pocket")
		)
