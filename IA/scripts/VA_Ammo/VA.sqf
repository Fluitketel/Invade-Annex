//--- BL1P thingy ma bob

//--- check if player has acre radio
_ret = false;
if !(isserver) then {
	_ret = [player] call acre_api_fnc_hasRadio;
	};
if (_ret) exitwith {systemchat "You can not use the VR ammo system while you have an ACRE radio.";};

[] spawn BIS_fnc_arsenal;

//--- Universal Gear
[_this,[
	
	//--- bis
	"B_Parachute",
	"B_FieldPack_blk",
	"B_OutdoorPack_blk",
	"B_TacticalPack_blk",
	
	//--- DR
	"DR_Backpack_DPM",
	"DR_Backpack_Compact_DPM",
	"DR_Backpack_Kitbag_DPM",
	"DR_Backpack_DPM_Medic",
	
	"DR_Backpack_Desert",
	"DR_Backpack_Compact_Desert",
	"DR_Backpack_Kitbag_Desert",
	"DR_Backpack_Desert_Medic",
	
	"DR_Backpack_Dark",
	"DR_Backpack_Compact_Dark",
	"DR_Backpack_Kitbag_Dark",
	"DR_Backpack_Dark_Medic",
	
	"DR_Backpack_URBAN",
	"DR_Backpack_Compact_URBAN",
	"DR_Backpack_Kitbag_URBAN",
	"DR_Backpack_URBAN_Medic"
	
],true] call BIS_fnc_addVirtualBackpackCargo;

[_this,[
	"30Rnd_45ACP_Mag_SMG_01",
	"30Rnd_45ACP_Mag_SMG_01_tracer_green",
	
	"30Rnd_9x21_Mag",
	"11Rnd_45ACP_Mag",
	"16Rnd_9x21_Mag",
	
	"30Rnd_65x39_caseless_mag",
	"30Rnd_65x39_caseless_mag_Tracer",
	
	"100Rnd_65x39_caseless_mag",
	"100Rnd_65x39_caseless_mag_Tracer",
	"200Rnd_65x39_cased_Box",
	"200Rnd_65x39_cased_Box_Tracer",
	
	"20Rnd_762x51_Mag",
	
	"1Rnd_HE_Grenade_shell",
	"3Rnd_HE_Grenade_shell",

	"NLAW_F",
	"Titan_AA",
	"Titan_AT",

	"Laserbatteries",
	
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
	"SatchelCharge_Remote_Mag"
	],true] call BIS_fnc_addVirtualMagazineCargo;
	
[_this,[
	
	//--- DR
	"DR_arifle_MXC_Wood_F",
	"DR_arifle_MX_Wood_F",
	"DR_arifle_MXM_Wood_F",
	"DR_arifle_MX_GL_Wood_F",
	"DR_arifle_MX_SW_Wood_F",
	
	"DR_arifle_MXC_Urban_F",
	"DR_arifle_MX_Urban_F",
	"DR_arifle_MXM_Urban_F",
	"DR_arifle_MX_GL_Urban_F",
	"DR_arifle_MX_SW_Urban_F",

	
	//--- bis
	"arifle_MX_Black_F",
	"arifle_MXC_Black_F",
	"arifle_MXM_Black_F",
	"arifle_MX_SW_Black_F",
	"arifle_MX_GL_Black_F",
	
	"arifle_MX_F",
	"arifle_MXC_F",
	"arifle_MXM_F",
	"arifle_MX_SW_F",
	"arifle_MX_GL_F",
	
	"LMG_Mk200_F",
	"srifle_EBR_F",
	
//--- smgs
	"SMG_01_F",
	"hgun_PDW2000_F",
//--- launchers
	"launch_B_Titan_F",
	"launch_B_Titan_short_F",
	"launch_NLAW_F",
//--- pistols
	"hgun_P07_F",
	"hgun_Pistol_heavy_01_F",
//--- binoc types
	"Rangefinder",
	"Binocular",
	"Laserdesignator"

	],true] call BIS_fnc_addVirtualWeaponCargo;

[_this,[
//--- stuff
	"ItemCompass",
	"ItemGPS",
	"ItemMap",
	"ItemWatch",
	"NVGoggles",
	"FirstAidKit",
	"Medikit",
	"ToolKit",
	
//--- scopes
	"optic_Aco",
	"optic_Aco_smg",
	"optic_Holosight",
	"optic_Holosight_smg",
	"optic_Hamr",
	"optic_MRCO",
	"optic_Arco",
	"optic_MRD",
	"optic_Yorris",
	"optic_DMS",
	"optic_NVS",
	
//--- suppresors
	"muzzle_snds_acp",
	"muzzle_snds_H",
	"muzzle_snds_L",
	"muzzle_snds_M",
	"muzzle_snds_H_SW",
	
//--- attachments
	"acc_flashlight",
	"acc_pointer_IR",
	
//--- uniforms
	
	//--- bis
	"U_B_CombatUniform_mcam",
	"U_B_CombatUniform_mcam_tshirt",
	"U_B_CombatUniform_mcam_vest",
	"U_B_CTRG_1",
	"U_B_CTRG_2",
	"U_B_CTRG_3",
	
	//--- DR
	"DR_CombatUniform_DPM",
	"DR_CombatUniform_DPM_tshirt",
	"DR_CombatUniform_DPM_vest",
	
	"DR_CombatUniform_URBAN",
	"DR_CombatUniform_URBAN_tshirt",
	"DR_CombatUniform_URBAN_vest",
	
	"DR_CombatUniform_Dark",
	"DR_CombatUniform_Dark_tshirt",
	"DR_CombatUniform_Dark_vest",
	
	"DR_CombatUniform_Desert",
	"DR_CombatUniform_Desert_tshirt",
	"DR_CombatUniform_Desert_vest",
	
//--- vests

	//--- bis
	"V_BandollierB_blk",
	"V_Chestrig_blk",
	"V_PlateCarrier1_blk",
	"V_PlateCarrierH_CTRG",
	"V_PlateCarrierL_CTRG",
	"V_TacVestIR_blk",
	
	//--- DR
	"DR_DPM_Plate_Carrier",
	"DR_DPM_Plate_Carrier_H",
	"DR_DPM_PlateCarrier_1",
	"DR_DPM_PlateCarrier_2",
	
	"DR_URBAN_Plate_Carrier",
	"DR_URBAN_Plate_Carrier_H",
	"DR_URBAN_PlateCarrier_1",
	"DR_URBAN_PlateCarrier_2",
	
	"DR_Dark_Plate_Carrier",
	"DR_Dark_Plate_Carrier_H",
	"DR_Dark_PlateCarrier_1",
	"DR_Dark_PlateCarrier_2",
	
	"DR_Desert_Plate_Carrier",
	"DR_Desert_Plate_Carrier_H",
	"DR_Desert_PlateCarrier_1",
	"DR_Desert_PlateCarrier_2",
	
//--- berets
	"DR_Beret_Green",
	"DR_Beret_Blue",
	"DR_Beret_Red",
	"DR_Folded_boonie",
	"DR_Headsetsmall",
	"DR_capRev",
	
//--- Helmets
	//--- DR
	"DR_Helmet_wood",
	"DR_Helmet_simple_wood",
	"DR_Helmet_Light_wood",
	"DR_Helmet_Cammo_Wood",
	"DR_Helmet_Wood_medic",
	
	"DR_Helmet_urban",
	"DR_Helmet_simple_urban",
	"DR_Helmet_Light_urban",
	"DR_Helmet_Cammo_Urban",
	"DR_Helmet_Urban_medic",
	
	"DR_Helmet_Dark",
	"DR_Helmet_simple_Dark",
	"DR_Helmet_Light_Dark",
	"DR_Helmet_Cammo_Dark",
	"DR_Helmet_Dark_medic",
	
	"DR_Helmet_Desert",
	"DR_Helmet_simple_Desert",
	"DR_Helmet_Light_Desert",
	"DR_Helmet_Cammo_Desert",
	"DR_Helmet_Desert_medic",
	
	//--- Bis
	"H_HelmetB_camo",
	"H_HelmetB_light",
	"H_HelmetSpecB",
		
	"H_HelmetCrew_B",
	"H_PilotHelmetHeli_B",

//--- caps n hats 

	//--- bis
	"H_Cap_blk",
	"H_Cap_oli_hs",
	"H_Bandanna_khk_hs",
	"H_Booniehat_dirty",
	"H_Booniehat_khk_hs",
	
	//--- DR
	"DR_Cap_headphones",
	"DR_DPM_booniehat",
	"DR_DPM_booniehat_Medic",
	"DR_Urban_booniehat",
	"DR_Urban_booniehat_Medic",
	"DR_Dark_booniehat",
	"DR_Dark_booniehat_Medic",
	"DR_Desert_booniehat",
	"DR_Desert_booniehat_Medic",
	"DR_Woolhat_black",
	"DR_Woolhat_blue",
	"DR_Woolhat_brown",
	"DR_Woolhat_green",
	"DR_Woolhat_red",
	
	//--- bis
	"G_Spectacles",
	"G_Combat",
	"G_Lowprofile",
	"G_Shades_Black",
	"G_Tactical_Black",
	"G_Balaclava_lowprofile",
	"G_Balaclava_combat",
	"G_Bandanna_beast",
	"G_Bandanna_shades",
	
	//--- DR
	"DR_bandana_Desert",
	"DR_bandana_Dark",
	"DR_bandana_Wood",
	"DR_bandana_Urban",
	"DR_bandana_Skull",
	"DR_bandana_Skull2",
	
	"DR_balaclarva_Wood",
	"DR_balaclarva_Urban",
	"DR_balaclarva_Ghost"
	],true] call BIS_fnc_addVirtualItemCargo;	

["open",false] spawn BIS_fnc_arsenal;

