//Allow player to respawn with his loadout? If true unit will respawn with all ammo from initial save! Set to false to disable this and rely on other scripts!
vas_onRespawn = true;
//Preload Weapon Config?
vas_preload = true;
//If limiting weapons its probably best to set this to true so people aren't loading custom loadouts with restricted gear.
vas_disableLoadSave = false;
//Amount of save/load slots
vas_customslots = 19; //9 is actually 10 slots, starts from 0 to whatever you set, so always remember when setting a number to minus by 1, i.e 12 will be 11.
//Disable 'VAS hasn't finished loading' Check !!! ONLY RECOMMENDED FOR THOSE THAT USE ACRE AND OTHER LARGE ADDONS !!!
vas_disableSafetyCheck = true;
/*
	NOTES ON EDITING!
	YOU MUST PUT VALID CLASS NAMES IN THE VARIABLES IN AN ARRAY FORMAT, NOT DOING SO WILL RESULT IN BREAKING THE SYSTEM!
	PLACE THE CLASS NAMES OF GUNS/ITEMS/MAGAZINES/BACKPACKS/GOGGLES IN THE CORRECT ARRAYS! TO DISABLE A SELECTION I.E
	GOGGLES vas_goggles = [""]; AND THAT WILL DISABLE THE ITEM SELECTION FOR WHATEVER VARIABLE YOU ARE WANTING TO DISABLE!
	
														EXAMPLE
	vas_weapons = ["srifle_EBR_ARCO_point_grip_F","arifle_Khaybar_Holo_mzls_F","arifle_TRG21_GL_F","Binocular"];
	vas_magazines = ["30Rnd_65x39_case_mag","20Rnd_762x45_Mag","30Rnd_65x39_caseless_green"];
	vas_items = ["ItemMap","ItemGPS","NVGoggles"];
	vas_backpacks = ["B_Bergen_sgg_Exp","B_AssaultPack_rgr_Medic"];
	vas_goggles = [""];				

												Example for side specific (TvT)
	switch(playerSide) do
	{
		//Blufor
		case west:
		{
			vas_weapons = ["srifle_EBR_F","arifle_MX_GL_F"];
			vas_items = ["muzzle_snds_H","muzzle_snds_B","muzzle_snds_L","muzzle_snds_H_MG"]; //Removes suppressors from VAS
			vas_goggles = ["G_Diving"]; //Remove diving goggles from VAS
		};
		//Opfor
		case west:
		{
			vas_weapons = ["srifle_EBR_F","arifle_MX_GL_F"];
			vas_items = ["muzzle_snds_H","muzzle_snds_B","muzzle_snds_L","muzzle_snds_H_MG"]; //Removes suppressors from VAS
			vas_goggles = ["G_Diving"]; //Remove diving goggles from VAS
		};
	};
*/

//If the arrays below are empty (as they are now) all weapons, magazines, items, backpacks and goggles will be available
//Want to limit VAS to specific weapons? Place the classnames in the array!
vas_weapons = [
"arifle_MX_F",
"arifle_MX_Black_F",
"arifle_MX_GL_F",
"arifle_MX_GL_Black_F",
"arifle_MXC_F",
"arifle_MXC_Black_F",
"arifle_MX_SW_F",
"arifle_MX_SW_Black_F",
"arifle_MXM_F",
"arifle_MXM_Black_F",
//"arifle_TRG20_F",
//"arifle_TRG21_F",
//"arifle_TRG21_GL_F",

"LMG_Mk200_F",
"srifle_EBR_F",

"arifle_SDAR_F",
"SMG_01_F",
"hgun_PDW2000_F",

"hgun_P07_F",
"hgun_ACPC2_F",
"hgun_Pistol_heavy_01_F",
"hgun_Pistol_heavy_02_F",


"launch_B_Titan_F",
"launch_B_Titan_short_F",
"launch_NLAW_F",
//"launch_RPG32_F",

"Laserdesignator",
"Rangefinder",
"MineDetector",
"Binocular"
];
//Want to limit VAS to specific magazines? Place the classnames in the array!
vas_magazines = [

"30Rnd_45ACP_Mag_SMG_01",
"30Rnd_9x21_Mag",
"16Rnd_9x21_Mag",
"9Rnd_45ACP_Mag",
"11Rnd_45ACP_Mag",
"30Rnd_65x39_caseless_mag",
"30Rnd_65x39_caseless_mag_Tracer",
"100Rnd_65x39_caseless_mag",
"100Rnd_65x39_caseless_mag_Tracer",
"20Rnd_762x51_Mag",
"5Rnd_127x108_Mag",
"30Rnd_556x45_Stanag",
"20Rnd_556x45_UW_mag",

"200Rnd_65x39_cased_Box",
"200Rnd_65x39_cased_Box_Tracer",

"30Rnd_45ACP_Mag_SMG_01_tracer_green",

"NLAW_F",
"Titan_AA",
//"Titan_AP",
"Titan_AT",
//"RPG32_F",

"Laserbatteries",

"Chemlight_blue",
"Chemlight_green",
"Chemlight_red",
"Chemlight_yellow",
"SmokeShell",
"SmokeShellBlue",
"SmokeShellYellow",
"SmokeShellGreen",
"SmokeShellOrange",
"SmokeShellPurple",
"SmokeShellRed",
"HandGrenade",
"MiniGrenade",
"B_IR_Grenade",

"1Rnd_HE_Grenade_shell",
"3Rnd_HE_Grenade_shell",

"1Rnd_Smoke_Grenade_shell",
"1Rnd_SmokeBlue_Grenade_shell",
"1Rnd_SmokeGreen_Grenade_shell",
"1Rnd_SmokeOrange_Grenade_shell",
"1Rnd_SmokePurple_Grenade_shell",
"1Rnd_SmokeRed_Grenade_shell",
"1Rnd_SmokeYellow_Grenade_shell",

"3Rnd_Smoke_Grenade_shell",
"3Rnd_SmokeBlue_Grenade_shell",
"3Rnd_SmokeGreen_Grenade_shell",
"3Rnd_SmokeOrange_Grenade_shell",
"3Rnd_SmokePurple_Grenade_shell",
"3Rnd_SmokeRed_Grenade_shell",
"3Rnd_SmokeYellow_Grenade_shell",
"3Rnd_UGL_FlareCIR_F",
"3Rnd_UGL_FlareGreen_F",
"3Rnd_UGL_FlareRed_F",
"3Rnd_UGL_FlareWhite_F",
"UGL_FlareCIR_F",
"UGL_FlareGreen_F",
"UGL_FlareRed_F",
"UGL_FlareWhite_F",

"APERSBoundingMine_Range_Mag",
"APERSMine_Range_Mag",
"APERSTripMine_Wire_Mag",
"ATMine_Range_Mag",
"ClaymoreDirectionalMine_Remote_Mag",
"SLAMDirectionalMine_Wire_Mag",
"DemoCharge_Remote_Mag",
"SatchelCharge_Remote_Mag"];
//Want to limit VAS to specific items? Place the classnames in the array!
vas_items = [
"ItemCompass",
"ItemGPS",
"ItemMap",
//"ItemRadio",
//"ACRE_PRC119",

//tfa radios
"tf_rf7800str",
"tf_anprc152",

"ItemWatch",
"NVGoggles",
"NVGoggles_OPFOR",
"FirstAidKit",
"Medikit",
"ToolKit",
"B_UavTerminal",

//--- uniforms
"U_B_CombatUniform_mcam",
"U_B_CombatUniform_mcam_tshirt",
"U_B_CombatUniform_mcam_vest",
"U_B_CTRG_1",
"U_B_CTRG_2",
"U_B_CTRG_3",
//"U_B_GhillieSuit",
//"U_B_HeliPilotCoveralls",
//"U_B_PilotCoveralls",
//"U_B_survival_uniform",
"U_B_Wetsuit",

//--- vests
"V_RebreatherB",
"V_BandollierB_blk",
"V_BandollierB_cbr",
"V_BandollierB_khk",
"V_BandollierB_oli",
"V_BandollierB_rgr",
"V_Chestrig_blk",
"V_Chestrig_khk",
"V_Chestrig_oli",
"V_Chestrig_rgr",
"V_HarnessO_brn",
"V_HarnessO_gry",
"V_HarnessOGL_brn",
"V_HarnessOGL_gry",
"V_HarnessOSpec_brn",
"V_HarnessOSpec_gry",
"V_PlateCarrier1_blk",
"V_PlateCarrier1_rgr",
"V_PlateCarrier2_rgr",
"V_PlateCarrier3_rgr",
"V_PlateCarrierGL_rgr",
"V_PlateCarrierH_CTRG",
"V_PlateCarrierIA1_dgtl",
"V_PlateCarrierIA2_dgtl",
"V_PlateCarrierIAGL_dgtl",
"V_PlateCarrierL_CTRG",
"V_PlateCarrierSpec_rgr",
"V_TacVest_blk",
"V_TacVest_brn",
"V_TacVest_camo",
"V_TacVest_khk",
"V_TacVest_oli",
"V_TacVestCamo_khk",
"V_TacVestIR_blk",

//--- hats
"H_CrewHelmetHeli_B",
"H_HelmetCrew_B",
"H_PilotHelmetFighter_B",
"H_PilotHelmetHeli_B",
"H_MilCap_dgtl",
"H_MilCap_gry",
"H_MilCap_mcamo",
"H_MilCap_oucamo",
"H_Helmet_Kerry",
"H_HelmetB",
"H_HelmetB_black",
"H_HelmetB_camo",
"H_HelmetB_desert",
"H_HelmetB_grass",
"H_HelmetB_light",
"H_HelmetB_light_black",
"H_HelmetB_light_desert",
"H_HelmetB_light_grass",
"H_HelmetB_light_sand",
"H_HelmetB_light_snakeskin",
"H_HelmetB_paint",
"H_HelmetB_plain_blk",
"H_HelmetB_plain_mcamo",
"H_HelmetB_sand",
"H_HelmetB_snakeskin",
"H_HelmetSpecB",
"H_HelmetSpecB_blk",
"H_HelmetSpecB_paint1",
"H_HelmetSpecB_paint2",
"H_Cap_tan_specops_US",
"H_Cap_khaki_specops_UK",
"H_Cap_blk",
"H_Cap_blk_CMMG",
"H_Cap_blk_ION",
"H_Cap_blk_Raven",
"H_Cap_grn",
"H_Cap_headphones",
"H_Cap_tan_specops_US",
"H_Booniehat_dgtl",
"H_Booniehat_dirty",
"H_Booniehat_grn",
"H_Booniehat_indp",
"H_Booniehat_khk",
"H_Booniehat_mcamo",
"H_Watchcap_blk",
"H_Beret_blk",
"H_Beret_02",
"H_Beret_Colonel",
"H_Booniehat_khk_hs",
"H_Bandanna_khk_hs",
"H_Cap_oli_hs",
"H_Bandanna_camo",

//"U_C_Journalist",
//"H_Cap_press",
//"V_Press_F",

//--- Optics
"optic_Aco",
"optic_Aco_smg",
"optic_Holosight",
"optic_Holosight_smg",

"optic_Hamr",
"optic_MRCO",
"optic_Arco",

"optic_MRD",
"optic_Yorris",

//"optic_LRPS",
//"optic_SOS",
"optic_DMS",
"optic_NVS",

//--- Silencers
//"muzzle_snds_B",
//"muzzle_snds_H_MG",
"muzzle_snds_acp",
"muzzle_snds_H",
"muzzle_snds_L",
"muzzle_snds_M",

//--- Attachments
"acc_flashlight",
"acc_pointer_IR"];

//Want to limit backpacks? Place the classnames in the array!
vas_backpacks = [
"tf_rt1523g",
"B_Parachute",
"B_UAV_01_backpack_F",
"B_AssaultPack_cbr",
"B_AssaultPack_khk",
"B_AssaultPack_mcamo",
"B_AssaultPack_rgr",
"B_AssaultPack_sgg",

"B_FieldPack_blk",
"B_FieldPack_cbr",
"B_FieldPack_khk",
"B_FieldPack_oli",
"B_FieldPack_oucamo",

"B_Kitbag_cbr",
"B_Kitbag_mcamo",
"B_Kitbag_sgg",

"B_OutdoorPack_blk",
"B_OutdoorPack_blu",
"B_OutdoorPack_tan",

"B_TacticalPack_blk",
"B_TacticalPack_mcamo",
"B_TacticalPack_oli",
"B_TacticalPack_rgr"];

//Want to limit goggles? Place the classnames in the array!
vas_glasses = [];


/*
	NOTES ON EDITING:
	THIS IS THE SAME AS THE ABOVE VARIABLES, YOU NEED TO KNOW THE CLASS NAME OF THE ITEM YOU ARE RESTRICTING. THIS DOES NOT WORK IN 
	CONJUNCTION WITH THE ABOVE METHOD, THIs IS ONLY FOR RESTRICTING / LIMITING ITEMS FROM VAS AND NOTHING MORE
	
														EXAMPLE
	vas_r_weapons = ["srifle_EBR_F","arifle_MX_GL_F"];
	vas_r_items = ["muzzle_snds_H","muzzle_snds_B","muzzle_snds_L","muzzle_snds_H_MG"]; //Removes suppressors from VAS
	vas_r_goggles = ["G_Diving"]; //Remove diving goggles from VAS
	
												Example for side specific (TvT)
	switch(playerSide) do
	{
		//Blufor
		case west:
		{
			vas_r_weapons = ["srifle_EBR_F","arifle_MX_GL_F"];
			vas_r_items = ["muzzle_snds_H","muzzle_snds_B","muzzle_snds_L","muzzle_snds_H_MG"]; //Removes suppressors from VAS
			vas_r_goggles = ["G_Diving"]; //Remove diving goggles from VAS
		};
		//Opfor
		case west:
		{
			vas_r_weapons = ["srifle_EBR_F","arifle_MX_GL_F"];
			vas_r_items = ["muzzle_snds_H","muzzle_snds_B","muzzle_snds_L","muzzle_snds_H_MG"]; //Removes suppressors from VAS
			vas_r_goggles = ["G_Diving"]; //Remove diving goggles from VAS
		};
	};
*/

//Below are variables you can use to restrict certain items from being used.
//Remove Weapon
vas_r_weapons = [];
vas_r_backpacks = 
[
"B_Bergen_blk",
"B_Bergen_mcamo",
"B_Bergen_rgr",
"B_Bergen_sgg",
"B_Carryall_cbr",
"B_Carryall_khk",
"B_Carryall_mcamo",
"B_Carryall_oli",
"B_Carryall_oucamo"
];
//Magazines to remove from VAS
vas_r_magazines = ["Titan_AP","30Rnd_556x45_Stanag_Tracer_Yellow","30Rnd_556x45_Stanag_Tracer_Green"];
//Items to remove from VAS
vas_r_items = ["optic_tws_mg","optic_tws","optic_Nightstalker","optic_LRPS","optic_SOS","muzzle_snds_H_MG","muzzle_snds_B"];
//Goggles to remove from VAS
vas_r_glasses = [];
