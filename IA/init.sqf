// JIP Check (This code should be placed first line of init.sqf file)
if (!isServer && isNull player) then {isJIP=true;} else {isJIP=false;};
 
 // Wait until player is initialized
if (!isDedicated) then
{
	waitUntil {!isNull player && isPlayer player};
	sidePlayer = side player;
};


//--- set object , view , terrain
setViewDistance 2000;
setObjectViewDistance 2000;
setTerrainGrid 3.125;

#define WELCOME_MESSAGE	"Welcome to Invade & Annex ~ALTIS~\n" +\
                        "Edited By [dR]Hellstorm77\n\n" +\
						"And BL1P\n\n" +\
						"Check out our websites at:\n" +\
						"www.dedicatedrejects.com \n\n" +\
						"Feel free to join us on TeamSpeak at\n" +\
						"Voice.dedicatedrejects.com"



/* =============================================== */
/* =============== GLOBAL VARIABLES ============== */


private ["_pos","_uavAction","_isAdmin","_i","_isPerpetual","_accepted","_position","_randomWreck","_firstTarget","_validTarget","_targetsLeft","_flatPos","_targetStartText","_lastTarget","_targets","_dt","_enemiesArray","_enemiesArray2","_radioTowerDownText","_targetCompleteText","_null","_unitSpawnPlus","_unitSpawnMinus","_missionCompleteText","_SERVERUNITSCHECK","_debugCounter","_doneTargets","_Houses","_allowedTargetAmount"];

_handle = execVM "scripts\aw_functions.sqf";
waitUntil{scriptDone _handle};

///*
_initialTargets = [
	"Kalochori",
	"Sofia",
	"Feres",
	"Skopos",
	"Neri",
	"Factory",
	"Syrta",
	"Zaros",
	"Chalkeia",
	"Aristi",
	"Dump",
	"Outpost",
	"Frini",
	"Athira",
	"Swamp",
	"Rodopoli",
	"Charkia",
	"Alikampos",
	"Stavros",
	"Agios Dionysios",
	"Poliakko",
	"Paros",
	"Molos",
	"Game of Thronos",
	"The wind turbines",
	"Therisa",
	"Panochori",
	"The Stadium",
	"The Xirolimni Dam",
	"The small industrial complex",
	"Lakka military outpost",
	"Negades",
	"Abdera",
	"Millers Despair",
	"Chapel",
	"Krya Nera AIrfield",
	"Vikos Valley",
	"Feres Airfield",
	"Molos Airfield",
	"Moria",
	"Aktinarki Crossroads",
	"Power Plant"
];

_targets = [
	"Kalochori",
	"Sofia",
	"Feres",
	"Skopos",
	"Neri",
	"Factory",
	"Syrta",
	"Zaros",
	"Chalkeia",
	"Aristi",
	"Dump",
	"Outpost",
	"Frini",
	"Athira",
	"Swamp",
	"Rodopoli",
	"Charkia",
	"Alikampos",
	"Stavros",
	"Agios Dionysios",
	"Poliakko",
	"Paros",
	"Molos",
	"Game of Thronos",
	"The wind turbines",
	"Therisa",
	"Panochori",
	"The Stadium",
	"The Xirolimni Dam",
	"The small industrial complex",
	"Lakka military outpost",
	"Negades",
	"Abdera",
	"Millers Despair",
	"Chapel",
	"Krya Nera AIrfield",
	"Vikos Valley",
	"Feres Airfield",
	"Molos Airfield",
	"Moria",
	"Aktinarki Crossroads",
	"Power Plant"
];
//*/

//
/*
	// AOs for testing
	_initialTargets = [
		"Feres"
	];

	_targets = [
		"Feres"
	];
//
*/


//Grab parameters and put them into readable variables
for [ {_i = 0}, {_i < count(paramsArray)}, {_i = _i + 1} ] do
{
	call compile format
	[
		"PARAMS_%1 = %2",
		(configName ((missionConfigFile >> "Params") select _i)),
		(paramsArray select _i)
	];
};

if(isMultiplayer) then
	{
		if(PARAMS_DebugMode == 1) then {DEBUG = true} else {DEBUG = false};
		//if(PARAMS_DebugMode2 == 1) then {DEBUG2 = true} else {DEBUG2 = false};
	} else {DEBUG = true};

	if(DEBUG) then
		{
			diag_log format ["I am in the MAIN GLOBAL section of the init.sqf params are read and debug = %1",DEBUG];
		};

// Disable saving to save time
enableSaving [false, false];

"GlobalHint" addPublicVariableEventHandler
	{
		private ["_GHint"];
		_GHint = _this select 1;
		hint parseText format["%1", _GHint];
	};

"runOnServer" addPublicVariableEventHandler
	{
		if (isServer) then
		{
			private ["_codeToRun"];
			_codeToRun = _this select 1;
			call _codeToRun;
		};
	};

"radioTower" addPublicVariableEventHandler
	{
		"radioMarker" setMarkerPosLocal (markerPos "radioMarker");
		"radioMarker" setMarkerTextLocal (markerText "radioMarker");
		"radioMarker" SetMarkerAlpha 0;
	};

"refreshMarkers" addPublicVariableEventHandler
	{
		{
			_x setMarkerShapeLocal (markerShape _x);
			_x setMarkerSizeLocal (markerSize _x);
			_x setMarkerBrushLocal (markerBrush _x);
			_x setMarkerColorLocal (markerColor _x);
		} forEach _targets;

		{
			_x setMarkerPosLocal (markerPos _x);
			_x setMarkerTextLocal (markerText _x);
		} forEach ["aoMarker","aoCircle"];
		//-- bl1p
		"aoCircle" SetMarkerAlpha 0;
		"aoMarker" SetMarkerAlpha 0;
		
		//--- DEFEND MARKERS
		{
			_x setMarkerPosLocal (markerPos _x);
			_x setMarkerTextLocal (markerText _x);
		} forEach ["aoMarker_2","aoCircle_2"];
		//-- bl1p
		"aoCircle_2" SetMarkerAlpha 0;
		"aoMarker_2" SetMarkerAlpha 0;
	};

"showNotification" addPublicVariableEventHandler
	{
		private ["_type", "_message"];
		_array = _this select 1;
		_type = _array select 0;
		_message = "";
		if (count _array > 1) then { _message = _array select 1; };
		[_type, [_message]] call bis_fnc_showNotification;
	};

"showSingleNotification" addPublicVariableEventHandler
	{
		/* Slam somethin' 'ere */
	};


"priorityMarker" addPublicVariableEventHandler
	{
		"priorityMarker" setMarkerPosLocal (markerPos "priorityMarker");
		"priorityCircle" setMarkerPosLocal (markerPos "priorityCircle");
		"priorityMarker" setMarkerTextLocal format["Priority Target: %1",priorityTargetText];
	};

"aw_addAction" addPublicVariableEventHandler
	{
		_obj = (_this select 1) select 0;
		_actionArray = [(_this select 1) select 1, (_this select 1) select 2];
		_obj addAction _actionArray;
	};

"aw_removeAction" addPublicVariableEventHandler
	{
		_obj = (_this select 1) select 0;
		_id = (_this select 1) select 1;
		_obj removeAction _id;
	};

"aw_unitSay" addPublicVariableEventHandler
	{
		_obj = (_this select 1) select 0;
		_sound = (_this select 1) select 1;
		_obj say [_sound,15];
	};

"hqSideChat" addPublicVariableEventHandler
	{
		_message = _this select 1;
		[WEST,"HQ"] sideChat _message;
	};

"debugMessage" addPublicVariableEventHandler
	{
		private ["_isAdmin", "_message"];
		_isAdmin = serverCommandAvailable "#kick";
		if (_isAdmin) then
		{
			if (debugMode) then
			{
				_message = _this select 1;
				[_message] call bis_fnc_error;
			};
		};
	};




/* ========================================================== */
/* ========================================================== */
/* =========== THE_PLAYER_AND_SERVER_INITIALISATION ========= */
/* ========================================================== */
/* ========================================================== */

//--- bl1p onplayer connected thingy
//onPlayerConnected {diag_log [_id, _uid, _name]};
//onPlayerConnected "[_id, _name] execVM ""PlayerConnected.sqf""";
//["PlayerConnectEH", "onPlayerConnected", { diag_log format ["playerconnect: %1 %2", _id, _name]; }] call BIS_fnc_addStackedEventHandler;

//--- Fluit's functions!!
	_fluitFunctions = [] execVM "core\Fluit\FluitInit.sqf"; 
	waitUntil {scriptDone _fluitFunctions};
	
	//--- simulates gforce on players not wearing correct pilot clothes in planes
	[] spawn handle_gforce;

//--- stop shooting at base
if (PARAMS_SpawnProtection == 1) then { _null = [] execVM "scripts\grenadeStop.sqf"; };

//--- players names on map
if (PARAMS_PlayerMarkers == 1) then { _null = [] execVM "misc\playerMarkers.sqf"; };

//Set time of day
//	if (PARAMS_TimeOfDay == 25) then 
//		{
//			_randTime = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23] call BIS_fnc_selectRandom; 
//			skipTime _randTime;
//			if(DEBUG) then
//			{
//			diag_log format ["_randTime = %1",_randTime]
//			};
//		}
//	else
//	{
//		skipTime PARAMS_TimeOfDay;
//	};


// report weather if debug
// removed because of none sync
if(DEBUG) then
		{
			diag_log "I am in the player and server section of the init.sqf";
		};

//---!!!! Fluit N bl1p The Imortal Gods of The Universe and beyond !!!!!!!
//  small script for debug to make imortal
	if(DEBUG) then
	{
		{
		   if (side _x == WEST) then {
			   _x allowDamage false;
		   };
		} forEach allunits;
	};


//--- Outro by EightySix fucked up by BL1P.
	mps_outro_camera		= compile preprocessFileLineNumbers ("core\func\mps_func_outro_camera.sqf");
	mps_new_position		= compile preprocessFileLineNumbers ("core\func\mps_func_new_position.sqf");
	mps_outro			= compile preprocessFileLineNumbers ("core\func\mps_func_outro_sequence.sqf");

	[] call mps_outro;


// Check if player is a dR member or friend ran by player and server
	_handle3 = execVM "core\dR_N_Friends.sqf";
	waitUntil{scriptDone _handle3};

// weather script
//	execVM "misc\randomWeather.sqf";

//--- score loop thing
//	execVM "core\scoreloop.sqf";

// group manager
	0 = [] execVM 'DOM_squad\group_manager.sqf';
	[] execVM "DOM_squad\init.sqf";
	
//--- fluit player placed markers
	//[] spawn format_markers;

//--- bl1p Determine which machine is running this init script from bennys cti
	DR_IsHostedServer = if (isServer && !isDedicated) then {true} else {false};
	DR_IsServer = if (isDedicated || DR_IsHostedServer) then {true} else {false};
	DR_IsClient = if ((DR_IsHostedServer || !isDedicated) && (hasInterface)) then {true} else {false};
	DR_IsHeadless = if !(hasInterface || isDedicated) then {true} else {false};

	if(DEBUG) then
		{
			diag_log format ["DR_IsHostedServer = %1",DR_IsHostedServer];
			diag_log format ["DR_IsServer = %1",DR_IsServer];
			diag_log format ["DR_IsClient = %1",DR_IsClient];
			diag_log format ["DR_IsHeadless = %1",DR_IsHeadless];
		};
	
/* =============================================== */
/* =============================================== */
/* =========== THE_PLAYER_INITIALISATION ========= */
/* =============================================== */
/* =============================================== */

if (DR_IsClient) exitwith
	{
		execVm "Client\Init_Client.sqf";
	};

/* ============================================================ */
/* ============================================================ */
/* ============ SERVER INITIALISATION ============ */
/* ============================================================ */
/* ============================================================ */



if(DEBUG) then
		{
			diag_log "I am in the SERVER init.sqf";
		};

if (PARAMS_DEP > 0) then {        
    _dep = [PARAMS_DEP, 500, [getMarkerPos "respawn_west"]] call DynamicEnemyPopulation;
};
		
//--- bl1p read the defend function
		execVm "core\bl1p_fnc_defend.sqf";
		
// Body removal script by celery
	[300,900,900,900] execVM "scripts\bodyRemoval.sqf";


	//Init UPSMON script 
		//call compile preprocessFileLineNumbers "scripts\Init_UPSMON.sqf";


//--- bl1p supresion thing

if (PARAMS_AISUPPRESSION == 1) then
	{
		null = [3] execvm "tpwcas\tpwcas_script_init.sqf";
	};

//--- bl1p server only	
	
	//Set a few blank variables for event handlers and solid vars for SM
		debugMode = true; publicVariable "debugMode";
		eastSide = createCenter EAST;
		radioTowerAlive = false;publicVariable "radioTowerAlive";
		AOAICREATIONMAINDONE = false;publicVariable "AOAICREATIONMAINDONE";
		ConvoyAlive = false; publicvariable "ConvoyAlive";
		sideMissionUp = false;
		priorityTargetUp = false;
		currentAOUp = false;
		refreshMarkers = true;
		sideObj = objNull;
		priorityTargets = ["None"];
		UnlockAssets = true;publicvariable "UnlockAssets";
		NUKEYES = false;publicVariable "NUKEYES";
		LASTNUKE = 0; publicVariable "LASTNUKE";
		LASTDEFEND = 0; publicVariable "LASTDEFEND";
	
	//////////////////////////
	//--- bl1p run remloc TEST
	// execVM "core\BL1P_FUNC_REMLOC.sqf";
	
	//--- bl1p stats set variables
		execVM "core\stats.sqf";
	
	//Run a few miscellaneous server-side scripts
		_null = [] execVM "misc\clearBodies.sqf";
		_null = [] execVM "misc\clearItems.sqf";


	// is it perpetual ?
		_isPerpetual = false;

		if (PARAMS_Perpetual == 1) then
		{
			_isPerpetual = true;
			AOENDCOUNT = 0;
			publicvariable "AOENDCOUNT";
		};

		currentAO = "Nothing";
		publicVariable "currentAO";
		_lastTarget = "Nothing";
		_targetsLeft = count _targets;

	"TakeMarker" addPublicVariableEventHandler
		{
			createMarker [((_this select 1) select 0), getMarkerPos ((_this select 1) select 1)];
			"theTakeMarker" setMarkerShape "ICON";
			"theTakeMarker" setMarkerType "o_unknown";
			"theTakeMarker" setMarkerColor "ColorOPFOR";
			"theTakeMarker" setMarkerText format["Take %1", ((_this select 1) select 1)];
		};

	"addToScore" addPublicVariableEventHandler
		{
			((_this select 1) select 0) addScore ((_this select 1) select 1);
		};

	// bl1p wtf does this do ?
		_unitSpawnPlus = PARAMS_AOSize;
		_unitSpawnMinus = _unitSpawnPlus - (_unitSpawnPlus * 2);
		
	if (DR_IsServer) then 
	{ 
		"addToScore" addPublicVariableEventHandler 
		{ 
			((_this select 1) select 0) addScore ((_this select 1) select 1); 
		}; 
	};



//--- bl1p moved ao unit creation into seperate script

	_handle2 = execVM "core\Create_Units.sqf";
	waitUntil{scriptDone _handle2};


// create some random aa opsitions

	_null = [] execVM "core\AAPosCreation.sqf";

	


	_firstTarget = true;
	_lastTarget = "Nothing";


while {count _targets > PARAMS_AOENDCOUNT} do
{
	sleep 10;
	
	//--- bl1p server only	

		//Set new current target and calculate targets left
		if (_isPerpetual) then
		{
			_validTarget = false;
			while {!_validTarget} do
			{
				currentAO = _targets call BIS_fnc_selectRandom;
				if (currentAO != _lastTarget) then
				{
					_validTarget = true;
				};
				if (DEBUG) then
				{
				diag_log format["_validTarget = %1; %2 was our last target.",_validTarget,currentAO];
				};
				sleep 5;
			};
		} else {
		
			currentAO = _targets call BIS_fnc_selectRandom;
			_targetsLeft = count _targets;
			
			if (DEBUG) then
				{
				diag_log format["====================   currentAO = %1  ====================",currentAO];
				};
		};

		//Set currentAO for UAVs and JIP updates
		publicVariable "currentAO";
		currentAOUp = true;
		publicVariable "currentAOUp";

		//Edit and place markers for new target
		//_marker = [currentAO] call AW_fnc_markerActivate
		{_x setMarkerPos (getMarkerPos currentAO);} forEach ["aoCircle","aoMarker"];
		"aoMarker" setMarkerText format["Take %1",currentAO];
		"aoMarker" SetMarkerAlpha 0;
	
		sleep 5;
		publicVariable "refreshMarkers";
	
	
		//Create AO detection trigger IF ONE DOESNT ALREADY EXIST
	
		dt = createTrigger ["EmptyDetector", getMarkerPos currentAO];
		dt setTriggerArea [PARAMS_AOSize, PARAMS_AOSize, 0, false];
		dt setTriggerActivation ["EAST", "PRESENT", false];
		dt setTriggerStatements ["this","",""];
		publicvariable "dt";

	
	upsmon_enabled = true; publicVariable "upsmon_enabled";
	call compile preprocessFileLineNumbers "scripts\Init_UPSMON.sqf";
	
	//--- bl1p Spawn AI on Server

	_enemiesArray = [currentAO] call AW_fnc_spawnUnits;

	
	//--- bl1p server only	
	
		if (DEBUG) then {diag_log "MAKING A TOWER ON SERVER";};
		//Spawn radiotower
		_position = [[[getMarkerPos currentAO, PARAMS_AOSize],dt],["water","out"]] call BIS_fnc_randomPos;
		_flatPos = _position isFlatEmpty[3, 1, 0.7, 20, 0, false];
		
		
		_debugCounter = 1;
		while {(count _flatPos) < 1} do
		{
			//if (DEBUG) then { diag_log format["Finding position in INIT script For radio tower.Attempt #%1",_debugCounter]; };
			_debugCounter = _debugCounter + 1;
			_position = [[[getMarkerPos currentAO, PARAMS_AOSize],dt],["water","out"]] call BIS_fnc_randomPos;
			_flatPos = _position isFlatEmpty[3, 1, 0.7, 20, 0, false];
			sleep 1;
		};
		
		// --- make the tower NOT a light houise because fluit said thats stupid !!!
		radioTower = "Land_TTowerBig_2_F" createVehicle _flatPos;
		
			waitUntil {sleep 0.5; alive radioTower};
			radioTower setVectorUp [0,0,1];
			radioTowerAlive = true;
			publicVariable "radioTowerAlive";
			
			"radioMarker" SetMarkerAlpha 0;
			"radioMarker" setMarkerPos (getPos radioTower);
			
			//Tower EH for sachels
			_tower = radioTower;
			_tower addEventHandler 
			["HandleDamage", 
				{if ((_this select 4) == "SatchelCharge_Remote_Ammo") then 
					[
						{
							_this select 2;
							[] spawn {sleep 1;radioTower setdamage 1};
							[] spawn {sleep 10;deleteVehicle radioTower;};
						},{0}
					]; 
				}
			]; 
			
		publicVariable "radioTower";

	
	//--- bl1p radio tower check 
	if (DEBUG) then {diag_log format ["Waiting for Radio tower and radioTowerAlive = %1",radioTowerAlive];};
	waitUntil {sleep 0.5; radioTowerAlive};
		//--- bl1p spawn tower defenders
		
		_enemiesArray2 = [radioTower] call BL_fnc_towerDefence;

	if (DEBUG) then {diag_log format ["Radio tower should be up now radioTowerAlive = %1",radioTowerAlive];};
	
	//--- bl1p server only	
	
		if (DEBUG) then 
			{
			diag_log format ["=========AOAICREATIONMAINDONE = %1 ==========",AOAICREATIONMAINDONE];
			};
		
			"aoMarker" SetMarkerAlpha 1;
			"radioMarker" SetMarkerAlpha 0;
				
		
		//Set target start text
		_targetStartText = format
		[
			"<t align='center' size='2.2'>New Target</t><br/><t size='1.5' align='center' color='#FFCF11'>%1</t><br/>____________________<br/>Get yourselves over to %1 and take 'em all down!<br/><br/><t size='1.5' align='center' color='#FFCF11'>Take down that radio tower so the enemy cannot call in reinforcements!</t>",
			currentAO
		];

		if (!_isPerpetual) then
		{
			_targetStartText = format
			[
				"%1 Only %2 more targets to go for the OUTRO !!",
				_targetStartText,
				_targetsLeft - PARAMS_AOENDCOUNT
			];
		};

		//Show global target start hint
		GlobalHint = _targetStartText; publicVariable "GlobalHint"; hint parseText GlobalHint;
		showNotification = ["NewMain", currentAO]; publicVariable "showNotification";
		showNotification = ["NewSub", "Destroy the enemy radio tower."]; publicVariable "showNotification";

	
	
	//----bl1p create reinforments on Server

		if (PARAMS_HeavyReinforcement > 0) then { _null = [] execVM "Reinforcement\AOHeavyReinforce.sqf"; };
		if (PARAMS_AOReinforcement  > 0) then { _null = [] execVM "Reinforcement\AOReinforcement.sqf"; };
		if (PARAMS_ConvoyChance > 0) then { _null = [] execVM "Reinforcement\AOConvoy.sqf"; };

	
	/* =============================================== */
	/* ========= WAIT FOR TARGET COMPLETION ========== */
	/* =============================================== */
	
	if(DEBUG) then
			{
				diag_log "init.sqf waiting for target compleation";
				diag_log "waitUntil {sleep 5; count list dt > PARAMS_EnemyLeftThreshhold};";
				diag_log "waitUntil {sleep 0.5; !alive radioTower};";
			};

		//---bl1p Server wait
		waitUntil {sleep 5; count list dt > PARAMS_EnemyLeftThreshhold};
		waitUntil {sleep 0.5; !alive radioTower};
		
		//--- bl1p server only	

			radioTowerAlive = false;
			publicVariable "radioTowerAlive";
		
			"radioMarker" setMarkerPos [0,0,0];
			_radioTowerDownText =
				"<t align='center' size='2.2'>Radio Tower</t><br/><t size='1.5' color='#08b000' align='center'>DESTROYED</t><br/>____________________<br/>The enemy radio tower has been destroyed!<br/><br/><t size='1.2' color='#08b000' align='center'> The enemy cannot call in anymore support now!</t><br/><br/> Leaders can now use UAVs!";
			GlobalHint = _radioTowerDownText; publicVariable "GlobalHint"; hint parseText GlobalHint;
			showNotification = ["CompletedSub", "Enemy radio tower destroyed."]; publicVariable "showNotification";
			showNotification = ["Reward", "Personal UAVs now available."]; publicVariable "showNotification";

				
		//---bl1p Server wait
		waitUntil {sleep 5; count list dt < PARAMS_EnemyLeftThreshhold};
	
		//--- bl1p unlock assets
		UnlockAssets = true;
		publicvariable "UnlockAssets";
	
	//---bl1p server only		

		if (_isPerpetual) then
		{
			_lastTarget = currentAO;
			if ((count (_targets)) == 1) then
			{
				_targets = _initialTargets;
			} else {
				_targets = _targets - [currentAO];
			};
		} else {
			_targets = _targets - [currentAO];
		};

		publicVariable "refreshMarkers";
		currentAOUp = false;
		publicVariable "currentAOUp";

		//Small sleep to let deletions process
		sleep 5;

		//Set target completion text
		_targetCompleteText = format
		[
			"<t align='center' size='2.2'>Target Taken</t><br/><t size='1.5' align='center' color='#FFCF11'>%1</t><br/>____________________<br/><t align='left'>Please wait for next target.</t>",
			currentAO
		];

		{_x setMarkerPos [0,0,0];} forEach ["aoCircle","aoMarker"];

		//Show global target completion hint
		GlobalHint = _targetCompleteText; publicVariable "GlobalHint"; hint parseText GlobalHint;
		showNotification = ["CompletedMain", currentAO]; publicVariable "showNotification";
		"aoCircle" SetMarkerAlpha 0;
		AOAICREATIONMAINDONE = false;publicVariable "AOAICREATIONMAINDONE";
	
		//Delete detection trigger and markers on Server
			deleteVehicle dt;
			sleep 1;

	
	//--- bl1p Server clean up units left over before next AO call
		if(DEBUG) then
				{
					diag_log "===============STARTING CLEAN UP=====================";
				};
		
		upsmon_enabled = false; publicVariable "upsmon_enabled"; // Disable UPSMON
		
		//FIRST check of groups Before cleaning
		_Eastgroups=[];
		{
			if ((count units _x>0 and side _x==east) && (!isNull _x)) then 
				{
				_Eastgroups=_Eastgroups+[_x];
				};
		} forEach allGroups;
		
			if (DEBUG) then
				{
					diag_log format ["====FIRST CHECK OF _Eastgroups=%1====",_Eastgroups];
				};
		
		[] spawn aw_cleanGroups;
		sleep 2;
		
		// clean up arrays by fluit and bl1p
		_arraystocleanup = [];
		if ((!isnil ("_enemiesArray")) && (count _enemiesArray > 0)) then {
			if (DEBUG) then
			{
			diag_log format ["_enemiesArray = %1",_enemiesArray];
			};
			_arraystocleanup set [count _arraystocleanup, _enemiesArray]; 
		};
		if ((!isnil ("_enemiesArray2")) && (count _enemiesArray2 > 0)) then {
			if (DEBUG) then
			{
			diag_log format ["_enemiesArray2 = %1",_enemiesArray2];
			};
			_arraystocleanup set [count _arraystocleanup, _enemiesArray2]; 
		};
		if ((!isnil ("ReinforcementUnits")) && (count ReinforcementUnits > 0))  then {
			if (DEBUG) then
			{
			diag_log format ["ReinforcementUnits = %1",ReinforcementUnits];
			};
			_arraystocleanup set [count _arraystocleanup, ReinforcementUnits]; 
		};
		if ((!isnil ("ReinforcementVehicles")) && (count ReinforcementVehicles > 0)) then {
			if (DEBUG) then
			{
			diag_log format ["ReinforcementVehicles = %1",ReinforcementVehicles];
			};
			_arraystocleanup set [count _arraystocleanup, ReinforcementVehicles]; 
		};
		if ((!isnil ("HeavyReinforcementUnits")) && (count HeavyReinforcementUnits > 0)) then {
			if (DEBUG) then
			{
			diag_log format ["HeavyReinforcementUnits = %1",HeavyReinforcementUnits];
			};
			_arraystocleanup set [count _arraystocleanup, HeavyReinforcementUnits]; 
		};
		if ((!isnil ("HeavyReVehicles")) && (count HeavyReVehicles > 0)) then {
			if (DEBUG) then
			{
			diag_log format ["HeavyReVehicles = %1",HeavyReVehicles];
			};
			_arraystocleanup set [count _arraystocleanup, HeavyReVehicles]; 
		};
		if ((!isnil ("ConvoyUnits")) && (count ConvoyUnits > 0)) then {
			if (DEBUG) then
			{
			diag_log format ["ConvoyUnits = %1",ConvoyUnits];
			};
			_arraystocleanup set [count _arraystocleanup, ConvoyUnits]; 
		};
		if ((!isnil ("ConvoyVehicles")) && (count ConvoyVehicles > 0)) then {
			if (DEBUG) then
			{
			diag_log format ["ConvoyVehicles = %1",ConvoyVehicles];
			};
			_arraystocleanup set [count _arraystocleanup, ConvoyVehicles]; 
		};
		sleep 0.5;
		if (DEBUG) then
				{
				diag_log "===========FINAL ARRAYS TO CLEAN UP================";
				diag_log format ["_arraystocleanup = %1",_arraystocleanup];
				diag_log format ["count of elements in _arraystocleanup = %1",count _arraystocleanup];
				};
		
		_handleAOclean = [_arraystocleanup] execVM "core\AOCleanup.sqf";
		waitUntil{scriptDone _handleAOclean};
		
		//--- bl1p loop and check groups and remove null groups from array to check
		_finalArraysdebugcount = 0;
		while {count _Eastgroups > 0} do
		{
			_finalArraysdebugcount = _finalArraysdebugcount + 1;
			if (_finalArraysdebugcount > 10) exitwith {diag_log format ["_finalArraysdebugcount =%1 exiting loop ",_finalArraysdebugcount];};
			//second check of groups after cleaning
				_Eastgroups=[];
				{
					if ((count units _x>0 and side _x==east) && (!isNull _x)) then 
						{
						_Eastgroups=_Eastgroups+[_x];
						};
				} forEach allGroups;
				
					if (DEBUG) then
						{
							diag_log format ["====LOOPED CHECK OF _Eastgroups=%1====",_Eastgroups];
						};
			//second check of groups after cleaning			
			if (DEBUG) then 
				{
					diag_log format["====waiting for array to clear attempt #%1====",_finalArraysdebugcount];
					//diag_log format ["INIT.SQF --==-- _Eastgroups = %1",_Eastgroups];
				};
			sleep 5;
		};
		
		
		//--- wait until all east units are cleaned up (if 2 mins has passed delete ALL east units as a fail safe)
		_SERVERUNITSCHECK = east countSide allunits;
			if (DEBUG) then 
			{
				diag_log format ["====_SERVERUNITSCHECK = %1====",_SERVERUNITSCHECK];
			};
		sleep 0.5;
		_DebugCountEnd = 0;
		while {_SERVERUNITSCHECK > 0} do
		{
			_DebugCountEnd = _DebugCountEnd + 1;
			_SERVERUNITSCHECK = east countSide allunits;
			sleep 1;
				if (_DebugCountEnd > 60) then 
					{
						{ if (side _x == east) then {_x setdamage 1;} } foreach allunits;
					};
			sleep 1;
				if (DEBUG) then 
					{
						diag_log format ["_SERVERUNITSCHECK = %1 _DebugCountEnd = %2",_SERVERUNITSCHECK,_DebugCountEnd];
					};
		};
		
		// DECLARE ALL FALSE FOR REINFORCEMENTS
		if (ConvoyAlive) then 
		{
			showNotification = ["CompletedSub", "Enemy Convoy Retreated when AO was captured."]; publicVariable "showNotification";
		};
		
	//////////////////////////////////////////////////
	//--- RUN INCREASING RANDOM TO CREATE DEFENED MISSION
	//////////////////////////////////////////////////
		_createDefend = random 1;
		if (DEBUG) then
			{
				diag_log "=========DEFENCE CHECKS START============";
				diag_log format ["BASE _createDefend = %1",_createDefend];
			};
			
		_doneTargetsForDefend = ((count (_initialTargets)) - (count (_targets)));
		if (_doneTargetsForDefend > LASTDEFEND) then {_createDefend = _createDefend + 0.02 * (_doneTargetsForDefend - LASTDEFEND);};
		if (DEBUG) then
			{
				diag_log format ["_doneTargetsForDefend = %1",_doneTargetsForDefend];
				diag_log format ["LASTDEFEND = %1",LASTDEFEND];
				diag_log format ["AFTER ALTERATION _createDefend = %1 (+ 0.02 for each _doneTargetsForDefend - LASTDEFEND)",_createDefend];
				if (_createDefend > 0.8) then
				{
					diag_log "_createDefend = Pass";
				} else {diag_log "_createDefend = Fail";};
				diag_log "=========DEFENCE CHECKS END============";
			};
		//if (DEBUG) then {diag_log format ["====_createDefend chance = %1 with >=0.8 to create====",_createDefend];};
		if (_createDefend >= 0.8) then   //-- random chance
		{
			RunninngDefenceAO = true;
			publicvariable "RunninngDefenceAO";
			[] call bl1p_fnc_defend;
			"aoCircle_2" SetMarkerAlpha 1;
			"aoMarker_2" SetMarkerAlpha 1;
			LASTDEFEND = _doneTargetsForDefend;
			publicVariable "LASTDEFEND";
			waituntil {sleep 1; !RunninngDefenceAO};
		};
	//////////////////////////////////////////////////
	//--- END DEFEND MISSION
	//////////////////////////////////////////////////
	
	//////////////////////////////////////////////////
	//--- RUN CHECKS FOR NUKE MISSION
	//////////////////////////////////////////////////
		
		//--- bl1p count how many AOs have been done
		_doneTargets = ((count (_initialTargets)) - (count (_targets)));
		if (DEBUG) then 
			{
				diag_log "=========NUKE CHECKS START============";
				diag_log format ["done targets = %1",_doneTargets];
				diag_log format ["LASTNUKE = %1",LASTNUKE];
				if (_doneTargets > LASTNUKE+5) then 
				{
					diag_log "(AO count = Pass)";
				} else {diag_log "(AO count = Fail)";};
			};
		sleep 0.2;
		
		//--- bl1p count how many players online
		players_online = West countSide allunits;
		publicVariable "players_online";
		if (DEBUG) then 
			{
				diag_log format ["players_online = %1",players_online];
			if (players_online >= 5) then
			{
				diag_log "players_online count = Pass";
			} else {diag_log "players_online count = Fail";};
			};
		sleep 0.2;
		
		//--- was last defend a fail 
		if (DEBUG) then
		{
			if (!UnlockAssets) then
				{
				diag_log "UnlockedAssets = Pass";
				} else {diag_log "UnlockedAssets = Fail";};
		};
		sleep 0.2;
		
		//--- bl1p create the INCREASING random chance for a nuke mission
		_NukeRandom = random 1; //--- base random
		if (DEBUG) then
			{
			diag_log format ["BASE _NukeRandom = %1",_NukeRandom];
			};
		if (_doneTargets > LASTNUKE) then {_NukeRandom = _NukeRandom + 0.02 * (_doneTargets - LASTNUKE);}; 
		if (DEBUG) then
			{
				diag_log format ["AFTER ALTERATION _NukeRandom = %1 (+ 0.02 for each _doneTargets - LASTNUKE)",_NukeRandom];
				if (_NukeRandom > 0.8) then
				{
					diag_log "_NukeRandom = Pass";
				} else {diag_log "_NukeRandom = Fail";};
			};
		//--- run check 
		if ((!NUKEYES) && (_doneTargets > LASTNUKE+5) && (players_online >= 5) && (!UnlockAssets) && (_NukeRandom > 0.8)) then 
		{
			diag_log "====----NUKE CHECKS PASSED----====";
			NUKEYES = true;
			publicVariable "NUKEYES";
			//--- save how many targets where done on last nuke creation as LASTNUKE
			LASTNUKE = _doneTargets;
			publicVariable "LASTNUKE";
			diag_log format ["LASTNUKE = %1",LASTNUKE];
		}else {NUKEYES = false; publicVariable "NUKEYES";diag_log "====----NUKE CHECKS FAILED----====";};
		
		if (DEBUG) then
		{
		diag_log format ["====----NUKEYES = %1----====",NUKEYES];
		diag_log "=========NUKE CHECKS END============";
		};
	//////////////////////////////////////////////////
	//--- END CHECKS FOR NUKE MISSION
	//////////////////////////////////////////////////

		
		//Hide priorityMarker
		"priorityMarker" setMarkerPos [0,0,0];
		"priorityCircle" setMarkerPos [0,0,0];
		//--- bl1p
		"priorityCircle" SetMarkerAlpha 0;
		"priorityMarker" SetMarkerAlpha 0;
		publicVariable "priorityMarker";
		
		ConvoyAlive = false;
		publicVariable "ConvoyAlive";
		
		ReinforcedPlane = false;
		publicVariable "ReinforcedPlane";

		ReinforcedTank = false;
		publicvariable "ReinforcedTank";
		
		Reinforced = false;
		publicVariable "Reinforced";
		
		[] spawn aw_cleanGroups;
		sleep 5;
		
		//--- bl1p stat collection report
		diag_log "=====================STATS=====================";
		diag_log format ["_doneTargets = %1 players_online = %2",_doneTargets,players_online];
		diag_log format ["TotalFullRevives = %1 TotalMedicalRevives = %2 TotalNormalRevives = %3",TotalFullRevives,TotalMedicalRevives,TotalNormalRevives];
		diag_log format ["Totalfriendlyfire = %1 TotalSuicides = %2 TotalDrags = %3",Totalfriendlyfire,TotalSuicides,TotalDrags];
		diag_log format ["TotalRespawns = %1",TotalRespawns];
		diag_log format ["Side Score = %1",scoreSide WEST];
};


if(DEBUG) then
			{
				diag_log "OUT OF WHILE LOOP FOR AO CREATION";	
			};
			
//--- bl1p server only	

		//Set completion text
		_missionCompleteText = "<t align='center' size='2.0'>Congratulations!</t><br/>
		<t size='1.2' align='center'>You've successfully completed BL1Ps edit of Ahoy World Invade &amp; Annex!</t><br/>
		____________________<br/>
		<br/>
		Thank you so much for playing and we at dR hope to see you in the future. For more and to aid in the development of this mission, please visit www.dedicatedrejects.com.<br/>
		<br/>
		The game will return to the mission screen in after this short outro. Thanks to Fluit, Flipped and HellStorm also to everyone else at dR who helped test this mission.";

		//Show global mission completion hint
		GlobalHint = _missionCompleteText;
		publicVariable "GlobalHint";
		hint parseText GlobalHint;

		mps_mission_finished = "true"; publicvariable "mps_mission_finished";

		//Wait 30 seconds
		sleep 30;

		//End mission
		endMission "END1";
