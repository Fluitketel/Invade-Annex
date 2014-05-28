/* by wildw1ng */
if (isServer || isDedicated || !hasInterFace) exitWith {Diag_log "I was kicked from the restrictions.sqf I am not a true client";};
// bl1p edited
[] spawn
{
	while {true} do
	{
		// Pilots and crew
		// todo make it so they can carry submachine guns not side arms
		
		if 
		(
			(!(primaryWeapon player == "") && (typeOf player == "B_Helipilot_F")) || 
			(!(primaryWeapon player == "") && (typeOf player == "B_Pilot_F")) || 
			(!(primaryWeapon player == "") && (typeOf player == "B_helicrew_F")) ||
			(!(primaryWeapon player == "") && (typeOf player == "B_soldier_repair_F"))
		) 
		then
		{
			player removeWeapon (primaryWeapon player);
			{player removeMagazine _x} forEach magazines player;
			{player addMagazine "16Rnd_9x21_Mag"} forEach [1,2,3,4];
			player addweapon "hgun_P07_F";
			player addHandgunItem "muzzle_snds_L";
			player globalChat "Pilots and Crew may use side arms only. Primary weapon removed.";		
		};

		//MG
		if 
		(
			(player hasWeapon "LMG_Mk200_F") || 
			(player hasWeapon "LMG_Mk200_pointer_F") || 
			(player hasWeapon "LMG_Mk200_MRCO_F") || 
			(player hasWeapon "LMG_Zafir_pointer_F") || 
			(player hasWeapon "LMG_Zafir_F") || 
			(player hasWeapon "arifle_MX_SW_F") || 
			(player hasWeapon "arifle_MX_SW_Black_F")
		) 
		then
		{
			if (typeOf player != "B_soldier_AR_F") then
				{
					player removeWeapon "LMG_Mk200_F";
					player removeWeapon "LMG_Mk200_pointer_F";
					player removeWeapon "LMG_Mk200_MRCO_F";
					player removeWeapon "LMG_Zafir_pointer_F";
					player removeWeapon "LMG_Zafir_F";
					player removeWeapon "arifle_MX_SW_F";
					player removeWeapon "arifle_MX_SW_Black_F";
					player globalChat "Only Automatic Rifelmen are trained to use the MG class. Weapon removed.";
				};
			
		};
		
		// MG Scopes
		if 
			(
				( "optic_DMS" in (primaryWeaponItems player + items player) ) 
				
				|| ( "optic_SOS" in (primaryWeaponItems player + items player) )
				|| ( "optic_LRPS" in (primaryWeaponItems player + items player) )
				
				|| ( "optic_Nightstalker" in (primaryWeaponItems player + items player) )
				|| ( "optic_tws" in (primaryWeaponItems player + items player) )
				|| ( "optic_tws_mg" in (primaryWeaponItems player + items player) )
			)
		then
		{
		//hint "has optic_DMS";
			if ((player hasWeapon "LMG_Mk200_F") || (player hasWeapon "LMG_Zafir_F")) then
			{
				
				player removePrimaryWeaponItem "optic_DMS";
				player removeItem "optic_DMS";
				player removePrimaryWeaponItem "optic_SOS";
				player removeItem "optic_SOS";
				player removePrimaryWeaponItem "optic_LRPS";
				player removeItem "optic_LRPS";
				player removePrimaryWeaponItem "optic_Nightstalker";
				player removeItem "optic_Nightstalker";
				player removePrimaryWeaponItem "optic_tws";
				player removeItem "optic_tws";
				player removePrimaryWeaponItem "optic_tws_mg";
				player removeItem "optic_tws_mg";
				player globalChat "Heavy MG with Some Scopes Unsupported. Scope Removed.";
			};
		}; 
		
		//GR
		if (("1Rnd_HE_Grenade_shell" in magazines player) || ("3Rnd_HE_Grenade_shell" in magazines player)) then
		{
			if ((playerSide == west && typeOf player != "B_Soldier_GL_F")) then
			{
				player removeMagazines "1Rnd_HE_Grenade_shell";
				player removeMagazines "3Rnd_HE_Grenade_shell";
				player globalChat "Only Grenadiers are trained in the use of the HE Underslung. HEs Removed.";
			};
		}; 
		
		//Explosives
		if (("SatchelCharge_Remote_Mag" in magazines player) || ("APERSBoundingMine_Range_Mag" in magazines player) || ("APERSMine_Range_Mag" in magazines player) || ("APERSTripMine_Wire_Mag" in magazines player) || ("ATMine_Range_Mag" in magazines player) || ("ClaymoreDirectionalMine_Remote_Mag" in magazines player) || ("SLAMDirectionalMine_Wire_Mag" in magazines player) || ("DemoCharge_Remote_Mag" in magazines player)) then
		
		{
			if (typeOf player != "B_soldier_exp_F") then
			{
				player removeMagazines "SatchelCharge_Remote_Mag";
				player removeMagazines "APERSBoundingMine_Range_Mag";
				player removeMagazines "APERSMine_Range_Mag";
				player removeMagazines "APERSTripMine_Wire_Mag";
				player removeMagazines "ATMine_Range_Mag";
				player removeMagazines "ClaymoreDirectionalMine_Remote_Mag";
				player removeMagazines "SLAMDirectionalMine_Wire_Mag";
				player removeMagazines "DemoCharge_Remote_Mag";
				player globalChat "Only Explosive Experts are trained in the use of the High Explsives. Explosives Removed.";
			};
		}; 
		
		// medic
		
		if ("Medikit" in Items player) then
		{
			if (typeOf player != "B_medic_F") then
			{
				player removeItem "Medikit";
				player globalChat "Only Medics are trained in the use of the Advanced Medical Equipment. Item Removed.";
			};
		}; 
		
		//medic boonie hats
		if 
		(
			(headgear player == "H_Booniehat_khk") ||
			(headgear player == "H_Booniehat_dgtl") ||
			(headgear player == "H_Booniehat_dirty") ||
			(headgear player == "H_Booniehat_grn") ||
			(headgear player == "H_Booniehat_indp") ||
			(headgear player == "H_Booniehat_khk_hs") ||
			(headgear player == "H_Booniehat_mcamo")
		) 
		then
        {
            _allowed = ["B_medic_F"];
            if !(typeOf player in _allowed) then 
            {
                // not alowed!
                removeHeadgear player;
                player globalChat "For Ease of Recognition boonie restricted to Medics";
            };    
        };
		
		//com sl tl laser des
		if (("Laserdesignator" in Items player ) || ("Laserdesignator" in assignedItems player)) then
        {
                
            
            _allowed = ["B_Soldier_SL_F", "B_Soldier_TL_F", "B_officer_F"];
            if !(typeOf player in _allowed) then 
            {
                // not alowed!
                player unassignItem "Laserdesignator";
                player removeItem "Laserdesignator";
                player removeweapon "Laserdesignator";
                player globalChat "Only SL and TL can carry the Laser designator. Item Removed.";
            };    
        };
		
		//AT
		if ((player hasWeapon "launch_NLAW_F") || (player hasWeapon "launch_B_Titan_F") || (player hasWeapon "launch_B_Titan_short_F") || (player hasWeapon "launch_I_Titan_F") || (player hasWeapon "launch_I_Titan_short_F") || (player hasWeapon "launch_O_Titan_F") || (player hasWeapon "launch_O_Titan_short_F") || (player hasWeapon "launch_Titan_F") || (player hasWeapon "launch_Titan_short_F") || (player hasWeapon "launch_RPG32_F")) then
		
		{
			if 
			(
				(typeOf player != "B_soldier_LAT_F")
			) 
			then
			{
				player removeWeapon "launch_NLAW_F";
				player removeWeapon "launch_B_Titan_F";
				player removeWeapon "launch_B_Titan_short_F";
				player removeWeapon "launch_I_Titan_F";
				player removeWeapon "launch_I_Titan_short_F";
				player removeWeapon "launch_O_Titan_F";
				player removeWeapon "launch_O_Titan_short_F";
				player removeWeapon "launch_Titan_short_F";
				player removeWeapon "launch_RPG32_F";
				player globalChat "Only AT Soldiers are trained in missile launcher operations. Launcher removed.";
			};
		};
		
		//Sniper
		if 
		(
			(player hasWeapon "srifle_DMR_01_F") || 
			(player hasWeapon "srifle_DMR_01_ACO_F") || 
			(player hasWeapon "srifle_DMR_01_MRCO_pointer_F") || 
			(player hasWeapon "srifle_DMR_01_SOS_F") || 
			(player hasWeapon "srifle_DMR_01_DMS_F") || 
			(player hasWeapon "srifle_DMR_01_DMS_pointer_snds_F") || 
			(player hasWeapon "srifle_DMR_01_ARCO_pointer_F") || 
			(player hasWeapon "srifle_GM6_F") || 
			(player hasWeapon "srifle_LRR_F") || 
			(player hasWeapon "srifle_GM6_SOS_F") || 
			(player hasWeapon "srifle_GM6_LRPS_F") || 
			(player hasWeapon "srifle_LRR_LRPS_F") ||
			(player hasWeapon "srifle_LRR_SOS_F")
		) then
		{
			if ((playerSide == west && typeOf player != "B_sniper_F") || (playerside == east && typeOf player != "O_sniper_F")) then
			{
				
				if (random 5 < 3) then 
					{
						_layer = 85125; 
						_layer cutText ["====WEAPON BOOBY TRAPPED=====","PLAIN"];
						player removeWeapon "srifle_DMR_01_F";
						player removeWeapon "srifle_DMR_01_ACO_F";
						player removeWeapon "srifle_DMR_01_MRCO_pointer_F";
						player removeWeapon "srifle_DMR_01_SOS_F";
						player removeWeapon "srifle_DMR_01_DMS_F";
						player removeWeapon "srifle_DMR_01_DMS_pointer_snds_F";
						player removeWeapon "srifle_DMR_01_ARCO_pointer_F";
						player removeWeapon "srifle_GM6_F";
						player removeWeapon "srifle_LRR_F";
						player removeWeapon "srifle_GM6_SOS_F";
						player removeWeapon "srifle_LRR_SOS_F";
						player removeWeapon "srifle_GM6_LRPS_F";
						player removeWeapon "srifle_LRR_LRPS_F";
						"grenadeHand" createVehicle getPos player;
						//sleep 3;
					}
					else
					{	
						player removeWeapon "srifle_DMR_01_F";
						player removeWeapon "srifle_DMR_01_ACO_F";
						player removeWeapon "srifle_DMR_01_MRCO_pointer_F";
						player removeWeapon "srifle_DMR_01_SOS_F";
						player removeWeapon "srifle_DMR_01_DMS_F";
						player removeWeapon "srifle_DMR_01_DMS_pointer_snds_F";
						player removeWeapon "srifle_DMR_01_ARCO_pointer_F";
						player removeWeapon "srifle_GM6_F";
						player removeWeapon "srifle_LRR_F";
						player removeWeapon "srifle_GM6_SOS_F";
						player removeWeapon "srifle_LRR_SOS_F";
						player removeWeapon "srifle_GM6_LRPS_F";
						player removeWeapon "srifle_LRR_LRPS_F";
						player globalChat "Weapon removed not your class";
						
					};
				
			};
		};

		sleep 2;
	} foreach allUnits;
};