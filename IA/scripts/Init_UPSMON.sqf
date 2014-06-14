// only run on server (including SP, MP, Dedicated) and Headless Client 
if (!isServer && hasInterface ) exitWith {};


//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
//        These Variables should be checked and set as required, to make the mission runs properly.
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

//1=Enable or 0=disable debug. In debug could see a mark positioning de leader and another mark of the destination of movement, very useful for editing mission
if (PARAMS_DebugMode2 == 1) then 
{
UPSMON_Debug = 1;
}
else
{
UPSMON_Debug = 0;
};

//1=Enable or 0=disable. In game display global chat info about who just killed a civilian. 
//numbers of Civilians killed by players could be read from array 'KILLED_CIV_COUNTER' -> [Total, by West, by East, by Res, The killer]
R_WHO_IS_CIV_KILLER_INFO = 0;

// if you are spotted by AI group, how close the other AI group have to be to You , to be informed about your present position. over this, will lose target
UPSMON_sharedist = 500; // org value 800 => increased for ArmA3 map sizes for less predictable missions..

// If enabled AI communication between them with radio defined sharedist distance, 0/2 
// (must be set to 2 in order to use reinforcement !R)
UPSMON_comradio = 2;

//Sides that are enemies of resistance
UPSMON_Res_enemy = [];
_resEnemyWest = false;
_resEnemyEast = false;				
if ( (resistance getFriend WEST) < 0.6 ) then { _resEnemyWest = true }; // resistance is enemy of West
if ( (resistance getFriend EAST) < 0.6 ) then { _resEnemyEast = true }; // resistance is enemy of East

if ( _resEnemyWest && _resEnemyEast ) then { UPSMON_Res_enemy = [west, east] };
if ( _resEnemyWest && !_resEnemyEast ) then { UPSMON_Res_enemy = [west] };
if ( !_resEnemyWest && _resEnemyEast ) then { UPSMON_Res_enemy = [east] };
//if ( !_resEnemyWest && !_resEnemyEast ) then { UPSMON_Res_enemy = [] };

// Distance from destination for searching vehicles. (Search area is about 200m), 
// If your destination point is further than KRON_UPS_searchVehicledist, AI will try to find a vehicle to go there.
UPSMON_searchVehicledist = 600; // 700, 900  

//Enables or disables AI to use static weapons
UPSMON_useStatics = true;

//Enables or disables AI to put mines if armoured enemies near (use ambush2 if needed)
UPSMON_useMines = true; //ToDo verify this param

//Group formations
UPSMON_groupFormation	= ["COLUMN","STAG COLUMN","WEDGE","ECH LEFT","ECH RIGHT","VEE","LINE","FILE","DIAMOND"];	//Group formations

//------------------------------------------------------------------------------------------------------------------------------
//        These Variables can be changed if needed but it is not necessary.
//------------------------------------------------------------------------------------------------------------------------------

//% of chance to use smoke by team members when someone wounded or killed in the group in %(default 13 & 35).
// set both to 0 -> to switch off this function 
UPSMON_USE_SMOKE = 10; // org 13: decreased while AI is popping smoke a bit too often


//Height that heli will fly this input will be randomised in a 10%
UPSMON_flyInHeight = 40; //80;

//Autorise Surrender or not.
UPSMON_SURRENDER = false;
if ( UPSMON_SURRENDER ) then 
{
	//Adding eventhandlers
	"UPSMON_EAST_SURRENDED" addPublicVariableEventHandler { if (_this select 1) then { nul=[east] execvm "scripts\UPSMON\MODULES\UPSMON_surrended.sqf";};};
	"UPSMON_WEST_SURRENDED" addPublicVariableEventHandler { if (_this select 1) then { nul=[west] execvm "scripts\UPSMON\MODULES\UPSMON_surrended.sqf";};};
	"UPSMON_GUER_SURRENDED" addPublicVariableEventHandler { if (_this select 1) then { nul=[resistance] execvm "scripts\UPSMON\MODULES\UPSMON_surrended.sqf";};};
	
	UPSMON_EAST_SURRENDER = 70;
	UPSMON_WEST_SURRENDER = 70;
	UPSMON_GUER_SURRENDER = 70;
}
else
{
	UPSMON_EAST_SURRENDER = 0;
	UPSMON_WEST_SURRENDER = 0;
	UPSMON_GUER_SURRENDER = 0;
};

UPSMON_RETREAT = false;
if ( UPSMON_RETREAT ) then 
{

	UPSMON_EAST_RETREAT = 70;
	UPSMON_WEST_RETREAT = 70;
	UPSMON_GUER_RETREAT = 70;
}
else
{
	UPSMON_EAST_RETREAT = 0;
	UPSMON_WEST_RETREAT = 0;
	UPSMON_GUER_RETREAT = 0;
};

// knowsAbout 0.5 1.03 , 1.49 to add this enemy to "target list" (1-4) the higher number the less detect ability (original in 5.0.7 was 0.5)
// it does not mean the AI will not shoot at you. This means: what must be knowsAbout you to UPSMON adds you to the list of targets (UPSMON list of target) 
UPSMON_knowsAboutEnemy = 1.2; // 5

// units will react (change the beahaviour) when dead bodies found 
UPSMON_deadBodiesReact = true;  // true OR false // modified so AI will react to dead bodies found

// ---------------------------------------------------------------------------------------------------------------------
//      Better do not change these variables if you aren't sure !R
// ---------------------------------------------------------------------------------------------------------------------

//Efective distance for doing perfect ambush (max distance is this x2)
UPSMON_ambushdist = 100; // decreased from 100 to 75, so max distance is 150 m

//Max distance to target for doing para-drop, will be randomised between 0 and 100% of this value.
UPSMON_paradropdist = 350;

//Height that heli will fly if his mission his paradroping. 
UPSMON_paraflyinheight = 110;

//Frequency for doing calculations for each squad.
UPSMON_Cycle = 10; //org 20

//Time that lider wait until doing another movement, this time reduced dynamically under fire, and on new targets
UPSMON_react = 60;// 60

//Min time to wait for doing another reaction
UPSMON_minreact = 30; // org 30

//Max waiting is the maximum time patrol groups will wait when arrived to target for doing another target.
UPSMON_maxwaiting = 30;

// how long AI units should be in alert mode after initially spotting an enemy
UPSMON_alerttime = 90;

// how far opfors should move away if they're under attack
UPSMON_safedist = 280; //org 300

// How far opfor disembark from non armoured vehicle
UPSMON_closeenoughV = 800;

// how close unit has to be to target to generate a new one target or to enter stealth mode
UPSMON_closeenough = 300;  // ToDo investigate effect of decrease of this value to e.g. 50 // 300

//Enable it to send reinforcements, better done it in a trigger inside your mission.
UPSMON_reinforcement = false; // ToDo Set to true if UPSMON reinf is going ot be used

//Artillery support, better control if set in trigger 
UPSMON_ARTILLERY_EAST_FIRE = false; //set to true for doing east to fire //ToDo verify if needed
UPSMON_ARTILLERY_WEST_FIRE = false; //set to true for doing west to fire
UPSMON_ARTILLERY_GUER_FIRE = false; //set to true for doing resistance to fire
UPSMON_Night = true;
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
//		Do not touch these variables !!!! !R	
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------			
	UPSMON_GOTHIT_ARRAY = [];
	UPSMON_GOTKILL_ARRAY = [];
	UPSMON_Version = "UPSMON 6.0.7.2";
	KILLED_CIV_COUNTER = [0,0,0,0,0];
	UPSMON_INIT = 0;        //Variable que indica que ha sido inicializado
	UPSMON_EAST_SURRENDED = false;
	UPSMON_WEST_SURRENDED = false;
	UPSMON_GUER_SURRENDED = false;
	UPSMON_AllWest=[];	//All west AI 
	UPSMON_AllEast=[];	//All east AI 
	UPSMON_AllRes=[];		//All resistance AI 
	UPSMON_East_enemies = [];
	UPSMON_West_enemies = [];
	UPSMON_Guer_enemies = [];
	UPSMON_East_friends = [];
	UPSMON_West_friends = [];
	UPSMON_Guer_friends = [];
	UPSMON_targets0 =[];//objetivos west
	UPSMON_targets1 =[];//objetivos east
	UPSMON_targets2 =[];//resistence	
	UPSMON_targetsPos =[];//Posiciones de destino actuales.
	UPSMON_NPCs = []; //Lideres de los grupos actuales
	UPSMON_Instances=0; // -1; // => -1 would start group nr with 0 
	UPSMON_Total=0;
	UPSMON_Exited=0;
	UPSMON_East_Total = 0;
	UPSMON_West_Total = 0;
	UPSMON_Guer_Total = 0;
	UPSMON_Civ_Total = 0;
	UPSMON_ARTILLERY_WEST_UNITS = [];
	UPSMON_ARTILLERY_EAST_UNITS = [];
	UPSMON_ARTILLERY_GUER_UNITS = [];	
	UPSMON_ARTILLERY_WEST_TARGET = objnull;
	UPSMON_ARTILLERY_EAST_TARGET = objnull;
	UPSMON_ARTILLERY_GUER_TARGET = objnull;
	UPSMON_REINFORCEMENT_WEST_UNITS = [];
	UPSMON_REINFORCEMENT_EAST_UNITS = [];
	UPSMON_REINFORCEMENT_GUER_UNITS = [];	
	UPSMON_FlareInTheAir = false;
	Publicvariable "UPSMON_FlareInTheAir";
	UPSMON_TEMPLATES = [];
	UPSMON_MG_WEAPONS = ["LMG_Mk200_F","LMG_Mk200_MRCO_F","LMG_Mk200_pointer_F","LMG_Zafir_F","LMG_Zafir_pointer_F","arifle_MX_SW_F","arifle_MX_SW_Hamr_pointer_F","arifle_MX_SW_pointer_F"];
	// For future updates check this for weapons with > 100Rnd ammo:
	// http://browser.six-projects.net/cfg_weapons/classlist?utf8=%E2%9C%93&version=70&commit=Change&options[group_by]=weap_type&options[custom_type]=Rifle&options[faction]=
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


	// ***************************************** SERVER INITIALIZATION *****************************************
	if (isNil("UPSMON_INIT") || UPSMON_INIT == 0) then {

		// global functions
		call compile preprocessFileLineNumbers "scripts\UPSMON\COMMON\UPSMON_KRON_FNC.sqf";
		
		//Init library function, Required Version: 5.0 of mon_functions
		call compile preprocessFileLineNumbers "scripts\UPSMON\COMMON\MON_functions.sqf";
		
		//init !R functions
		call compile preprocessFileLineNumbers "scripts\UPSMON\COMMON\UPSMON_R_FNC.sqf";
		
		//init Aze Functions
		call compile preprocessFileLineNumbers "scripts\UPSMON\COMMON\UPSMON_Aze_FNC.sqf";
		call compile preprocessFileLineNumbers "scripts\UPSMON\COMMON\func_getcover.sqf";
		
		// Init Modules
		call compile preprocessFileLineNumbers "scripts\UPSMON\MODULES\UPSMON_AMBUSH.sqf";
		call compile preprocessFileLineNumbers "scripts\UPSMON\MODULES\UPSMON_CLONES.sqf";
		call compile preprocessFileLineNumbers "scripts\UPSMON\MODULES\UPSMON_FORTIFY.sqf";
		call compile preprocessFileLineNumbers "scripts\UPSMON\MODULES\UPSMON_MOVEMENT.sqf";
		call compile preprocessFileLineNumbers "scripts\UPSMON\MODULES\UPSMON_RESPAWN.sqf";
		call compile preprocessFileLineNumbers "scripts\UPSMON\MODULES\UPSMON_RENF.sqf";
		call compile preprocessFileLineNumbers "scripts\UPSMON\MODULES\UPSMON_ARTILLERYMOD.sqf";
		call compile preprocessFileLineNumbers "scripts\UPSMON\MODULES\UPSMON_ORDERS.sqf";
		
		[] execVM "scripts\UPSMON\UPSMON_MAINLOOP.sqf";
		If (UPSMON_DEBUG > 0) then {[] execvm "scripts\UPSMON\MODULES\UPSMON_TRACK.sqf";};
		
		//init SunAngle Functions
		call compile preprocessFileLineNumbers "scripts\SunAngle_fnc.sqf";
		
		// Init Mando function
		mando_check_los = compile (preprocessFileLineNumbers "scripts\mando_check_los.sqf");
		
		//scripts initialization
		UPSMON = compile preprocessFile "scripts\UPSMON.sqf";	
		//UPSMON_surrended = compile preprocessFile "scripts\UPSMON\MODULES\UPSMON_surrended.sqf";		
		
		// Example code below, not required in your mission
		fnc_createMarker = {
			private ["_pos","_m"];
			_pos = _this select 0;
			_m = createMarker [format["mPos%1%2",(floor(_pos select 0)),(floor(_pos select 1))],_pos];
			_m setmarkerColor (_this select 1);
			_m setMarkerShape "Icon";
			_m setMarkerType "mil_dot";
		};
		
		
		
	_UPSMON_Minesclassname = [] call UPSMON_getminesclass;
	UPSMON_Minestype1 = _UPSMON_Minesclassname select 0; // ATmines
	UPSMON_Minestype2 = _UPSMON_Minesclassname select 1; // APmines
	
		// declaración de variables privadas
		private["_obj","_trg","_l","_pos"];


	// Set KRON_fnc_setVehicleInit. Replaces setVehicleInit.  This is taken from MCC Controls Mission with permission from shay_gman
	// moved to functions definition file			
		
	// ***********************************************************************************************************	
	//									  MAIN UPSMON SERVER FUNCTION 
	// ***********************************************************************************************************	
		UPSMON_MAIN_server = 
		{		
			private["_obj","_trg","_l","_pos","_countWestSur","_countEastSur","_countResSur","_WestSur","_EastSur","_ResSur","_target","_targets","_targets0","_targets1","_targets2","_npc","_cycle"
				,"_side","_area","_knownpos","_sharedenemy","_enemyside","_timeout"];
			
			_cycle = 5; //Time to do a call to commander  // ToDo make server FPS agile
			_arti = objnull;
			_side = "";
			_range = 0;
			_rounds = 0;	
			_area = 0;	
			_maxcadence = 0;	
			_mincadence = 0;	
			_bullet = "";	
			_fire = false;
			_target = objnull;
			_knownpos =[0,0,0];
			_enemyside = [];

			_WestSur = UPSMON_WEST_SURRENDED;
			_EastSur = UPSMON_EAST_SURRENDED;
			_ResSur = UPSMON_GUER_SURRENDED;	
			
			
			//Main loop
			while {true} do 
			{	
				_Night = [] call UPSMON_SunAngle;
				UPSMON_Night = _Night;
				publicvariable "UPSMON_Night";
				
				_countWestSur = round ( UPSMON_West_Total * UPSMON_WEST_SURRENDER / 100);
				_countEastSur = round ( UPSMON_East_Total * UPSMON_EAST_SURRENDER / 100);
				_countResSur = round ( UPSMON_Guer_Total * UPSMON_GUER_SURRENDER / 100);
				
				

				if (UPSMON_Debug>0) then { diag_log format ["UPSMON_NPCs: [%1]", UPSMON_NPCs]; };				
				
				
				//Target debug console
				if (UPSMON_Debug>0) then {hintsilent parseText format["%1<br/>--------------------------<br/><t color='#33CC00'>West(A=%2 C=%3 T=%4)</t><br/><t color='#FF0000'>East(A=%5 C=%6 T=%7)</t><br/><t color='#00CCFF'>Res(A=%8 C=%9 T=%10)</t><br/>"
					,UPSMON_Version
					,UPSMON_West_Total, count UPSMON_AllWest, count UPSMON_targets0
					,UPSMON_East_Total, count UPSMON_AllEast, count UPSMON_targets1
					,UPSMON_Guer_Total, count UPSMON_AllRes, count UPSMON_targets2					]}; 	
				sleep 0.02;
				
				//diag_log format ["UPSMON_Arti: [%1]", UPSMON_ARTILLERY_WEST_UNITS];
				
				sleep _cycle;			
			};
		};	
	};
	
	
// ***********************************************************************************************************	
//									  INITIALIZATION  OF UPSMON
// ***********************************************************************************************************		
	
	_l = allunits + vehicles;
	{
		if ((_x iskindof "AllVehicles") && (side _x != civilian)) then 
		{
			_s = side _x;
			switch (_s) do {
				case west: 
					{ UPSMON_AllWest=UPSMON_AllWest+[_x]; };
				case east: 
					{ UPSMON_AllEast=UPSMON_AllEast+[_x]; };
				case resistance: 
					{ UPSMON_AllRes=UPSMON_AllRes+[_x]; };
			};
		};
	} forEach _l;
	_l = nil;

	if (isNil("UPSMON_Debug")) then {UPSMON_Debug=0};

	UPSMON_East_enemies = UPSMON_AllWest;
	UPSMON_West_enemies = UPSMON_AllEast;
	
	// ToDo rewrite based on getFriend relationship
	if (east in UPSMON_Res_enemy ) then {	
		UPSMON_East_enemies = UPSMON_East_enemies+UPSMON_AllRes;
		UPSMON_Guer_enemies = UPSMON_AllEast;
	} else {
		UPSMON_East_friends = UPSMON_East_friends+UPSMON_AllRes;
		UPSMON_Guer_friends = UPSMON_AllEast;
	}; 
		
	if (west in UPSMON_Res_enemy ) then {
		UPSMON_West_enemies = UPSMON_West_enemies+UPSMON_AllRes;
		UPSMON_Guer_enemies = UPSMON_Guer_enemies+UPSMON_AllWest;
	} else {
		UPSMON_West_friends = UPSMON_West_friends+UPSMON_AllRes;
		UPSMON_Guer_friends = UPSMON_Guer_friends+UPSMON_AllWest;
	};

	UPSMON_West_Total = count UPSMON_AllWest;		
	UPSMON_East_Total = count UPSMON_AllEast;
	UPSMON_Guer_Total = count UPSMON_AllRes;		
	
	//Initialization done
	UPSMON_INIT=1;	

	
	//killciv EH
	_l = allunits;
	{
		if (side _x == civilian) then // ToDo verify what's the use..?
		{						
			_x AddEventHandler ["firedNear", {nul = _this spawn UPSMON_SN_EHFIREDNEAR}];
			sleep 0.01;					

			_x AddEventHandler ["killed", {nul = _this spawn UPSMON_SN_EHKILLEDCIV}];
			sleep 0.01;					
		};
	} forEach _l;
	_l = nil;
	
	
// ---------------------------------------------------------------------------------------------------------

//Executes de main process of server
[] SPAWN UPSMON_MAIN_server;

diag_log "--------------------------------";
diag_log (format["UPSMON INITIALIZED"]);
if(true) exitWith {};