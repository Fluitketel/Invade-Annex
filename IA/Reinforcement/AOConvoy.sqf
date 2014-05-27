waitUntil {sleep 0.5; !(isNil "currentAOUp")};
waitUntil {sleep 0.5; !(isNil "currentAO")};
private ["_ConvoyCreatePos","_ConvoyMovetoPos","_ConvoyGroup","_fuzzyPos","_Convoydead","_ConRandAmount","_ConvoySafePos","_Convoy_Vehicle","_flatPos","_accepted","_debugCounter","_position","_nearUnits","_RandCreation","_randomInfantry","_SERVERUNITSCHECK","_randomChopper","_giveup","_SERVERUNITSCHECK1","_SERVERUNITSCHECKresistance"];

if (DEBUG) then {diag_log "===============Reading CONVOY reinforcements====================";};

ConvoyAlive = false;
publicVariable "ConvoyAlive";

ConvoyUnits = [];
ConvoyVehicles = [];
_SERVERUNITSCHECK = 0;
_giveup = false;

while {!_giveup} do 
{
	// sleep before running the random creation
	if(DEBUG) then
		{
		// lower for testing
			sleep (10 + (random 10));
		}
		else
		{
			sleep (1800 + (random 600));
		};
	_RandCreation = random 10;
	if(DEBUG && !ConvoyAlive) then
			{
				diag_log format ["_RandCreation for convoys = %1 PARAMS_ConvoyChance = %2  (%1 <= %2 ?)",_RandCreation,PARAMS_ConvoyChance];
			};
	if (radioTowerAlive && !ConvoyAlive) then
		{
			_SERVERUNITSCHECK1 = east countSide allunits;
			_SERVERUNITSCHECKresistance = resistance countSide allunits;
			_SERVERUNITSCHECK = (_SERVERUNITSCHECK1 + _SERVERUNITSCHECKresistance);
			
			sleep 1;
			if(DEBUG) then
						{
							diag_log format ["_SERVERUNITSCHECK for convoys = %1",_SERVERUNITSCHECK];
						};
		};		
		
    if (radioTowerAlive && (_SERVERUNITSCHECK < PARAMS_TOTALMAXAI) && (_RandCreation <= PARAMS_ConvoyChance)) then 
	{
        if (!ConvoyAlive) then 
		{
			
			if(DEBUG) then
				{
					diag_log format ["ConvoyAlive = %1",ConvoyAlive];
				};
							/// find flat pos not near base ///
							_flatPos = [0];
							_accepted = false;
							_debugCounter = 1;
								while {!_accepted} do
							{
								if (_debugCounter >= 50) exitWith 
								{
									_giveup = true;
									_flatPos = [];
									_debugCounter = 1;
									diag_log "Cant find a good convoy start position exit 1";
								};
								if (DEBUG) then { diag_log format["Finding flat position in convoy script.Attempt #%1",_debugCounter]; };

								//---bl1p change from 3000 to 10000 when not testing
								_position = [[[getMarkerPos currentAO,10000]],["water","out"]] call BIS_fnc_randomPos;
								_flatPos = _position isFlatEmpty [5, 0, 0.2, 5, 0, false];
								
								// bl1p edit (getMarkerPos currentAO)) > 1500 from 800
								
								if ((count _flatPos) == 3) then {
									if ((_flatPos distance (getMarkerPos "respawn_west")) > 3000 && (_flatPos distance (getMarkerPos currentAO)) > 8000) then 
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
					
					if (_giveup) exitWith 
								{
									diag_log "Cant find a good convoy start position exit 2";
								};
					
					_ConvoyCreatePos = _flatPos;
					_ConvoyMovetoPos = getMarkerPos currentAO;
					_ConvoyGroup = createGroup EAST;
							
					_x = 0;
					_ConRandAmount = [2,3] call BIS_fnc_selectRandom;
									if(DEBUG) then
										{
										diag_log format ["_ConRandAmount = %1",_ConRandAmount];
										};
							// create lead vehicle
							_ConvoySafePos = [_ConvoyCreatePos, 30,5] call aw_fnc_randomPosbl1p;
							_Convoy_Vehicle = [_ConvoySafePos,0,["O_MBT_02_cannon_F"] call BIS_fnc_selectRandom,_ConvoyGroup] call BIS_fnc_spawnVehicle;
							
							ConvoyVehicles set [count ConvoyVehicles, _Convoy_Vehicle select 0];
							
							(vehicle (leader _ConvoyGroup)) spawn aw_fnc_fuelMonitor;
							sleep 1;
							
							//create random amount and type vehs		
							for "_x" from 1 to _ConRandAmount do 
								{
									_ConvoySafePos = [_ConvoyCreatePos, 30,5] call aw_fnc_randomPosbl1p;
									_Convoy_Vehicle = [_ConvoySafePos,0,["O_APC_Wheeled_02_rcws_F","O_APC_Tracked_02_cannon_F","O_APC_Tracked_02_AA_F","O_Truck_03_repair_F"] call BIS_fnc_selectRandom,_ConvoyGroup] call BIS_fnc_spawnVehicle;
									ConvoyVehicles set [count ConvoyVehicles, _Convoy_Vehicle select 0];
									(vehicle (leader _ConvoyGroup)) spawn aw_fnc_fuelMonitor;
									sleep 1;
								};
								
								
								
							// create a chopper random chance
							//--- bl1p made it never spawn for now
							_randomChopper = random 10;
							if (_randomChopper > 10) then 
								{
									_ConvoySafePos = [_ConvoyCreatePos, 30,5] call aw_fnc_randomPosbl1p;
									_Convoy_Vehicle = [_ConvoySafePos,0,["O_Heli_Light_02_F"] call BIS_fnc_selectRandom,_ConvoyGroup] call BIS_fnc_spawnVehicle;
									ConvoyVehicles set [count ConvoyVehicles, _Convoy_Vehicle select 0];
									(vehicle (leader _ConvoyGroup)) spawn aw_fnc_fuelMonitor;
									
									// create infantry with chopper
									"O_Soldier_SL_F" createUnit [_ConvoySafePos, _ConvoyGroup];
									"O_Soldier_AA_F" createUnit [_ConvoySafePos, _ConvoyGroup];
									"O_Soldier_GL_F" createUnit [_ConvoySafePos, _ConvoyGroup];
									"O_Soldier_AR_F" createUnit [_ConvoySafePos, _ConvoyGroup];
									"O_Soldier_GL_F" createUnit [_ConvoySafePos, _ConvoyGroup];
									"O_Soldier_LAT_F" createUnit [_ConvoySafePos, _ConvoyGroup];
									"O_medic_F" createUnit [_ConvoySafePos, _ConvoyGroup];
									"O_Soldier_A_F" createUnit [_ConvoySafePos, _ConvoyGroup];
									
										if(DEBUG) then
											{
												diag_log "Created Helicopter for convoy";
											};
											sleep 1;
								};
								
										if(DEBUG) then
											{
											diag_log format ["_ConvoyGroup = %1",_ConvoyGroup];
											};
						
							[_ConvoyGroup, getMarkerPos currentAO,250] call aw_fnc_spawn2_perimeterPatrolBL1P;
						
									
		   //Set fuzzy marker
			_fuzzyPos =
			[
				((_ConvoyCreatePos select 0) - 300) + (random 600),
				((_ConvoyCreatePos select 1) - 300) + (random 600),
				0
			];
			
			_gridPos = mapGridPosition _fuzzyPos;
			_gridPos2 = mapGridPosition getmarkerpos "aoMarker";
			
			{ _x setMarkerPos _fuzzyPos; } forEach ["priorityMarker", "priorityCircle"];
			"priorityMarker" setMarkerText "Convoy Target: Start Area";
			publicVariable "priorityMarker";
			
			_convoytext = format ["Enemy Convoy Spotted Near %1 Heading to %2",_gridPos,_gridPos2];
			showNotification = ["NewSub",_convoytext]; publicVariable "showNotification";
			   
			   ConvoyAlive = true;
			   publicVariable "ConvoyAlive";
			   if(DEBUG) then
					{
					diag_log format ["All created ConvoyAlive = %1",ConvoyAlive];
					};
				
				{
				  ConvoyUnits set [count ConvoyUnits, _x];
				  publicVariable "ConvoyUnits";
				} forEach units _ConvoyGroup;
				
				publicVariable "ConvoyVehicles";
				
				 if(DEBUG) then
					{
					diag_log format ["Count Convoy Alive units = %1",count ConvoyUnits];
					};
        }
		else
		{
			////////////////////////////
			_Convoydead = true;
			//Check status of units
				{
				  if (alive _x) then 
				  {
					_Convoydead = false;
				  };
				} forEach ConvoyUnits;
			
			
			// If all dead reset the convoy status
			if ( _Convoydead) then 
				{
					showNotification = ["CompletedSub", "Enemy Convoy destroyed."]; publicVariable "showNotification";
					ConvoyAlive = false;
					publicVariable "ConvoyAlive";
					ConvoyUnits = [];
					publicVariable "ConvoyUnits";
					ConvoyVehicles = [];
					publicVariable "ConvoyVehicles";
					
					//Hide priorityMarker
					"priorityMarker" setMarkerPos [0,0,0];
					"priorityCircle" setMarkerPos [0,0,0];
					publicVariable "priorityMarker";
					[] spawn aw_cleanGroups;
					
				};
			////////////////////////////
			
		};
    };
    sleep 10;
};
