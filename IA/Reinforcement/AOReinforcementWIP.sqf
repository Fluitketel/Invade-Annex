//////////////////////////////////////////////
// LIGHT reinf script by BL1P and Fluit     //
//////////////////////////////////////////////


waitUntil {sleep 0.5; !(isNil "currentAOUp")};
waitUntil {sleep 0.5; !(isNil "currentAO")};
private ["_priorityMessageHelo", "_reinforcementsdead","_SERVERUNITSCHECKRE","_roadList","_road","_roadPos","_SERVERUNITSCHECKRE1","_SERVERUNITSCHECKREresistance","_amount","_subType","_reinforceTypes","_roadList"];

if (DEBUG) then {diag_log "===============Reading LIGHT reinforcements====================";};

Reinforced = false;
publicVariable "Reinforced";

ReinforcementUnits = [];
ReinforcementVehicles = [];

_SERVERUNITSCHECKRE = 0;
_amount = [];
_subType = "";
_reinforceTypes = 0;
_giveup = false;

while {true} do 
{
	if(DEBUG) then
		{
			sleep (10 + (random 10));
		}
		else
		{
			sleep (180 + (random 120))
		};
		
		_randReinfChance = random 10;
		if(DEBUG) then
					{
						diag_log format ["_randReinfChance = %1 PARAMS_AOReinforcement = %2 (%1 <= %2 ?)",_randReinfChance,PARAMS_AOReinforcement];
					};
					
					
		if (radioTowerAlive && !Reinforced && spotted) then
			{
				_SERVERUNITSCHECKRE1 = east countSide allunits;
				_SERVERUNITSCHECKREresistance = resistance countSide allunits;
				_SERVERUNITSCHECKRE = (_SERVERUNITSCHECKRE1 + _SERVERUNITSCHECKREresistance);
				sleep 1;
				if(DEBUG) then
							{
								diag_log format ["_SERVERUNITSCHECKRE for TOTAL LIGHT reinforcements = %1",_SERVERUNITSCHECKRE];
							};
			};	
			
        if (radioTowerAlive && spotted  && (_SERVERUNITSCHECKRE < PARAMS_TOTALMAXAI) && (_randReinfChance <= PARAMS_AOReinforcement)) then //is tower alive and is spotted and server isnt over loaded
		{
			if !(Reinforced) then // is it already reinforced 
			{
			
					//_amount = [2,3,4]  call BIS_fnc_selectRandom; //--- use this in mission
					_amount = 3; //--- use this for testing smounts
					if (DEBUG) then
						{
						diag_log format ["_amount = %1",_amount];
						};
					
					
					//_reinforceTypes = round (random 4); //--- use this in mission
					_reinforceTypes = 1; //--- use this to define the type
					switch (_reinforceTypes) do 
					{ 
						case 0: {_subType = ["G1","G2","G3"] call BIS_fnc_selectRandom;}; //--- Guer
						case 1: {_subType = ["I1","I2","I3"] call BIS_fnc_selectRandom;}; //--- Inf
						case 2: {_subType = ["A1","A2","A3"] call BIS_fnc_selectRandom;}; //--- Air
						case 3: {_subType = ["M1","M2","M3"] call BIS_fnc_selectRandom;}; //--- Mech
						case 4: {_subType = ["V1","V2","V3"] call BIS_fnc_selectRandom;}; //--- vech
					};
					
					////////////////////////////////////
					//          GUERILA GROUPS    #0  //
					////////////////////////////////////
					
					if (_subType == "G1") then 
					{
						_randomPosInf = [getMarkerPos currentAO, PARAMS_AOSize+750] call aw_fnc_randomPosbl1p; //--- primary position
						//--- place on road if road near
						_roadpos = _randomPosInf;
						_list = _randomPosInf nearRoads 400;
						if (count _list > 0) then {
							_road = _list call BIS_fnc_selectRandom;
							_roadpos = getPos _road;
						};	
						if ((count _roadpos) == 3) then //--- check if pos is infact an xyz array if not do not create
						{
							_x = 0;
							for "_x" from 1 to _amount do //--- from 1 to amount generated
							{
								_spawnGroup = createGroup EAST;
								[_roadpos,_spawnGroup] call GurillaSquad; //--- squad type at secondary pos
								sleep 0.5; //--- small sleep
								[(leader _spawnGroup), "aoCircle" , "NOSLOW"] execVM "UPS_BL1P.sqf";
								sleep 0.5;
								
								{
								  ReinforcementUnits set [count ReinforcementUnits, _x]; //--- create array of reinforcements
								  publicVariable "ReinforcementUnits";
								} forEach units _spawnGroup;
								
								if(DEBUG) then
								{
								diag_log format ["reinforcement count = %1",count ReinforcementUnits];
								};
								Reinforced = true; //--- set variable to let all scripts know AO is reinforced
								publicVariable "Reinforced";
								sleep 1;
							};
						}else{ diag_log "DID NOT CREATE REINF FAILED ON RANDPOS";};//--- send message if rand pos fails
					};
					
					if (_subType == "G2") then 
					{
						_randomPosInf = [getMarkerPos currentAO, PARAMS_AOSize+750] call aw_fnc_randomPosbl1p; //--- primary position
						//--- place on road if road near
						_roadpos = _randomPosInf;
						_list = _randomPosInf nearRoads 400;
						if (count _list > 0) then {
							_road = _list call BIS_fnc_selectRandom;
							_roadpos = getPos _road;
						};	
						if ((count _roadpos) == 3) then //--- check if pos is infact an xyz array if not do not create
						{
							_x = 0;
							for "_x" from 1 to _amount do //--- from 1 to amount generated
							{
								_spawnGroup = createGroup EAST;
								[_roadpos,_spawnGroup] call GurillaSquad; //--- squad type at secondary pos
								sleep 0.5; //--- small sleep
								[(leader _spawnGroup), "aoCircle" , "NOSLOW"] execVM "UPS_BL1P.sqf";
								sleep 0.5;
								
								{
								  ReinforcementUnits set [count ReinforcementUnits, _x]; //--- create array of reinforcements
								  publicVariable "ReinforcementUnits";
								} forEach units _spawnGroup;
								
								if(DEBUG) then
								{
								diag_log format ["reinforcement count = %1",count ReinforcementUnits];
								};
								Reinforced = true; //--- set variable to let all scripts know AO is reinforced
								publicVariable "Reinforced";
								sleep 1;
							};
						}else{ diag_log "DID NOT CREATE REINF FAILED ON RANDPOS";};//--- send message if rand pos fails
					};
					
					if (_subType == "G3") then 
					{
						_randomPosInf = [getMarkerPos currentAO, PARAMS_AOSize+750] call aw_fnc_randomPosbl1p; //--- primary position
						//--- place on road if road near
						_roadpos = _randomPosInf;
						_list = _randomPosInf nearRoads 400;
						if (count _list > 0) then {
							_road = _list call BIS_fnc_selectRandom;
							_roadpos = getPos _road;
						};	
						if ((count _roadpos) == 3) then //--- check if pos is infact an xyz array if not do not create
						{
							_x = 0;
							for "_x" from 1 to _amount do //--- from 1 to amount generated
							{
								_spawnGroup = createGroup EAST;
								[_roadpos,_spawnGroup] call GurillaSquad; //--- squad type at secondary pos
								sleep 0.5; //--- small sleep
								[(leader _spawnGroup), "aoCircle" , "NOSLOW"] execVM "UPS_BL1P.sqf";
								sleep 0.5;
								
								{
								  ReinforcementUnits set [count ReinforcementUnits, _x]; //--- create array of reinforcements
								  publicVariable "ReinforcementUnits";
								} forEach units _spawnGroup;
								
								if(DEBUG) then
								{
								diag_log format ["reinforcement count = %1",count ReinforcementUnits];
								};
								Reinforced = true; //--- set variable to let all scripts know AO is reinforced
								publicVariable "Reinforced";
								sleep 1;
							};
						}else{ diag_log "DID NOT CREATE REINF FAILED ON RANDPOS";};//--- send message if rand pos fails
					};
					
					////////////////////////////////////
					//          INFANTRY GROUPS    #1 //
					////////////////////////////////////
					
					if (_subType == "I1") then 
					{
							/// find flat pos not near base ///
							_flatPos = [0];
							_accepted = false;
							_debugCounter = 1;
							
							_debugCounter2 = 1;
							_flatPos2 = [0];
							_accepted2 = false;
							
							while {!_accepted} do
							{
								if (_debugCounter >= 100) exitWith 
								{
									_giveup = true;
									_flatPos = [];
									_debugCounter = 1;
									diag_log "Cant find a good convoy start position exit 1";
								};
								if (DEBUG) then { diag_log format["Finding flat position in convoy script.Attempt #%1",_debugCounter]; };
								//_position = [[[getMarkerPos currentAO,3000]],["water","out"]] call BIS_fnc_randomPos;
								//_flatPos = _position isFlatEmpty [5, 0, 0.2, 5, 0, false];
								
								_flatPos = [[[getMarkerPos currentAO,3000]],["water","out"]] call BIS_fnc_randomPos;
								
								_roadpos = _flatPos;
								_list = _roadpos nearRoads 500;
								if (count _list > 0) then {
									_road = _list call BIS_fnc_selectRandom;
									_roadpos = getPos _road;
								};
								_flatPos = _roadpos;
								
								if ((count _flatPos) == 3) then {
									if ((_flatPos distance (getMarkerPos "respawn_west")) > 3000 && (_flatPos distance (getMarkerPos currentAO)) > 1500) then 
									{
										_nearUnits = 0;
										{
											if ((_flatPos distance (getPos _x)) < 1500) then
											{
												_nearUnits = _nearUnits + 1;
											};
										} forEach playableUnits;

										if (_nearUnits == 0) then
										{
											_accepted = true;
										};
									} else {
										_flatPos = [0];
									};
								};
								_debugCounter = _debugCounter + 1;
							};
						
						if ((count _flatPos) == 3) then //--- check if pos is infact an xyz array if not do not create
						{
							_x = 0;
							for "_x" from 1 to _amount do //--- from 1 to amount generated
							{
								//double check position now
								while {!_accepted2} do
									{ 
										if (_debugCounter2 >= 100) exitWith 
											{
												_giveup2 = true;
												_flatPos2 = [];
												_debugCounter2 = 1;
												diag_log "Cant find a good convoy start position exit 1";
											};
										_flatPos2 = _flatPos isFlatEmpty [10, 5, 0.2, 5, 0, false];
										if ((count _flatPos2) == 3) then 
										{
											_accepted2 = true;
										};
										_debugCounter2 = _debugCounter2 + 1;
									};	
								if ((count _flatPos2) == 3) then
								{
									_spawnGroup = createGroup EAST;
									diag_log format ["==== _flatPos2 = %1",_flatPos2];									
									_vehcar = [_flatPos2,0,"O_MRAP_02_gmg_F",_spawnGroup] call BIS_fnc_spawnVehicle;
									diag_log format ["_vehcar = %1",_vehcar];
									
									_vehcardam = _vehcar select 0;
									_vehcardam allowdamage false;
									_vehcarpos = _vehcar select 0;
									_vehcarpos setPosATL [ getPosATL _vehcarpos select 0, getPosATL _vehcarpos select 1 ,(getPosATL _vehcarpos select 2) + 5];
									sleep 2; //--- small sleep
									_vehcardam allowdamage true;
									
									sleep 0.5; //--- small sleep
									[(leader _spawnGroup), "aoCircle"] execVM "UPS_BL1P.sqf";
									
									{
									  ReinforcementUnits set [count ReinforcementUnits, _x]; //--- create array of reinforcements
									  publicVariable "ReinforcementUnits";
									} forEach units _spawnGroup;
									
									if(DEBUG) then
									{
									diag_log format ["reinforcement count = %1",count ReinforcementUnits];
									};
									Reinforced = true; //--- set variable to let all scripts know AO is reinforced
									publicVariable "Reinforced";
									sleep 1;
								}else {diag_log "DID NOT CREATE REINF FAILED ON POS";};
							};
						}else{ diag_log "DID NOT CREATE REINF FAILED ON POS";};//--- send message if rand pos fails
					};
					
					if (_subType == "I2") then 
					{
							/// find flat pos not near base ///
							_flatPos = [0];
							_accepted = false;
							_debugCounter = 1;
							
							_debugCounter2 = 1;
							_flatPos2 = [0];
							_accepted2 = false;
							
							while {!_accepted} do
							{
								if (_debugCounter >= 100) exitWith 
								{
									_giveup = true;
									_flatPos = [];
									_debugCounter = 1;
									diag_log "Cant find a good convoy start position exit 1";
								};
								if (DEBUG) then { diag_log format["Finding flat position in convoy script.Attempt #%1",_debugCounter];};
								//_position = [[[getMarkerPos currentAO,3000]],["water","out"]] call BIS_fnc_randomPos;
								//_flatPos = _position isFlatEmpty [5, 0, 0.2, 5, 0, false];
								
								_flatPos = [[[getMarkerPos currentAO,3000]],["water","out"]] call BIS_fnc_randomPos;
								
								_roadpos = _flatPos;
								_list = _roadpos nearRoads 500;
								if (count _list > 0) then {
									_road = _list call BIS_fnc_selectRandom;
									_roadpos = getPos _road;
								};
								_flatPos = _roadpos;
								
								if ((count _flatPos) == 3) then {
									if ((_flatPos distance (getMarkerPos "respawn_west")) > 3000 && (_flatPos distance (getMarkerPos currentAO)) > 1500) then 
									{
										_nearUnits = 0;
										{
											if ((_flatPos distance (getPos _x)) < 1500) then
											{
												_nearUnits = _nearUnits + 1;
											};
										} forEach playableUnits;

										if (_nearUnits == 0) then
										{
											_accepted = true;
										};
									} else {
										_flatPos = [0];
									};
								};
								_debugCounter = _debugCounter + 1;
							};
						
						if ((count _flatPos) == 3) then //--- check if pos is infact an xyz array if not do not create
						{
							_x = 0;
							for "_x" from 1 to _amount do //--- from 1 to amount generated
							{
								//double check position now
								while {!_accepted2} do
									{ 
										if (_debugCounter2 >= 100) exitWith 
											{
												_giveup2 = true;
												_flatPos2 = [];
												_debugCounter2 = 1;
												diag_log "Cant find a good convoy start position exit 1";
											};
										_flatPos2 = _flatPos isFlatEmpty [10, 5, 0.2, 5, 0, false];
										if ((count _flatPos2) == 3) then 
										{
											_accepted2 = true;
										};
										_debugCounter2 = _debugCounter2 + 1;
									};	
								if ((count _flatPos2) == 3) then
								{
									_spawnGroup = createGroup EAST;
									diag_log format ["==== _flatPos2 = %1",_flatPos2];	
									_vehcar = [_flatPos2,0,"O_MRAP_02_gmg_F",_spawnGroup] call BIS_fnc_spawnVehicle;
									diag_log format ["_vehcar = %1",_vehcar];
									
									_vehcardam = _vehcar select 0;
									_vehcardam allowdamage false;
									_vehcarpos = _vehcar select 0;
									_vehcarpos setPosATL [ getPosATL _vehcarpos select 0, getPosATL _vehcarpos select 1 ,(getPosATL _vehcarpos select 2) + 5];
									sleep 2; //--- small sleep
									_vehcardam allowdamage true;
									
									sleep 0.5; //--- small sleep
									[(leader _spawnGroup), "aoCircle"] execVM "UPS_BL1P.sqf";
									
									{
									  ReinforcementUnits set [count ReinforcementUnits, _x]; //--- create array of reinforcements
									  publicVariable "ReinforcementUnits";
									} forEach units _spawnGroup;
									
									if(DEBUG) then
									{
									diag_log format ["reinforcement count = %1",count ReinforcementUnits];
									};
									Reinforced = true; //--- set variable to let all scripts know AO is reinforced
									publicVariable "Reinforced";
									sleep 1;
								}else {diag_log "DID NOT CREATE REINF FAILED ON POS";};
							};
						}else{ diag_log "DID NOT CREATE REINF FAILED ON POS";};//--- send message if rand pos fails
					};
					
					if (_subType == "I3") then 
					{
							/// find flat pos not near base ///
							_flatPos = [0];
							_accepted = false;
							_debugCounter = 1;
							
							_debugCounter2 = 1;
							_flatPos2 = [0];
							_accepted2 = false;
							
							while {!_accepted} do
							{
								if (_debugCounter >= 100) exitWith 
								{
									_giveup = true;
									_flatPos = [];
									_debugCounter = 1;
									diag_log "Cant find a good convoy start position exit 1";
								};
								if (DEBUG) then { diag_log format["Finding flat position in convoy script.Attempt #%1",_debugCounter]; };
								//_position = [[[getMarkerPos currentAO,3000]],["water","out"]] call BIS_fnc_randomPos;
								//_flatPos = _position isFlatEmpty [5, 0, 0.2, 5, 0, false];
								
								_flatPos = [[[getMarkerPos currentAO,3000]],["water","out"]] call BIS_fnc_randomPos;
								
								_roadpos = _flatPos;
								_list = _roadpos nearRoads 500;
								if (count _list > 0) then {
									_road = _list call BIS_fnc_selectRandom;
									_roadpos = getPos _road;
								};
								_flatPos = _roadpos;
								
								if ((count _flatPos) == 3) then {
									if ((_flatPos distance (getMarkerPos "respawn_west")) > 3000 && (_flatPos distance (getMarkerPos currentAO)) > 1500) then 
									{
										_nearUnits = 0;
										{
											if ((_flatPos distance (getPos _x)) < 1500) then
											{
												_nearUnits = _nearUnits + 1;
											};
										} forEach playableUnits;

										if (_nearUnits == 0) then
										{
											_accepted = true;
										};
									} else {
										_flatPos = [0];
									};
								};
								_debugCounter = _debugCounter + 1;
							};
						
						if ((count _flatPos) == 3) then //--- check if pos is infact an xyz array if not do not create
						{
							_x = 0;
							for "_x" from 1 to _amount do //--- from 1 to amount generated
							{
								//double check position now
								while {!_accepted2} do
									{ 
										if (_debugCounter2 >= 100) exitWith 
											{
												_giveup2 = true;
												_flatPos2 = [];
												_debugCounter2 = 1;
												diag_log "Cant find a good convoy start position exit 1";
											};
										_flatPos2 = _flatPos isFlatEmpty [10, 5, 0.2, 5, 0, false];
										if ((count _flatPos2) == 3) then 
										{
											_accepted2 = true;
										};
										_debugCounter2 = _debugCounter2 + 1;
									};	
								if ((count _flatPos2) == 3) then
								{
									_spawnGroup = createGroup EAST;
									diag_log format ["==== _flatPos2 = %1",_flatPos2];
									_vehcar = [_flatPos2,0,"O_MRAP_02_gmg_F",_spawnGroup] call BIS_fnc_spawnVehicle;
									diag_log format ["_vehcar = %1",_vehcar];
									
									_vehcardam = _vehcar select 0;
									_vehcardam allowdamage false;
									_vehcarpos = _vehcar select 0;
									_vehcarpos setPosATL [ getPosATL _vehcarpos select 0, getPosATL _vehcarpos select 1 ,(getPosATL _vehcarpos select 2) + 5];
									sleep 2; //--- small sleep
									_vehcardam allowdamage true;
									
									sleep 0.5; //--- small sleep
									[(leader _spawnGroup), "aoCircle"] execVM "UPS_BL1P.sqf";
									
									{
									  ReinforcementUnits set [count ReinforcementUnits, _x]; //--- create array of reinforcements
									  publicVariable "ReinforcementUnits";
									} forEach units _spawnGroup;
									
									if(DEBUG) then
									{
									diag_log format ["reinforcement count = %1",count ReinforcementUnits];
									};
									Reinforced = true; //--- set variable to let all scripts know AO is reinforced
									publicVariable "Reinforced";
									sleep 1;
								}else {diag_log "DID NOT CREATE REINF FAILED ON POS";};
							};
						}else{ diag_log "DID NOT CREATE REINF FAILED ON POS";};//--- send message if rand pos fails
					};
					
					////////////////////////////////////
					//          AIR GROUPS        #2  //
					////////////////////////////////////
					
					if (_subType == "A1") then 
					{
						_randomPosInf = [getMarkerPos currentAO, PARAMS_AOSize+750] call aw_fnc_randomPosbl1p;
						if ((count _randomPosInf) == 3) then 
							{
								_x = 0;
								for "_x" from 1 to _amount do 
								{
								[_randomPosInf,_spawnGroup] call GurillaSquad; //--- squad type
								[_spawnGroup, getMarkerPos currentAO,250] call aw_fnc_Reinforce_perimeterPatrolBL1P; //--- patrol 
								};
								
								{
								  ReinforcementUnits set [count ReinforcementUnits, _x];
								  publicVariable "ReinforcementUnits";
								} forEach units _spawnGroup;
								
								if(DEBUG) then
								{
								diag_log format ["reinforcement count = %1",count ReinforcementUnits];
								};
								Reinforced = true;
								publicVariable "Reinforced";
								sleep 1;
							}else{ diag_log "DID NOT CREATE REINF FAILED ON RANDPOS";};
					};
					
					if (_subType == "A2") then 
					{
						_randomPosInf = [getMarkerPos currentAO, PARAMS_AOSize+750] call aw_fnc_randomPosbl1p;
						if ((count _randomPosInf) == 3) then 
							{
								_x = 0;
								for "_x" from 1 to _amount do 
								{
								[_randomPosInf,_spawnGroup] call GurillaSquad; //--- squad type
								[_spawnGroup, getMarkerPos currentAO,250] call aw_fnc_Reinforce_perimeterPatrolBL1P; //--- patrol 
								};
								
								{
								  ReinforcementUnits set [count ReinforcementUnits, _x];
								  publicVariable "ReinforcementUnits";
								} forEach units _spawnGroup;
								
								if(DEBUG) then
								{
								diag_log format ["reinforcement count = %1",count ReinforcementUnits];
								};
								Reinforced = true;
								publicVariable "Reinforced";
								sleep 1;
							}else{ diag_log "DID NOT CREATE REINF FAILED ON RANDPOS";};
					};
					
					if (_subType == "A3") then 
					{
						_randomPosInf = [getMarkerPos currentAO, PARAMS_AOSize+750] call aw_fnc_randomPosbl1p;
						if ((count _randomPosInf) == 3) then 
							{
								_x = 0;
								for "_x" from 1 to _amount do 
								{
								[_randomPosInf,_spawnGroup] call GurillaSquad; //--- squad type
								[_spawnGroup, getMarkerPos currentAO,250] call aw_fnc_Reinforce_perimeterPatrolBL1P; //--- patrol 
								};
								
								{
								  ReinforcementUnits set [count ReinforcementUnits, _x];
								  publicVariable "ReinforcementUnits";
								} forEach units _spawnGroup;
								
								if(DEBUG) then
								{
								diag_log format ["reinforcement count = %1",count ReinforcementUnits];
								};
								Reinforced = true;
								publicVariable "Reinforced";
								sleep 1;
							}else{ diag_log "DID NOT CREATE REINF FAILED ON RANDPOS";};
					};
					
					////////////////////////////////////
					//         MECH GROUPS        #3  //
					////////////////////////////////////
					
					if (_subType == "M1") then 
					{
						_randomPoscar = [getMarkerPos currentAO, PARAMS_AOSize+1000] call aw_fnc_randomPosbl1p;
						if ((count _randomPoscar) == 3) then 
						{
							//find a road if posible
							_roadList = _randomPoscar nearRoads 400;
							_awayFromBase = false;
							while {!_awayFromBase} do
							{
								_road = _roadList call BIS_fnc_selectRandom;
								_roadPos = getPos _road;
								
								if (_roadPos distance (getMarkerPos "respawn_west") > 1000 && (_roadPos distance (getMarkerPos currentAO)) > 1000) then
								{
									_awayFromBase = true;
								};
							};
						
							_x = 0;
							for "_x" from 1 to _amount do 
							{
							[_roadPos,_spawnGroup] call SquadcarGmG; //--- squad type
							[_spawnGroup, getMarkerPos currentAO,250] call aw_fnc_Reinforce_perimeterPatrolBL1P; //--- patrol 
							};
						
							{
							  ReinforcementUnits set [count ReinforcementUnits, _x];
							  publicVariable "ReinforcementUnits";
							} forEach units _spawnGroup;
							
							if(DEBUG) then
							{
							diag_log format ["reinforcement count = %1",count ReinforcementUnits];
							};
							Reinforced = true;
							publicVariable "Reinforced";
							sleep 1;
						}else{ diag_log "DID NOT CREATE REINF FAILED ON RANDPOS";};
					}; 
					
					if (_subType == "M2") then 
					{
						_randomPoscar = [getMarkerPos currentAO, PARAMS_AOSize+1000] call aw_fnc_randomPosbl1p;
						if ((count _randomPoscar) == 3) then 
						{
							//find a road if posible
							_roadList = _randomPoscar nearRoads 400;
							_awayFromBase = false;
							while {!_awayFromBase} do
							{
								_road = _roadList call BIS_fnc_selectRandom;
								_roadPos = getPos _road;
								
								if (_roadPos distance (getMarkerPos "respawn_west") > 1000 && (_roadPos distance (getMarkerPos currentAO)) > 1000) then
								{
									_awayFromBase = true;
								};
							};
						
							_x = 0;
							for "_x" from 1 to _amount do 
							{
							[_roadPos,_spawnGroup] call SquadcarGmG; //--- squad type
							[_spawnGroup, getMarkerPos currentAO,250] call aw_fnc_Reinforce_perimeterPatrolBL1P; //--- patrol 
							};
						
							{
							  ReinforcementUnits set [count ReinforcementUnits, _x];
							  publicVariable "ReinforcementUnits";
							} forEach units _spawnGroup;
							
							if(DEBUG) then
							{
							diag_log format ["reinforcement count = %1",count ReinforcementUnits];
							};
							Reinforced = true;
							publicVariable "Reinforced";
							sleep 1;
						}else{ diag_log "DID NOT CREATE REINF FAILED ON RANDPOS";};
					};
					
					if (_subType == "M3") then 
					{
						_randomPoscar = [getMarkerPos currentAO, PARAMS_AOSize+1000] call aw_fnc_randomPosbl1p;
						if ((count _randomPoscar) == 3) then 
						{
							//find a road if posible
							_roadList = _randomPoscar nearRoads 400;
							_awayFromBase = false;
							while {!_awayFromBase} do
							{
								_road = _roadList call BIS_fnc_selectRandom;
								_roadPos = getPos _road;
								
								if (_roadPos distance (getMarkerPos "respawn_west") > 1000 && (_roadPos distance (getMarkerPos currentAO)) > 1000) then
								{
									_awayFromBase = true;
								};
							};
						
							_x = 0;
							for "_x" from 1 to _amount do 
							{
							[_roadPos,_spawnGroup] call SquadcarGmG; //--- squad type
							[_spawnGroup, getMarkerPos currentAO,250] call aw_fnc_Reinforce_perimeterPatrolBL1P; //--- patrol 
							};
						
							{
							  ReinforcementUnits set [count ReinforcementUnits, _x];
							  publicVariable "ReinforcementUnits";
							} forEach units _spawnGroup;
							
							if(DEBUG) then
							{
							diag_log format ["reinforcement count = %1",count ReinforcementUnits];
							};
							Reinforced = true;
							publicVariable "Reinforced";
							sleep 1;
						}else{ diag_log "DID NOT CREATE REINF FAILED ON RANDPOS";};
					};
					
					////////////////////////////////////
					//          VECH GROUPS       #4  //
					////////////////////////////////////
					
					if (_subType == "V1") then 
					{
						_randomPoscar = [getMarkerPos currentAO, PARAMS_AOSize+1000] call aw_fnc_randomPosbl1p;
						if ((count _randomPoscar) == 3) then 
						{
							//find a road if posible
							_roadList = _randomPoscar nearRoads 400;
							_awayFromBase = false;
							while {!_awayFromBase} do
							{
								_road = _roadList call BIS_fnc_selectRandom;
								_roadPos = getPos _road;
								
								if (_roadPos distance (getMarkerPos "respawn_west") > 1000 && (_roadPos distance (getMarkerPos currentAO)) > 1000) then
								{
									_awayFromBase = true;
								};
							};
						
							_x = 0;
							for "_x" from 1 to _amount do 
							{
							[_roadPos,_spawnGroup] call SquadcarGmG; //--- squad type
							[_spawnGroup, getMarkerPos currentAO,250] call aw_fnc_Reinforce_perimeterPatrolBL1P; //--- patrol 
							};
						
							{
							  ReinforcementUnits set [count ReinforcementUnits, _x];
							  publicVariable "ReinforcementUnits";
							} forEach units _spawnGroup;
							
							if(DEBUG) then
							{
							diag_log format ["reinforcement count = %1",count ReinforcementUnits];
							};
							Reinforced = true;
							publicVariable "Reinforced";
							sleep 1;
						}else{ diag_log "DID NOT CREATE REINF FAILED ON RANDPOS";};
					};
						
					if (_subType == "V2") then 
					{
						_randomPoscar = [getMarkerPos currentAO, PARAMS_AOSize+1000] call aw_fnc_randomPosbl1p;
						if ((count _randomPoscar) == 3) then 
						{
							//find a road if posible
							_roadList = _randomPoscar nearRoads 400;
							_awayFromBase = false;
							while {!_awayFromBase} do
							{
								_road = _roadList call BIS_fnc_selectRandom;
								_roadPos = getPos _road;
								
								if (_roadPos distance (getMarkerPos "respawn_west") > 1000 && (_roadPos distance (getMarkerPos currentAO)) > 1000) then
								{
									_awayFromBase = true;
								};
							};
						
							_x = 0;
							for "_x" from 1 to _amount do 
							{
							[_roadPos,_spawnGroup] call SquadcarGmG; //--- squad type
							[_spawnGroup, getMarkerPos currentAO,250] call aw_fnc_Reinforce_perimeterPatrolBL1P; //--- patrol 
							};
						
							{
							  ReinforcementUnits set [count ReinforcementUnits, _x];
							  publicVariable "ReinforcementUnits";
							} forEach units _spawnGroup;
							
							if(DEBUG) then
							{
							diag_log format ["reinforcement count = %1",count ReinforcementUnits];
							};
							Reinforced = true;
							publicVariable "Reinforced";
							sleep 1;
						}else{ diag_log "DID NOT CREATE REINF FAILED ON RANDPOS";};
					}; 
						
					if (_subType == "V3") then 
					{
						_randomPoscar = [getMarkerPos currentAO, PARAMS_AOSize+1000] call aw_fnc_randomPosbl1p;
						if ((count _randomPoscar) == 3) then 
						{
							//find a road if posible
							_roadList = _randomPoscar nearRoads 400;
							_awayFromBase = false;
							while {!_awayFromBase} do
							{
								_road = _roadList call BIS_fnc_selectRandom;
								_roadPos = getPos _road;
								
								if (_roadPos distance (getMarkerPos "respawn_west") > 1000 && (_roadPos distance (getMarkerPos currentAO)) > 1000) then
								{
									_awayFromBase = true;
								};
							};
						
							_x = 0;
							for "_x" from 1 to _amount do 
							{
							[_roadPos,_spawnGroup] call SquadcarGmG; //--- squad type
							[_spawnGroup, getMarkerPos currentAO,250] call aw_fnc_Reinforce_perimeterPatrolBL1P; //--- patrol 
							};
						
							{
							  ReinforcementUnits set [count ReinforcementUnits, _x];
							  publicVariable "ReinforcementUnits";
							} forEach units _spawnGroup;
							
							if(DEBUG) then
							{
							diag_log format ["reinforcement count = %1",count ReinforcementUnits];
							};
							Reinforced = true;
							publicVariable "Reinforced";
							sleep 1;
						}else{ diag_log "DID NOT CREATE REINF FAILED ON RANDPOS";};
					}; 
					
					diag_log format ["_reinforceTypes = %1 _subType = %2 _amount = %3",_reinforceTypes,_subType,_amount];
					

				if(DEBUG) then
				{
				diag_log format ["TOTAL reinforcement count = %1",count ReinforcementUnits];
				};
			} 
			else 
			{
				// Fluit: Check if reinforcements are all dead
				_reinforcementsdead = true;
				{
				  if (alive _x) then {
						_reinforcementsdead = false;
				  };
				} forEach ReinforcementUnits;

				// If all dead reset the reinforcement status
				if (_reinforcementsdead) then 
				{
						
						Reinforced = false;
						publicVariable "Reinforced";
						ReinforcementUnits = [];
						publicVariable "ReinforcementUnits";
						
						ReinforcementVehicles =[];
						publicVariable "ReinforcementVehicles";
						// reset spotters
						spotted = false;
						publicvariable "spotted";
				};
			};
		};
sleep 5;
};
