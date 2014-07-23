    diag_log "========================== I AM IN THE RPT START FROM initPlayerLocal.sqf ======================"; //--- THIS SCRIPT IS AUTO RAN BY BIS ON PAYER JOINING
	if (isServer || isDedicated || !hasInterFace) exitWith {Diag_log "I was kicked from the intiPlayerLocal.sqf I am not a true client";};

//--- Wait for player to initialize
	waitUntil {!isNull player}; 
	
//--- Lets remove everything
	removeAllWeapons player;
	removeAllItems player;
	removeBackpack player;
	removeVest player;
	removeHeadgear player;
	player unassignItem "NVGoggles";
	player removeItem "NVGoggles";
	
//--- BL1P check for acre mod on Client
	//acre_enabled	= isClass(configFile/"CfgPatches"/"acre_main");
	
	player setcaptive false;                                                           
	player enableSimulation true; 
	player switchMove "";
	Uncon = false;publicvariable "Uncon"; 													//--- Reset player slot on join to counter the effects of diconnect while in revive bleedout.

//--- Fluit: Reset the number of times revived
	player setVariable ["revives", 0, true];

//--- bl1p blablabla
	execVM "core\briefing.sqf";                                                         	//--- Briefing on player
	
//--- bl1p revive
	call compileFinal preprocessFileLineNumbers "core\FAR_revive\FAR_revive_init.sqf"; 		//--- revive
	
//--- bl1p ooo im tired // removed to see if flipped stops walking because of this script
//	execVM "core\fatigueSystem\fatiguesystem.sqf";											//--- Alter amount of damage effects
//	execVM "core\fatigueSystem\reducedfatigue.sqf";											//--- Alter amount of damage effects