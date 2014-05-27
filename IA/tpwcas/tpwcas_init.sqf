/*    
AI_SUPPRESS - TPWC AI SUPPRESSION 
SP / MP / DEDI COMPATIBLE   

Authors: TPW && -Coulum- && fabrizio_T && Ollem

Version: 5.5

Last modified: 20140428

Requires: 		tpwcas_bdetect.sqf
				tpwcas_client_debug.sqf
				tpwcas_debug.sqf
				tpwcas_decskill.sqf
				tpwcas_getcover.sqf
				tpwcas_incskill.sqf
				tpwcas_init.sqf
				tpwcas_los.sqf
				tpwcas_los_sunangle.sqf
				tpwcas_mainloop.sqf
				tpwcas_runforit.sqf
				tpwcas_supstate.sqf
				tpwcas_textdebug.sqf => DEPRECATED
				tpwcas_visuals.sqf							
				
Disclaimer: Feel free to use and modify this code, on the proviso that you post back changes and improvements so that everyone can benefit from them, and acknowledge the original authors in any derivative works. 
*/ 

private ["_version"];

_version = "TPWCAS_A3 v5.5";

if (isNil "tpwcas_running") then { 	tpwcas_running = false;};
if ( tpwcas_running ) exitWith { diag_log "EXIT: tpwcas already running" };
tpwcas_running = true;

	// if server and for some reason tpwcas is still not set, set it to 3
	if ( (isServer) && (isNil "tpwcas_mode") ) then {
		tpwcas_mode = [_this, 0, 3] call BIS_fnc_param;
		};

	//////////////////////////////////////////////////////////////////	
	// Set default values in case not found in userconfig file
	
	//STARTUP HINT (TPWCAS & BDETECT). 0 = NO HINT, 1 = HINT. 
	if(isDedicated || isNil "tpwcas_hint") then {
		tpwcas_hint = 0;
		}; 

	//DELAY BEFORE SUPPRESSION FUNCTIONS START. ALLOWS TIME FOR OTHER MODS TO INITIALISE ETC. 
	if(isNil "tpwcas_sleep") then {
		tpwcas_sleep = 5;
		}; 

	//DEBUGGING. 0 = NO DEBUGGING, 1 = DISPLAY COLOURED BALLS OVER ANY SUPPRESSED UNITS, 2 = BALLS + BDETECT LOGGING. 
	if(isNil "tpwcas_debug") then {
		tpwcas_debug = 0;
		}; 

	////////////////////
	// BULLET VARIABLES
	////////////////////

	//BULLET IGNORE RADIUS (M). BULLETS FROM A SHOOTER CLOSER THAN THIS WILL NOT SUPPRESS.  
	if(isNil "tpwcas_ir") then {
		tpwcas_ir = 17;
		}; 


	//MAXIMUM BULLET DISTANCE (m). A BULLET FURTHER THAN THIS FROM ITS SHOOTER WILL NOT SUPPRESS. SET LARGER IF YOU PLAN ON DOING A LOT OF SNIPING - BUT MAY IMPACT PERFORMANCE.
	if(isNil "tpwcas_maxdist") then {
		tpwcas_maxdist = 1000;
		}; 

	//BULLET LIFETIME (sec). BULLETS STILL ALIVE THIS LONG AFTER BEING SHOT ARE IGNORED.
	if(isNil "tpwcas_bulletlife") then {
		tpwcas_bulletlife = 1.1;
		}; 

	//SHOT THRESHOLD. MORE SHOTS THAN THIS WILL CAUSE UNIT TO DROP/CRAWL. 
	if(isNil "tpwcas_st") then {
			tpwcas_st = 7;
		};

	//PISTOL AND SMG AMMO TO IGNORE. ADD CUSTOM AMMO (EG SUPPRESSED) OR CHANGE TO TASTE.   
	//ToDo: add ACR DLC Ammo
	if(isNil "tpwcas_mags") then 
	{
		tpwcas_mags =
		[
			"B_9x21_Ball",
			"B_9x21_Ball_Tracer_Green",
			"B_556x45_dual"
		];	
	};
	
	/////////////////////////
	// SUPPRESSION VARIABLES
	/////////////////////////
		
	//AI SKILL SUPPRESSION. 0 = SKILLS WILL NOT BE CHANGED, ONLY STANCE. 1 = SKILLS AND STANCE CHANGED UNDER SUPPRESSION. 
	if(isNil "tpwcas_skillsup") then {
		tpwcas_skillsup = 1;
		}; 

	//MINIMUM SKILL VALUE, NONE OF A UNIT'S SKILLS WILL DROP BELOW THIS UNDER SUPPRESSION. 
	if(isNil "tpwcas_minskill") then {
		tpwcas_minskill = 0.3; // minimum 30% of original skill
		};  

	//REVEAL VALUE WHEN SUPPRESSED. 0 = REVEAL DISABLED. <1 = SUPPRESSED UNIT KNOWS NOTHING ABOUT SHOOTER. 4 = UNIT KNOWS THE SHOOTER'S SIDE, POSITION, SHOE SIZE ETC. 
	if(isNil "tpwcas_reveal") then {
		tpwcas_reveal = 3.0;
		}; 

	//UNITS CAN FLEE IF COURAGE AND MORALE TOO LOW. 0 = UNITS WILL NOT FLEE. 1 = UNITS WILL FLEE. SET TO 0 IF TOO MANY UNITS ARE FLEEING OR UNSUPPRESSABLE. 
	if(isNil "tpwcas_canflee") then {
		tpwcas_canflee = 0;
		}; 

	///////////
	//TPW LOS VARIABLES
	///////////

	//MAXIMUM LOS DISTANCE (M). LOS STUFF ONLY WORKS FOR UNITS CLOSER THAN THIS.
	if(isNil "tpwcas_los_maxdist") then {
		tpwcas_los_maxdist = 70;
		};

	//MINIMUM LOS DISTANCE (M). ENEMIES ARE CONSIDERED "VISIBLE" IF IN LOS, NO MATTER WHAT (CAMO, STANCE, VISIBILITY), IF LESS THAN THIS DISTANCE - EXCEPT FOR SNIPERS AND SPOTTER WITH GHILLIE SUITS
	if(isNil "tpwcas_los_mindist") then {
		tpwcas_los_mindist = 5;
		};

	//EMBEDDED TPWLOS: DISABLE = 0, ENABLE = 1 
	if(isNil "tpwcas_los_enable") then {
		tpwcas_los_enable = 0; //disabled by default
		};

	//EMBEDDED TPWLOS REQUIRED MINIMAL SERVER FPS, ELSE PROCESS IS SKIPPED
	if(isNil "tpwcas_los_minfps") then {
		tpwcas_los_minfps = 25;
		};
	
	//EMBEDDED TPWLOS MAXIMAL KNOWSABOUT VALUE: ABOVE WILL SKIP TPWLOS FOR THIS SPECIFIC SPOTTER-TARGET COMBI
	//    VALUES: SEE TPWCAS_REVEAL ABOVE
	if(isNil "tpwcas_los_knowsabout") then {
		tpwcas_los_knowsabout = 4.0;
		};
	
	//AI SEARCH COVER: DISABLE = 0, ENABLE = 1 
	if(isNil "tpwcas_getcover") then {
		tpwcas_getcover = 1; //enabled by default
		};

	//AI SEARCH COVER MAX DISTANCE (M). RECOMMENDED TO KEEP LOW NUMBER (5 to 15)
	if(isNil "tpwcas_coverdist") then {
		tpwcas_coverdist = 15;
		};
	
	//AI SEARCH COVER REQUIRED MINIMAL SERVER FPS, ELSE PROCESS IS SKIPPED
	if(isNil "tpwcas_getcover_minfps") then {
		tpwcas_getcover_minfps = 20;
		};
	
	//PLAYER SUPPRESSION SHAKE. 0 = NO SUPPRESSION, 1 = SUPPRESSION.    
	if(isNil "tpwcas_playershake") then {
		tpwcas_playershake = 1;	
		};  

	//PLAYER SUPPRESSION VISUALS. 0 = NO SUPPRESSION, 1 = SUPPRESSION.     
	if(isNil "tpwcas_playervis") then {
		tpwcas_playervis = 1;
		}; 

		
	//////////   
	//SET UP    
	//////////   

	//WAIT 
	sleep tpwcas_sleep;    

	//START HINT       
	if ( !(isDedicated) && (tpwcas_hint == 1) ) then
	{    
		0 = [_version] spawn 
		{   
			_version = _this select 0;
			hintsilent format ["%1 Starting...", _version];    
			sleep 3;    
			hintsilent "";
		};
	};
	
	diag_log format ["%1 - %2 Initiated - tpwcas_mode: [%3]", time, _version, tpwcas_mode];    

	//CHECK IF ASR_AI 0.0.0.0 OR GREATER IS RUNNING       
	if (isClass (configFile >> "cfgPatches">>"asr_ai3_danger")) then    
	{   
		_asr_ai_va = getArray (configFile>>"cfgPatches">>"asr_ai3_main">>"versionAr");  
		if (_asr_ai_va select 0 >= 0 && _asr_ai_va select 1 >= 0 && _asr_ai_va select 2 >= 0 && _asr_ai_va select 3 >= 0) then   
		{  
			//DISABLE REVEAL
			tpwcas_reveal = 0;
			diag_log format ["%1 - %2 supported version of ASR_AI found", time, _asr_ai_va];    
		};      
	};		
		
	//////////////////////////
	//COMPILE TPWCAS FUNCTIONS
	//////////////////////////

	call compileFinal preprocessFileLineNumbers "tpwcas\tpwcas_debug.sqf"; //visual debugging

	if !(isDedicated) then 
	{
		call compileFinal preprocessFileLineNumbers "tpwcas\tpwcas_client_debug.sqf"; //visual debugging
		call compileFinal preprocessFileLineNumbers "tpwcas\tpwcas_visuals.sqf"; //player suppression visuals
	};
	
	call compileFinal preprocessFileLineNumbers "tpwcas\tpwcas_decskill.sqf"; //decrease AI skills
	call compileFinal preprocessFileLineNumbers "tpwcas\tpwcas_incskill.sqf"; //increase AI skills
	call compileFinal preprocessFileLineNumbers "tpwcas\tpwcas_supstate.sqf"; //bdetect callback to assign unit suppression status
	call compileFinal preprocessFileLineNumbers "tpwcas\tpwcas_getcover.sqf"; //move suppressed unit into cover
	call compileFinal preprocessFileLineNumbers "tpwcas\tpwcas_runforit.sqf"; //civilians will run away from the shooting

	call compileFinal preprocessFileLineNumbers "tpwcas\tpwcas_mainloop.sqf"; //main loop
	
	//////////////
	//CALL BDETECT
	////////////// 

	call compileFinal preprocessFileLineNumbers "tpwcas\tpwcas_bdetect.sqf"; //bullet detection
	
	bdetect_bullet_skip_mags = tpwcas_mags; 
	bdetect_bullet_min_distance = tpwcas_ir;
	bdetect_bullet_max_distance = tpwcas_maxdist;
	bdetect_bullet_max_lifespan = tpwcas_bulletlife;
	if ( tpwcas_hint == 0 ) then { 
		bdetect_startup_hint = false;
	};
	bdetect_debug_levels = [0,3,6,7,8,9,10,11];

	if !(tpwcas_debug == 2) then {
		bdetect_debug_enable = false;
	} else {
		bdetect_debug_enable = true;
	};

	bdetect_callback = "tpwcas_fnc_supstate"; 
	
	// In case of multiplayer overrule specific settings and make sure parameters are synched if adjusted
	if ( isMultiPlayer ) then 
	{
		bdetect_mp_per_frame_emulation = true;
		bdetect_mp_per_frame_emulation_frame_d = 0.015;

		if ( ( tpwcas_mode == 3 ) || ( tpwcas_mode == 4 ) ) then 
		{
			tpwcas_playershake = 0;
			tpwcas_playervis = 0;
		};	

		// Broadcast variables to all clients to be in sync with server settings
		//publicVariable "tpwcas_mode";

		if ( (isMultiPlayer) && (isServer) ) then 
		{	
			publicVariable "tpwcas_mode";
			sleep 0.1;
			
			publicVariable "tpwcas_mindist";
			sleep 0.1;
			publicVariable "tpwcas_maxdist";
			sleep 0.1;
			publicVariable "tpwcas_ir"; 
			sleep 0.1;
			publicVariable "tpwcas_st"; 
			sleep 0.1;
			publicVariable "tpwcas_bulletlife";
			sleep 0.1;
			publicVariable "tpwcas_mags";
			sleep 0.1;
			
			publicVariable "tpwcas_skillsup"; 
			sleep 0.1;
			publicVariable "tpwcas_minskill"; 
			sleep 0.1;
			publicVariable "tpwcas_reveal"; 
			sleep 0.1;
			publicVariable "tpwcas_canflee";
			sleep 0.1;

			publicVariable "tpwcas_getcover";
			sleep 0.1;
			publicVariable "tpwcas_coverdist";
			sleep 0.1;
			publicVariable "tpwcas_getcover_minfps";
			sleep 0.1;
			
			publicVariable "tpwcas_playershake"; 
			sleep 0.1;
			publicVariable "tpwcas_playervis";
			sleep 0.1;

			publicVariable "tpwcas_debug";
			sleep 0.1;
			
			sleep 4; // just in case to make sure to allow some time for the variables to reach all clients

			//tpwcas_client_mode = 1;
			//publicVariable "tpwcas_client_mode";
			//sleep 0.1;
			
		};
	};
	
	if ( tpwcas_debug > 0 ) then 
	{
		diag_log format ["--- tpwcas parameters ---------------------------------------------------"];
		diag_log format ["%1 TPWCAS Var: tpwcas_mode - [%2]", time, tpwcas_mode];
		diag_log format ["%1 TPWCAS Var: tpwcas_ir - [%2]", time, tpwcas_ir];
		diag_log format ["%1 TPWCAS Var: tpwcas_st - [%2]", time, tpwcas_st];
		diag_log format ["%1 TPWCAS Var: tpwcas_bulletlife - [%2]", time, tpwcas_bulletlife];
		diag_log format ["%1 TPWCAS Var: tpwcas_skillsup - [%2]", time, tpwcas_skillsup];
		diag_log format ["%1 TPWCAS Var: tpwcas_minskill - [%2]", time, tpwcas_minskill];
		diag_log format ["%1 TPWCAS Var: tpwcas_reveal - [%2]", time, tpwcas_reveal];
		diag_log format ["%1 TPWCAS Var: tpwcas_canflee - [%2]", time, tpwcas_canflee];
		diag_log format ["%1 TPWCAS Var: tpwcas_getcover - [%2]", time, tpwcas_getcover];
		diag_log format ["%1 TPWCAS Var: tpwcas_coverdist - [%2]", time, tpwcas_coverdist];
		diag_log format ["%1 TPWCAS Var: tpwcas_playershake - [%2]", time, tpwcas_playershake];
		diag_log format ["%1 TPWCAS Var: tpwcas_playervis - [%2]", time, tpwcas_playervis];
		//diag_log format ["%1 TPWCAS Var: tpwcas_textdebug - [%2]", time, tpwcas_textdebug]; => DEPRECATED
		diag_log format ["%1 TPWCAS Var: tpwcas_debug - [%2]", time, tpwcas_debug];
		if ( isServer ) then 
		{
			diag_log format ["%1 TPWCAS Var: tpwcas_los_enable - [%2]", time, tpwcas_los_enable];
			diag_log format ["%1 TPWCAS Var: tpwcas_los_maxdist - [%2]", time, tpwcas_los_maxdist];
			diag_log format ["%1 TPWCAS Var: tpwcas_los_mindist - [%2]", time, tpwcas_los_mindist];
			diag_log format ["%1 TPWCAS Var: tpwcas_los_minfps - [%2]", time, tpwcas_los_minfps];
			diag_log format ["%1 TPWCAS Var: tpwcas_los_knowsabout - [%2]", time, tpwcas_los_knowsabout];
			
			diag_log format ["%1 TPWCAS Var: tpwcas_getcover_minfps - [%2]", time, tpwcas_getcover_minfps];
		};
		//diag_log format ["%1 TPWCAS Var:  - [%2]", time, ];
		diag_log format ["-------------------------------------------------------------------------"];
	};
	
	////////
	//RUN IT 
	////////
	
	call bdetect_fnc_init; 
	waitUntil { !(isNil "bdetect_init_done") };

	// Trigger debug color changes on client
//	if ( (tpwcas_mode == 2) && (tpwcas_debug >= 1) && (hasInterface) ) then 
//	{
//		suppressDebug_compiled = call compileFinal format["%1", tpwcas_fnc_client_debug];
//	};
	
	// START EMBEDDED TPW LOS
	if ( (tpwcas_los_enable == 1) && (isServer) ) then 
	{
		call compileFinal preprocessFileLineNumbers "tpwcas\tpwcas_los.sqf"; //tpw los main loop
		
		// Run day/night determination
		[] execVM "tpwcas\tpwcas_los_sunangle.sqf"; //determine day or night
		diag_log format ["%1 - %2 LOS Sun angle detection started", time, _version];

		sleep 1;

		//if !(isMultiPlayer) then 
		//{
		//	[tpwcas_los_fnc_mainloop, 0.5] call cba_fnc_addperframehandler; // SP Usage
		//}
		//else 
		//{
			[] spawn tpwcas_los_fnc_init; // MP Usage
		//};
		
		diag_log format ["%1 - %2 LOS started", time, _version];
	};
	
	sleep 0.5;
	
	// Run main suppression function	
	[] spawn tpwcas_fnc_main_loop;
	diag_log format ["%1 - %2 Mainloop started", time, _version];

	// Enable visual markers and debug logging
	if ( (tpwcas_debug > 0) && ( isServer || (tpwcas_mode == 2 ) || tpwcas_isHC ) ) then 
	{
		[] spawn tpwcas_fnc_debug; 
		diag_log format ["%1 - %2 Debug started", time, _version];
	};
	
	//START HINT       
	if ( !(isDedicated) && (tpwcas_hint == 1) ) then 
	{    
		0 = [_version] spawn 
		{   
			_version = _this select 0;
			hintsilent format ["%1 Active", _version];    
			sleep 3;    
			hintsilent "";
		};
	};
	
	diag_log format ["%1 - %2 Active - tpwcas_mode: [%3]", time, _version, tpwcas_mode];  

