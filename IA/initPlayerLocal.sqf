    diag_log "========================== I AM IN THE RPT START FROM initPlayerLocal.sqf ======================"; //--- THIS SCRIPT IS AUTO RAN BY BIS ON PAYER JOINING
	if (isServer || isDedicated || !hasInterFace) exitWith {Diag_log "I was kicked from the intiPlayerLocal.sqf I am not a true client";};

//--- Wait for player to initialize
	waitUntil {!isNull player}; 
	
//--- BL1P check for acre mod on Client
	acre_enabled	= isClass(configFile/"CfgPatches"/"acre_main");
	
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
	
//--- bl1p ooo im tired
	execVM "core\fatigueSystem\fatiguesystem.sqf";											//--- Alter amount of damage effects
	execVM "core\fatigueSystem\reducedfatigue.sqf";											//--- Alter amount of damage effects
	
	 

	
	