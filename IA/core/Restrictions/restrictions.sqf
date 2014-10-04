//--- by BL1P 
if (isServer || isDedicated || !hasInterFace) exitWith {Diag_log "I was kicked from the restrictions.sqf I am not a true client";};
// bl1p edited
[] spawn
{
	while {true} do
	{
		// 
		// todo make it so Pilots and crew can carry submachine guns not main guns
		
		//--- Recon EBR
		if 
		(
			(player hasWeapon "srifle_EBR_F") || 
			(player hasWeapon "srifle_EBR_ACO_F") || 
			(player hasWeapon "srifle_EBR_MRCO_pointer_F") || 
			(player hasWeapon "srifle_EBR_SOS_F") || 
			(player hasWeapon "srifle_EBR_ARCO_pointer_F") || 
			(player hasWeapon "srifle_EBR_ARCO_pointer_snds_F") || 
			(player hasWeapon "srifle_EBR_DMS_F") || 
			(player hasWeapon "srifle_EBR_Hamr_pointer_F") || 
			(player hasWeapon "srifle_EBR_DMS_pointer_snds_F")
		) 
		then
		{
			_ClassRM = ["B_recon_M_F","DR_DPM_recon_M","DR_URBAN_recon_M","DR_Desert_recon_M","DR_Dark_recon_M"];
			if !(typeOf player in _ClassRM) then
			{
				player removeWeapon "srifle_EBR_F";
				player removeWeapon "srifle_EBR_ACO_F";
				player removeWeapon "srifle_EBR_MRCO_pointer_F";
				player removeWeapon "srifle_EBR_SOS_F";
				player removeWeapon "srifle_EBR_ARCO_pointer_F";
				player removeWeapon "srifle_EBR_ARCO_pointer_snds_F"; 
				player removeWeapon "srifle_EBR_DMS_F";
				player removeWeapon "srifle_EBR_Hamr_pointer_F"; 
				player removeWeapon "srifle_EBR_DMS_pointer_snds_F";
				systemchat "Only Recon Marksmen are trained to use the EBR. Weapon removed.";
			};
		};
		
		//--- MG
		if 
		(
			(player hasWeapon "LMG_Mk200_F") || 
			(player hasWeapon "LMG_Mk200_pointer_F") || 
			(player hasWeapon "LMG_Mk200_MRCO_F") || 
			(player hasWeapon "LMG_Zafir_pointer_F") || 
			(player hasWeapon "LMG_Zafir_F") || 
			(player hasWeapon "arifle_MX_SW_F") || 
			(player hasWeapon "arifle_MX_SW_Black_F") || 
			(player hasWeapon "DR_arifle_MX_SW_Wood_F") || 
			(player hasWeapon "DR_arifle_MX_SW_Urban_F")


		) 
		then
		{
			_ClassMG = ["B_soldier_AR_F","DR_DPM_soldier_AR","DR_URBAN_soldier_AR","DR_Desert_soldier_AR","DR_Dark_soldier_AR"];
			if !(typeOf player in _ClassMG) then
			{
				player removeWeapon "LMG_Mk200_F";
				player removeWeapon "LMG_Mk200_pointer_F";
				player removeWeapon "LMG_Mk200_MRCO_F";
				player removeWeapon "LMG_Zafir_pointer_F";
				player removeWeapon "LMG_Zafir_F";
				player removeWeapon "arifle_MX_SW_F";
				player removeWeapon "arifle_MX_SW_Black_F";
				player removeWeapon "DR_arifle_MX_SW_Wood_F";
				player removeWeapon "DR_arifle_MX_SW_Urban_F";
				
				systemchat "Only Automatic Rifelmen are trained to use the MG class. Weapon removed.";
			};
		};
		
		//--- DMS Scope
		if 
			("optic_DMS" in (primaryWeaponItems player + items player))
		then
		{
			_ClassRM = ["B_recon_M_F","DR_DPM_recon_M","DR_URBAN_recon_M","DR_Desert_recon_M","DR_Dark_recon_M"];
			if !(typeOf player in _ClassRM) then
			{
				
				player removePrimaryWeaponItem "optic_DMS";
				player removeItem "optic_DMS";
				systemchat "DMS scope restricted to Marksman. Scope Removed.";
			};
		}; 
		
		//--- GR
		if 
		(
			(player hasWeapon "arifle_MX_GL_F") || 
			(player hasWeapon "arifle_MX_GL_Black_F") || 
			(player hasWeapon "DR_arifle_MX_GL_Urban_F") || 
			(player hasWeapon "DR_arifle_MX_GL_Wood_F") 
		) 
		then
		{
			_ClassGR = ["B_Soldier_GL_F","DR_DPM_soldier_GL","DR_URBAN_soldier_GL","DR_Desert_soldier_GL","DR_Dark_soldier_GL"];
			if !(typeOf player in _ClassGR) then
			{
				player removeWeapon "arifle_MX_GL_F";
				player removeWeapon "arifle_MX_GL_Black_F";
				player removeWeapon "DR_arifle_MX_GL_Urban_F";
				player removeWeapon "DR_arifle_MX_GL_Wood_F";
				systemchat "Only Grenadiers are trained in the use of the HE Underslung.";
			};
		}; 
		
		//--- Explosives
		if (("SatchelCharge_Remote_Mag" in magazines player) || ("APERSBoundingMine_Range_Mag" in magazines player) || ("APERSMine_Range_Mag" in magazines player) || ("APERSTripMine_Wire_Mag" in magazines player) || ("ATMine_Range_Mag" in magazines player) || ("ClaymoreDirectionalMine_Remote_Mag" in magazines player) || ("SLAMDirectionalMine_Wire_Mag" in magazines player) || ("DemoCharge_Remote_Mag" in magazines player)) then
		
		{
			_classEX = ["B_soldier_exp_F","DR_DPM_soldier_exp","DR_URBAN_soldier_exp","DR_Desert_soldier_exp","DR_Dark_soldier_exp"];
			if !(typeOf player in _classEX) then
			{
				player removeMagazines "SatchelCharge_Remote_Mag";
				player removeMagazines "APERSBoundingMine_Range_Mag";
				player removeMagazines "APERSMine_Range_Mag";
				player removeMagazines "APERSTripMine_Wire_Mag";
				player removeMagazines "ATMine_Range_Mag";
				player removeMagazines "ClaymoreDirectionalMine_Remote_Mag";
				player removeMagazines "SLAMDirectionalMine_Wire_Mag";
				player removeMagazines "DemoCharge_Remote_Mag";
				systemchat "Only Explosive Experts are trained in the use of the High Explsives. Explosives Removed.";
			};
		}; 
		
		//---Helipilot hat
		if 
		(
			(headgear player == "H_PilotHelmetHeli_B")
		) 
		then
        {
			_ClassHP = ["B_helicrew_F","B_Helipilot_F"];
            if !(typeOf player in _ClassHP) then 
            {
                // not alowed!
                removeHeadgear player;
				systemchat "For Ease of Recognition Helmet restricted to Heli Pilots";
			};
		};
		
		//--- Crewman hat
		if 
		(
			(headgear player == "H_HelmetCrew_B")
		) 
		then
        {
			_ClassCR = ["B_soldier_repair_F","DR_DPM_soldier_repair","DR_URBAN_soldier_repair","DR_Desert_soldier_repair","DR_Dark_soldier_repair"];
            if !(typeOf player in _ClassCR) then 
            {
                // not alowed!
                removeHeadgear player;
				systemchat "For Ease of Recognition Helmet restricted to Crewmen";
			};
		};
		
		//--- toolkit
		if ("ToolKit" in Items player) then
		{
			_classEX = ["B_soldier_exp_F","DR_DPM_soldier_exp","DR_URBAN_soldier_exp","DR_Desert_soldier_exp","DR_Dark_soldier_exp"];
			_ClassCR = ["B_soldier_repair_F","DR_DPM_soldier_repair","DR_URBAN_soldier_repair","DR_Desert_soldier_repair","DR_Dark_soldier_repair"];
			_Theworkers = _classEX + _ClassCR;
			if !(typeOf player in _Theworkers) then
			{
				player removeItem "ToolKit";
				systemchat "Only Engineer types are trained in the use of the Toolkit, Item Removed.";
			};
		}; 
		
		
		//--- medic
		if ("Medikit" in Items player) then
		{
			_ClassMD = ["B_medic_F","DR_DPM_medic","DR_URBAN_medic","DR_Desert_medic","DR_Dark_medic","DR_URBAN_recon_medic","DR_DPM_recon_medic","DR_Desert_recon_medic","DR_Dark_recon_medic"];
			if !(typeOf player in _ClassMD) then
			{
				player removeItem "Medikit";
				systemchat "Only Medics are trained in the use of the Advanced Medical Equipment. Item Removed.";
				 "Item_Medikit" createVehicle (getPos player);
			};
		}; 
		
		//--- medic boonie hats and backpacks
		if 
		(
		
			(headgear player == "DR_Desert_booniehat_Medic") ||
			(headgear player == "DR_Dark_booniehat_Medic") ||
			(headgear player == "DR_Urban_booniehat_Medic") ||
			(headgear player == "DR_DPM_booniehat_Medic") ||
			(headgear player == "DR_Dark_Urban_medic") ||
			(headgear player == "DR_Desert_Wood_medic") ||
			(headgear player == "DR_Helmet_Urban_medic") ||
			(headgear player == "DR_Helmet_Wood_medic")
		) 
		then
        {
           _ClassMD = ["B_medic_F","DR_DPM_medic","DR_URBAN_medic","DR_Desert_medic","DR_Dark_medic","DR_URBAN_recon_medic","DR_DPM_recon_medic","DR_Desert_recon_medic","DR_Dark_recon_medic"];
            if !(typeOf player in _ClassMD) then 
            {
                // not alowed!
                removeHeadgear player;
                systemchat "For Ease of Recognition Helmet restricted to Medics";
            };    
        };
		
		//--- medic backpacks
		if 
		(
		(backpack player == "DR_Backpack_Desert_Medic") ||
		(backpack player == "DR_Backpack_Dark_Medic") ||
		(backpack player == "DR_Backpack_URBAN_Medic") ||
		(backpack player == "DR_Backpack_DPM_Medic")
		)
		then
		{
			_ClassMD = ["B_medic_F","DR_DPM_medic","DR_URBAN_medic","DR_Desert_medic","DR_Dark_medic","DR_URBAN_recon_medic","DR_DPM_recon_medic","DR_Desert_recon_medic","DR_Dark_recon_medic"];
            if !(typeOf player in _ClassMD) then 
            {
				removebackpack player;
				systemchat "For Ease of Recognition backpack restricted to Medics";
			};
		};
		
		//--- com sl tl laserdes
		if (("Laserdesignator" in Items player ) || ("Laserdesignator" in assignedItems player)) then
        {
                
            _ClassCR = ["B_soldier_repair_F","DR_DPM_soldier_repair","DR_URBAN_soldier_repair","DR_Desert_soldier_repair","DR_Dark_soldier_repair"];
			_ClassCO = ["B_officer_F","DR_DPM_officer","DR_URBAN_officer","DR_Desert_officer","DR_Dark_officer"];
			_ClassSL = ["B_Soldier_SL_F","DR_DPM_soldier_SL","DR_URBAN_soldier_SL","DR_Desert_soldier_SL","DR_Dark_soldier_SL"];
			_ClassTL = ["B_Soldier_TL_F","DR_DPM_soldier_TL","DR_URBAN_soldier_TL","DR_Desert_soldier_TL","DR_Dark_soldier_TL"];
			_TheBrass = _ClassCO + _ClassSL + _ClassTL + _ClassCR;
            if !(typeOf player in _TheBrass) then 
            {
                // not alowed!
                player unassignItem "Laserdesignator";
                player removeItem "Laserdesignator";
                player removeweapon "Laserdesignator";
                systemchat "Only SL and TL can carry the Laser designator. Item Removed.";
            };    
        };
		
		//--- AT
		if ((player hasWeapon "launch_NLAW_F") || (player hasWeapon "launch_B_Titan_F") || (player hasWeapon "launch_B_Titan_short_F") || (player hasWeapon "launch_I_Titan_F") || (player hasWeapon "launch_I_Titan_short_F") || (player hasWeapon "launch_O_Titan_F") || (player hasWeapon "launch_O_Titan_short_F") || (player hasWeapon "launch_Titan_F") || (player hasWeapon "launch_Titan_short_F") || (player hasWeapon "launch_RPG32_F")) then
		
		{
			_ClassAT = ["B_soldier_LAT_F","DR_DPM_soldier_LAT","DR_URBAN_soldier_LAT","DR_Desert_soldier_LAT","DR_Dark_soldier_LAT"];
			if !(typeOf player in _ClassAT) then
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
				systemchat "Only AT Soldiers are trained in missile launcher operations. Launcher removed.";
			};
		};
		
		//--- Sniper
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
					systemchat "Weapon removed not your class";
					
				};
			};
		};
		
		//--- UAV backpack
		if (backpack player == "B_UAV_01_backpack_F") then 
		{
			_classUA = ["B_soldier_UAV_F","DR_DPM_soldier_UAV","DR_URBAN_soldier_UAV"];
			if !(typeOf player in _classUA) then
			{
				removeBackpack player;
				systemchat "You are not a UAV operator";
			};
		};
		
		//--- Uav terminal
		if (("B_UavTerminal" in Items player ) || ("B_UavTerminal" in assignedItems player)) then
        {
			_classUA = ["B_soldier_UAV_F","DR_DPM_soldier_UAV","DR_URBAN_soldier_UAV"];
			if !(typeOf player in _classUA) then
			{
				player unassignItem "B_UavTerminal";
				player removeItem "B_UavTerminal";
				player removeweapon "B_UavTerminal";
				systemchat "Only UAV Operators can use the Terminal. Item Removed.";
			};    
        };
		sleep 2;
	};
};