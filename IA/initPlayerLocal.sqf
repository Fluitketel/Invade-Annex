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
	acre_enabled = isClass(configFile/"CfgPatches"/"acre_main");
	//taskForce_enabled = isClass(configFile/"CfgPatches"/"task_force_radio");
	
//--- BL1P Black listed mods
	STGI = isClass(configFile/"CfgPatches"/"STGI");
	st_interact = isClass(configFile/"CfgPatches"/"st_interact");
	STNametags = isClass(configFile/"CfgPatches"/"STNametags");
	
	if (STGI) then {failMission "END9";};
	if (st_interact) then {failMission "END9";};
	if (STNametags) then {failMission "END9";};
	
	
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
    
// Initialize Client DEP functions
	_handle = execVM "scripts\DEP\client_init.sqf";
	waitUntil{scriptDone _handle};	
	
//--- Remove players voice
//	player setspeaker "NoVoice";
	
//--- Remove radio subtitles by Larrow
//	waitUntil {! (isNull player) && time > 1}; 
//	oldSubs = showSubtitles false;  
//	diag_log "showSubtitles is false";