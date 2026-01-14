return {
    PropLifetime = 300000, -- Time in milliseconds before the stash auto-removes (Default: 5 Minutes)

    ThrowForce = 15, -- Adjust to your liking

    CooldownTime = 1000, -- 1 second between throws/places
    MaxThrowDistance = 50.0, -- Maximum distance a prop can travel
    PickupDistance = 2.5, -- Maximum pickup distance
    MaxPlaceDistance = 10.0, -- Maximum raycast distance for placement
    MaxGiveDistance = 3.0, -- This is the max distance for giving items

    -- Item to prop model mapping
    ItemModels = {
        -- Food & Drink
        ['burger'] = 'prop_cs_burger_01',
        ['sprunk'] = 'prop_ld_can_01',
        ['water'] = 'prop_ld_flow_bottle',
        ['mustard'] = 'prop_food_mustard',
        ['wine'] = 'prop_wine_white',
        ['grape'] = 'prop_food_grape',
        ['grapejuice'] = 'prop_ld_flow_bottle',
        ['coffee'] = 'prop_fib_coffee',
        ['vodka'] = 'prop_vodka_bottle',
        ['whiskey'] = 'prop_whiskey_bottle',
        ['beer'] = 'prop_beer_bottle',
        ['sandwich'] = 'prop_sandwich_01',
        ['prison_food'] = 'prop_paper_bag_01',
        
        -- Equipment & Tools
        ['parachute'] = 'p_parachute_s',
        ['phone'] = 'prop_npc_phone_02',
        ['lockpick'] = 'prop_tool_screwdvr01',
        ['radio'] = 'prop_cs_hand_radio',
        ['jammer'] = 'prop_bomb_01',
        ['radiocell'] = 'prop_battery_01',
        ['advancedlockpick'] = 'prop_tool_screwdvr02',
        ['screwdriverset'] = 'prop_tool_screwdvr01',
        ['electronickit'] = 'prop_tool_box_01',
        ['cleaningkit'] = 'prop_cleaning_trolly',
        ['repairkit'] = 'prop_tool_box_01',
        ['advancedrepairkit'] = 'prop_tool_box_02',
        ['walking_stick'] = 'prop_cs_walking_stick',
        ['lighter'] = 'prop_cs_lighter_01',
        ['binoculars'] = 'prop_binoc_01',
        ['harness'] = 'prop_armour_pickup',
        ['handcuffs'] = 'prop_cs_cuffs_01',
        ['tablet'] = 'prop_cs_tablet',
        ['drill'] = 'prop_tool_drill',
        ['thermite'] = 'prop_c4_final_green',
        ['diving_gear'] = 'prop_dive_tank_01',
        ['diving_fill'] = 'prop_dive_tank_01',
        ['jerry_can'] = 'prop_jerrycan_01a',
        ['nitrous'] = 'prop_byard_gastank01',
        
        -- Clothing & Armor
        ['armour'] = 'prop_armour_pickup',
        ['clothing'] = 'prop_cs_shopping_bag',
        ['panties'] = 'prop_cs_panties_02',
        
        -- Bags & Containers
        ['garbage'] = 'prop_cs_rub_binbag_01',
        ['paperbag'] = 'prop_paper_bag_small',
        ['backpack'] = 'prop_paper_bag_01',
        
        -- Valuables
        ['money'] = 'prop_cash_pile_01',
        ['black_money'] = 'prop_money_bag_01',
        ['diamond_ring'] = 'prop_diamond_ring',
        ['rolex'] = 'prop_watch_01',
        ['goldbar'] = 'prop_gold_bar',
        ['goldchain'] = 'prop_acc_box_01',
        
        -- Documents
        ['id_card'] = 'prop_franklin_dl',
        ['driver_license'] = 'prop_franklin_dl',
        ['weaponlicense'] = 'prop_paper_bag_small',
        ['lawyerpass'] = 'prop_franklin_dl',
        ['stickynote'] = 'prop_paper_bag_small',
        
        -- Drugs
        ['crack_baggy'] = 'prop_meth_bag_01',
        ['cokebaggy'] = 'prop_drug_package',
        ['coke_brick'] = 'prop_coke_block_01',
        ['coke_small_brick'] = 'prop_drug_package',
        ['xtcbaggy'] = 'prop_drug_package',
        ['meth'] = 'prop_meth_bag_01',
        ['oxy'] = 'prop_pill_pot_01',
        ['weed_ak47'] = 'prop_weed_bottle',
        ['weed_ak47_seed'] = 'prop_weed_bottle',
        ['weed_skunk'] = 'prop_weed_bottle',
        ['weed_skunk_seed'] = 'prop_weed_bottle',
        ['weed_amnesia'] = 'prop_weed_bottle',
        ['weed_amnesia_seed'] = 'prop_weed_bottle',
        ['weed_og-kush'] = 'prop_weed_bottle',
        ['weed_og-kush_seed'] = 'prop_weed_bottle',
        ['weed_white-widow'] = 'prop_weed_bottle',
        ['weed_white-widow_seed'] = 'prop_weed_bottle',
        ['weed_purple-haze'] = 'prop_weed_bottle',
        ['weed_purple-haze_seed'] = 'prop_weed_bottle',
        ['weed_brick'] = 'prop_weed_block_01',
        ['weed_nutrition'] = 'prop_ld_can_01',
        ['joint'] = 'prop_cs_ciggy_01',
        ['rolling_paper'] = 'prop_paper_bag_small',
        ['empty_weed_bag'] = 'prop_money_bag_01',
        
        -- Medical
        ['firstaid'] = 'prop_ld_health_pack',
        ['ifaks'] = 'prop_ld_health_pack',
        ['painkillers'] = 'prop_pill_pot_01',
        ['bandage'] = 'prop_ld_health_pack',
        ['medbag'] = 'prop_ld_health_pack',
        ['tweezers'] = 'prop_tool_screwdvr01',
        ['suturekit'] = 'prop_ld_health_pack',
        ['icepack'] = 'prop_ld_health_pack',
        ['burncream'] = 'prop_ld_flow_bottle',
        ['defib'] = 'prop_defib_01',
        ['sedative'] = 'prop_cs_pills',
        ['morphine30'] = 'prop_cs_pills',
        ['morphine15'] = 'prop_cs_pills',
        ['perc30'] = 'prop_cs_pills',
        ['perc10'] = 'prop_cs_pills',
        ['perc5'] = 'prop_cs_pills',
        ['vic10'] = 'prop_cs_pills',
        ['vic5'] = 'prop_cs_pills',
        ['medikit'] = 'prop_ld_health_pack',
        
        -- Fireworks
        ['firework1'] = 'ind_prop_firework_01',
        ['firework2'] = 'ind_prop_firework_02',
        ['firework3'] = 'ind_prop_firework_03',
        ['firework4'] = 'ind_prop_firework_04',
        
        -- Materials
        ['steel'] = 'prop_ingot_01',
        ['rubber'] = 'prop_cs_rubber_tyre',
        ['metalscrap'] = 'prop_scrap_2_crate',
        ['iron'] = 'prop_ingot_01',
        ['copper'] = 'prop_ingot_01',
        ['aluminum'] = 'prop_ingot_01',
        ['plastic'] = 'prop_rub_binbag_03',
        ['glass'] = 'prop_ld_greenscreen_01',
        
        -- Electronics & Tech
        ['gatecrack'] = 'prop_cs_tablet',
        ['cryptostick'] = 'prop_ld_usb_01',
        ['trojan_usb'] = 'prop_ld_usb_01',
        ['toaster'] = 'prop_toaster_01',
        ['small_tv'] = 'prop_trev_tv_01',
        ['security_card_01'] = 'prop_franklin_dl',
        ['security_card_02'] = 'prop_franklin_dl',
        
        -- Coral
        ['antipatharia_coral'] = 'prop_coral_01',
        ['dendrogyra_coral'] = 'prop_coral_stone_03',
        
        -- Moonshine
        ['moonshine_still'] = 'prop_paper_bag_01',
        ['moonshine_crate'] = 'prop_paper_bag_01',
        ['moonshine_bottle'] = 'prop_paper_bag_01',
        ['sugar'] = 'prop_paper_bag_01',
        ['corn'] = 'prop_paper_bag_01',
        ['yeast'] = 'prop_paper_bag_01',
        ['wheat'] = 'prop_paper_bag_01',
        
        -- Recycling
        ['recyclablematerial'] = 'prop_paper_bag_01',
        ['bottle'] = 'prop_ld_flow_bottle',
        ['can'] = 'prop_ld_can_01',
        
        -- Armor Plates
        ['steel_plate'] = 'prop_paper_bag_01',
        ['uhmwpe_plate'] = 'prop_paper_bag_01',
        ['ceramic_plate'] = 'prop_paper_bag_01',
        ['kevlar_plate'] = 'prop_paper_bag_01',
        ['brokenplate'] = 'prop_paper_bag_01',
        ['heavypc'] = 'prop_paper_bag_01',
        ['lightpc'] = 'prop_paper_bag_01',
        
        -- Miscellaneous
        ['headbag'] = 'prop_money_bag_01',
        ['brick'] = 'ng_proc_brick_01a',
        ['report_card'] = 'prop_paper_bag_01',
        ['cash_bag'] = 'prop_money_bag_01',
        ['inked_cash_bag'] = 'prop_money_bag_01',
        ['prison_bomb'] = 'prop_paper_bag_01',
        
        -- Evidence
        ['evidence_laptop'] = 'prop_laptop_01a',
        ['evidence_box'] = 'prop_box_ammo03a',
        ['empty_evidence_bag'] = 'prop_money_bag_01',
        ['filled_evidence_bag'] = 'prop_money_bag_01',
        ['baggy_empty'] = 'prop_money_bag_01',
        ['baggy_blood'] = 'prop_money_bag_01',
        ['baggy_magazine'] = 'prop_money_bag_01',
        ['hydrogen_peroxide'] = 'prop_ld_flow_bottle',
        ['fingerprint_brush'] = 'prop_tool_screwdvr01',
        ['fingerprint_taken'] = 'prop_paper_bag_small',
        ['fingerprint_scanner'] = 'prop_cs_tablet',
        ['spy_microphone'] = 'prop_cs_hand_radio',
    }
}