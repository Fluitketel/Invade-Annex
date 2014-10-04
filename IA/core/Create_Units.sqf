//===================================//
//==========Create Untis=============//
//===========BL1P EDIT===============//
//===================================//

if (DEBUG) then {diag_log "READING the Create_units.sqf";};

AW_fnc_spawnUnits = 
{
//===================================//
//==========Start create untis=======//
//===================================//
		waitUntil {!isNil "fluitfunctions"};

		if (DEBUG) then 
		{
		diag_log "=============AO AI CREATION ( AW_fnc_spawnUnits ) FUNC STARTED=============";
		diag_log format ["currentAO = %1",currentAO];
		};

		private ["_randomPos","_spawnGroup","_pos","_x","_armourGroup","_armour","_airGroup","_air","_airType","_randmort","_ExtOrCenterChance"];
		_pos = getMarkerPos (_this select 0);
		_enemiesArray = [grpNull];
		_houses = [];

		// check and remove this list of triggers
		if (!isNil ("_upsZone")) then {if (DEBUG) then {diag_log "_upsZone was not nil removing";};deleteVehicle _upsZone;}; 
		if (!isNil ("_upsZone2")) then {if (DEBUG) then {diag_log "_upsZone2 was not nil removing";};deleteVehicle _upsZone2;}; 
		if (!isNil ("_upsZone3")) then {if (DEBUG) then {diag_log "_upsZone3 was not nil removing";};deleteVehicle _upsZone3;}; 
		if (!isNil ("upsZoneDef")) then {if (DEBUG) then {diag_log "upsZoneDef was not nil removing";};deleteMarker upsZoneDef;};
		if (!isNil ("_upsZoneMid")) then {if (DEBUG) then {diag_log "_upsZoneMid was not nil removing";};deleteMarker _upsZoneMid;};
		if (!isNil ("_upsZoneExt")) then {if (DEBUG) then {diag_log "_upsZoneExt was not nil removing";};deleteMarker _upsZoneExt;};
		
		
		// reinf ups zone
		if (!isNil ("_upsZoneReinforce")) then {if (DEBUG) then {diag_log "_upsZoneReinforce was not nil removing";};deleteVehicle _upsZoneReinforce;}; 	

		// check and remove this list of mortars
		if (!isNil ("mortar1")) then {if (DEBUG) then {diag_log "mortar1 was not nil removing";};deleteVehicle mortar1;}; 
		if (!isNil ("mortar2")) then {if (DEBUG) then {diag_log "mortar2 was not nil removing";};deleteVehicle mortar2;}; 
		
		// check and remove this list of groups
		if (!isNil ("_spawnGroupSN")) then {if (DEBUG) then {diag_log "_spawnGroupSN was not nil removing";};deleteGroup _spawnGroupSN;};
		if (!isNil ("_spawnGroup")) then {if (DEBUG) then {diag_log "_spawnGroup was not nil removing";};deleteGroup _spawnGroup;};
		if (!isNil ("_spawnGroupSP")) then {if (DEBUG) then {diag_log "_spawnGroupSP was not nil removing";};deleteGroup _spawnGroupSP;};
		if (!isNil ("_spawnGroupSPX")) then {if (DEBUG) then {diag_log "_spawnGroupSPX was not nil removing";};deleteGroup _spawnGroupSPX;};
		if (!isNil ("_spawngroupcar")) then {if (DEBUG) then {diag_log "_spawnGroupcar was not nil removing";};deleteGroup _spawngroupcar;};
		if (!isNil ("_armourGroup")) then {if (DEBUG) then {diag_log "_armourGroup was not nil removing";};deleteGroup _armourGroup;};
		if (!isNil ("_airGroup")) then {if (DEBUG) then {diag_log "_airGroup was not nil removing";};deleteGroup _airGroup;};

	//--- bl1p house count within 150meters	
		{
			_Houses = _Houses + [_x];
		} forEach (getMarkerPos currentAO nearObjects ["House", 150]);
			//if (DEBUG) then {diag_log format ["=======_Houses = %1=========",_Houses];};
			Houses = false;
			if (count _Houses > 10) then {Houses = true;};	
			if (DEBUG) then {diag_log format ["=========House count = %1 Houses = %2=========",count _Houses,Houses];};
			
//////////////////////////////////////////////////////// CAMPS START ////////////////////////////////////////////////////////

campArray = []; publicVariable "campArray";
_numberofcamps = PARAMS_RAMCamps;
if (PARAMS_RAMCamps < 0)  then {
    _numberofcamps = round (random 3);
};    
[_numberofcamps, 200, getMarkerPos currentAO, 400, [getMarkerPos "respawn_west"]] call random_camps;

//////////////////////////////////////////////////////// CAMPS END ////////////////////////////////////////////////////////


//////////////////////////////////////////////////////// ROADBLOCKS START ////////////////////////////////////////////////////////
if (PARAMS_Roadblocks == 1 && _numberofcamps <= 2) then {
	[round (random 2), 1000, getMarkerPos currentAO, 400 + round (random 400)] call defensive_roadblocks;
};
//////////////////////////////////////////////////////// ROADBLOCKS END ////////////////////////////////////////////////////////

//////////////////////////////////////////////////////// MORTAR START ////////////////////////////////////////////////////////			
	//-- define vars for mortars	
	Mortars = [];
	_randmort = random 10;
	Createmortars = false;
	if (random 10 <= PARAMS_MortarChance) then {
		Createmortars = true;
	};
	_interior = false;
	if (random 10 <= PARAMS_INOUTMortarChance) then {
		_interior = true;
	};

	if(DEBUG) then {
		if (Createmortars) then	{
			diag_log format ["==== CREATING MORTARS ==== _randmort = %1 PARAMS_MortarChance = %2",_randmort,PARAMS_MortarChance];
		} else {
			diag_log format ["==== NOT CREATING MORTARS ==== _randmort = %1 PARAMS_MortarChance = %2 ",_randmort,PARAMS_MortarChance];
		};
	};
	
	if (Createmortars) then {
		_radius = 1000;
		if (_interior) then {
			if(DEBUG) then { diag_log "========creating mortars INSIDE AO ===========";};
			_radius = 20 + round (random 40);
		} else {
			if(DEBUG) then { diag_log "========creating mortars OUTSIDE AO ===========";};
		};
		_camplocations = [1, getMarkerPos currentAO, _radius, ceil (random 3)] call random_mortar_camps;
		_enemiesArray = _enemiesArray + campArray;
	
		sleep 0.5;	
		// Spotters
		_x = 0;
		_rand = [2,3,4,5] call BIS_fnc_selectRandom;
		if (DEBUG) then {diag_log format ["=====Creating %1 MORTSPOT=====",_rand];};
		for "_x" from 1 to _rand do 
		{
			_randomPos = [getMarkerPos currentAO, 350,2] call aw_fnc_randomPos;
			if ((count _randomPos) == 3) then 
			{
				_spawnGroupSP = createGroup EAST;
				
				"O_officer_F" createUnit [_randomPos, _spawnGroupSP];
				
				(leader _spawnGroupSP) addWeapon "Rangefinder";
				(leader _spawnGroupSP) addItem "NVGoggles_OPFOR";
				(leader _spawnGroupSP) assignItem "NVGoggles_OPFOR";
				//(leader _spawnGroupSP) selectWeapon "Rangefinder";

				//[_spawnGroupSP, getMarkerPos currentAO,350] call aw_fnc_spawn2_randomPatrol;
				[_spawnGroupSP, getMarkerPos currentAO,375] call aw_fnc_spawn2_perimeterPatrol;
				
				// run mortar spotter if mortars are present
				if (count Mortars > 0) then 
				{
					[(leader _spawnGroupSP), Mortars] execVM "core\mortar_spotter.sqf";
				};
				[(units _spawnGroupSP)] call aw_setGroupSkill;
				sleep 1;
				if(DEBUG) then
				{
					_name = format ["%1%2",name (leader _spawnGroupSP),_x];
					createMarker [_name,getPos (leader _spawnGroupSP)];
					_name setMarkerType "o_unknown";
					_name setMarkerText format ["M Spotters %1",_x];
					_name setMarkerColor "ColorRed";
					[_spawnGroupSP,_name] spawn
					{
						private["_group","_marker"];
						_group = _this select 0;
						_marker = _this select 1;

						while{count (units _group) > 0} do
						{
							_marker setMarkerPos (getPos (leader _group));
							sleep 1;
						};
						deleteMarker _marker;
					};
				};

				_enemiesArray = _enemiesArray + [_spawnGroupSP];
			}
			else
			{
				diag_log "DID NOT CREATE SPOTTERS FAILED ON RAND POS";
			};
		};
	};
//////////////////////////////////////////////////////// MORTAR END ////////////////////////////////////////////////////////		
			
//////////////////////////////////////////////////////// SQPAT START ////////////////////////////////////////////////////////
		// squad patrol UPS
			_x = 0;
			if (DEBUG) then {diag_log format ["=====Creating %1 SQPAT UPS=====",PARAMS_SquadsPatrol];};
			for "_x" from 1 to PARAMS_SquadsPatrol do 
			{
				
				_randomPos = [getMarkerPos currentAO, PARAMS_AOSize,2] call aw_fnc_randomPos;
				if ((count _randomPos) == 3) then 
				{	
					
					_spawnGroup = createGroup EAST;
					_randomtype = random 12;
					if (_randomtype <=3) then 
						{
							[_randomPos,_spawnGroup] call urbanSquad1;
						};
					if ((_randomtype >3) && (_randomtype <=6)) then 
						{
							[_randomPos,_spawnGroup] call urbanSquad2;
						};
					if ((_randomtype >6) && (_randomtype <=9)) then 
						{
							[_randomPos,_spawnGroup] call OpSquad1;
						};
					if (_randomtype >9) then 
						{
							[_randomPos,_spawnGroup] call GurillaSquad;
						};
					
					//nul=[(leader _spawnGroup), "aoCircle","RANDOM"] execVm "scripts\UPSMON.sqf";
					sleep 0.5;
					//[(leader _spawnGroup), "aoCircle"] execVM "UPS_BL1P.sqf";
					[_spawnGroup, getMarkerPos currentAO, PARAMS_AOSize] call aw_fnc_spawn2_randomPatrol;
					sleep 0.5;
					[(leader _spawnGroup)] execVM "core\spotter.sqf";
					sleep 0.5;
					[(units _spawnGroup)] call aw_setGroupSkill;
					sleep 1;
					if(DEBUG) then
					{
						_name = format ["%1%2",name (leader _spawnGroup),_x];
						createMarker [_name,getPos (leader _spawnGroup)];
						_name setMarkerType "o_unknown";
						_name setMarkerText format ["Sq-Pat-UPS %1",_x];
						_name setMarkerColor "ColorRed";
						[_spawnGroup,_name] spawn
						{
							private["_group","_marker"];
							_group = _this select 0;
							_marker = _this select 1;

							while{count (units _group) > 0} do
							{
								_marker setMarkerPos (getPos (leader _group));
								sleep 1;
							};
							deleteMarker _marker;
						};
					};

					_enemiesArray = _enemiesArray + [_spawnGroup];
				}
				else
				{
					diag_log "====DID NOT CREATE SQPATUPS BECAUSE OF FAILED RANDOM POS====";
				};
			};
//////////////////////////////////////////////////////// SQPAT END ////////////////////////////////////////////////////////	

//////////////////////////////////////////////////////// DEFPAT START ////////////////////////////////////////////////////////		
		//--- Defence pat NONE UPS
			_x = 0;
			if (DEBUG) then {diag_log format ["=====Creating %1 DEFSQ=====",PARAMS_SquadsDefend];};
			for "_x" from 1 to PARAMS_SquadsDefend do {
				
				_randomPos = [getMarkerPos currentAO, 200,2] call aw_fnc_randomPos;
			if ((count _randomPos) == 3) then 
				{
					_spawnGroup = createGroup EAST;
					
					_randomtype = random 12;
					if (_randomtype <=3) then 
						{
							[_randomPos,_spawnGroup] call urbanSquad1;
						};
					if ((_randomtype >3) && (_randomtype <=6)) then 
						{
							[_randomPos,_spawnGroup] call urbanSquad2;
						};
					if ((_randomtype >6) && (_randomtype <=9)) then 
						{
							[_randomPos,_spawnGroup] call OpSquad1;
						};
					if (_randomtype >9) then 
						{
							[_randomPos,_spawnGroup] call GurillaSquad;
						};
					
					sleep 0.5;
					[_spawnGroup, getMarkerPos currentAO,75] call aw_fnc_spawn2_perimeterPatrol;
					sleep 0.5;
					[(leader _spawnGroup)] execVM "core\spotter.sqf";
					sleep 0.5;
					[(units _spawnGroup)] call aw_setGroupSkill;
					sleep 0.5;
					(leader _spawnGroup) setVariable ["asr_ai_exclude", true];
					
					if(DEBUG) then
					{
						_name = format ["%1%2",name (leader _spawnGroup),_x];
						createMarker [_name,getPos (leader _spawnGroup)];
						_name setMarkerType "o_unknown";
						_name setMarkerText format ["Def-Sq %1",_x];;
						_name setMarkerColor "ColorRed";
						[_spawnGroup,_name] spawn
						{
							private["_group","_marker"];
							_group = _this select 0;
							_marker = _this select 1;

							while{count (units _group) > 0} do
							{
								_marker setMarkerPos (getPos (leader _group));
								sleep 1;
							};
							deleteMarker _marker;
						};
					};

					_enemiesArray = _enemiesArray + [_spawnGroup];
				}
				else
				{
					diag_log "====DID NOT CREATE DEFSQ BECAUSE OF FAILED RANDOM POS====";
				};
			};
//////////////////////////////////////////////////////// DEFPAT END ////////////////////////////////////////////////////////
	
//////////////////////////////////////////////////////// MIDPAT START ////////////////////////////////////////////////////////
		// MID MidPatrol NONE UPS
			_x = 0;
			_amountHotel = PARAMS_MidPatrol;
			if (currentAO == "Bates Motel") then
				{
					_amountHotel = 4;
				}
				else
				{
					_amountHotel = PARAMS_MidPatrol;
				};
				
				if (DEBUG) then {diag_log format ["=====Creating %1 MIDPAT=====",PARAMS_MidPatrol];};
			for "_x" from 1 to _amountHotel do {
				_randomPos = [getMarkerPos currentAO, 450,2] call dR_fnc_randomPosbl1p;
				if ((count _randomPos) == 3) then 
				{
					_spawnGroup = createGroup EAST;
					//-- type chance
					_randomtype = random 12;
					if (_randomtype <=3) then 
						{
							[_randomPos,_spawnGroup] call urbanSquad1;
						};
					if ((_randomtype >3) && (_randomtype <=6)) then 
						{
							[_randomPos,_spawnGroup] call urbanSquad2;
						};
					if ((_randomtype >6) && (_randomtype <=9)) then 
						{
							[_randomPos,_spawnGroup] call OpSquad1;
						};
					if (_randomtype >9) then 
						{
							[_randomPos,_spawnGroup] call GurillaSquad;
						};
					// house chance
					if (currentAO == "Bates Motel") then
					{
						//--- bl1p it is hotel
						if (DEBUG) then {diag_log format ["HOTEL ===== being creating currentAO = %1",currentAO];};
						
						//_upsZoneMid = createTrigger ["EmptyDetector", getMarkerPos currentAO];
						//_upsZoneMid setTriggerArea [150, 150, 0, false];
							
							//nul=[(leader _spawnGroup), "HOTEL", "RANDOMA", "NOSHARE"] execVm "scripts\UPSMON.sqf";
						sleep 0.5;
						//[(leader _spawnGroup), _upsZoneMid] execVM "UPS_MID.sqf";
						[_spawnGroup, getMarkerPos currentAO, PARAMS_AOSize - 250] call aw_fnc_spawn2_randomPatrol;
						sleep 0.5;
						[(leader _spawnGroup)] execVM "core\spotter.sqf";
						sleep 0.5;
						[(units _spawnGroup)] call aw_setGroupSkill;
						sleep 0.5;
						
						if(DEBUG) then
						{
							_name = format ["%1%2",name (leader _spawnGroup),_x];
							createMarker [_name,getPos (leader _spawnGroup)];
							_name setMarkerType "o_unknown";
							_name setMarkerText format ["Mid-Pat %1",_x];;
							_name setMarkerColor "ColorRed";
							[_spawnGroup,_name] spawn
							{
								private["_group","_marker"];
								_group = _this select 0;
								_marker = _this select 1;

								while{count (units _group) > 0} do
								{
									_marker setMarkerPos (getPos (leader _group));
									sleep 1;
								};
								deleteMarker _marker;
							};
						};
					}
					else
					{
					//--- bl1p normal none hotel
						_HousesPercent = random 10;
						
						if ((Houses) && (_HousesPercent <= PARAMS_HousesPercent)) then 
						{
						if (DEBUG) then {diag_log format ["_HousesPercent = %1 PARAMS_HousesPercent = %2 :: Houses = %3",_HousesPercent,PARAMS_HousesPercent,Houses];};
						if (DEBUG) then {diag_log "=====Creating MIDPAT UPS=====";};
						
						//_upsZoneMid = createTrigger ["EmptyDetector", getMarkerPos currentAO];
						//_upsZoneMid setTriggerArea [150, 150, 0, false];
						
							//nul=[(leader _spawnGroup), "aoCircle", "RANDOMDN"] execVm "scripts\UPSMON.sqf";
							sleep 0.5;
							//[(leader _spawnGroup), _upsZoneMid] execVM "UPS_MID.sqf";
							[_spawnGroup, getMarkerPos currentAO, PARAMS_AOSize - 250] call aw_fnc_spawn2_randomPatrol;
							sleep 0.5;
							
						}
						else
						{
							if (DEBUG) then {diag_log "Spawning Mid on Patrol not houses not UPS"};
							sleep 0.5;
							[_spawnGroup, getMarkerPos currentAO,450] call aw_fnc_spawn2_perimeterPatrol;
						};
						
						[(leader _spawnGroup)] execVM "core\spotter.sqf";
						
						[(units _spawnGroup)] call aw_setGroupSkill;
						sleep 1;
						
						if(DEBUG) then
						{
							_name = format ["%1%2",name (leader _spawnGroup),_x];
							createMarker [_name,getPos (leader _spawnGroup)];
							_name setMarkerType "o_unknown";
							_name setMarkerText format ["Mid-Pat %1",_x];;
							_name setMarkerColor "ColorRed";
							[_spawnGroup,_name] spawn
							{
								private["_group","_marker"];
								_group = _this select 0;
								_marker = _this select 1;

								while{count (units _group) > 0} do
								{
									_marker setMarkerPos (getPos (leader _group));
									sleep 1;
								};
								deleteMarker _marker;
							};
						};
					};
					_enemiesArray = _enemiesArray + [_spawnGroup];
				}
				else
				{
					diag_log "====DID NOT CREATE MIDPAT BECAUSE OF FAILED RANDOM POS====";
				};
			};
//////////////////////////////////////////////////////// MIDPAT END ////////////////////////////////////////////////////////	

//////////////////////////////////////////////////////// EXTPAT START ////////////////////////////////////////////////////////		
		// External Squads OUTSIDE AO NONE UPS
			_randExtern = random 10;
			if (_randmort <= PARAMS_MortarChance) then 
			{
			_randExtern = 0.1;
			if (DEBUG) then {diag_log "====mortars = true so external groups = true====";};
			};
				if (DEBUG) then 
					{
						if (_randExtern <= PARAMS_ExternChance) then
							{
								diag_log format ["=========_randExtern = %1 I AM CREATING External UPS ==========",_randExtern];
							}
							else
							{
								diag_log format ["=====_randExtern = %1 I AM NOT CREATING External UPS =========",_randExtern];
							};
					};
			if ( _randExtern <= PARAMS_ExternChance) then	
				{
					_x = 0;
					_randamountSquad = [2,3,4] call BIS_fnc_selectRandom;
					if(DEBUG) then
						{
						diag_log format ["====_randamountSquad = %1 amount of extern squad====",_randamountSquad];
						};
						if (DEBUG) then {diag_log format ["=====Creating %1 EXTSQ UPS=====",_randamountSquad];};
					for "_x" from 1 to _randamountSquad do 
					{
						_randomPos = [getMarkerPos currentAO, PARAMS_AOSize+500,2] call dR_fnc_randomPosbl1p;
						if ((count _randomPos) == 3) then 
						{
							_randSquadMort = random 10;
							_spawnGroupSPX = createGroup EAST;
							if (_randSquadMort <= 6) then 
								{
									_randRecon = random 10;
									if (_randRecon <= 5) then 
									{
										"O_officer_F" createUnit [_randomPos, _spawnGroupSPX];
										"O_Soldier_GL_F" createUnit [_randomPos, _spawnGroupSPX];
										"O_Soldier_lite_F" createUnit [_randomPos, _spawnGroupSPX];
										"O_Soldier_GL_F" createUnit [_randomPos, _spawnGroupSPX];
										"O_Soldier_lite_F" createUnit [_randomPos, _spawnGroupSPX];
										"O_Soldier_GL_F" createUnit [_randomPos, _spawnGroupSPX];
									};
									
									if (_randRecon > 5) then 
									{
									if (DEBUG) then {diag_log "Creating recon exterior Mortar spotters";};
										"O_officer_F" createUnit [_randomPos, _spawnGroupSPX];
										"O_recon_exp_F" createUnit [_randomPos, _spawnGroupSPX];
										"O_recon_medic_F" createUnit [_randomPos, _spawnGroupSPX];
										"O_recon_LAT_F" createUnit [_randomPos, _spawnGroupSPX];
										"O_recon_M_F" createUnit [_randomPos, _spawnGroupSPX];
										"O_recon_F" createUnit [_randomPos, _spawnGroupSPX];
									};

									// run mortar spotter if both mortars are present
									if (count Mortars > 0) then 
									{
										[(leader _spawnGroupSPX), Mortars] execVM "core\mortar_spotter.sqf";
									};	
								};
							if (_randSquadMort > 6) then 
								{
								
									_randRecon = random 10;
									if (_randRecon <= 5) then 
									{
										"O_Soldier_SL_F" createUnit [_randomPos, _spawnGroupSPX];
										"O_Soldier_GL_F" createUnit [_randomPos, _spawnGroupSPX];
										"O_Soldier_lite_F" createUnit [_randomPos, _spawnGroupSPX];
										"O_Soldier_GL_F" createUnit [_randomPos, _spawnGroupSPX];
										"O_Soldier_lite_F" createUnit [_randomPos, _spawnGroupSPX];
										"O_Soldier_GL_F" createUnit [_randomPos, _spawnGroupSPX];
									};
									
									if (_randRecon > 5) then 
									{
									if (DEBUG) then {diag_log "Creating recon exterior NONE spotter dudes";};
										"O_officer_F" createUnit [_randomPos, _spawnGroupSPX];
										"O_recon_exp_F" createUnit [_randomPos, _spawnGroupSPX];
										"O_recon_medic_F" createUnit [_randomPos, _spawnGroupSPX];
										"O_recon_LAT_F" createUnit [_randomPos, _spawnGroupSPX];
										"O_recon_M_F" createUnit [_randomPos, _spawnGroupSPX];
										"O_recon_F" createUnit [_randomPos, _spawnGroupSPX];
									};
								};
							
							sleep 0.5;
							
							//_upsZoneExt = createTrigger ["EmptyDetector", getMarkerPos currentAO];
							//_upsZoneExt setTriggerArea [1000, 1000, 0, false];
							
							sleep 0.5;
							
							//[(leader _spawnGroupSPX), _upsZoneExt] execVM "UPS_EXT.sqf";
							[_spawnGroupSPX, getMarkerPos currentAO, PARAMS_AOSize + 300] call aw_fnc_spawn2_randomPatrol;
							
							
							sleep 0.5;
							[(units _spawnGroupSPX)] call aw_setGroupSkill;
							
							sleep 1;
							if(DEBUG) then
							{
								_name = format ["%1%2",name (leader _spawnGroupSPX),_x];
								createMarker [_name,getPos (leader _spawnGroupSPX)];
								_name setMarkerType "o_unknown";
								_name setMarkerText format ["Ext-T-Pat %1",_x];;
								_name setMarkerColor "ColorRed";
								[_spawnGroupSPX,_name] spawn
								{
									private["_group","_marker"];
									_group = _this select 0;
									_marker = _this select 1;

									while{count (units _group) > 0} do
									{
										_marker setMarkerPos (getPos (leader _group));
										sleep 1;
									};
									deleteMarker _marker;
								};
							};

							_enemiesArray = _enemiesArray + [_spawnGroupSPX];
						}
						else
						{
							diag_log "====DID NOT CREATE EXTPAT BECAUSE OF FAILED RANDOM POS====";
						};
					};
				};
//////////////////////////////////////////////////////// EXTPAT END ////////////////////////////////////////////////////////

//////////////////////////////////////////////////////// CARPAT START ////////////////////////////////////////////////////////
				
			// cars pat NONE UPS
			_randCar = random 10;
				if (DEBUG) then
				{
					if (_randCar <= PARAMS_CarsChance) then
					{
						diag_log format ["====I AM CREATING CARS ====_randCar = %1 ",_randCar];
					}
					else
					{
						diag_log format ["====I AM NOT CREATING CARS====_randCar = %1",_randCar];
					};
					
				};	
			if ( _randCar <= PARAMS_CarsChance) then
			{
				
				_x = 0;
				for "_x" from 1 to (round random PARAMS_CarsPatrol) do 
				{
					_spawngroupcar = createGroup east;
					_randomPos = [getMarkerPos currentAO, PARAMS_AOSize,6] call aw_fnc_randomPos;
					_roadpos = _randomPos;
					_list = _randomPos nearRoads 400;
					if (count _list > 0) then {
						_road = _list call BIS_fnc_selectRandom;
						_roadpos = getPos _road;
					};
					if ((count _roadpos) == 3) then 
					{
						_vehcar = [_roadpos,0,"O_APC_Wheeled_02_rcws_F",_spawngroupcar] call BIS_fnc_spawnVehicle;
						// wait untill alive
						//waitUntil {alive (leader _spawngroupcar)};
						_InOrOutChanceCar = random 10;
						if (_InOrOutChanceCar <= 3) then 
							{
							if (DEBUG) then
								{
									diag_log Format ["_InOrOutChanceCar = %1 :: CAR perim pat at PARAMS_AOSize / 1.1 ",_InOrOutChanceCar];
								};
								[_spawngroupcar,getMarkerPos currentAO,(PARAMS_AOSize)] call aw_fnc_spawn2_perimeterPatrol;
							};
						if (_InOrOutChanceCar > 3 && _InOrOutChanceCar <= 6) then 
							{
								if (DEBUG) then
								{
									diag_log Format ["_InOrOutChanceCar = %1 :: CAR perim pat at PARAMS_AOSize",_InOrOutChanceCar];
								};
								[_spawngroupcar,getMarkerPos currentAO,(PARAMS_AOSize+250)] call aw_fnc_spawn2_perimeterPatrol;
							};
						if (_InOrOutChanceCar > 6) then
							{
								if (DEBUG) then
								{
									diag_log Format ["_InOrOutChanceCar = %1 :: CAR perim pat at PARAMS_AOSize+200 ",_InOrOutChanceCar];
								};
								[_spawngroupcar,getMarkerPos currentAO,(PARAMS_AOSize+500)] call aw_fnc_spawn2_perimeterPatrol;
							};
							
						
						[_spawngroupcar, getMarkerPos currentAO, PARAMS_AOSize] call aw_fnc_spawn2_randomPatrol;
						(vehicle (leader _spawngroupcar)) spawn aw_fnc_fuelMonitor;
						[(units _spawngroupcar)] call aw_setGroupSkill;
						if !(isNil "dep_fnc_vehicledamage") then {
						[(_vehcar select 0)] spawn dep_fnc_vehicledamage;
						};

						sleep 1;
						if(DEBUG) then
						{
							_name = format ["%1%2",name (leader _spawngroupcar),_x];
							createMarker [_name,getPos (leader _spawngroupcar)];
							_name setMarkerType "o_unknown";
							_name setMarkerText format ["Car %1",_x];;
							_name setMarkerColor "ColorRed";
							[_spawngroupcar,_name] spawn
							{
								private["_group","_marker"];
								_group = _this select 0;
								_marker = _this select 1;

								while{count (units _group) > 0} do
								{
									_marker setMarkerPos (getPos (leader _group));
									sleep 1;
								};
								deleteMarker _marker;
							};
						};

						_enemiesArray = _enemiesArray + [_spawngroupcar];
					}
					else
					{
						diag_log "====DID NOT CREATE CARPAT BECAUSE OF FAILED RANDOM POS====";
					};
				};
			};
//////////////////////////////////////////////////////// CARPAT END ////////////////////////////////////////////////////////

//////////////////////////////////////////////////////// ARMOURPAT START ////////////////////////////////////////////////////////
		// armour pat NONE UPS
			_randarmour = random 10;
				if ( _randarmour <= PARAMS_ArmourChance) then
					{
						if (DEBUG) then
						{
						diag_log format ["====I AM CREATING ARMOUR====_randarmour = %1",_randarmour];
						};
					}
					else
					{
						if (DEBUG) then
						{
						diag_log format ["====I AM NOT CREATING ARMOUR====_randarmour = %1",_randarmour];
						};
					};
			if ( _randarmour <= PARAMS_ArmourChance) then
			{
				if (DEBUG) then {diag_log format ["Creating %1 Armour vehicles",PARAMS_ArmourPatrol];};
				for "_x" from 1 to (round random PARAMS_ArmourPatrol) do 
				{
					_armourGroup = createGroup east;
					_randomPos = [getMarkerPos currentAO, PARAMS_AOSize,6] call aw_fnc_randomPos;
					_roadpos = _randomPos;
					_list = _randomPos nearRoads 400;
					if (count _list > 0) then {
						_road = _list call BIS_fnc_selectRandom;
						_roadpos = getPos _road;
					};
					if ((count _roadpos) == 3) then 
					{
						_randomArmourChance = random 6;
						if(_randomArmourChance <= 2) then 
						{
						_armour = [_roadpos,0,"O_MBT_02_cannon_F",_armourGroup] call BIS_fnc_spawnVehicle;
						}; 
						if (_randomArmourChance > 2 && _randomArmourChance <= 4) then
						{
						_armour = [_roadpos,0,"O_APC_Tracked_02_AA_F",_armourGroup] call BIS_fnc_spawnVehicle;
						};
						if (_randomArmourChance > 4) then
						{
						_armour = [_roadpos,0,"O_APC_Tracked_02_cannon_F",_armourGroup] call BIS_fnc_spawnVehicle;
						};
						sleep 1;
						// wait untill alive
						//waitUntil {alive (leader _armourGroup)};
						_InOrOutChance = random 10;
						if (_InOrOutChance <= 3) then 
							{
								if (DEBUG) then
									{
										diag_log Format ["_InOrOutChance = %1 :: Armour perim pat at PARAMS_AOSize / 1.1 ",_InOrOutChance];
									};
									[_armourGroup,getMarkerPos currentAO,(PARAMS_AOSize / 1.1)] call aw_fnc_spawn2_perimeterPatrol;
							};
						if (_InOrOutChance > 3 && _InOrOutChance <= 6) then 
							{
								if (DEBUG) then
								{
									diag_log Format ["_InOrOutChance = %1 :: Armour perim pat at PARAMS_AOSize",_InOrOutChance];
								};
								[_armourGroup,getMarkerPos currentAO,(PARAMS_AOSize)] call aw_fnc_spawn2_perimeterPatrol;
							};
						if (_InOrOutChance > 6) then
							{
								if (DEBUG) then
								{
									diag_log Format ["_InOrOutChance = %1 :: Armour perim pat at PARAMS_AOSize+200 ",_InOrOutChance];
								};
								[_armourGroup,getMarkerPos currentAO,(PARAMS_AOSize+300)] call aw_fnc_spawn2_perimeterPatrol;
							};
							
							
						(vehicle (leader _armourGroup)) spawn aw_fnc_fuelMonitor;
						[(units _armourGroup)] call aw_setGroupSkill;
						if !(isNil "dep_fnc_vehicledamage") then {
						[(_armour select 0)] spawn dep_fnc_vehicledamage;
						};
						
						
						sleep 1;
						if(DEBUG) then
						{
							_name = format ["%1%2",name (leader _armourGroup),_x];
							createMarker [_name,getPos (leader _armourGroup)];
							_name setMarkerType "o_unknown";
							_name setMarkerText format ["Armour %1",_x];;
							_name setMarkerColor "ColorRed";
							[_armourGroup,_name] spawn
							{
								private["_group","_marker"];
								_group = _this select 0;
								_marker = _this select 1;

								while{count (units _group) > 0} do
								{
									_marker setMarkerPos (getPos (leader _group));
									sleep 1;
								};
								deleteMarker _marker;
							};
						};
						_enemiesArray = _enemiesArray + [_armourGroup];
					}
					else
					{
						diag_log "====DID NOT CREATE ARMOURPAT BECAUSE OF FAILED RANDOM POS====";
					};
				};
			};
//////////////////////////////////////////////////////// ARMOURPAT END ////////////////////////////////////////////////////////

//////////////////////////////////////////////////////// AIRPAT START ////////////////////////////////////////////////////////
				if((random 10 <= PARAMS_AirPatrol)) then 
				{
					_airGroup = createGroup east;
					_randomPos = [getMarkerPos currentAO, PARAMS_AOSize] call aw_fnc_randomPos;
					if ((count _randomPos) == 3) then 
					{
					
						_airType = if(random 1 <= 0.5) then {"O_Heli_Attack_02_F"} else {"O_Heli_Light_02_F"};
						_air = _airType createVehicle [_randomPos select 0,_randomPos select 1,1000];
						waitUntil{!isNull _air};
						_air engineOn true;
						_air lock 3;
						_air setPos [_randomPos select 0,_randomPos select 1,300];

						_air spawn
						{
							private["_x"];
							for [{_x=0},{_x<=200},{_x=_x+1}] do
							{
								_this setVelocity [0,0,0];
								sleep 1;
							};
						};

						"O_crew_F" createUnit [_randomPos,_airGroup];
						((units _airGroup) select 0) assignAsDriver _air;
						((units _airGroup) select 0) moveInDriver _air;
						_air removeMagazineTurret ["8Rnd_LG_scalpel",[0]];
						_air removeMagazines "8Rnd_LG_scalpel";

						if(_airType == "O_Heli_Light_02_F") then
						{
							"O_crew_F" createUnit [_randomPos,_airGroup];
							((units _airGroup) select 1) assignAsGunner _air;
							((units _airGroup) select 1) moveInGunner _air;
						};

						[_airGroup,getMarkerPos currentAO,(2 * (PARAMS_AOSize / 3))] call aw_fnc_spawn2_perimeterPatrol;
						_air spawn aw_fnc_fuelMonitor;
						
						sleep 1;
						if(DEBUG) then
						{
							_name = format ["%1%2",name (leader _airGroup),_x];
							createMarker [_name,getPos (leader _airGroup)];
							_name setMarkerType "o_unknown";
							_name setMarkerText format ["Air %1",_x];;
							_name setMarkerColor "ColorRed";
							[_airGroup,_name] spawn
							{
								private["_group","_marker"];
								_group = _this select 0;
								_marker = _this select 1;

								while{count (units _group) > 0} do
								{
									_marker setMarkerPos (getPos (leader _group));
									sleep 1;
								};
								deleteMarker _marker;
							};
						};
						_enemiesArray = _enemiesArray + [_airGroup];
					}
					else
					{
						diag_log "====DID NOT CREATE AIRPAT BECAUSE OF FAILED RANDOM POS====";
					};
				};
//////////////////////////////////////////////////////// AIRPAT END ////////////////////////////////////////////////////////

//////////////////////////////////////////////////////// GARRISON START ////////////////////////////////////////////////////////
				
				{
					_newGrp = [_x] call AW_fnc_garrisonBuildings;
					if (!isNull _newGrp) then { _enemiesArray = _enemiesArray + [_newGrp]; };
					sleep 0.2;
				} forEach (getMarkerPos currentAO nearObjects ["House", 500]);

//////////////////////////////////////////////////////// GARRISON END   ////////////////////////////////////////////////////////


				if (DEBUG) then {diag_log "=============AO AI CREATION ( AW_fnc_spawnUnits ) FUNC DONE=============";};
				AOAICREATIONMAINDONE = true;
				publicVariable "AOAICREATIONMAINDONE";
				
	_enemiesArray
};

//===================================//
//==========TOWER defence n Sniper ==//
//===================================//
BL_fnc_towerDefence =
{

	if (DEBUG) then {diag_log "===============TOWER DEFENCE FUNC STARTED==============";};
	_enemiesArray2 = [grpNull];
	// Reconguards
	_x = 0;
	for "_x" from 1 to PARAMS_TowerDefenders do 
	{
		_randomPos = [getMarkerPos "radioMarker", 10] call dR_fnc_randomPosbl1p;
		if ((count _randomPos) == 3) then 
		{
			_spawnGroup = createGroup EAST;
			
			"O_recon_TL_F" createUnit [_randomPos, _spawnGroup];
			"O_recon_medic_F" createUnit [_randomPos, _spawnGroup];
			"O_recon_F" createUnit [_randomPos, _spawnGroup];
			
			// wait untill alive
			//waitUntil {alive (leader _spawnGroup)};
			//[_spawnGroup, getMarkerPos "radioMarker"] call BIS_fnc_taskDefend;
			[(units _spawnGroup)] call aw_setGroupSkill;
			sleep 1;
			
			if(DEBUG) then
			{
				_name = format ["%1%2",name (leader _spawnGroup),_x];
				createMarker [_name,getPos (leader _spawnGroup)];
				_name setMarkerType "o_unknown";
				_name setMarkerText format ["Tow-Def-T %1",_x];;
				_name setMarkerColor "ColorRed";
				[_spawnGroup,_name] spawn
				{
					private["_group","_marker"];
					_group = _this select 0;
					_marker = _this select 1;

					while{count (units _group) > 0} do
					{
						_marker setMarkerPos (getPos (leader _group));
						sleep 1;
					};
					deleteMarker _marker;
				};
			};

			_enemiesArray2 = _enemiesArray2 + [_spawnGroup];
		}
		else
		{
				diag_log "====DID NOT CREATE TOWDEF BECAUSE OF FAILED RANDOM POS====";
		};
	};
	
	// Sniper
	_randSnipe = random 10;
	if (DEBUG) then
	{
		if ( _randSnipe <= PARAMS_SniperChance) then
				{
					diag_log format ["_randSnipe = %1 I AM CREATING SNIPERS ============ ",_randSnipe];
				}
				else
				{
					diag_log format ["_randSnipe = %1 I AM NOT CREATING SNIPERS ========== ",_randSnipe];
				};
	};
	if ( _randSnipe <= PARAMS_SniperChance) then	
	{
		_x = 0;
		_sniperand = [2,3,4] call BIS_fnc_selectRandom;
		if(DEBUG) then
			{
			diag_log format ["_sniperand = %1 amount of snipers",_sniperand];
			};
		for "_x" from 1 to _sniperand do 
		{
			
			
			//_upsZone3 = createTrigger ["EmptyDetector", getMarkerPos currentAO];
			//_upsZone3 setTriggerArea [100, 100, 0, false];
			
			_spawnGroupSN = createGroup EAST;
			
			"O_sniper_F" createUnit [getMarkerPos "radioMarker", _spawnGroupSN];
			// wait untill alive
			//waitUntil {alive (leader _spawnGroupSN)};
			
					//[(leader _spawnGroupSN), _upsZone3, "RANDOMUP", "NOMOVE"] execVM "ups.sqf";
					[_spawnGroupSN, getMarkerPos currentAO, PARAMS_AOSize] call aw_fnc_spawn2_randomPatrol;
				
			[(units _spawnGroupSN)] call dR_fnc_Snipers;
			sleep 1;
			
			if(DEBUG) then
			{
				_name = format ["%1%2",name (leader _spawnGroupSN),_x];
				createMarker [_name,getPos (leader _spawnGroupSN)];
				_name setMarkerType "o_unknown";
				_name setMarkerText format ["Sniper %1",_x];;
				_name setMarkerColor "ColorRed";
				[_spawnGroupSN,_name] spawn
				{
					private["_group","_marker"];
					_group = _this select 0;
					_marker = _this select 1;

					while{count (units _group) > 0} do
					{
						_marker setMarkerPos (getPos (leader _group));
						sleep 1;
					};
					deleteMarker _marker;
				};
			};

			_enemiesArray2 = _enemiesArray2 + [_spawnGroupSN];
		};
	};
	if (DEBUG) then {diag_log "==============TOWER DEFENCE FUNC DONE===============";};
	_enemiesArray2
};	

//===================================//
//==========Random squads============//
//===================================//

//--- bl1p a few squads for random
urbanSquad1 = 
{
	_randomPos = _this select 0;
	_spawnGroup = _this select 1;

	"O_SoldierU_SL_F" createUnit [_randomPos, _spawnGroup];
	"O_soldierU_medic_F" createUnit [_randomPos, _spawnGroup];
	"O_soldierU_AR_F" createUnit [_randomPos, _spawnGroup];
	"O_soldierU_AT_F" createUnit [_randomPos, _spawnGroup];
	"O_SoldierU_GL_F" createUnit [_randomPos, _spawnGroup];	
	"O_soldierU_F" createUnit [_randomPos, _spawnGroup];
	
};	

urbanSquad2 =
{
	_randomPos = _this select 0;
	_spawnGroup = _this select 1;
	
	"O_SoldierU_SL_F" createUnit [_randomPos, _spawnGroup];
	"O_soldierU_medic_F" createUnit [_randomPos, _spawnGroup];
	"O_soldierU_AR_F" createUnit [_randomPos, _spawnGroup];
	"O_soldierU_AT_F" createUnit [_randomPos, _spawnGroup];
	"O_SoldierU_GL_F" createUnit [_randomPos, _spawnGroup];	
	"O_soldierU_F" createUnit [_randomPos, _spawnGroup];
};

OpSquad1 =
{
	_randomPos = _this select 0;
	_spawnGroup = _this select 1;

	"O_Soldier_SL_F" createUnit [_randomPos, _spawnGroup];
	"O_Soldier_AA_F" createUnit [_randomPos, _spawnGroup];
	"O_Soldier_AR_F" createUnit [_randomPos, _spawnGroup];
	"O_Soldier_GL_F" createUnit [_randomPos, _spawnGroup];
	"O_Soldier_LAT_F" createUnit [_randomPos, _spawnGroup];
	"O_medic_F" createUnit [_randomPos, _spawnGroup];
};	


GurillaSquad =
{
	_randomPos = _this select 0;
	_spawnGroup = _this select 1;

	"O_G_Soldier_SL_F" createUnit [_randomPos, _spawnGroup];
	"O_G_Soldier_GL_F" createUnit [_randomPos, _spawnGroup];
	"O_G_Soldier_GL_F" createUnit [_randomPos, _spawnGroup];
	"O_G_Soldier_AR_F" createUnit [_randomPos, _spawnGroup];
	"O_G_Soldier_AR_F" createUnit [_randomPos, _spawnGroup];
	"O_G_medic_F" createUnit [_randomPos, _spawnGroup];
};

//===================================//
//==========Garrison squads==========//
//===================================//
AW_fnc_garrisonBuildings =
{
	//if (DEBUG) then {diag_log "===========GARISON FUNC STARTED============";};
	_building = _this select 0;
	_faction = "OPF_F";
	_coef = 1;

	BIS_getRelPos = {
		_relDir = [_this, player] call BIS_fnc_relativeDirTo;
		_dist = [_this, player] call BIS_fnc_distance2D;
		_elev = ((getPosASL _this) select 2) - ((getPosASL player) select 2);
		_dir = (direction player) - direction _this;

		[_relDir, _dist, _elev, _dir];
	};

	_buildings = [
		"Land_Cargo_House_V1_F", [
			[216.049,2.33014,-0.0721207,-173.782]
		],
		"Land_Cargo_House_V2_F", [
			[216.049,2.33014,-0.0721207,-173.782]
		],
		"Land_Cargo_HQ_V1_F", [
			[-89.3972,5.45408,-0.724457,-89.757],
			[160.876,5.95225,-0.59613,-0.245575],
			[30.379,5.37352,-3.03543,-32.9396],
			[49.9438,7.04951,-3.03488,1.15405],
			[109.73,7.20652,-3.12396,-273.082],
			[190.289,6.1683,-3.12094,-181.174],
			[212.535,6.83544,-3.1217,-154.507]
			
		],
		"Land_Cargo_Patrol_V1_F", [
			[84.1156,2.21253,-4.1396,88.6112],
			[316.962,3.81801,-4.14061,270.592],
			[31.6563,3.91418,-4.13602,-0.194908]

		],
		"Land_Cargo_Tower_V1_F", [
			[99.5325,3.79597,-4.62543,-271,3285],
			[-65.1654,4.17803,-8.59327,2,79],
			[-50.097,4.35226,-12.7691,2,703],
			[115.749,5.55055,-12.7623,-270,6282],
			[-143.89,7.92183,-12.9027,-180,867],
			[67.2957,6.75608,-15.4993,-270,672],
			[-68.9994,7.14031,-15.507,-88,597],
			[195.095,7.46374,-17.792,-182,651],
			[-144.962,8.67736,-17.7939,-178,337],
			[111.831,6.52689,-17.7889,-271,5161],
			[-48.2151,6.2476,-17.7976,-1,334],
			[-24.622,4.62995,-17.796,1,79]
		],
		"Land_Cargo_Tower_V2_F", [
			[99.5325,3.79597,-4.62543,-271,3285],
			[-65.1654,4.17803,-8.59327,2,79],
			[-50.097,4.35226,-12.7691,2,703],
			[115.749,5.55055,-12.7623,-270,6282],
			[-143.89,7.92183,-12.9027,-180,867],
			[67.2957,6.75608,-15.4993,-270,672],
			[-68.9994,7.14031,-15.507,-88,597],
			[195.095,7.46374,-17.792,-182,651],
			[-144.962,8.67736,-17.7939,-178,337],
			[111.831,6.52689,-17.7889,-271,5161],
			[-48.2151,6.2476,-17.7976,-1,334],
			[-24.622,4.62995,-17.796,1,79]
		],
		"Land_Cargo_Tower_V3_F", [
			[99.5325,3.79597,-4.62543,-271,3285],
			[-65.1654,4.17803,-8.59327,2,79],
			[-50.097,4.35226,-12.7691,2,703],
			[115.749,5.55055,-12.7623,-270,6282],
			[-143.89,7.92183,-12.9027,-180,867],
			[67.2957,6.75608,-15.4993,-270,672],
			[-68.9994,7.14031,-15.507,-88,597],
			[195.095,7.46374,-17.792,-182,651],
			[-144.962,8.67736,-17.7939,-178,337],
			[111.831,6.52689,-17.7889,-271,5161],
			[-48.2151,6.2476,-17.7976,-1,334],
			[-24.622,4.62995,-17.796,1,79]
		],
		"Land_i_Barracks_V1_F", [
			[66.6219,14.8599,-3.8678,94.6476],
			[52.0705,10.0203,-3.86142,4.09206],
			[11.4515,6.26249,-3.85385,1.42117],
			[306.455,10.193,-3.84314,0.0715332],
			[294.846,14.2778,-3.83774,-91.0892],
			[7.04782,1.86908,-0.502411,-90.3917],
			[86.3556,7.98911,-0.510651,129.846]
		],
		"Land_i_Barracks_V2_F", [
			[66.6219,14.8599,-3.8678,94.6476],
			[52.0705,10.0203,-3.86142,4.09206],
			[11.4515,6.26249,-3.85385,1.42117],
			[306.455,10.193,-3.84314,0.0715332],
			[294.846,14.2778,-3.83774,-91.0892],
			[7.04782,1.86908,-0.502411,-90.3917],
			[86.3556,7.98911,-0.510651,129.846]
		]
		
	];

	if (!(typeOf _building in _buildings)) exitWith {_newGrp = objNull; _newGrp};

	_paramsArray = (_buildings select ((_buildings find (typeOf _building)) + 1));
	
	_newGrp = createGroup EAST;

	_units = ["O_Soldier_F", "O_Soldier_AR_F"];
	
	_finalCnt = count _paramsArray;
	if(DEBUG) then
			{
			diag_log format ["_finalCnt = %1 buildings array",_finalCnt];
			};
	
	_SERVERUNITSCHECKHGarison1 = 0;	
	_SERVERUNITSCHECKResistance = 0;	
	_SERVERUNITSCHECKHGarison = 0;
	
	_SERVERUNITSCHECKHGarison1 = east countSide allunits;	
	_SERVERUNITSCHECKResistance = resistance countside allunits;
	_SERVERUNITSCHECKHGarison = (_SERVERUNITSCHECKHGarison1 + _SERVERUNITSCHECKResistance);
	
	if (_SERVERUNITSCHECKHGarison1 < PARAMS_TOTALMAXAI) then
		{
		if(DEBUG) then
					{
					diag_log format ["_SERVERUNITSCHECKHGarison1 = %1",_SERVERUNITSCHECKHGarison1];
					diag_log "Creating garison units";
					};
			{
				_pos =  [_building, _x select 1, (_x select 0) + direction _building] call BIS_fnc_relPos;
				_pos = [_pos select 0, _pos select 1, ((getPosASL _building) select 2) - (_x select 2)];
				_units select floor random 2 createUnit [_pos, _newGrp, "BIS_currentDude = this"];
				doStop BIS_currentDude;
				commandStop BIS_currentDude;
				BIS_currentDude setPosASL _pos;
				BIS_currentDude setUnitPos "UP";
				BIS_currentDude doWatch ([BIS_currentDude, 1000, direction _building + (_x select 3)] call BIS_fnc_relPos);
				BIS_currentDude setDir direction _building + (_x select 3);
				sleep 0.5;
			} forEach _paramsArray;
			sleep 0.5;
			[(units _newGrp)] call aw_setGroupSkill;
		}
		else 
		{
		if(DEBUG) then
					{
					diag_log "DID NOT Creat garison units";
					};
		};
	if (DEBUG) then {diag_log "===========GARISON FUNC DONE============";};
	_newGrp
	
};